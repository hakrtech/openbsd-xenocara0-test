/****************************************************************************
*
*                        Mesa 3-D graphics library
*                        Direct3D Driver Interface
*
*  ========================================================================
*
*   Copyright (C) 1991-2004 SciTech Software, Inc. All rights reserved.
*
*   Permission is hereby granted, free of charge, to any person obtaining a
*   copy of this software and associated documentation files (the "Software"),
*   to deal in the Software without restriction, including without limitation
*   the rights to use, copy, modify, merge, publish, distribute, sublicense,
*   and/or sell copies of the Software, and to permit persons to whom the
*   Software is furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included
*   in all copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
*   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
*   SCITECH SOFTWARE INC BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
*   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
*   OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.
*
*  ======================================================================
*
* Language:     ANSI C
* Environment:  Windows 9x/2000/XP/XBox (Win32)
*
* Description:  GLDirect Direct3D 8.x WGL (WindowsGL)
*
****************************************************************************/

#include "dglcontext.h"
#include "gld_driver.h"
//#include "gld_dxerr8.h"
#include "gld_dx7.h"

#include "tnl/tnl.h"
#include "tnl/t_context.h"

// Copied from dglcontect.c
#define GLDERR_NONE     0
#define GLDERR_MEM      1
#define GLDERR_DDRAW    2
#define GLDERR_D3D      3
#define GLDERR_BPP      4
#define GLDERR_DDS      5
// This external var keeps track of any error
extern int nContextError;

// Uncomment this for persistant resources
//#define _GLD_PERSISTANT

#define DDLOG_CRITICAL_OR_WARN	DDLOG_CRITICAL

extern void _gld_mesa_warning(struct gl_context *, char *);
extern void _gld_mesa_fatal(struct gl_context *, char *);

//---------------------------------------------------------------------------

static char	szColorDepthWarning[] =
"GLDirect does not support the current desktop\n\
color depth.\n\n\
You may need to change the display resolution to\n\
16 bits per pixel or higher color depth using\n\
the Windows Display Settings control panel\n\
before running this OpenGL application.\n";

// The only depth-stencil formats currently supported by Direct3D
// Surface Format	Depth	Stencil		Total Bits
// D3DFMT_D32		32		-			32
// D3DFMT_D15S1		15		1			16
// D3DFMT_D24S8		24		8			32
// D3DFMT_D16		16		-			16
// D3DFMT_D24X8		24		-			32
// D3DFMT_D24X4S4	24		4			32

// This pixel format will be used as a template when compiling the list
// of pixel formats supported by the hardware. Many fields will be
// filled in at runtime.
// PFD flag defaults are upgraded to match ChoosePixelFormat() -- DaveM
static DGL_pixelFormat pfTemplateHW =
{
    {
	sizeof(PIXELFORMATDESCRIPTOR),	// Size of the data structure
		1,							// Structure version - should be 1
									// Flags:
		PFD_DRAW_TO_WINDOW |		// The buffer can draw to a window or device surface.
		PFD_DRAW_TO_BITMAP |		// The buffer can draw to a bitmap. (DaveM)
		PFD_SUPPORT_GDI |			// The buffer supports GDI drawing. (DaveM)
		PFD_SUPPORT_OPENGL |		// The buffer supports OpenGL drawing.
		PFD_DOUBLEBUFFER |			// The buffer is double-buffered.
		0,							// Placeholder for easy commenting of above flags
		PFD_TYPE_RGBA,				// Pixel type RGBA.
		16,							// Total colour bitplanes (excluding alpha bitplanes)
		5, 0,						// Red bits, shift
		5, 0,						// Green bits, shift
		5, 0,						// Blue bits, shift
		0, 0,						// Alpha bits, shift (destination alpha)
		0,							// Accumulator bits (total)
		0, 0, 0, 0,					// Accumulator bits: Red, Green, Blue, Alpha
		0,							// Depth bits
		0,							// Stencil bits
		0,							// Number of auxiliary buffers
		0,							// Layer type
		0,							// Specifies the number of overlay and underlay planes.
		0,							// Layer mask
		0,							// Specifies the transparent color or index of an underlay plane.
		0							// Damage mask
	},
	D3DX_SF_UNKNOWN,	// No depth/stencil buffer
};

//---------------------------------------------------------------------------
// Vertex Shaders
//---------------------------------------------------------------------------
/*
// Vertex Shader Declaration
static DWORD dwTwoSidedLightingDecl[] =
{
	D3DVSD_STREAM(0),
	D3DVSD_REG(0,  D3DVSDT_FLOAT3), 	 // XYZ position
	D3DVSD_REG(1,  D3DVSDT_FLOAT3), 	 // XYZ normal
	D3DVSD_REG(2,  D3DVSDT_D3DCOLOR),	 // Diffuse color
	D3DVSD_REG(3,  D3DVSDT_D3DCOLOR),	 // Specular color
	D3DVSD_REG(4,  D3DVSDT_FLOAT2), 	 // 2D texture unit 0
	D3DVSD_REG(5,  D3DVSDT_FLOAT2), 	 // 2D texture unit 1
	D3DVSD_END()
};

// Vertex Shader for two-sided lighting
static char *szTwoSidedLightingVS =
// This is a test shader!
"vs.1.0\n"
"m4x4 oPos,v0,c0\n"
"mov oD0,v2\n"
"mov oD1,v3\n"
"mov oT0,v4\n"
"mov oT1,v5\n"
;
*/
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

typedef struct {
//	HINSTANCE			hD3D8DLL;			// Handle to d3d8.dll
//	FNDIRECT3DCREATE7	fnDirect3DCreate7;	// Direct3DCreate8 function prototype
//	BOOL				bDirect3D;			// Persistant Direct3D7 exists
//	BOOL				bDirect3DDevice;	// Persistant Direct3DDevice7 exists
//	IDirect3D7			*pD3D;				// Persistant Direct3D7
//	IDirect3DDevice7	*pDev;				// Persistant Direct3DDevice7
	BOOL				bD3DXStarted;
} GLD_dx7_globals;

// These are "global" to all DX7 contexts. KeithH
static GLD_dx7_globals dx7Globals;

// Added for correct clipping of multiple open windows. (DaveM)
LPDIRECTDRAWSURFACE7 lpDDSPrimary = NULL;
LPDIRECTDRAWCLIPPER lpDDClipper = NULL;

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

BOOL gldGetDXErrorString_DX(
	HRESULT hr,
	char *buf,
	int nBufSize)
{
	//
	// Return a string describing the input HRESULT error code
	//

	D3DXGetErrorString(hr, nBufSize, buf);
	return TRUE;
}

//---------------------------------------------------------------------------
//
// DX7 does not support multisample
/*
static D3DMULTISAMPLE_TYPE _gldGetDeviceMultiSampleType(
	IDirect3D8 *pD3D8,
	D3DFORMAT SurfaceFormat,
	D3DDEVTYPE d3dDevType,
	BOOL Windowed)
{
	int			i;
	HRESULT		hr;

	if (glb.dwMultisample == GLDS_MULTISAMPLE_NONE)
		return D3DMULTISAMPLE_NONE;

	if (glb.dwMultisample == GLDS_MULTISAMPLE_FASTEST) {
		// Find fastest multisample
		for (i=2; i<17; i++) {
			hr = IDirect3D8_CheckDeviceMultiSampleType(
					pD3D8,
					glb.dwAdapter,
					d3dDevType,
					SurfaceFormat,
					Windowed,
					(D3DMULTISAMPLE_TYPE)i);
			if (SUCCEEDED(hr)) {
				return (D3DMULTISAMPLE_TYPE)i;
			}
		}
	} else {
		// Find nicest multisample
		for (i=16; i>1; i--) {
			hr = IDirect3D8_CheckDeviceMultiSampleType(
					pD3D8,
					glb.dwAdapter,
					d3dDevType,
					SurfaceFormat,
					Windowed,
					(D3DMULTISAMPLE_TYPE)i);
			if (SUCCEEDED(hr)) {
				return (D3DMULTISAMPLE_TYPE)i;
			}
		}
	}

	// Nothing found - return default
	return D3DMULTISAMPLE_NONE;
}
*/
//---------------------------------------------------------------------------

void _gldDestroyPrimitiveBuffer(
	GLD_pb_dx7 *gldVB)
{
	SAFE_RELEASE(gldVB->pVB);

	// Sanity check...
	gldVB->nLines = gldVB->nPoints = gldVB->nTriangles = 0;
}

//---------------------------------------------------------------------------

