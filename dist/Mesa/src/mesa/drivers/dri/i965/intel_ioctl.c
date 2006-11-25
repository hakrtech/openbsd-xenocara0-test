/**************************************************************************
 * 
 * Copyright 2003 Tungsten Graphics, Inc., Cedar Park, Texas.
 * All Rights Reserved.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sub license, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice (including the
 * next paragraph) shall be included in all copies or substantial portions
 * of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT.
 * IN NO EVENT SHALL TUNGSTEN GRAPHICS AND/OR ITS SUPPLIERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 **************************************************************************/


#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <sched.h>

#include "mtypes.h"
#include "context.h"
#include "swrast/swrast.h"

#include "intel_context.h"
#include "intel_ioctl.h"
#include "intel_batchbuffer.h"
#include "intel_blit.h"
#include "intel_regions.h"
#include "drm.h"
#include "bufmgr.h"


int intelEmitIrqLocked( struct intel_context *intel )
{
   int seq = 1;

   if (!intel->no_hw) {
      drmI830IrqEmit ie;
      int ret;
      
      assert(((*(int *)intel->driHwLock) & ~DRM_LOCK_CONT) == 
	     (DRM_LOCK_HELD|intel->hHWContext));

      ie.irq_seq = &seq;

      ret = drmCommandWriteRead( intel->driFd, DRM_I830_IRQ_EMIT, 
				 &ie, sizeof(ie) );
      if ( ret ) {
	 fprintf( stderr, "%s: drmI830IrqEmit: %d\n", __FUNCTION__, ret );
	 exit(1);
      }   

      if (0)
	 fprintf(stderr, "%s -->  %d\n", __FUNCTION__, seq );
   }

   return seq;
}

void intelWaitIrq( struct intel_context *intel, int seq )
{
   if (!intel->no_hw) {
      drmI830IrqWait iw;
      int ret;
      
      if (0)
	 fprintf(stderr, "%s %d\n", __FUNCTION__, seq );

      iw.irq_seq = seq;
	
      do {
	 ret = drmCommandWrite( intel->driFd, DRM_I830_IRQ_WAIT, &iw, sizeof(iw) );

	 /* This seems quite often to return before it should!?! 
	  */
      } while (ret == -EAGAIN || ret == -EINTR || (ret == 0 && seq > intel->sarea->last_dispatch));
      

      if ( ret ) {
	 fprintf( stderr, "%s: drmI830IrqWait: %d\n", __FUNCTION__, ret );

	 if (intel->aub_file) {
	    intel->vtbl.aub_dump_bmp( intel, intel->ctx.Visual.doubleBufferMode ? 1 : 0 );
	 }

	 exit(1);
      }
   }
}


void intel_batch_ioctl( struct intel_context *intel, 
			GLuint start_offset,
			GLuint used,
			GLboolean ignore_cliprects)
{
   drmI830BatchBuffer batch;

   assert(intel->locked);
   assert(used);

   if (0)
      fprintf(stderr, "%s used %d offset %x..%x ignore_cliprects %d\n",
	      __FUNCTION__, 
	      used, 
	      start_offset,
	      start_offset + used,
	      ignore_cliprects);

   batch.start = start_offset;
   batch.used = used;
   batch.cliprects = intel->pClipRects;
   batch.num_cliprects = ignore_cliprects ? 0 : intel->numClipRects;
   batch.DR1 = 0;
   batch.DR4 = ((((GLuint)intel->drawX) & 0xffff) | 
		(((GLuint)intel->drawY) << 16));
      
   if (INTEL_DEBUG & DEBUG_DMA)
      fprintf(stderr, "%s: 0x%x..0x%x DR4: %x cliprects: %d\n",
	      __FUNCTION__, 
	      batch.start, 
	      batch.start + batch.used * 4,
	      batch.DR4, batch.num_cliprects);

   if (!intel->no_hw) {
      if (drmCommandWrite (intel->driFd, DRM_I830_BATCHBUFFER, &batch, 
			   sizeof(batch))) {
	 fprintf(stderr, "DRM_I830_BATCHBUFFER: %d\n",  -errno);
	 UNLOCK_HARDWARE(intel);
	 exit(1);
      }
   }      
}

void intel_cmd_ioctl( struct intel_context *intel, 
		      char *buf,
		      GLuint used,
		      GLboolean ignore_cliprects)
{
   drmI830CmdBuffer cmd;

   assert(intel->locked);
   assert(used);

   cmd.buf = buf;
   cmd.sz = used;
   cmd.cliprects = intel->pClipRects;
   cmd.num_cliprects = ignore_cliprects ? 0 : intel->numClipRects;
   cmd.DR1 = 0;
   cmd.DR4 = ((((GLuint)intel->drawX) & 0xffff) | 
	      (((GLuint)intel->drawY) << 16));
      
   if (INTEL_DEBUG & DEBUG_DMA)
      fprintf(stderr, "%s: 0x%x..0x%x DR4: %x cliprects: %d\n",
	      __FUNCTION__, 
	      0, 
	      0 + cmd.sz,
	      cmd.DR4, cmd.num_cliprects);

   if (!intel->no_hw) {
      if (drmCommandWrite (intel->driFd, DRM_I830_CMDBUFFER, &cmd, 
			   sizeof(cmd))) {
	 fprintf(stderr, "DRM_I830_CMDBUFFER: %d\n",  -errno);
	 UNLOCK_HARDWARE(intel);
	 exit(1);
      }
   }      
}
