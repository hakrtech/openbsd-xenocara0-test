/*
 * Copyright © 2013 Intel Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the next
 * paragraph) shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

/**
 * \file brw_vec4_gs_visitor.cpp
 *
 * Geometry-shader-specific code derived from the vec4_visitor class.
 */

#include "brw_vec4_gs_visitor.h"
#include "gen6_gs_visitor.h"
#include "brw_fs.h"
#include "brw_nir.h"

namespace brw {

vec4_gs_visitor::vec4_gs_visitor(const struct brw_compiler *compiler,
                                 void *log_data,
                                 struct brw_gs_compile *c,
                                 struct brw_gs_prog_data *prog_data,
                                 const nir_shader *shader,
                                 void *mem_ctx,
                                 bool no_spills,
                                 int shader_time_index)
   : vec4_visitor(compiler, log_data, &c->key.tex,
                  &prog_data->base, shader,  mem_ctx,
                  no_spills, shader_time_index),
     c(c),
     gs_prog_data(prog_data)
{
}


dst_reg *
vec4_gs_visitor::make_reg_for_system_value(int location,
                                           const glsl_type *type)
{
   dst_reg *reg = new(mem_ctx) dst_reg(this, type);

   switch (location) {
   case SYSTEM_VALUE_INVOCATION_ID:
      this->current_annotation = "initialize gl_InvocationID";
      emit(GS_OPCODE_GET_INSTANCE_ID, *reg);
      break;
   default:
      unreachable("not reached");
   }

   return reg;
}


int
vec4_gs_visitor::setup_varying_inputs(int payload_reg, int *attribute_map,
                                      int attributes_per_reg)
{
   /* For geometry shaders there are N copies of the input attributes, where N
    * is the number of input vertices.  attribute_map[BRW_VARYING_SLOT_COUNT *
    * i + j] represents attribute j for vertex i.
    *
    * Note that GS inputs are read from the VUE 256 bits (2 vec4's) at a time,
    * so the total number of input slots that will be delivered to the GS (and
    * thus the stride of the input arrays) is urb_read_length * 2.
    */
   const unsigned num_input_vertices = nir->info.gs.vertices_in;
   assert(num_input_vertices <= MAX_GS_INPUT_VERTICES);
   unsigned input_array_stride = prog_data->urb_read_length * 2;

   for (int slot = 0; slot < c->input_vue_map.num_slots; slot++) {
      int varying = c->input_vue_map.slot_to_varying[slot];
      for (unsigned vertex = 0; vertex < num_input_vertices; vertex++) {
         attribute_map[BRW_VARYING_SLOT_COUNT * vertex + varying] =
            attributes_per_reg * payload_reg + input_array_stride * vertex +
            slot;
      }
   }

   int regs_used = ALIGN(input_array_stride * num_input_vertices,
                         attributes_per_reg) / attributes_per_reg;
   return payload_reg + regs_used;
}


void
vec4_gs_visitor::setup_payload()
{
   int attribute_map[BRW_VARYING_SLOT_COUNT * MAX_GS_INPUT_VERTICES];

   /* If we are in dual instanced or single mode, then attributes are going
    * to be interleaved, so one register contains two attribute slots.
    */
   int attributes_per_reg =
      prog_data->dispatch_mode == DISPATCH_MODE_4X2_DUAL_OBJECT ? 1 : 2;

   /* If a geometry shader tries to read from an input that wasn't written by
    * the vertex shader, that produces undefined results, but it shouldn't
    * crash anything.  So initialize attribute_map to zeros--that ensures that
    * these undefined results are read from r0.
    */
   memset(attribute_map, 0, sizeof(attribute_map));

   int reg = 0;

   /* The payload always contains important data in r0, which contains
    * the URB handles that are passed on to the URB write at the end
    * of the thread.
    */
   reg++;

   /* If the shader uses gl_PrimitiveIDIn, that goes in r1. */
   if (gs_prog_data->include_primitive_id)
      attribute_map[VARYING_SLOT_PRIMITIVE_ID] = attributes_per_reg * reg++;

   reg = setup_uniforms(reg);

   reg = setup_varying_inputs(reg, attribute_map, attributes_per_reg);

   lower_attributes_to_hw_regs(attribute_map, attributes_per_reg > 1);

   this->first_non_payload_grf = reg;
}


void
vec4_gs_visitor::emit_prolog()
{
   /* In vertex shaders, r0.2 is guaranteed to be initialized to zero.  In
    * geometry shaders, it isn't (it contains a bunch of information we don't
    * need, like the input primitive type).  We need r0.2 to be zero in order
    * to build scratch read/write messages correctly (otherwise this value
    * will be interpreted as a global offset, causing us to do our scratch
    * reads/writes to garbage memory).  So just set it to zero at the top of
    * the shader.
    */
   this->current_annotation = "clear r0.2";
   dst_reg r0(retype(brw_vec4_grf(0, 0), BRW_REGISTER_TYPE_UD));
   vec4_instruction *inst = emit(GS_OPCODE_SET_DWORD_2, r0, brw_imm_ud(0u));
   inst->force_writemask_all = true;

   /* Create a virtual register to hold the vertex count */
   this->vertex_count = src_reg(this, glsl_type::uint_type);

   /* Initialize the vertex_count register to 0 */
   this->current_annotation = "initialize vertex_count";
   inst = emit(MOV(dst_reg(this->vertex_count), brw_imm_ud(0u)));
   inst->force_writemask_all = true;

   if (c->control_data_header_size_bits > 0) {
      /* Create a virtual register to hold the current set of control data
       * bits.
       */
      this->control_data_bits = src_reg(this, glsl_type::uint_type);

      /* If we're outputting more than 32 control data bits, then EmitVertex()
       * will set control_data_bits to 0 after emitting the first vertex.
       * Otherwise, we need to initialize it to 0 here.
       */
      if (c->control_data_header_size_bits <= 32) {
         this->current_annotation = "initialize control data bits";
         inst = emit(MOV(dst_reg(this->control_data_bits), brw_imm_ud(0u)));
         inst->force_writemask_all = true;
      }
   }

   this->current_annotation = NULL;
}

void
vec4_gs_visitor::emit_thread_end()
{
   if (c->control_data_header_size_bits > 0) {
      /* During shader execution, we only ever call emit_control_data_bits()
       * just prior to outputting a vertex.  Therefore, the control data bits
       * corresponding to the most recently output vertex still need to be
       * emitted.
       */
      current_annotation = "thread end: emit control data bits";
      emit_control_data_bits();
   }

   /* MRF 0 is reserved for the debugger, so start with message header
    * in MRF 1.
    */
   int base_mrf = 1;

   bool static_vertex_count = gs_prog_data->static_vertex_count != -1;

   /* If the previous instruction was a URB write, we don't need to issue
    * a second one - we can just set the EOT bit on the previous write.
    *
    * Skip this on Gen8+ unless there's a static vertex count, as we also
    * need to write the vertex count out, and combining the two may not be
    * possible (or at least not straightforward).
    */
   vec4_instruction *last = (vec4_instruction *) instructions.get_tail();
   if (last && last->opcode == GS_OPCODE_URB_WRITE &&
       !(INTEL_DEBUG & DEBUG_SHADER_TIME) &&
       devinfo->gen >= 8 && static_vertex_count) {
      last->urb_write_flags = BRW_URB_WRITE_EOT | last->urb_write_flags;
      return;
   }

   current_annotation = "thread end";
   dst_reg mrf_reg(MRF, base_mrf);
   src_reg r0(retype(brw_vec8_grf(0, 0), BRW_REGISTER_TYPE_UD));
   vec4_instruction *inst = emit(MOV(mrf_reg, r0));
   inst->force_writemask_all = true;
   if (devinfo->gen < 8 || !static_vertex_count)
      emit(GS_OPCODE_SET_VERTEX_COUNT, mrf_reg, this->vertex_count);
   if (INTEL_DEBUG & DEBUG_SHADER_TIME)
      emit_shader_time_end();
   inst = emit(GS_OPCODE_THREAD_END);
   inst->base_mrf = base_mrf;
   inst->mlen = devinfo->gen >= 8 && !static_vertex_count ? 2 : 1;
}


void
vec4_gs_visitor::emit_urb_write_header(int mrf)
{
   /* The SEND instruction that writes the vertex data to the VUE will use
    * per_slot_offset=true, which means that DWORDs 3 and 4 of the message
    * header specify an offset (in multiples of 256 bits) into the URB entry
    * at which the write should take place.
    *
    * So we have to prepare a message header with the appropriate offset
    * values.
    */
   dst_reg mrf_reg(MRF, mrf);
   src_reg r0(retype(brw_vec8_grf(0, 0), BRW_REGISTER_TYPE_UD));
   this->current_annotation = "URB write header";
   vec4_instruction *inst = emit(MOV(mrf_reg, r0));
   inst->force_writemask_all = true;
   emit(GS_OPCODE_SET_WRITE_OFFSET, mrf_reg, this->vertex_count,
        brw_imm_ud(gs_prog_data->output_vertex_size_hwords));
}


vec4_instruction *
vec4_gs_visitor::emit_urb_write_opcode(bool complete)
{
   /* We don't care whether the vertex is complete, because in general
    * geometry shaders output multiple vertices, and we don't terminate the
    * thread until all vertices are complete.
    */
   (void) complete;

   vec4_instruction *inst = emit(GS_OPCODE_URB_WRITE);
   inst->offset = gs_prog_data->control_data_header_size_hwords;

   /* We need to increment Global Offset by 1 to make room for Broadwell's
    * extra "Vertex Count" payload at the beginning of the URB entry.
    */
   if (devinfo->gen >= 8 && gs_prog_data->static_vertex_count == -1)
      inst->offset++;

   inst->urb_write_flags = BRW_URB_WRITE_PER_SLOT_OFFSET;
   return inst;
}


/**
 * Write out a batch of 32 control data bits from the control_data_bits
 * register to the URB.
 *
 * The current value of the vertex_count register determines which DWORD in
 * the URB receives the control data bits.  The control_data_bits register is
 * assumed to contain the correct data for the vertex that was most recently
 * output, and all previous vertices that share the same DWORD.
 *
 * This function takes care of ensuring that if no vertices have been output
 * yet, no control bits are emitted.
 */
void
vec4_gs_visitor::emit_control_data_bits()
{
   assert(c->control_data_bits_per_vertex != 0);

   /* Since the URB_WRITE_OWORD message operates with 128-bit (vec4 sized)
    * granularity, we need to use two tricks to ensure that the batch of 32
    * control data bits is written to the appropriate DWORD in the URB.  To
    * select which vec4 we are writing to, we use the "slot {0,1} offset"
    * fields of the message header.  To select which DWORD in the vec4 we are
    * writing to, we use the channel mask fields of the message header.  To
    * avoid penalizing geometry shaders that emit a small number of vertices
    * with extra bookkeeping, we only do each of these tricks when
    * c->prog_data.control_data_header_size_bits is large enough to make it
    * necessary.
    *
    * Note: this means that if we're outputting just a single DWORD of control
    * data bits, we'll actually replicate it four times since we won't do any
    * channel masking.  But that's not a problem since in this case the
    * hardware only pays attention to the first DWORD.
    */
   enum brw_urb_write_flags urb_write_flags = BRW_URB_WRITE_OWORD;
   if (c->control_data_header_size_bits > 32)
      urb_write_flags = urb_write_flags | BRW_URB_WRITE_USE_CHANNEL_MASKS;
   if (c->control_data_header_size_bits > 128)
      urb_write_flags = urb_write_flags | BRW_URB_WRITE_PER_SLOT_OFFSET;

   /* If we are using either channel masks or a per-slot offset, then we
    * need to figure out which DWORD we are trying to write to, using the
    * formula:
    *
    *     dword_index = (vertex_count - 1) * bits_per_vertex / 32
    *
    * Since bits_per_vertex is a power of two, and is known at compile
    * time, this can be optimized to:
    *
    *     dword_index = (vertex_count - 1) >> (6 - log2(bits_per_vertex))
    */
   src_reg dword_index(this, glsl_type::uint_type);
   if (urb_write_flags) {
      src_reg prev_count(this, glsl_type::uint_type);
      emit(ADD(dst_reg(prev_count), this->vertex_count,
               brw_imm_ud(0xffffffffu)));
      unsigned log2_bits_per_vertex =
         _mesa_fls(c->control_data_bits_per_vertex);
      emit(SHR(dst_reg(dword_index), prev_count,
               brw_imm_ud(6 - log2_bits_per_vertex)));
   }

   /* Start building the URB write message.  The first MRF gets a copy of
    * R0.
    */
   int base_mrf = 1;
   dst_reg mrf_reg(MRF, base_mrf);
   src_reg r0(retype(brw_vec8_grf(0, 0), BRW_REGISTER_TYPE_UD));
   vec4_instruction *inst = emit(MOV(mrf_reg, r0));
   inst->force_writemask_all = true;

   if (urb_write_flags & BRW_URB_WRITE_PER_SLOT_OFFSET) {
      /* Set the per-slot offset to dword_index / 4, to that we'll write to
       * the appropriate OWORD within the control data header.
       */
      src_reg per_slot_offset(this, glsl_type::uint_type);
      emit(SHR(dst_reg(per_slot_offset), dword_index, brw_imm_ud(2u)));
      emit(GS_OPCODE_SET_WRITE_OFFSET, mrf_reg, per_slot_offset,
           brw_imm_ud(1u));
   }

   if (urb_write_flags & BRW_URB_WRITE_USE_CHANNEL_MASKS) {
      /* Set the channel masks to 1 << (dword_index % 4), so that we'll
       * write to the appropriate DWORD within the OWORD.  We need to do
       * this computation with force_writemask_all, otherwise garbage data
       * from invocation 0 might clobber the mask for invocation 1 when
       * GS_OPCODE_PREPARE_CHANNEL_MASKS tries to OR the two masks
       * together.
       */
      src_reg channel(this, glsl_type::uint_type);
      inst = emit(AND(dst_reg(channel), dword_index, brw_imm_ud(3u)));
      inst->force_writemask_all = true;
      src_reg one(this, glsl_type::uint_type);
      inst = emit(MOV(dst_reg(one), brw_imm_ud(1u)));
      inst->force_writemask_all = true;
      src_reg channel_mask(this, glsl_type::uint_type);
      inst = emit(SHL(dst_reg(channel_mask), one, channel));
      inst->force_writemask_all = true;
      emit(GS_OPCODE_PREPARE_CHANNEL_MASKS, dst_reg(channel_mask),
                                            channel_mask);
      emit(GS_OPCODE_SET_CHANNEL_MASKS, mrf_reg, channel_mask);
   }

   /* Store the control data bits in the message payload and send it. */
   dst_reg mrf_reg2(MRF, base_mrf + 1);
   inst = emit(MOV(mrf_reg2, this->control_data_bits));
   inst->force_writemask_all = true;
   inst = emit(GS_OPCODE_URB_WRITE);
   inst->urb_write_flags = urb_write_flags;
   /* We need to increment Global Offset by 256-bits to make room for
    * Broadwell's extra "Vertex Count" payload at the beginning of the
    * URB entry.  Since this is an OWord message, Global Offset is counted
    * in 128-bit units, so we must set it to 2.
    */
   if (devinfo->gen >= 8 && gs_prog_data->static_vertex_count == -1)
      inst->offset = 2;
   inst->base_mrf = base_mrf;
   inst->mlen = 2;
}

void
vec4_gs_visitor::set_stream_control_data_bits(unsigned stream_id)
{
   /* control_data_bits |= stream_id << ((2 * (vertex_count - 1)) % 32) */

   /* Note: we are calling this *before* increasing vertex_count, so
    * this->vertex_count == vertex_count - 1 in the formula above.
    */

   /* Stream mode uses 2 bits per vertex */
   assert(c->control_data_bits_per_vertex == 2);

   /* Must be a valid stream */
   assert(stream_id >= 0 && stream_id < MAX_VERTEX_STREAMS);

   /* Control data bits are initialized to 0 so we don't have to set any
    * bits when sending vertices to stream 0.
    */
   if (stream_id == 0)
      return;

   /* reg::sid = stream_id */
   src_reg sid(this, glsl_type::uint_type);
   emit(MOV(dst_reg(sid), brw_imm_ud(stream_id)));

   /* reg:shift_count = 2 * (vertex_count - 1) */
   src_reg shift_count(this, glsl_type::uint_type);
   emit(SHL(dst_reg(shift_count), this->vertex_count, brw_imm_ud(1u)));

   /* Note: we're relying on the fact that the GEN SHL instruction only pays
    * attention to the lower 5 bits of its second source argument, so on this
    * architecture, stream_id << 2 * (vertex_count - 1) is equivalent to
    * stream_id << ((2 * (vertex_count - 1)) % 32).
    */
   src_reg mask(this, glsl_type::uint_type);
   emit(SHL(dst_reg(mask), sid, shift_count));
   emit(OR(dst_reg(this->control_data_bits), this->control_data_bits, mask));
}

void
vec4_gs_visitor::gs_emit_vertex(int stream_id)
{
   this->current_annotation = "emit vertex: safety check";

   /* Haswell and later hardware ignores the "Render Stream Select" bits
    * from the 3DSTATE_STREAMOUT packet when the SOL stage is disabled,
    * and instead sends all primitives down the pipeline for rasterization.
    * If the SOL stage is enabled, "Render Stream Select" is honored and
    * primitives bound to non-zero streams are discarded after stream output.
    *
    * Since the only purpose of primives sent to non-zero streams is to
    * be recorded by transform feedback, we can simply discard all geometry
    * bound to these streams when transform feedback is disabled.
    */
   if (stream_id > 0 && !nir->info.has_transform_feedback_varyings)
      return;

   /* If we're outputting 32 control data bits or less, then we can wait
    * until the shader is over to output them all.  Otherwise we need to
    * output them as we go.  Now is the time to do it, since we're about to
    * output the vertex_count'th vertex, so it's guaranteed that the
    * control data bits associated with the (vertex_count - 1)th vertex are
    * correct.
    */
   if (c->control_data_header_size_bits > 32) {
      this->current_annotation = "emit vertex: emit control data bits";
      /* Only emit control data bits if we've finished accumulating a batch
       * of 32 bits.  This is the case when:
       *
       *     (vertex_count * bits_per_vertex) % 32 == 0
       *
       * (in other words, when the last 5 bits of vertex_count *
       * bits_per_vertex are 0).  Assuming bits_per_vertex == 2^n for some
       * integer n (which is always the case, since bits_per_vertex is
       * always 1 or 2), this is equivalent to requiring that the last 5-n
       * bits of vertex_count are 0:
       *
       *     vertex_count & (2^(5-n) - 1) == 0
       *
       * 2^(5-n) == 2^5 / 2^n == 32 / bits_per_vertex, so this is
       * equivalent to:
       *
       *     vertex_count & (32 / bits_per_vertex - 1) == 0
       */
      vec4_instruction *inst =
         emit(AND(dst_null_ud(), this->vertex_count,
                  brw_imm_ud(32 / c->control_data_bits_per_vertex - 1)));
      inst->conditional_mod = BRW_CONDITIONAL_Z;

      emit(IF(BRW_PREDICATE_NORMAL));
      {
         /* If vertex_count is 0, then no control data bits have been
          * accumulated yet, so we skip emitting them.
          */
         emit(CMP(dst_null_ud(), this->vertex_count, brw_imm_ud(0u),
                  BRW_CONDITIONAL_NEQ));
         emit(IF(BRW_PREDICATE_NORMAL));
         emit_control_data_bits();
         emit(BRW_OPCODE_ENDIF);

         /* Reset control_data_bits to 0 so we can start accumulating a new
          * batch.
          *
          * Note: in the case where vertex_count == 0, this neutralizes the
          * effect of any call to EndPrimitive() that the shader may have
          * made before outputting its first vertex.
          */
         inst = emit(MOV(dst_reg(this->control_data_bits), brw_imm_ud(0u)));
         inst->force_writemask_all = true;
      }
      emit(BRW_OPCODE_ENDIF);
   }

   this->current_annotation = "emit vertex: vertex data";
   emit_vertex();

   /* In stream mode we have to set control data bits for all vertices
    * unless we have disabled control data bits completely (which we do
    * do for GL_POINTS outputs that don't use streams).
    */
   if (c->control_data_header_size_bits > 0 &&
       gs_prog_data->control_data_format ==
          GEN7_GS_CONTROL_DATA_FORMAT_GSCTL_SID) {
       this->current_annotation = "emit vertex: Stream control data bits";
       set_stream_control_data_bits(stream_id);
   }

   this->current_annotation = NULL;
}

void
vec4_gs_visitor::gs_end_primitive()
{
   /* We can only do EndPrimitive() functionality when the control data
    * consists of cut bits.  Fortunately, the only time it isn't is when the
    * output type is points, in which case EndPrimitive() is a no-op.
    */
   if (gs_prog_data->control_data_format !=
       GEN7_GS_CONTROL_DATA_FORMAT_GSCTL_CUT) {
      return;
   }

   /* Cut bits use one bit per vertex. */
   assert(c->control_data_bits_per_vertex == 1);

   /* Cut bit n should be set to 1 if EndPrimitive() was called after emitting
    * vertex n, 0 otherwise.  So all we need to do here is mark bit
    * (vertex_count - 1) % 32 in the cut_bits register to indicate that
    * EndPrimitive() was called after emitting vertex (vertex_count - 1);
    * vec4_gs_visitor::emit_control_data_bits() will take care of the rest.
    *
    * Note that if EndPrimitve() is called before emitting any vertices, this
    * will cause us to set bit 31 of the control_data_bits register to 1.
    * That's fine because:
    *
    * - If max_vertices < 32, then vertex number 31 (zero-based) will never be
    *   output, so the hardware will ignore cut bit 31.
    *
    * - If max_vertices == 32, then vertex number 31 is guaranteed to be the
    *   last vertex, so setting cut bit 31 has no effect (since the primitive
    *   is automatically ended when the GS terminates).
    *
    * - If max_vertices > 32, then the ir_emit_vertex visitor will reset the
    *   control_data_bits register to 0 when the first vertex is emitted.
    */

   /* control_data_bits |= 1 << ((vertex_count - 1) % 32) */
   src_reg one(this, glsl_type::uint_type);
   emit(MOV(dst_reg(one), brw_imm_ud(1u)));
   src_reg prev_count(this, glsl_type::uint_type);
   emit(ADD(dst_reg(prev_count), this->vertex_count, brw_imm_ud(0xffffffffu)));
   src_reg mask(this, glsl_type::uint_type);
   /* Note: we're relying on the fact that the GEN SHL instruction only pays
    * attention to the lower 5 bits of its second source argument, so on this
    * architecture, 1 << (vertex_count - 1) is equivalent to 1 <<
    * ((vertex_count - 1) % 32).
    */
   emit(SHL(dst_reg(mask), one, prev_count));
   emit(OR(dst_reg(this->control_data_bits), this->control_data_bits, mask));
}

extern "C" const unsigned *
brw_compile_gs(const struct brw_compiler *compiler, void *log_data,
               void *mem_ctx,
               const struct brw_gs_prog_key *key,
               struct brw_gs_prog_data *prog_data,
               const nir_shader *src_shader,
               struct gl_shader_program *shader_prog,
               int shader_time_index,
               unsigned *final_assembly_size,
               char **error_str)
{
   struct brw_gs_compile c;
   memset(&c, 0, sizeof(c));
   c.key = *key;

   nir_shader *shader = nir_shader_clone(mem_ctx, src_shader);
   shader = brw_nir_apply_sampler_key(shader, compiler->devinfo, &key->tex,
                                      compiler->scalar_stage[MESA_SHADER_GEOMETRY]);
   shader = brw_postprocess_nir(shader, compiler->devinfo,
                                compiler->scalar_stage[MESA_SHADER_GEOMETRY]);

   prog_data->include_primitive_id =
      (shader->info.inputs_read & VARYING_BIT_PRIMITIVE_ID) != 0;

   prog_data->invocations = shader->info.gs.invocations;

   if (compiler->devinfo->gen >= 8)
      prog_data->static_vertex_count = nir_gs_count_vertices(shader);

   if (compiler->devinfo->gen >= 7) {
      if (shader->info.gs.output_primitive == GL_POINTS) {
         /* When the output type is points, the geometry shader may output data
          * to multiple streams, and EndPrimitive() has no effect.  So we
          * configure the hardware to interpret the control data as stream ID.
          */
         prog_data->control_data_format = GEN7_GS_CONTROL_DATA_FORMAT_GSCTL_SID;

         /* We only have to emit control bits if we are using streams */
         if (shader_prog && shader_prog->Geom.UsesStreams)
            c.control_data_bits_per_vertex = 2;
         else
            c.control_data_bits_per_vertex = 0;
      } else {
         /* When the output type is triangle_strip or line_strip, EndPrimitive()
          * may be used to terminate the current strip and start a new one
          * (similar to primitive restart), and outputting data to multiple
          * streams is not supported.  So we configure the hardware to interpret
          * the control data as EndPrimitive information (a.k.a. "cut bits").
          */
         prog_data->control_data_format = GEN7_GS_CONTROL_DATA_FORMAT_GSCTL_CUT;

         /* We only need to output control data if the shader actually calls
          * EndPrimitive().
          */
         c.control_data_bits_per_vertex =
            shader->info.gs.uses_end_primitive ? 1 : 0;
      }
   } else {
      /* There are no control data bits in gen6. */
      c.control_data_bits_per_vertex = 0;

      /* If it is using transform feedback, enable it */
      if (shader->info.has_transform_feedback_varyings)
         prog_data->gen6_xfb_enabled = true;
      else
         prog_data->gen6_xfb_enabled = false;
   }
   c.control_data_header_size_bits =
      shader->info.gs.vertices_out * c.control_data_bits_per_vertex;

   /* 1 HWORD = 32 bytes = 256 bits */
   prog_data->control_data_header_size_hwords =
      ALIGN(c.control_data_header_size_bits, 256) / 256;

   /* Compute the output vertex size.
    *
    * From the Ivy Bridge PRM, Vol2 Part1 7.2.1.1 STATE_GS - Output Vertex
    * Size (p168):
    *
    *     [0,62] indicating [1,63] 16B units
    *
    *     Specifies the size of each vertex stored in the GS output entry
    *     (following any Control Header data) as a number of 128-bit units
    *     (minus one).
    *
    *     Programming Restrictions: The vertex size must be programmed as a
    *     multiple of 32B units with the following exception: Rendering is
    *     disabled (as per SOL stage state) and the vertex size output by the
    *     GS thread is 16B.
    *
    *     If rendering is enabled (as per SOL state) the vertex size must be
    *     programmed as a multiple of 32B units. In other words, the only time
    *     software can program a vertex size with an odd number of 16B units
    *     is when rendering is disabled.
    *
    * Note: B=bytes in the above text.
    *
    * It doesn't seem worth the extra trouble to optimize the case where the
    * vertex size is 16B (especially since this would require special-casing
    * the GEN assembly that writes to the URB).  So we just set the vertex
    * size to a multiple of 32B (2 vec4's) in all cases.
    *
    * The maximum output vertex size is 62*16 = 992 bytes (31 hwords).  We
    * budget that as follows:
    *
    *   512 bytes for varyings (a varying component is 4 bytes and
    *             gl_MaxGeometryOutputComponents = 128)
    *    16 bytes overhead for VARYING_SLOT_PSIZ (each varying slot is 16
    *             bytes)
    *    16 bytes overhead for gl_Position (we allocate it a slot in the VUE
    *             even if it's not used)
    *    32 bytes overhead for gl_ClipDistance (we allocate it 2 VUE slots
    *             whenever clip planes are enabled, even if the shader doesn't
    *             write to gl_ClipDistance)
    *    16 bytes overhead since the VUE size must be a multiple of 32 bytes
    *             (see below)--this causes up to 1 VUE slot to be wasted
    *   400 bytes available for varying packing overhead
    *
    * Worst-case varying packing overhead is 3/4 of a varying slot (12 bytes)
    * per interpolation type, so this is plenty.
    *
    */
   unsigned output_vertex_size_bytes = prog_data->base.vue_map.num_slots * 16;
   assert(compiler->devinfo->gen == 6 ||
          output_vertex_size_bytes <= GEN7_MAX_GS_OUTPUT_VERTEX_SIZE_BYTES);
   prog_data->output_vertex_size_hwords =
      ALIGN(output_vertex_size_bytes, 32) / 32;

   /* Compute URB entry size.  The maximum allowed URB entry size is 32k.
    * That divides up as follows:
    *
    *     64 bytes for the control data header (cut indices or StreamID bits)
    *   4096 bytes for varyings (a varying component is 4 bytes and
    *              gl_MaxGeometryTotalOutputComponents = 1024)
    *   4096 bytes overhead for VARYING_SLOT_PSIZ (each varying slot is 16
    *              bytes/vertex and gl_MaxGeometryOutputVertices is 256)
    *   4096 bytes overhead for gl_Position (we allocate it a slot in the VUE
    *              even if it's not used)
    *   8192 bytes overhead for gl_ClipDistance (we allocate it 2 VUE slots
    *              whenever clip planes are enabled, even if the shader doesn't
    *              write to gl_ClipDistance)
    *   4096 bytes overhead since the VUE size must be a multiple of 32
    *              bytes (see above)--this causes up to 1 VUE slot to be wasted
    *   8128 bytes available for varying packing overhead
    *
    * Worst-case varying packing overhead is 3/4 of a varying slot per
    * interpolation type, which works out to 3072 bytes, so this would allow
    * us to accommodate 2 interpolation types without any danger of running
    * out of URB space.
    *
    * In practice, the risk of running out of URB space is very small, since
    * the above figures are all worst-case, and most of them scale with the
    * number of output vertices.  So we'll just calculate the amount of space
    * we need, and if it's too large, fail to compile.
    *
    * The above is for gen7+ where we have a single URB entry that will hold
    * all the output. In gen6, we will have to allocate URB entries for every
    * vertex we emit, so our URB entries only need to be large enough to hold
    * a single vertex. Also, gen6 does not have a control data header.
    */
   unsigned output_size_bytes;
   if (compiler->devinfo->gen >= 7) {
      output_size_bytes =
         prog_data->output_vertex_size_hwords * 32 * shader->info.gs.vertices_out;
      output_size_bytes += 32 * prog_data->control_data_header_size_hwords;
   } else {
      output_size_bytes = prog_data->output_vertex_size_hwords * 32;
   }

   /* Broadwell stores "Vertex Count" as a full 8 DWord (32 byte) URB output,
    * which comes before the control header.
    */
   if (compiler->devinfo->gen >= 8)
      output_size_bytes += 32;

   assert(output_size_bytes >= 1);
   unsigned max_output_size_bytes = GEN7_MAX_GS_URB_ENTRY_SIZE_BYTES;
   if (compiler->devinfo->gen == 6)
      max_output_size_bytes = GEN6_MAX_GS_URB_ENTRY_SIZE_BYTES;
   if (output_size_bytes > max_output_size_bytes)
      return NULL;


   /* URB entry sizes are stored as a multiple of 64 bytes in gen7+ and
    * a multiple of 128 bytes in gen6.
    */
   if (compiler->devinfo->gen >= 7)
      prog_data->base.urb_entry_size = ALIGN(output_size_bytes, 64) / 64;
   else
      prog_data->base.urb_entry_size = ALIGN(output_size_bytes, 128) / 128;

   prog_data->output_topology =
      get_hw_prim_for_gl_prim(shader->info.gs.output_primitive);

   prog_data->vertices_in = shader->info.gs.vertices_in;

   /* The GLSL linker will have already matched up GS inputs and the outputs
    * of prior stages.  The driver does extend VS outputs in some cases, but
    * only for legacy OpenGL or Gen4-5 hardware, neither of which offer
    * geometry shader support.  So we can safely ignore that.
    *
    * For SSO pipelines, we use a fixed VUE map layout based on variable
    * locations, so we can rely on rendezvous-by-location making this work.
    *
    * However, we need to ignore VARYING_SLOT_PRIMITIVE_ID, as it's not
    * written by previous stages and shows up via payload magic.
    */
   GLbitfield64 inputs_read =
      shader->info.inputs_read & ~VARYING_BIT_PRIMITIVE_ID;
   brw_compute_vue_map(compiler->devinfo,
                       &c.input_vue_map, inputs_read,
                       shader->info.separate_shader);

   /* GS inputs are read from the VUE 256 bits (2 vec4's) at a time, so we
    * need to program a URB read length of ceiling(num_slots / 2).
    */
   prog_data->base.urb_read_length = (c.input_vue_map.num_slots + 1) / 2;

   /* Now that prog_data setup is done, we are ready to actually compile the
    * program.
    */
   if (unlikely(INTEL_DEBUG & DEBUG_GS)) {
      fprintf(stderr, "GS Input ");
      brw_print_vue_map(stderr, &c.input_vue_map);
      fprintf(stderr, "GS Output ");
      brw_print_vue_map(stderr, &prog_data->base.vue_map);
   }

   if (compiler->scalar_stage[MESA_SHADER_GEOMETRY]) {
      /* TODO: Support instanced GS.  We have basically no tests... */
      assert(prog_data->invocations == 1);

      fs_visitor v(compiler, log_data, mem_ctx, &c, prog_data, shader,
                   shader_time_index);
      if (v.run_gs()) {
         prog_data->base.dispatch_mode = DISPATCH_MODE_SIMD8;

         fs_generator g(compiler, log_data, mem_ctx, &c.key,
                        &prog_data->base.base, v.promoted_constants,
                        false, MESA_SHADER_GEOMETRY);
         if (unlikely(INTEL_DEBUG & DEBUG_GS)) {
            const char *label =
               shader->info.label ? shader->info.label : "unnamed";
            char *name = ralloc_asprintf(mem_ctx, "%s geometry shader %s",
                                         label, shader->info.name);
            g.enable_debug(name);
         }
         g.generate_code(v.cfg, 8);
         return g.get_assembly(final_assembly_size);
      }
   }

   if (compiler->devinfo->gen >= 7) {
      /* Compile the geometry shader in DUAL_OBJECT dispatch mode, if we can do
       * so without spilling. If the GS invocations count > 1, then we can't use
       * dual object mode.
       */
      if (prog_data->invocations <= 1 &&
          likely(!(INTEL_DEBUG & DEBUG_NO_DUAL_OBJECT_GS))) {
         prog_data->base.dispatch_mode = DISPATCH_MODE_4X2_DUAL_OBJECT;

         vec4_gs_visitor v(compiler, log_data, &c, prog_data, shader,
                           mem_ctx, true /* no_spills */, shader_time_index);
         if (v.run()) {
            return brw_vec4_generate_assembly(compiler, log_data, mem_ctx,
                                              shader, &prog_data->base, v.cfg,
                                              final_assembly_size);
         }
      }
   }

   /* Either we failed to compile in DUAL_OBJECT mode (probably because it
    * would have required spilling) or DUAL_OBJECT mode is disabled.  So fall
    * back to DUAL_INSTANCED or SINGLE mode, which consumes fewer registers.
    *
    * FIXME: Single dispatch mode requires that the driver can handle
    * interleaving of input registers, but this is already supported (dual
    * instance mode has the same requirement). However, to take full advantage
    * of single dispatch mode to reduce register pressure we would also need to
    * do interleaved outputs, but currently, the vec4 visitor and generator
    * classes do not support this, so at the moment register pressure in
    * single and dual instance modes is the same.
    *
    * From the Ivy Bridge PRM, Vol2 Part1 7.2.1.1 "3DSTATE_GS"
    * "If InstanceCount>1, DUAL_OBJECT mode is invalid. Software will likely
    * want to use DUAL_INSTANCE mode for higher performance, but SINGLE mode
    * is also supported. When InstanceCount=1 (one instance per object) software
    * can decide which dispatch mode to use. DUAL_OBJECT mode would likely be
    * the best choice for performance, followed by SINGLE mode."
    *
    * So SINGLE mode is more performant when invocations == 1 and DUAL_INSTANCE
    * mode is more performant when invocations > 1. Gen6 only supports
    * SINGLE mode.
    */
   if (prog_data->invocations <= 1 || compiler->devinfo->gen < 7)
      prog_data->base.dispatch_mode = DISPATCH_MODE_4X1_SINGLE;
   else
      prog_data->base.dispatch_mode = DISPATCH_MODE_4X2_DUAL_INSTANCE;

   vec4_gs_visitor *gs = NULL;
   const unsigned *ret = NULL;

   if (compiler->devinfo->gen >= 7)
      gs = new vec4_gs_visitor(compiler, log_data, &c, prog_data,
                               shader, mem_ctx, false /* no_spills */,
                               shader_time_index);
   else
      gs = new gen6_gs_visitor(compiler, log_data, &c, prog_data, shader_prog,
                               shader, mem_ctx, false /* no_spills */,
                               shader_time_index);

   if (!gs->run()) {
      if (error_str)
         *error_str = ralloc_strdup(mem_ctx, gs->fail_msg);
   } else {
      ret = brw_vec4_generate_assembly(compiler, log_data, mem_ctx, shader,
                                       &prog_data->base, gs->cfg,
                                       final_assembly_size);
   }

   delete gs;
   return ret;
}


} /* namespace brw */