HRESULT _gldCreatePrimitiveBuffer(
	struct gl_context *ctx,
	GLD_driver_dx7 *lpCtx,
	GLD_pb_dx7 *gldVB)
{
	HRESULT				hResult;
	char				*szCreateVertexBufferFailed = "CreateVertexBuffer failed";
	DWORD				dwMaxVertices;	// Max number of vertices in vertex buffer
	DWORD				dwVBSize;		// Total size of vertex buffer
	D3DVERTEXBUFFERDESC	vbdesc;

	// If CVA (Compiled Vertex Array) is used by an OpenGL app, then we
	// will need enough vertices to cater for Mesa::Const.MaxArrayLockSize.
	// We'll use IMM_SIZE if it's larger (which it should not be).
	dwMaxVertices = MAX_ARRAY_LOCK_SIZE;

    // Max vertex buffer size limited in DX7. (DaveM)
    if (dwMaxVertices*9 > D3DMAXNUMVERTICES)
        dwMaxVertices = D3DMAXNUMVERTICES/9;

	// Now calculate how many vertices to allow for in total
	// 1 per point, 2 per line, 6 per quad = 9
	dwVBSize = dwMaxVertices * 9 * gldVB->dwStride;

	vbdesc.dwSize			= sizeof(vbdesc);
	vbdesc.dwCaps			= gldVB->dwCreateFlags;
	vbdesc.dwFVF			= gldVB->dwFVF;
	vbdesc.dwNumVertices	= dwMaxVertices * 9;

/*	hResult = IDirect3DDevice8_CreateVertexBuffer(
		lpCtx->pDev,
		dwVBSize,
RAgldVB->dwUsage,
		gldVB->dwFVF,
		gldVB->dwPool,
		&gldVB->pVB);*/
	hResult = IDirect3D7_CreateVertexBuffer(
		lpCtx->pD3D,
		&vbdesc,
		&gldVB->pVB,
		0);
	if (FAILED(hResult)) {
		ddlogMessage(DDLOG_CRITICAL_OR_WARN, szCreateVertexBufferFailed);
		return hResult;
	}

	gldVB->nLines = gldVB->nPoints = gldVB->nTriangles = 0;
	gldVB->pPoints	= gldVB->pLines = gldVB->pTriangles = NULL;
	gldVB->iFirstLine = dwMaxVertices; // Index of first line in VB
	gldVB->iFirstTriangle = dwMaxVertices*3; // Index of first triangle in VB

	return S_OK;
}

//---------------------------------------------------------------------------
// Function: _gldCreateVertexShaders
// Create DX8 Vertex Shaders.
//---------------------------------------------------------------------------
/*
void _gldCreateVertexShaders(
	GLD_driver_dx8 *gld)
{
	DWORD			dwFlags;
	LPD3DXBUFFER	pVSOpcodeBuffer; // Vertex Shader opcode buffer
	HRESULT			hr;

#ifdef _DEBUG
	dwFlags = D3DXASM_DEBUG;
#else
	dwFlags = 0; // D3DXASM_SKIPVALIDATION;
#endif

	ddlogMessage(DDLOG_INFO, "Creating shaders...\n");

	// Init the shader handle
	gld->VStwosidelight.hShader = 0;

	if (gld->d3dCaps8.MaxStreams == 0) {
		// Lame DX8 driver doesn't support streams
		// Not fatal, as defaults will be used
		ddlogMessage(DDLOG_WARN, "Driver doesn't support Vertex Shaders (MaxStreams==0)\n");
		return;
	}

	// ** THIS DISABLES VERTEX SHADER SUPPORT **
//	return;
	// ** THIS DISABLES VERTEX SHADER SUPPORT **

	//
	// Two-sided lighting
	//

#if 0
	//
	// DEBUGGING: Load shader from a text file
	//
	{
	LPD3DXBUFFER	pVSErrorBuffer; // Vertex Shader error buffer
	hr = D3DXAssembleShaderFromFile(
			"twoside.vsh",
			dwFlags,
			NULL, // No constants
			&pVSOpcodeBuffer,
			&pVSErrorBuffer);
	if (pVSErrorBuffer && pVSErrorBuffer->lpVtbl->GetBufferPointer(pVSErrorBuffer))
		ddlogMessage(DDLOG_INFO, pVSErrorBuffer->lpVtbl->GetBufferPointer(pVSErrorBuffer));
	SAFE_RELEASE(pVSErrorBuffer);
	}
#else
	{
	LPD3DXBUFFER	pVSErrorBuffer; // Vertex Shader error buffer
	// Assemble ascii shader text into shader opcodes
	hr = D3DXAssembleShader(
			szTwoSidedLightingVS,
			strlen(szTwoSidedLightingVS),
			dwFlags,
			NULL, // No constants
			&pVSOpcodeBuffer,
			&pVSErrorBuffer);
	if (pVSErrorBuffer && pVSErrorBuffer->lpVtbl->GetBufferPointer(pVSErrorBuffer))
		ddlogMessage(DDLOG_INFO, pVSErrorBuffer->lpVtbl->GetBufferPointer(pVSErrorBuffer));
	SAFE_RELEASE(pVSErrorBuffer);
	}
#endif
	if (FAILED(hr)) {
		ddlogError(DDLOG_WARN, "AssembleShader failed", hr);
		SAFE_RELEASE(pVSOpcodeBuffer);
		return;
	}

// This is for debugging. Remove to enable vertex shaders in HW
#define _GLD_FORCE_SW_VS 0

	if (_GLD_FORCE_SW_VS) {
		// _GLD_FORCE_SW_VS should be disabled for Final Release
		ddlogMessage(DDLOG_SYSTEM, "[Forcing shaders in SW]\n");
	}

	// Try and create shader in hardware.
	// NOTE: The D3D Ref device appears to succeed when trying to
	//       create the device in hardware, but later complains
	//       when trying to set it with SetVertexShader(). Go figure.
	if (_GLD_FORCE_SW_VS || glb.dwDriver == GLDS_DRIVER_REF) {
		// Don't try and create a hardware shader with the Ref device
		hr = E_FAIL; // COM error/fail result
	} else {
		gld->VStwosidelight.bHardware = TRUE;
		hr = IDirect3DDevice8_CreateVertexShader(
			gld->pDev,
			dwTwoSidedLightingDecl,
			pVSOpcodeBuffer->lpVtbl->GetBufferPointer(pVSOpcodeBuffer),
			&gld->VStwosidelight.hShader,
			0);
	}
	if (FAILED(hr)) {
		ddlogMessage(DDLOG_INFO, "... HW failed, trying SW...\n");
		// Failed. Try and create shader for software processing
		hr = IDirect3DDevice8_CreateVertexShader(
			gld->pDev,
			dwTwoSidedLightingDecl,
			pVSOpcodeBuffer->lpVtbl->GetBufferPointer(pVSOpcodeBuffer),
			&gld->VStwosidelight.hShader,
			D3DUSAGE_SOFTWAREPROCESSING);
		if (FAILED(hr)) {
			gld->VStwosidelight.hShader = 0; // Sanity check
			ddlogError(DDLOG_WARN, "CreateVertexShader failed", hr);
			return;
		}
		// Succeeded, but for software processing
		gld->VStwosidelight.bHardware = FALSE;
	}

	SAFE_RELEASE(pVSOpcodeBuffer);

	ddlogMessage(DDLOG_INFO, "... OK\n");
}

//---------------------------------------------------------------------------

void _gldDestroyVertexShaders(
	GLD_driver_dx8 *gld)
{
	if (gld->VStwosidelight.hShader) {
		IDirect3DDevice8_DeleteVertexShader(gld->pDev, gld->VStwosidelight.hShader);
		gld->VStwosidelight.hShader = 0;
	}
}
*/
//---------------------------------------------------------------------------

BOOL gldCreateDrawable_DX(
	DGL_ctx *ctx,
//	BOOL bDefaultDriver,
	BOOL bDirectDrawPersistant,
	BOOL bPersistantBuffers)
{
	//
	// bDirectDrawPersistant:	applies to IDirect3D8
	// bPersistantBuffers:		applies to IDirect3DDevice8
	//

//	D3DDEVTYPE				d3dDevType;
//	D3DPRESENT_PARAMETERS	d3dpp;
//	D3DDISPLAYMODE			d3ddm;
//	DWORD					dwBehaviourFlags;
//	D3DADAPTER_IDENTIFIER8	d3dIdent;

	HRESULT				hr;
	GLD_driver_dx7		*lpCtx = NULL;
	D3DX_VIDMODEDESC	d3ddm;

	// Parameters for D3DXCreateContextEx
	// These will be different for fullscreen and windowed
	DWORD				dwDeviceIndex;
	DWORD				dwFlags;
	HWND				hwnd;
	HWND				hwndFocus;
	DWORD				numColorBits;
	DWORD				numAlphaBits;
	DWORD				numDepthBits;
	DWORD				numStencilBits;
	DWORD				numBackBuffers;
	DWORD				dwWidth;
	DWORD				dwHeight;
	DWORD				refreshRate;

	// Error if context is NULL.
	if (ctx == NULL)
		return FALSE;

	if (ctx->glPriv) {
		lpCtx = ctx->glPriv;
		// Release any existing interfaces (in reverse order)
		SAFE_RELEASE(lpCtx->pDev);
		SAFE_RELEASE(lpCtx->pD3D);
		lpCtx->pD3DXContext->lpVtbl->Release(lpCtx->pD3DXContext);
		lpCtx->pD3DXContext = NULL;
	} else {
		lpCtx = (GLD_driver_dx7*)malloc(sizeof(GLD_driver_dx7));
		ZeroMemory(lpCtx, sizeof(lpCtx));
	}

//	d3dDevType = (glb.dwDriver == GLDS_DRIVER_HAL) ? D3DDEVTYPE_HAL : D3DDEVTYPE_REF;
	// Use REF device if requested. Otherwise D3DX_DEFAULT will choose highest level
	// of HW acceleration.
	dwDeviceIndex = (glb.dwDriver == GLDS_DRIVER_REF) ? D3DX_HWLEVEL_REFERENCE : D3DX_DEFAULT;

	// TODO: Check this
//	if (bDefaultDriver)
//		d3dDevType = D3DDEVTYPE_REF;

#ifdef _GLD_PERSISTANT
	// Use persistant interface if needed
	if (bDirectDrawPersistant && dx7Globals.bDirect3D) {
		lpCtx->pD3D = dx7Globals.pD3D;
		IDirect3D7_AddRef(lpCtx->pD3D);
		goto SkipDirectDrawCreate;
	}
#endif
/*
	// Create Direct3D7 object
	lpCtx->pD3D = dx7Globals.fnDirect3DCreate8(D3D_SDK_VERSION_DX8_SUPPORT_WIN95);
	if (lpCtx->pD3D == NULL) {
		MessageBox(NULL, "Unable to initialize Direct3D8", "GLDirect", MB_OK);
		ddlogMessage(DDLOG_CRITICAL_OR_WARN, "Unable to create Direct3D8 interface");
        nContextError = GLDERR_D3D;
		goto return_with_error;
	}
*/

#ifdef _GLD_PERSISTANT
	// Cache Direct3D interface for subsequent GLRCs
	if (bDirectDrawPersistant && !dx8Globals.bDirect3D) {
		dx7Globals.pD3D = lpCtx->pD3D;
		IDirect3D7_AddRef(dx7Globals.pD3D);
		dx7Globals.bDirect3D = TRUE;
	}
SkipDirectDrawCreate:
#endif
/*
	// Get the display mode so we can make a compatible backbuffer
	hResult = IDirect3D8_GetAdapterDisplayMode(lpCtx->pD3D, glb.dwAdapter, &d3ddm);
	if (FAILED(hResult)) {
        nContextError = GLDERR_D3D;
		goto return_with_error;
	}
*/

#if 0
	// Get device caps
	hResult = IDirect3D8_GetDeviceCaps(lpCtx->pD3D, glb.dwAdapter, d3dDevType, &lpCtx->d3dCaps8);
	if (FAILED(hResult)) {
		ddlogError(DDLOG_CRITICAL_OR_WARN, "IDirect3D8_GetDeviceCaps failed", hResult);
        nContextError = GLDERR_D3D;
		goto return_with_error;
	}

	// Check for hardware transform & lighting
	lpCtx->bHasHWTnL = lpCtx->d3dCaps8.DevCaps & D3DDEVCAPS_HWTRANSFORMANDLIGHT ? TRUE : FALSE;

	// If this flag is present then we can't default to Mesa
	// SW rendering between BeginScene() and EndScene().
	if (lpCtx->d3dCaps8.Caps2 & D3DCAPS2_NO2DDURING3DSCENE) {
		ddlogMessage(DDLOG_WARN,
			"Warning          : No 2D allowed during 3D scene.\n");
	}
#endif

	//
	//	Create the Direct3D context
	//

#ifdef _GLD_PERSISTANT
	// Re-use original IDirect3DDevice if persistant buffers exist.
	// Note that we test for persistant IDirect3D8 as well
	// bDirectDrawPersistant == persistant IDirect3D8 (DirectDraw8 does not exist)
	if (bDirectDrawPersistant && bPersistantBuffers && dx7Globals.pD3D && dx7Globals.pDev) {
		lpCtx->pDev = dx7Globals.pDev;
		IDirect3DDevice7_AddRef(dx7Globals.pDev);
		goto skip_direct3ddevice_create;
	}
#endif
/*
	// Clear the presentation parameters (sets all members to zero)
	ZeroMemory(&d3dpp, sizeof(d3dpp));

	// Recommended by MS; needed for MultiSample.
	// Be careful if altering this for FullScreenBlit
	d3dpp.SwapEffect = D3DSWAPEFFECT_DISCARD;

	d3dpp.BackBufferFormat	= d3ddm.Format;
	d3dpp.BackBufferCount	= 1;
	d3dpp.MultiSampleType	= _gldGetDeviceMultiSampleType(lpCtx->pD3D, d3ddm.Format, d3dDevType, !ctx->bFullscreen);
	d3dpp.AutoDepthStencilFormat	= ctx->lpPF->dwDriverData;
	d3dpp.EnableAutoDepthStencil	= (d3dpp.AutoDepthStencilFormat == D3DFMT_UNKNOWN) ? FALSE : TRUE;

	if (ctx->bFullscreen) {
		ddlogWarnOption(FALSE); // Don't popup any messages in fullscreen 
		d3dpp.Windowed							= FALSE;
		d3dpp.BackBufferWidth					= d3ddm.Width;
		d3dpp.BackBufferHeight					= d3ddm.Height;
		d3dpp.hDeviceWindow						= ctx->hWnd;
		d3dpp.FullScreen_RefreshRateInHz		= D3DPRESENT_RATE_DEFAULT;

		// Support for vertical retrace synchronisation.
		// Set default presentation interval in case caps bits are missing
		d3dpp.FullScreen_PresentationInterval	= D3DPRESENT_INTERVAL_DEFAULT;
		if (glb.bWaitForRetrace) {
			if (lpCtx->d3dCaps8.PresentationIntervals & D3DPRESENT_INTERVAL_ONE)
				d3dpp.FullScreen_PresentationInterval = D3DPRESENT_INTERVAL_ONE;
		} else {
			if (lpCtx->d3dCaps8.PresentationIntervals & D3DPRESENT_INTERVAL_IMMEDIATE)
				d3dpp.FullScreen_PresentationInterval = D3DPRESENT_INTERVAL_IMMEDIATE;
		}
	} else {
		ddlogWarnOption(glb.bMessageBoxWarnings); // OK to popup messages
		d3dpp.Windowed							= TRUE;
		d3dpp.BackBufferWidth					= ctx->dwWidth;
		d3dpp.BackBufferHeight					= ctx->dwHeight;
		d3dpp.hDeviceWindow						= ctx->hWnd;
		d3dpp.FullScreen_RefreshRateInHz		= 0;
		// FullScreen_PresentationInterval must be default for Windowed mode
		d3dpp.FullScreen_PresentationInterval	= D3DPRESENT_INTERVAL_DEFAULT;
	}

	// Decide if we can use hardware TnL
	dwBehaviourFlags = (lpCtx->bHasHWTnL) ?
		D3DCREATE_MIXED_VERTEXPROCESSING : D3DCREATE_SOFTWARE_VERTEXPROCESSING;
	// Add flag to tell D3D to be thread-safe
	if (glb.bMultiThreaded)
		dwBehaviourFlags |= D3DCREATE_MULTITHREADED;
	hResult = IDirect3D8_CreateDevice(lpCtx->pD3D,
								glb.dwAdapter,
								d3dDevType,
								ctx->hWnd,
								dwBehaviourFlags,
								&d3dpp,
								&lpCtx->pDev);
    if (FAILED(hResult)) {
		ddlogError(DDLOG_CRITICAL_OR_WARN, "IDirect3D8_CreateDevice failed", hResult);
        nContextError = GLDERR_D3D;
		goto return_with_error;
	}
*/

	// Create D3DX context
	if (ctx->bFullscreen) {
		//
		// FULLSCREEN
		//

		// Get display mode
		D3DXGetCurrentVideoMode(D3DX_DEFAULT, &d3ddm);

		// Fullscreen Parameters
		dwFlags			= D3DX_CONTEXT_FULLSCREEN;
		hwnd			= ctx->hWnd;
		hwndFocus		= ctx->hWnd;
		numColorBits	= ctx->lpPF->pfd.cColorBits;
		numAlphaBits	= ctx->lpPF->pfd.cAlphaBits;
		numDepthBits	= ctx->lpPF->pfd.cDepthBits + ctx->lpPF->pfd.cStencilBits;
		numStencilBits	= ctx->lpPF->pfd.cStencilBits;
		numBackBuffers	= D3DX_DEFAULT; // Default is 1 backbuffer
		dwWidth			= d3ddm.width;
		dwHeight		= d3ddm.height;
		refreshRate		= d3ddm.refreshRate; // D3DX_DEFAULT;
	} else {
		//
		// WINDOWED
		//

		// Windowed Parameters
		dwFlags			= 0; // No flags means "windowed"
		hwnd			= ctx->hWnd;
		hwndFocus		= (HWND)D3DX_DEFAULT;
		numColorBits	= D3DX_DEFAULT; // Use Desktop depth
		numAlphaBits	= ctx->lpPF->pfd.cAlphaBits;
		numDepthBits	= ctx->lpPF->pfd.cDepthBits + ctx->lpPF->pfd.cStencilBits;
		numStencilBits	= ctx->lpPF->pfd.cStencilBits;
		numBackBuffers	= D3DX_DEFAULT; // Default is 1 backbuffer
		dwWidth			= ctx->dwWidth;
		dwHeight		= ctx->dwHeight;
		refreshRate		= D3DX_DEFAULT;
	}
	hr = D3DXCreateContextEx(dwDeviceIndex, dwFlags, hwnd, hwndFocus,
							numColorBits, numAlphaBits, numDepthBits, numStencilBits,
							numBackBuffers,
							dwWidth, dwHeight, refreshRate,
							&lpCtx->pD3DXContext);
    if (FAILED(hr)) {
		ddlogError(DDLOG_CRITICAL_OR_WARN, "D3DXCreateContextEx failed", hr);
        nContextError = GLDERR_D3D;
		goto return_with_error;
	}

	// Obtain D3D7 interfaces from ID3DXContext
//	lpCtx->pDD	= ID3DXContext_GetDD(lpCtx->pD3DXContext);
	lpCtx->pDD	= lpCtx->pD3DXContext->lpVtbl->GetDD(lpCtx->pD3DXContext);
	if (lpCtx->pDD == NULL)
		goto return_with_error;
	lpCtx->pD3D	= lpCtx->pD3DXContext->lpVtbl->GetD3D(lpCtx->pD3DXContext);
	if (lpCtx->pD3D == NULL)
		goto return_with_error;
	lpCtx->pDev	= lpCtx->pD3DXContext->lpVtbl->GetD3DDevice(lpCtx->pD3DXContext);
	if (lpCtx->pDev == NULL)
		goto return_with_error;

    // Need to manage clipper manually for multiple windows
    // since DX7 D3DX utility lib does not appear to do that. (DaveM)
    if (!ctx->bFullscreen) {
        // Get primary surface too
        lpDDSPrimary = lpCtx->pD3DXContext->lpVtbl->GetPrimary(lpCtx->pD3DXContext);
	    if (lpDDSPrimary == NULL) {
		    ddlogPrintf(DDLOG_WARN, "GetPrimary");
            goto return_with_error;
	    }
	    // Create clipper for correct window updates
        if (IDirectDraw7_CreateClipper(lpCtx->pDD, 0, &lpDDClipper, NULL) != DD_OK) {
		    ddlogPrintf(DDLOG_WARN, "CreateClipper");
		    goto return_with_error;
	    }
        // Set the window that the clipper belongs to
        if (IDirectDrawClipper_SetHWnd(lpDDClipper, 0, hwnd) != DD_OK) {
		    ddlogPrintf(DDLOG_WARN, "SetHWnd");
		    goto return_with_error;
	    }
        // Attach the clipper to the primary surface
        if (IDirectDrawSurface7_SetClipper(lpDDSPrimary, lpDDClipper) != DD_OK) {
		    ddlogPrintf(DDLOG_WARN, "SetClipper");
            goto return_with_error;
	    }
    }

	// Get device caps
	IDirect3DDevice7_GetCaps(lpCtx->pDev, &lpCtx->d3dCaps);

	// Determine HW TnL
	lpCtx->bHasHWTnL = lpCtx->d3dCaps.dwDevCaps & D3DDEVCAPS_HWTRANSFORMANDLIGHT ? TRUE : FALSE;

#ifdef _GLD_PERSISTANT
	if (bDirectDrawPersistant && bPersistantBuffers && dx7Globals.pD3D) {
		dx7Globals.pDev = lpCtx->pDev;
		dx7Globals.bDirect3DDevice = TRUE;
	}
#endif

#if 0
	// Dump some useful stats
	hResult = IDirect3D8_GetAdapterIdentifier(
		lpCtx->pD3D,
		glb.dwAdapter,
		D3DENUM_NO_WHQL_LEVEL, // Avoids 1 to 2 second delay
		&d3dIdent);
	if (SUCCEEDED(hResult)) {
		ddlogPrintf(DDLOG_INFO, "[Driver Description: %s]", &d3dIdent.Description);
		ddlogPrintf(DDLOG_INFO, "[Driver file: %s %d.%d.%02d.%d]",
			d3dIdent.Driver,
			HIWORD(d3dIdent.DriverVersion.HighPart),
			LOWORD(d3dIdent.DriverVersion.HighPart),
			HIWORD(d3dIdent.DriverVersion.LowPart),
			LOWORD(d3dIdent.DriverVersion.LowPart));
		ddlogPrintf(DDLOG_INFO, "[VendorId: 0x%X, DeviceId: 0x%X, SubSysId: 0x%X, Revision: 0x%X]",
			d3dIdent.VendorId, d3dIdent.DeviceId, d3dIdent.SubSysId, d3dIdent.Revision);
	}
#endif

	// Init projection matrix for D3D TnL
	D3DXMatrixIdentity((D3DXMATRIX*)&lpCtx->matProjection);
	lpCtx->matModelView = lpCtx->matProjection;
//		gld->bUseMesaProjection = TRUE;

skip_direct3ddevice_create:

	// Create buffers to hold primitives
	lpCtx->PB2d.dwFVF			= GLD_FVF_2D_VERTEX;
//	lpCtx->PB2d.dwPool			= D3DPOOL_SYSTEMMEM;
	lpCtx->PB2d.dwStride		= sizeof(GLD_2D_VERTEX);
	lpCtx->PB2d.dwCreateFlags	= D3DVBCAPS_DONOTCLIP |
									D3DVBCAPS_SYSTEMMEMORY |
									D3DVBCAPS_WRITEONLY;
	hr = _gldCreatePrimitiveBuffer(ctx->glCtx, lpCtx, &lpCtx->PB2d);
	if (FAILED(hr))
		goto return_with_error;

	lpCtx->PB3d.dwFVF			= GLD_FVF_3D_VERTEX;
//	lpCtx->PB3d.dwPool			= D3DPOOL_DEFAULT;
	lpCtx->PB3d.dwStride		= sizeof(GLD_3D_VERTEX);
	lpCtx->PB3d.dwCreateFlags	= D3DVBCAPS_WRITEONLY;

	hr = _gldCreatePrimitiveBuffer(ctx->glCtx, lpCtx, &lpCtx->PB3d);
	if (FAILED(hr))
		goto return_with_error;

	// Zero the pipeline usage counters
	lpCtx->PipelineUsage.qwMesa.QuadPart = 
//	lpCtx->PipelineUsage.dwD3D2SVS.QuadPart =
	lpCtx->PipelineUsage.qwD3DFVF.QuadPart = 0;

	// Assign drawable to GL private
	ctx->glPriv = lpCtx;
	return TRUE;

return_with_error:
	// Clean up and bail
	_gldDestroyPrimitiveBuffer(&lpCtx->PB3d);
	_gldDestroyPrimitiveBuffer(&lpCtx->PB2d);

	SAFE_RELEASE(lpCtx->pDev);
	SAFE_RELEASE(lpCtx->pD3D);
	//SAFE_RELEASE(lpCtx->pD3DXContext);
	lpCtx->pD3DXContext->lpVtbl->Release(lpCtx->pD3DXContext);
	return FALSE;
}

//---------------------------------------------------------------------------

BOOL gldResizeDrawable_DX(
	DGL_ctx *ctx,
	BOOL bDefaultDriver,
	BOOL bPersistantInterface,
	BOOL bPersistantBuffers)
{
	GLD_driver_dx7			*gld = NULL;
//	D3DDEVTYPE				d3dDevType;
//	D3DPRESENT_PARAMETERS	d3dpp;
//	D3DDISPLAYMODE			d3ddm;
	D3DX_VIDMODEDESC		d3ddm;
	HRESULT					hr;
	DWORD					dwWidth, dwHeight;

	// Error if context is NULL.
	if (ctx == NULL)
		return FALSE;

	gld = ctx->glPriv;
	if (gld == NULL)
		return FALSE;

	if (ctx->bSceneStarted) {
		IDirect3DDevice7_EndScene(gld->pDev);
		ctx->bSceneStarted = FALSE;
	}
/*
	d3dDevType = (glb.dwDriver == GLDS_DRIVER_HAL) ? D3DDEVTYPE_HAL : D3DDEVTYPE_REF;
	if (!bDefaultDriver)
		d3dDevType = D3DDEVTYPE_REF; // Force Direct3D Reference Rasterise (software)

	// Get the display mode so we can make a compatible backbuffer
	hResult = IDirect3D8_GetAdapterDisplayMode(gld->pD3D, glb.dwAdapter, &d3ddm);
	if (FAILED(hResult)) {
        nContextError = GLDERR_D3D;
//		goto return_with_error;
		return FALSE;
	}
*/
	// Release objects before Reset()
	_gldDestroyPrimitiveBuffer(&gld->PB3d);
	_gldDestroyPrimitiveBuffer(&gld->PB2d);

/*
	// Clear the presentation parameters (sets all members to zero)
	ZeroMemory(&d3dpp, sizeof(d3dpp));

	// Recommended by MS; needed for MultiSample.
	// Be careful if altering this for FullScreenBlit
	d3dpp.SwapEffect = D3DSWAPEFFECT_DISCARD;

	d3dpp.BackBufferFormat	= d3ddm.Format;
	d3dpp.BackBufferCount	= 1;
	d3dpp.MultiSampleType	= _gldGetDeviceMultiSampleType(gld->pD3D, d3ddm.Format, d3dDevType, !ctx->bFullscreen);
	d3dpp.AutoDepthStencilFormat	= ctx->lpPF->dwDriverData;
	d3dpp.EnableAutoDepthStencil	= (d3dpp.AutoDepthStencilFormat == D3DFMT_UNKNOWN) ? FALSE : TRUE;

	// TODO: Sync to refresh

	if (ctx->bFullscreen) {
		ddlogWarnOption(FALSE); // Don't popup any messages in fullscreen 
		d3dpp.Windowed							= FALSE;
		d3dpp.BackBufferWidth					= d3ddm.Width;
		d3dpp.BackBufferHeight					= d3ddm.Height;
		d3dpp.hDeviceWindow						= ctx->hWnd;
		d3dpp.FullScreen_RefreshRateInHz		= D3DPRESENT_RATE_DEFAULT;
		d3dpp.FullScreen_PresentationInterval	= D3DPRESENT_INTERVAL_DEFAULT;
		// Get better benchmark results? KeithH
//		d3dpp.FullScreen_RefreshRateInHz		= D3DPRESENT_RATE_UNLIMITED;
	} else {
		ddlogWarnOption(glb.bMessageBoxWarnings); // OK to popup messages
		d3dpp.Windowed							= TRUE;
		d3dpp.BackBufferWidth					= ctx->dwWidth;
		d3dpp.BackBufferHeight					= ctx->dwHeight;
		d3dpp.hDeviceWindow						= ctx->hWnd;
		d3dpp.FullScreen_RefreshRateInHz		= 0;
		d3dpp.FullScreen_PresentationInterval	= D3DPRESENT_INTERVAL_DEFAULT;
	}
	hResult = IDirect3DDevice8_Reset(gld->pDev, &d3dpp);
	if (FAILED(hResult)) {
		ddlogError(DDLOG_CRITICAL_OR_WARN, "dglResize: Reset failed", hResult);
		return FALSE;
		//goto cleanup_and_return_with_error;
	}
*/
	// Obtain dimensions of 'window'
	if (ctx->bFullscreen) {
		D3DXGetCurrentVideoMode(D3DX_DEFAULT, &d3ddm);
		dwWidth = d3ddm.width;
		dwHeight = d3ddm.height;
	} else {
		dwWidth = ctx->dwWidth;
		dwHeight = ctx->dwHeight;
	}

	// Resize context
	hr = gld->pD3DXContext->lpVtbl->Resize(gld->pD3DXContext, dwWidth, dwHeight);
	if (FAILED(hr)) {
		ddlogError(DDLOG_CRITICAL_OR_WARN, "gldResizeDrawable_DX: Resize failed", hr);
		return FALSE;
	}

	// Clear the resized surface (DaveM)
	{
		D3DVIEWPORT7 vp1, vp2;
		IDirect3DDevice7_GetViewport(gld->pDev, &vp1);
		IDirect3DDevice7_GetViewport(gld->pDev, &vp2);
		vp2.dwX = 0;
		vp2.dwY = 0;
		vp2.dwWidth = dwWidth;
		vp2.dwHeight = dwHeight;
		IDirect3DDevice7_SetViewport(gld->pDev, &vp2);
		hr = gld->pD3DXContext->lpVtbl->Clear(gld->pD3DXContext, D3DCLEAR_TARGET);
		if (FAILED(hr))
			ddlogError(DDLOG_WARN, "gldResizeDrawable_DX: Clear failed", hr);
		IDirect3DDevice7_SetViewport(gld->pDev, &vp1);
	}

	//
	// Recreate objects
	//
	_gldCreatePrimitiveBuffer(ctx->glCtx, gld, &gld->PB2d);
	_gldCreatePrimitiveBuffer(ctx->glCtx, gld, &gld->PB3d);

	// Signal a complete state update
	ctx->glCtx->Driver.UpdateState(ctx->glCtx, _NEW_ALL);

	// Begin a new scene
	IDirect3DDevice7_BeginScene(gld->pDev);
	ctx->bSceneStarted = TRUE;

	return TRUE;
}

//---------------------------------------------------------------------------

BOOL gldDestroyDrawable_DX(
	DGL_ctx *ctx)
{
	GLD_driver_dx7			*lpCtx = NULL;

	// Error if context is NULL.
	if (!ctx)
		return FALSE;

	// Error if the drawable does not exist.
	if (!ctx->glPriv)
		return FALSE;

	lpCtx = ctx->glPriv;

#ifdef _DEBUG
	// Dump out stats
	ddlogPrintf(DDLOG_SYSTEM, "Usage: M:0x%X%X, D:0x%X%X",
		lpCtx->PipelineUsage.qwMesa.HighPart,
		lpCtx->PipelineUsage.qwMesa.LowPart,
		lpCtx->PipelineUsage.qwD3DFVF.HighPart,
		lpCtx->PipelineUsage.qwD3DFVF.LowPart);
#endif

	// Destroy Primtive Buffers
	_gldDestroyPrimitiveBuffer(&lpCtx->PB3d);
	_gldDestroyPrimitiveBuffer(&lpCtx->PB2d);

	// Release DX interfaces (in reverse order)
	SAFE_RELEASE(lpCtx->pDev);
	SAFE_RELEASE(lpCtx->pD3D);
	//SAFE_RELEASE(lpCtx->pD3DXContext);
	lpCtx->pD3DXContext->lpVtbl->Release(lpCtx->pD3DXContext);

	// Free the private drawable data
	free(ctx->glPriv);
	ctx->glPriv = NULL;

	return TRUE;
}

//---------------------------------------------------------------------------

BOOL gldCreatePrivateGlobals_DX(void)
{
/*
	ZeroMemory(&dx7Globals, sizeof(dx7Globals));

	// Load d3d8.dll
	dx8Globals.hD3D8DLL = LoadLibrary("D3D8.DLL");
	if (dx8Globals.hD3D8DLL == NULL)
		return FALSE;

	// Now try and obtain Direct3DCreate8
	dx8Globals.fnDirect3DCreate8 = (FNDIRECT3DCREATE8)GetProcAddress(dx8Globals.hD3D8DLL, "Direct3DCreate8");
	if (dx8Globals.fnDirect3DCreate8 == NULL) {
		FreeLibrary(dx8Globals.hD3D8DLL);
		return FALSE;
	}
*/
	
	// Initialise D3DX
	return FAILED(D3DXInitialize()) ? FALSE : TRUE;
}

//---------------------------------------------------------------------------

BOOL gldDestroyPrivateGlobals_DX(void)
{
/*
	if (dx7Globals.bDirect3DDevice) {
		SAFE_RELEASE(dx7Globals.pDev);
		dx7Globals.bDirect3DDevice = FALSE;
	}
	if (dx7Globals.bDirect3D) {
		SAFE_RELEASE(dx7Globals.pD3D);
		dx7Globals.bDirect3D = FALSE;
	}

	FreeLibrary(dx8Globals.hD3D8DLL);
	dx8Globals.hD3D8DLL = NULL;
	dx8Globals.fnDirect3DCreate8 = NULL;
*/
	return FAILED(D3DXUninitialize()) ? FALSE : TRUE;
}

//---------------------------------------------------------------------------

static void _BitsFromDisplayFormat(
	D3DX_SURFACEFORMAT fmt,
	BYTE *cColorBits,
	BYTE *cRedBits,
	BYTE *cGreenBits,
	BYTE *cBlueBits,
	BYTE *cAlphaBits)
{
	switch (fmt) {
/*	case D3DX_SF_X1R5G5B5:
		*cColorBits = 16;
		*cRedBits = 5;
		*cGreenBits = 5;
		*cBlueBits = 5;
		*cAlphaBits = 0;
		return;*/
	case D3DX_SF_R5G5B5:
		*cColorBits = 16;
		*cRedBits = 5;
		*cGreenBits = 5;
		*cBlueBits = 5;
		*cAlphaBits = 0;
		return;
	case D3DX_SF_R5G6B5:
		*cColorBits = 16;
		*cRedBits = 5;
		*cGreenBits = 6;
		*cBlueBits = 5;
		*cAlphaBits = 0;
		return;
	case D3DX_SF_X8R8G8B8:
		*cColorBits = 32;
		*cRedBits = 8;
		*cGreenBits = 8;
		*cBlueBits = 8;
		*cAlphaBits = 0;
		return;
	case D3DX_SF_A8R8G8B8:
		*cColorBits = 32;
		*cRedBits = 8;
		*cGreenBits = 8;
		*cBlueBits = 8;
		*cAlphaBits = 8;
		return;
	}

	// Should not get here!
	*cColorBits = 32;
	*cRedBits = 8;
	*cGreenBits = 8;
	*cBlueBits = 8;
	*cAlphaBits = 0;
}

//---------------------------------------------------------------------------

static void _BitsFromDepthStencilFormat(
	D3DX_SURFACEFORMAT fmt,
	BYTE *cDepthBits,
	BYTE *cStencilBits)
{
	// NOTE: GL expects either 32 or 16 as depth bits.
	switch (fmt) {
	case D3DX_SF_Z16S0:
		*cDepthBits = 16;
		*cStencilBits = 0;
		return;
	case D3DX_SF_Z32S0:
		*cDepthBits = 32;
		*cStencilBits = 0;
		return;
	case D3DX_SF_Z15S1:
		*cDepthBits = 15;
		*cStencilBits = 1;
		return;
	case D3DX_SF_Z24S8:
		*cDepthBits = 24;
		*cStencilBits = 8;
		return;
	case D3DX_SF_S1Z15:
		*cDepthBits = 15;
		*cStencilBits = 1;
		return;
	case D3DX_SF_S8Z24:
		*cDepthBits = 24;
		*cStencilBits = 8;
		return;
	}
}

//---------------------------------------------------------------------------
/*
BOOL GLD_CheckDepthStencilMatch(
	DWORD dwDeviceIndex,
	D3DX_SURFACEFORMAT sfWant)
{
	// Emulate function built in to DX9
	D3DX_SURFACEFORMAT	sfFound;
	int i;
	int nFormats = D3DXGetMaxSurfaceFormats(dwDeviceIndex, NULL, D3DX_SC_DEPTHBUFFER);
	if (nFormats) {
		for (i=0; i<nFormats; i++) {
		D3DXGetSurfaceFormat(dwDeviceIndex, NULL, D3DX_SC_DEPTHBUFFER, i, &sfFound);		}
		if (sfFound == sfWant)
			return TRUE;
	}

	return FALSE;
}
*/
//---------------------------------------------------------------------------

D3DX_SURFACEFORMAT _gldFindCompatibleDepthStencilFormat(
	DWORD dwDeviceIndex)
{
	// Jump through some hoops...

	ID3DXContext		*pD3DXContext = NULL;
	IDirectDrawSurface7	*pZBuffer = NULL;
	DDPIXELFORMAT		ddpf;
	HWND				hWnd;

	// Get an HWND - use Desktop's
	hWnd = GetDesktopWindow();

	// Create a fully specified default context.
	D3DXCreateContextEx(dwDeviceIndex, 0, hWnd, (HWND)D3DX_DEFAULT,
						D3DX_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT,
						D3DX_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT, D3DX_DEFAULT,
						&pD3DXContext);

	// Obtain depth buffer that was created in context
	pZBuffer = pD3DXContext->lpVtbl->GetZBuffer(pD3DXContext);

	// Get pixel format of depth buffer
	ddpf.dwSize = sizeof(ddpf);
	pZBuffer->lpVtbl->GetPixelFormat(pZBuffer, &ddpf);
	// Done with surface - release it
	pZBuffer->lpVtbl->Release(pZBuffer);

	// Done with D3DX context
	pD3DXContext->lpVtbl->Release(pD3DXContext);

	// Convert and return
	return D3DXMakeSurfaceFormat(&ddpf);
}

//---------------------------------------------------------------------------

BOOL gldBuildPixelformatList_DX(void)
{
	D3DX_DEVICEDESC		d3dxdd;
	D3DX_VIDMODEDESC	d3ddm;
	D3DX_SURFACEFORMAT	fmt[64]; // 64 should be enough...
	DWORD				dwDeviceIndex;
	DWORD				surfClassFlags;
//	IDirect3D7			*pD3D = NULL;
	HRESULT				hr;
	int					nSupportedFormats = 0;		// Total formats
	int					nDepthOnlyFormats = 0;
	int					nDepthStencilFormats = 0;
	int					i;
	DGL_pixelFormat		*pPF;
	BYTE				cColorBits, cRedBits, cGreenBits, cBlueBits, cAlphaBits;
//	char				buf[128];
//	char				cat[8];

	// Direct3D (SW or HW)
	// These are arranged so that 'best' pixelformat
	// is higher in the list (for ChoosePixelFormat).
/*	const D3DFORMAT DepthStencil[4] = {
		D3DX_SF_Z16S0, //D3DX_SF_D16,
		D3DX_SF_Z15S1, //D3DX_SF_D15S1,
		D3DX_SF_Z32S0, //D3DX_SF_D32,
		D3DX_SF_Z24S8, //D3DX_SF_D24S8,
		//D3DX_SF_D24X8,
		//D3DX_SF_D24X4S4,
	};*/

	// Dump DX version
	ddlogMessage(GLDLOG_SYSTEM, "DirectX Version  : 7.0\n");

	// Release any existing pixelformat list
	if (glb.lpPF) {
		free(glb.lpPF);
	}

	glb.nPixelFormatCount	= 0;
	glb.lpPF				= NULL;

	//
	// Pixelformats for Direct3D (SW or HW) rendering
	//

	dwDeviceIndex = (glb.dwDriver == GLDS_DRIVER_REF) ? D3DX_HWLEVEL_REFERENCE : D3DX_DEFAULT;

	// Dump description
	D3DXGetDeviceDescription(dwDeviceIndex, &d3dxdd);
	ddlogPrintf(GLDLOG_SYSTEM, "Device: %s", d3dxdd.driverDesc);

	// Get display mode
	D3DXGetCurrentVideoMode(D3DX_DEFAULT, &d3ddm);

#if 0
	// Phooey - this don't work...
/*
	// Since D3DXGetMaxSurfaceFormats() can lie to us, we'll need a workaround.
	// Explicitly test for matching depth/stencil to display bpp.
	if (d3ddm.bpp <= 16) {
		if (GLD_CheckDepthStencilMatch(dwDeviceIndex, D3DX_SF_Z16S0))
			fmt[nSupportedFormats++] = D3DX_SF_Z16S0;
		if (GLD_CheckDepthStencilMatch(dwDeviceIndex, D3DX_SF_Z15S1))
			fmt[nSupportedFormats++] = D3DX_SF_Z15S1;
		if (GLD_CheckDepthStencilMatch(dwDeviceIndex, D3DX_SF_S1Z15))
			fmt[nSupportedFormats++] = D3DX_SF_S1Z15;
		// Didn't find anything? Try default
		if (nSupportedFormats == 0) {
			if (GLD_CheckDepthStencilMatch(dwDeviceIndex, D3DX_SF_Z32S0))
				fmt[nSupportedFormats++] = D3DX_SF_Z32S0;
		}
	} else {
		if (GLD_CheckDepthStencilMatch(dwDeviceIndex, D3DX_SF_Z32S0))
			fmt[nSupportedFormats++] = D3DX_SF_Z32S0;
		if (GLD_CheckDepthStencilMatch(dwDeviceIndex, D3DX_SF_Z24S8))
			fmt[nSupportedFormats++] = D3DX_SF_Z24S8;
		if (GLD_CheckDepthStencilMatch(dwDeviceIndex, D3DX_SF_S8Z24))
			fmt[nSupportedFormats++] = D3DX_SF_S8Z24;
		// Didn't find anything? Try default
		if (nSupportedFormats == 0) {
			if (GLD_CheckDepthStencilMatch(dwDeviceIndex, D3DX_SF_Z16S0))
				fmt[nSupportedFormats++] = D3DX_SF_Z16S0;
		}
	}
*/
	// Go the Whole Hog...
	fmt[nSupportedFormats++] = _gldFindCompatibleDepthStencilFormat(dwDeviceIndex);
#else
	//
	// Depth buffer formats WITHOUT stencil
	//
	surfClassFlags = D3DX_SC_DEPTHBUFFER;
	nDepthOnlyFormats = D3DXGetMaxSurfaceFormats(dwDeviceIndex, NULL, surfClassFlags);
	//
	// Depth buffer formats WITH stencil
	//
	surfClassFlags = D3DX_SC_DEPTHBUFFER | D3DX_SC_STENCILBUFFER;
	nDepthStencilFormats = D3DXGetMaxSurfaceFormats(dwDeviceIndex, NULL, surfClassFlags);

	// Work out how many formats we have in total
	if ((nDepthOnlyFormats + nDepthStencilFormats) == 0)
		return FALSE; // Bail: no compliant pixelformats

	// Get depth buffer formats WITHOUT stencil
	surfClassFlags = D3DX_SC_DEPTHBUFFER;
	for (i=0; i<nDepthOnlyFormats; i++) {
		D3DXGetSurfaceFormat(dwDeviceIndex, NULL, surfClassFlags, i, &fmt[nSupportedFormats++]);
	}
	// NOTE: For some reason we already get stencil formats when only specifying D3DX_SC_DEPTHBUFFER
	/*
		// Get depth buffer formats WITH stencil
		surfClassFlags = D3DX_SC_DEPTHBUFFER | D3DX_SC_STENCILBUFFER;
		for (i=0; i<nDepthStencilFormats; i++) {
			D3DXGetSurfaceFormat(dwDeviceIndex, NULL, surfClassFlags, i, &fmt[nSupportedFormats++]);
		}
	*/
#endif

	// Total count of pixelformats is:
	// (nSupportedFormats+1)*2
	glb.lpPF = (DGL_pixelFormat *)calloc((nSupportedFormats)*2, sizeof(DGL_pixelFormat));
	glb.nPixelFormatCount = (nSupportedFormats)*2;
	if (glb.lpPF == NULL) {
		glb.nPixelFormatCount = 0;
		return FALSE;
	}

	// Get a copy of pointer that we can alter
	pPF = glb.lpPF;

	// Cache colour bits from display format
//	_BitsFromDisplayFormat(d3ddm.Format, &cColorBits, &cRedBits, &cGreenBits, &cBlueBits, &cAlphaBits);
	// Get display mode
	D3DXGetCurrentVideoMode(D3DX_DEFAULT, &d3ddm);
	cColorBits = d3ddm.bpp;
	cAlphaBits = 0;
	switch (d3ddm.bpp) {
	case 15:
		cRedBits = 5; cGreenBits = 5; cBlueBits = 5;
		break;
	case 16:
		cRedBits = 5; cGreenBits = 6; cBlueBits = 5;
		break;
	case 24:
	case 32:
		cRedBits = 8; cGreenBits = 8; cBlueBits = 8;
		break;
	default:
		cRedBits = 5; cGreenBits = 5; cBlueBits = 5;
	}

	//
	// Add single-buffer formats
	//

/*	// Single-buffer, no depth-stencil buffer
	memcpy(pPF, &pfTemplateHW, sizeof(DGL_pixelFormat));
	pPF->pfd.dwFlags &= ~PFD_DOUBLEBUFFER; // Remove doublebuffer flag
	pPF->pfd.cColorBits		= cColorBits;
	pPF->pfd.cRedBits		= cRedBits;
	pPF->pfd.cGreenBits		= cGreenBits;
	pPF->pfd.cBlueBits		= cBlueBits;
	pPF->pfd.cAlphaBits		= cAlphaBits;
	pPF->pfd.cDepthBits		= 0;
	pPF->pfd.cStencilBits	= 0;
	pPF->dwDriverData		= D3DX_SF_UNKNOWN;
	pPF++;*/

	for (i=0; i<nSupportedFormats; i++, pPF++) {
		memcpy(pPF, &pfTemplateHW, sizeof(DGL_pixelFormat));
		pPF->pfd.dwFlags &= ~PFD_DOUBLEBUFFER; // Remove doublebuffer flag
		pPF->pfd.cColorBits		= cColorBits;
		pPF->pfd.cRedBits		= cRedBits;
		pPF->pfd.cGreenBits		= cGreenBits;
		pPF->pfd.cBlueBits		= cBlueBits;
		pPF->pfd.cAlphaBits		= cAlphaBits;
		_BitsFromDepthStencilFormat(fmt[i], &pPF->pfd.cDepthBits, &pPF->pfd.cStencilBits);
		pPF->dwDriverData		= fmt[i];
	}

	//
	// Add double-buffer formats
	//

/*	memcpy(pPF, &pfTemplateHW, sizeof(DGL_pixelFormat));
	pPF->pfd.cColorBits		= cColorBits;
	pPF->pfd.cRedBits		= cRedBits;
	pPF->pfd.cGreenBits		= cGreenBits;
	pPF->pfd.cBlueBits		= cBlueBits;
	pPF->pfd.cAlphaBits		= cAlphaBits;
	pPF->pfd.cDepthBits		= 0;
	pPF->pfd.cStencilBits	= 0;
	pPF->dwDriverData		= D3DX_SF_UNKNOWN;
	pPF++;*/

	for (i=0; i<nSupportedFormats; i++, pPF++) {
		memcpy(pPF, &pfTemplateHW, sizeof(DGL_pixelFormat));
		pPF->pfd.cColorBits		= cColorBits;
		pPF->pfd.cRedBits		= cRedBits;
		pPF->pfd.cGreenBits		= cGreenBits;
		pPF->pfd.cBlueBits		= cBlueBits;
		pPF->pfd.cAlphaBits		= cAlphaBits;
		_BitsFromDepthStencilFormat(fmt[i], &pPF->pfd.cDepthBits, &pPF->pfd.cStencilBits);
		pPF->dwDriverData		= fmt[i];
	}

	// Popup warning message if non RGB color mode
	{
		// This is a hack. KeithH
		HDC hdcDesktop = GetDC(NULL);
		DWORD dwDisplayBitDepth = GetDeviceCaps(hdcDesktop, BITSPIXEL);
		ReleaseDC(0, hdcDesktop);
		if (dwDisplayBitDepth <= 8) {
			ddlogPrintf(DDLOG_WARN, "Current Color Depth %d bpp is not supported", dwDisplayBitDepth);
			MessageBox(NULL, szColorDepthWarning, "GLDirect", MB_OK | MB_ICONWARNING);
		}
	}

	// Mark list as 'current'
	glb.bPixelformatsDirty = FALSE;

	return TRUE;
}

//---------------------------------------------------------------------------

BOOL gldInitialiseMesa_DX(
	DGL_ctx *lpCtx)
{
	GLD_driver_dx7	*gld = NULL;
	int				MaxTextureSize, TextureLevels;
	BOOL			bSoftwareTnL;

	if (lpCtx == NULL)
		return FALSE;

	gld = lpCtx->glPriv;
	if (gld == NULL)
		return FALSE;

	if (glb.bMultitexture) {
		lpCtx->glCtx->Const.MaxTextureUnits = gld->d3dCaps.wMaxSimultaneousTextures;
		// Only support MAX_TEXTURE_UNITS texture units.
		// ** If this is altered then the FVF formats must be reviewed **.
		if (lpCtx->glCtx->Const.MaxTextureUnits > GLD_MAX_TEXTURE_UNITS_DX7)
			lpCtx->glCtx->Const.MaxTextureUnits = GLD_MAX_TEXTURE_UNITS_DX7;
	} else {
		// Multitexture override
		lpCtx->glCtx->Const.MaxTextureUnits = 1;
	}

	lpCtx->glCtx->Const.MaxDrawBuffers = 1;

	// max texture size
//	MaxTextureSize = min(gld->d3dCaps8.MaxTextureHeight, gld->d3dCaps8.MaxTextureWidth);
	MaxTextureSize = min(gld->d3dCaps.dwMaxTextureHeight, gld->d3dCaps.dwMaxTextureWidth);
	if (MaxTextureSize == 0)
		MaxTextureSize = 256; // Sanity check

	//
	// HACK!!
	if (MaxTextureSize > 1024)
		MaxTextureSize = 1024; // HACK - CLAMP TO 1024
	// HACK!!
	//

	// TODO: Check this again for Mesa 5
	// Got to set MAX_TEXTURE_SIZE as max levels.
	// Who thought this stupid idea up? ;)
	TextureLevels = 0;
	// Calculate power-of-two.
	while (MaxTextureSize) {
		TextureLevels++;
		MaxTextureSize >>= 1;
	}
	lpCtx->glCtx->Const.MaxTextureLevels = (TextureLevels) ? TextureLevels : 8;

	// Defaults
	IDirect3DDevice7_SetRenderState(gld->pDev, D3DRENDERSTATE_LIGHTING, FALSE);
	IDirect3DDevice7_SetRenderState(gld->pDev, D3DRENDERSTATE_CULLMODE, D3DCULL_NONE);
	IDirect3DDevice7_SetRenderState(gld->pDev, D3DRENDERSTATE_DITHERENABLE, TRUE);
	IDirect3DDevice7_SetRenderState(gld->pDev, D3DRENDERSTATE_SHADEMODE, D3DSHADE_GOURAUD);

	// Set texture coord set to be used with each stage
	IDirect3DDevice7_SetTextureStageState(gld->pDev, 0, D3DTSS_TEXCOORDINDEX, 0);
	IDirect3DDevice7_SetTextureStageState(gld->pDev, 1, D3DTSS_TEXCOORDINDEX, 1);

	// Set up Depth buffer
	IDirect3DDevice7_SetRenderState(gld->pDev, D3DRENDERSTATE_ZENABLE,
		(lpCtx->lpPF->dwDriverData!=D3DX_SF_UNKNOWN) ? D3DZB_TRUE : D3DZB_FALSE);

	// Set the view matrix
	{
		D3DXMATRIX	vm;
#if 1
		D3DXMatrixIdentity(&vm);
#else
		D3DXVECTOR3 Eye(0.0f, 0.0f, 0.0f);
		D3DXVECTOR3 At(0.0f, 0.0f, -1.0f);
		D3DXVECTOR3 Up(0.0f, 1.0f, 0.0f);
		D3DXMatrixLookAtRH(&vm, &Eye, &At, &Up);
		vm._31 = -vm._31;
		vm._32 = -vm._32;
		vm._33 = -vm._33;
		vm._34 = -vm._34;
#endif
		IDirect3DDevice7_SetTransform(gld->pDev, D3DTRANSFORMSTATE_VIEW, &vm);
	}

// DX7 does not support D3DRS_SOFTWAREVERTEXPROCESSING
/*
	if (gld->bHasHWTnL) {
		if (glb.dwTnL == GLDS_TNL_DEFAULT)
			bSoftwareTnL = FALSE; // HW TnL
		else {
			bSoftwareTnL = ((glb.dwTnL == GLDS_TNL_MESA) || (glb.dwTnL == GLDS_TNL_D3DSW)) ? TRUE : FALSE;
		}
	} else {
		// No HW TnL, so no choice possible
		bSoftwareTnL = TRUE;
	}
	IDirect3DDevice8_SetRenderState(gld->pDev, D3DRS_SOFTWAREVERTEXPROCESSING, bSoftwareTnL);
*/

// Dump this in a Release build as well, now.
//#ifdef _DEBUG
	ddlogPrintf(DDLOG_INFO, "HW TnL: %s",
//		gld->bHasHWTnL ? (bSoftwareTnL ? "Disabled" : "Enabled") : "Unavailable");
		gld->bHasHWTnL ? "Enabled" : "Unavailable");
//#endif

	// Set up interfaces to Mesa
	gldEnableExtensions_DX7(lpCtx->glCtx);
	gldInstallPipeline_DX7(lpCtx->glCtx);
	gldSetupDriverPointers_DX7(lpCtx->glCtx);

	// Signal a complete state update
	lpCtx->glCtx->Driver.UpdateState(lpCtx->glCtx, _NEW_ALL);

	// Start a scene
	IDirect3DDevice7_BeginScene(gld->pDev);
	lpCtx->bSceneStarted = TRUE;

	return TRUE;
}

//---------------------------------------------------------------------------

BOOL gldSwapBuffers_DX(
	DGL_ctx *ctx,
	HDC hDC,
	HWND hWnd)
{
	HRESULT			hr;
	GLD_driver_dx7	*gld = NULL;
	DWORD			dwFlags;

	if (ctx == NULL)
		return FALSE;

	gld = ctx->glPriv;
	if (gld == NULL)
		return FALSE;


	// End the scene if one is started
	if (ctx->bSceneStarted) {
		IDirect3DDevice7_EndScene(gld->pDev);
		ctx->bSceneStarted = FALSE;
	}

	// Needed by D3DX for MDI multi-window apps (DaveM)
	if (lpDDClipper)
		IDirectDrawClipper_SetHWnd(lpDDClipper, 0, hWnd);

	// Swap the buffers. hWnd may override the hWnd used for CreateDevice()
//	hr = IDirect3DDevice8_Present(gld->pDev, NULL, NULL, hWnd, NULL);

	// Set refresh sync flag
	dwFlags = glb.bWaitForRetrace ? 0 : D3DX_UPDATE_NOVSYNC;
	// Render and show frame
	hr = gld->pD3DXContext->lpVtbl->UpdateFrame(gld->pD3DXContext, dwFlags);
	if (FAILED(hr)) 
		ddlogError(DDLOG_WARN, "gldSwapBuffers_DX: UpdateFrame", hr);

	if (hr == DDERR_SURFACELOST) {
	hr = gld->pD3DXContext->lpVtbl->RestoreSurfaces(gld->pD3DXContext);
	if (FAILED(hr)) 
		ddlogError(DDLOG_WARN, "gldSwapBuffers_DX: RestoreSurfaces", hr);
	}

exit_swap:
	// Begin a new scene
	IDirect3DDevice7_BeginScene(gld->pDev);
	ctx->bSceneStarted = TRUE;

	return (FAILED(hr)) ? FALSE : TRUE;
}

//---------------------------------------------------------------------------

BOOL gldGetDisplayMode_DX(
	DGL_ctx *ctx,
	GLD_displayMode *glddm)
{
//	D3DDISPLAYMODE		d3ddm;
	D3DX_VIDMODEDESC	d3ddm;
	HRESULT				hr;
	GLD_driver_dx7		*lpCtx = NULL;
	BYTE cColorBits, cRedBits, cGreenBits, cBlueBits, cAlphaBits;

	if ((glddm == NULL) || (ctx == NULL))
		return FALSE;

	lpCtx = ctx->glPriv;
	if (lpCtx == NULL)
		return FALSE;

	if (lpCtx->pD3D == NULL)
		return FALSE;

//	hr = IDirect3D8_GetAdapterDisplayMode(lpCtx->pD3D, glb.dwAdapter, &d3ddm);
	hr = D3DXGetCurrentVideoMode(D3DX_DEFAULT, &d3ddm);
	if (FAILED(hr))
		return FALSE;

	// Get info from the display format
//	_BitsFromDisplayFormat(d3ddm.Format,
//		&cColorBits, &cRedBits, &cGreenBits, &cBlueBits, &cAlphaBits);

	glddm->Width	= d3ddm.width;
	glddm->Height	= d3ddm.height;
	glddm->BPP		= d3ddm.bpp;
	glddm->Refresh	= d3ddm.refreshRate;

	return TRUE;
}

//---------------------------------------------------------------------------

