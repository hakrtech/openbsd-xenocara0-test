/* $OpenBSD: wsfb_driver.c,v 1.7 2006/12/08 21:57:37 matthieu Exp $ */
/*
 * Copyright (c) 2001 Matthieu Herrb
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above
 *      copyright notice, this list of conditions and the following
 *      disclaimer in the documentation and/or other materials provided
 *      with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

/*
 * Based on fbdev.c written by:
 *
 * Authors:  Alan Hourihane, <alanh@fairlite.demon.co.uk>
 *	     Michel Dänzer, <michdaen@iiic.ethz.ch>
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <fcntl.h>
#include <sys/types.h>
#include <sys/time.h>
#include <dev/wscons/wsconsio.h>

/* all driver need this */
#include "xf86.h"
#include "xf86_OSproc.h"
#include "xf86_ansic.h"

#include "mipointer.h"
#include "mibstore.h"
#include "micmap.h"
#include "colormapst.h"
#include "xf86cmap.h"
#include "shadow.h"
#include "dgaproc.h"

/* for visuals */
#include "xf1bpp.h"
#include "xf4bpp.h"
#include "fb.h"

#include "xf86Resources.h"
#include "xf86RAC.h"

#ifdef XvExtension
#include "xf86xv.h"
#endif

/* #include "wsconsio.h" */

#ifndef XFree86LOADER
#include <sys/mman.h>
#endif

#ifdef X_PRIVSEP
extern int priv_open_device(const char *);
#else
#define priv_open_device(n)    open(n,O_RDWR|O_NONBLOCK|O_EXCL)
#endif

#if defined(__NetBSD__)
#define WSFB_DEFAULT_DEV "/dev/ttyE0"
#else
#define WSFB_DEFAULT_DEV "/dev/ttyC0"
#endif

#define DEBUG 0

#if DEBUG
# define TRACE_ENTER(str)       ErrorF("wsfb: " str " %d\n",pScrn->scrnIndex)
# define TRACE_EXIT(str)        ErrorF("wsfb: " str " done\n")
# define TRACE(str)             ErrorF("wsfb trace: " str "\n")
#else
# define TRACE_ENTER(str)
# define TRACE_EXIT(str)
# define TRACE(str)
#endif

/* Prototypes */
#ifdef XFree86LOADER
static pointer WsfbSetup(pointer, pointer, int *, int *);
#endif
static Bool WsfbGetRec(ScrnInfoPtr);
static void WsfbFreeRec(ScrnInfoPtr);
static const OptionInfoRec * WsfbAvailableOptions(int, int);
static void WsfbIdentify(int);
static Bool WsfbProbe(DriverPtr, int);
static Bool WsfbPreInit(ScrnInfoPtr, int);
static Bool WsfbScreenInit(int, ScreenPtr, int, char **);
static Bool WsfbCloseScreen(int, ScreenPtr);
static void *WsfbWindowLinear(ScreenPtr, CARD32, CARD32, int, CARD32 *,
			      void *);
static void WsfbPointerMoved(int, int, int);
static Bool WsfbEnterVT(int, int);
static void WsfbLeaveVT(int, int);
static Bool WsfbSwitchMode(int, DisplayModePtr, int);
static int WsfbValidMode(int, DisplayModePtr, Bool, int);
static void WsfbLoadPalette(ScrnInfoPtr, int, int *, LOCO *, VisualPtr);
static Bool WsfbSaveScreen(ScreenPtr, int);
static void WsfbSave(ScrnInfoPtr);
static void WsfbRestore(ScrnInfoPtr);

/* dga stuff */
#ifdef XFreeXDGA
static Bool WsfbDGAOpenFramebuffer(ScrnInfoPtr, char **, unsigned char **,
				   int *, int *, int *);
static Bool WsfbDGASetMode(ScrnInfoPtr, DGAModePtr);
static void WsfbDGASetViewport(ScrnInfoPtr, int, int, int);
static Bool WsfbDGAInit(ScrnInfoPtr, ScreenPtr);
#endif
static Bool WsfbDriverFunc(ScrnInfoPtr pScrn, xorgDriverFuncOp op,
				pointer ptr);

/* helper functions */
static int wsfb_open(char *);
static pointer wsfb_mmap(size_t, off_t, int);

enum { WSFB_ROTATE_NONE = 0,
       WSFB_ROTATE_CCW = 90,
       WSFB_ROTATE_UD = 180,
       WSFB_ROTATE_CW = 270
};

/*
 * This is intentionally screen-independent.  It indicates the binding
 * choice made in the first PreInit.
 */
static int pix24bpp = 0;

#define WSFB_VERSION 		4000
#define WSFB_NAME		"wsfb"
#define WSFB_DRIVER_NAME	"wsfb"
#define WSFB_MAJOR_VERSION	0
#define WSFB_MINOR_VERSION	2

_X_EXPORT DriverRec WSFB = {
	WSFB_VERSION,
	WSFB_DRIVER_NAME,
	WsfbIdentify,
	WsfbProbe,
	WsfbAvailableOptions,
	NULL,
	0,
	WsfbDriverFunc
};

/* Supported "chipsets" */
static SymTabRec WsfbChipsets[] = {
	{ 0, "wsfb" },
	{ -1, NULL }
};

/* Supported options */
typedef enum {
	OPTION_SHADOW_FB,
	OPTION_ROTATE
} WsfbOpts;

static const OptionInfoRec WsfbOptions[] = {
	{ OPTION_SHADOW_FB, "ShadowFB", OPTV_BOOLEAN, {0}, FALSE},
	{ OPTION_ROTATE, "Rotate", OPTV_STRING, {0}, FALSE},
	{ -1, NULL, OPTV_NONE, {0}, FALSE}
};

/* Symbols needed from other modules */
static const char *fbSymbols[] = {
	"fbPictureInit",
	"fbScreenInit",
	NULL
};
static const char *shadowSymbols[] = {
	"shadowAdd",
	"shadowSetup",
	"shadowUpdatePacked",
	"shadowUpdatePackedWeak",
	"shadowUpdateRotatePacked",
	"shadowUpdateRotatePackedWeak",
	NULL
};

#ifdef XFree86LOADER
static XF86ModuleVersionInfo WsfbVersRec = {
	"wsfb",
	MODULEVENDORSTRING,
	MODINFOSTRING1,
	MODINFOSTRING2,
	XORG_VERSION_CURRENT,
	WSFB_MAJOR_VERSION, WSFB_MINOR_VERSION, 0,
	ABI_CLASS_VIDEODRV,
	ABI_VIDEODRV_VERSION,
	NULL,
	{0, 0, 0, 0}
};

_X_EXPORT XF86ModuleData wsfbModuleData = { &WsfbVersRec, WsfbSetup, NULL };

static pointer
WsfbSetup(pointer module, pointer opts, int *errmaj, int *errmin)
{
	static Bool setupDone = FALSE;
	const char *osname;

	/* Check that we're being loaded on a OpenBSD or NetBSD system */
	LoaderGetOS(&osname, NULL, NULL, NULL);
	if (!osname || (strcmp(osname, "openbsd") != 0 &&
	                strcmp(osname, "netbsd") != 0)) {
		if (errmaj)
			*errmaj = LDR_BADOS;
		if (errmin)
			*errmin = 0;
		return NULL;
	}
	if (!setupDone) {
		setupDone = TRUE;
		xf86AddDriver(&WSFB, module, HaveDriverFuncs);
		LoaderRefSymLists(fbSymbols, shadowSymbols, NULL);
		return (pointer)1;
	} else {
		if (errmaj != NULL)
			*errmaj = LDR_ONCEONLY;
		return NULL;
	}
}
#endif /* XFree86LOADER */

/* private data */
typedef struct {
	int			fd; /* file descriptor of open device */
	struct wsdisplay_fbinfo info; /* frame buffer characteristics */
	int			linebytes; /* number of bytes per row */
	unsigned char*		fbstart;
	unsigned char*		fbmem;
	size_t			fbmem_len;
	int			rotate;
	Bool			shadowFB;
	CloseScreenProcPtr	CloseScreen;
	void			(*PointerMoved)(int, int, int);
	EntityInfoPtr		pEnt;
	struct wsdisplay_cmap	saved_cmap;

#ifdef XFreeXDGA
	/* DGA info */
	DGAModePtr		pDGAMode;
	int			nDGAMode;
#endif
	OptionInfoPtr		Options;
} WsfbRec, *WsfbPtr;

#define WSFBPTR(p) ((WsfbPtr)((p)->driverPrivate))

static Bool
WsfbGetRec(ScrnInfoPtr pScrn)
{

	if (pScrn->driverPrivate != NULL)
		return TRUE;

	pScrn->driverPrivate = xnfcalloc(sizeof(WsfbRec), 1);
	return TRUE;
}

static void
WsfbFreeRec(ScrnInfoPtr pScrn)
{

	if (pScrn->driverPrivate == NULL)
		return;
	xfree(pScrn->driverPrivate);
	pScrn->driverPrivate = NULL;
}

static const OptionInfoRec *
WsfbAvailableOptions(int chipid, int busid)
{
	return WsfbOptions;
}

static void
WsfbIdentify(int flags)
{
	xf86PrintChipsets(WSFB_NAME, "driver for wsdisplay framebuffer",
			  WsfbChipsets);
}

/* Open the framebuffer device */
static int
wsfb_open(char *dev)
{
	int fd = -1;

	/* try argument from XF86Config first */
	if (dev == NULL || ((fd = priv_open_device(dev)) == -1)) {
		/* second: environment variable */
		dev = getenv("XDEVICE");
		if (dev == NULL || ((fd = priv_open_device(dev)) == -1)) {
			/* last try: default device */
			dev = WSFB_DEFAULT_DEV;
			if ((fd = priv_open_device(dev)) == -1) {
				return -1;
			}
		}
	}
	return fd;
}

/* Map the framebuffer's memory */
static pointer
wsfb_mmap(size_t len, off_t off, int fd)
{
	int pagemask, mapsize;
	caddr_t addr;
	pointer mapaddr;

	pagemask = getpagesize() - 1;
	mapsize = ((int) len + pagemask) & ~pagemask;
	addr = 0;

	/*
	 * try and make it private first, that way once we get it, an
	 * interloper, e.g. another server, can't get this frame buffer,
	 * and if another server already has it, this one won't.
	 */
	mapaddr = (pointer) mmap(addr, mapsize,
				 PROT_READ | PROT_WRITE, MAP_SHARED,
				 fd, off);
	if (mapaddr == (pointer) -1) {
		mapaddr = NULL;
	}
#if DEBUG
	ErrorF("mmap returns: addr %p len 0x%x\n", mapaddr, mapsize);
#endif
	return mapaddr;
}

static Bool
WsfbProbe(DriverPtr drv, int flags)
{
	int i, fd, entity;
       	GDevPtr *devSections;
	int numDevSections;
	char *dev;
	Bool foundScreen = FALSE;

	TRACE("probe start");

	/* For now, just bail out for PROBE_DETECT. */
	if (flags & PROBE_DETECT)
		return FALSE;

	if ((numDevSections = xf86MatchDevice(WSFB_DRIVER_NAME,
					      &devSections)) <= 0)
		return FALSE;

	for (i = 0; i < numDevSections; i++) {
		ScrnInfoPtr pScrn = NULL;

		dev = xf86FindOptionValue(devSections[i]->options, "device");
		if ((fd = wsfb_open(dev)) >= 0) {
			entity = xf86ClaimFbSlot(drv, 0, devSections[i], TRUE);
			pScrn = xf86ConfigFbEntity(NULL,0,entity,
						   NULL,NULL,NULL,NULL);
			if (pScrn != NULL) {
				foundScreen = TRUE;
				pScrn->driverVersion = WSFB_VERSION;
				pScrn->driverName = WSFB_DRIVER_NAME;
				pScrn->name = WSFB_NAME;
				pScrn->Probe = WsfbProbe;
				pScrn->PreInit = WsfbPreInit;
				pScrn->ScreenInit = WsfbScreenInit;
				pScrn->SwitchMode = WsfbSwitchMode;
				pScrn->AdjustFrame = NULL;
				pScrn->EnterVT = WsfbEnterVT;
				pScrn->LeaveVT = WsfbLeaveVT;
				pScrn->ValidMode = WsfbValidMode;

				xf86DrvMsg(pScrn->scrnIndex, X_INFO,
				    "using %s\n", dev != NULL ? dev :
				    "default device");
			}
		}
	}
	xfree(devSections);
	TRACE("probe done");
	return foundScreen;
}

static Bool
WsfbPreInit(ScrnInfoPtr pScrn, int flags)
{
	WsfbPtr fPtr;
	int defaultDepth, depths, flags24, wstype;
	char *dev, *s;
	char *mod = NULL;
	const char *reqSym = NULL;
	Gamma zeros = {0.0, 0.0, 0.0};
	DisplayModePtr mode;

	if (flags & PROBE_DETECT) return FALSE;

	TRACE_ENTER("PreInit");

	if (pScrn->numEntities != 1) return FALSE;

	pScrn->monitor = pScrn->confScreen->monitor;

	WsfbGetRec(pScrn);
	fPtr = WSFBPTR(pScrn);

	fPtr->pEnt = xf86GetEntityInfo(pScrn->entityList[0]);

	pScrn->racMemFlags = RAC_FB | RAC_COLORMAP | RAC_CURSOR | RAC_VIEWPORT;
	pScrn->racIoFlags = pScrn->racMemFlags;

	dev = xf86FindOptionValue(fPtr->pEnt->device->options, "device");
	fPtr->fd = wsfb_open(dev);
	if (fPtr->fd == -1) {
		return FALSE;
	}
	if (ioctl(fPtr->fd, WSDISPLAYIO_GTYPE, &wstype) == -1) {
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			   "ioctl WSDISPLAY_GTYPE: %s\n",
			   strerror(errno));
		return FALSE;
	}
	/*
	 * depth
	 */
	defaultDepth = 0;
	if (ioctl(fPtr->fd, WSDISPLAYIO_GETSUPPORTEDDEPTH, 
		&depths) == 0) {
		/* Preferred order for default depth selection. */
		if (depths & WSDISPLAYIO_DEPTH_16)
			defaultDepth = 16;
		else if (depths & WSDISPLAYIO_DEPTH_15)
			defaultDepth = 15;
		else if (depths & WSDISPLAYIO_DEPTH_8)
			defaultDepth = 8;
		else if (depths & WSDISPLAYIO_DEPTH_24)
			defaultDepth = 24;
		else if (depths & WSDISPLAYIO_DEPTH_4)
			defaultDepth = 4;
		else if (depths & WSDISPLAYIO_DEPTH_1)
			defaultDepth = 1;
		
		flags24 = 0;
		if (depths & WSDISPLAYIO_DEPTH_24_24)
			flags24 |= Support24bppFb;
		if (depths & WSDISPLAYIO_DEPTH_24_32)
			flags24 |= Support32bppFb;
		if (!flags24)
			flags24 = Support24bppFb;
	} else {
		/* Old way */
		if (ioctl(fPtr->fd, WSDISPLAYIO_GINFO, &fPtr->info) == -1) {
			xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			    "no way to get depth info: %s\n",
			    strerror(errno));
			return FALSE;
		}
		if (fPtr->info.depth == 8) {
			/*
			 * We might run on a byte addressable frame buffer,
			 * but with less than 8 bits per pixel. 
			 * We can know this from the colormap size.
			 */
			defaultDepth = 1;
			while ((1 << defaultDepth) < fPtr->info.cmsize)
				defaultDepth++;
		} else
			defaultDepth = 
			    fPtr->info.depth <= 24 ? fPtr->info.depth : 24;

		if (fPtr->info.depth >= 24)
			flags24 = Support24bppFb|Support32bppFb;
		else 
			flags24 = 0;
	}

	/* Prefer 24bpp for fb since it potentially allows larger modes. */
	if (flags24 & Support24bppFb)
		flags24 |= SupportConvert32to24 | PreferConvert32to24;
	
	if (!xf86SetDepthBpp(pScrn, defaultDepth, 0, 0, flags24))
		return FALSE;

	if (wstype == WSDISPLAY_TYPE_PCIVGA) {
		/* Set specified mode */
		if (pScrn->display->modes != NULL &&
		    pScrn->display->modes[0] != NULL) {
			struct wsdisplay_gfx_mode gfxmode;
			
			if (sscanf(pScrn->display->modes[0], "%dx%d", 
				&gfxmode.width, &gfxmode.height) != 2) {
				xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
				    "Can't parse mode name %s\n", 
				    pScrn->display->modes[0]);
				return FALSE;
			}
			gfxmode.depth = pScrn->bitsPerPixel;
			if (ioctl(fPtr->fd, WSDISPLAYIO_SETGFXMODE, 
				&gfxmode) == -1) {
				xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
				    "ioctl WSDISPLAY_SETGFXMODE: %s\n", 
				    strerror(errno));
				return FALSE;
			}
		}
	}
	if (ioctl(fPtr->fd, WSDISPLAYIO_GINFO, &fPtr->info) == -1) {
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
		    "ioctl WSDISPLAY_GINFO: %s\n",
		    strerror(errno));
		return FALSE;
	}
	if (ioctl(fPtr->fd, WSDISPLAYIO_LINEBYTES, &fPtr->linebytes) == -1) {
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			   "ioctl WSDISPLAYIO_LINEBYTES: %s\n",
			   strerror(errno));
		return FALSE;
	}
	/*
	 * Allocate room for saving the colormap 
	 */
	if (fPtr->info.cmsize != 0) {
		fPtr->saved_cmap.red =
		    (unsigned char *)xalloc(fPtr->info.cmsize);
		if (fPtr->saved_cmap.red == NULL) {
			xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			    "Cannot malloc %d bytes\n", fPtr->info.cmsize);
			return FALSE;
		}
		fPtr->saved_cmap.green =
		    (unsigned char *)xalloc(fPtr->info.cmsize);
		if (fPtr->saved_cmap.green == NULL) {
			xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			    "Cannot malloc %d bytes\n", fPtr->info.cmsize);
			xfree(fPtr->saved_cmap.red);
			return FALSE;
		}
		fPtr->saved_cmap.blue =
		    (unsigned char *)xalloc(fPtr->info.cmsize);
		if (fPtr->saved_cmap.blue == NULL) {
			xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			    "Cannot malloc %d bytes\n", fPtr->info.cmsize);
			xfree(fPtr->saved_cmap.red);
			xfree(fPtr->saved_cmap.green);
			return FALSE;
		}
	}


	/* Check consistency */
	if (pScrn->bitsPerPixel != fPtr->info.depth) {
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
		    "specified depth (%d) or bpp (%d) doesn't match "
		    "framebuffer depth (%d)\n", pScrn->depth, 
		    pScrn->bitsPerPixel, fPtr->info.depth);
		return FALSE;
	}
	xf86PrintDepthBpp(pScrn);

	/* Get the depth24 pixmap format */
	if (pScrn->depth == 24 && pix24bpp == 0)
		pix24bpp = xf86GetBppFromDepth(pScrn, 24);

	/* color weight */
	if (pScrn->depth > 8) {
		rgb zeros = { 0, 0, 0 }, masks;

		switch (wstype) {
		case WSDISPLAY_TYPE_SUN24:
		case WSDISPLAY_TYPE_SUNCG12:
		case WSDISPLAY_TYPE_SUNCG14:
		case WSDISPLAY_TYPE_SUNTCX:
		case WSDISPLAY_TYPE_SUNFFB:
		case WSDISPLAY_TYPE_AGTEN:
		case WSDISPLAY_TYPE_XVIDEO:
		case WSDISPLAY_TYPE_SUNLEO:
			masks.red = 0x0000ff;
			masks.green = 0x00ff00;
			masks.blue = 0xff0000;
			break;
		case WSDISPLAY_TYPE_PXALCD:
			masks.red = 0x1f << 11;
			masks.green = 0x3f << 5;
			masks.blue = 0x1f;
			break;
		case WSDISPLAY_TYPE_MAC68K:
			if (pScrn->depth > 16) {
				masks.red = 0x0000ff;
				masks.green = 0x00ff00;
				masks.blue = 0xff0000;
			} else {
				masks.red = 0x1f << 11;
				masks.green = 0x3f << 5;
				masks.blue = 0x1f;
			}
			break;
		case WSDISPLAY_TYPE_PCIVGA:
			if (pScrn->depth > 16) {
				masks.red = 0xff0000;
				masks.green = 0x00ff00;
				masks.blue = 0x0000ff;
			} else {
				masks.red = 0x1f << 11;
				masks.green = 0x3f << 5;
				masks.blue = 0x1f;
			}
			break;
		default:
			masks.red = 0;
			masks.green = 0;
			masks.blue = 0;
			break;
		}

		if (!xf86SetWeight(pScrn, zeros, masks))
			return FALSE;
	}

	/* visual init */
	if (!xf86SetDefaultVisual(pScrn, -1))
		return FALSE;

	/* We don't currently support DirectColor at > 8bpp */
	if (pScrn->depth > 8 && pScrn->defaultVisual != TrueColor) {
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR, "Given default visual"
			   " (%s) is not supported at depth %d\n",
			   xf86GetVisualName(pScrn->defaultVisual),
			   pScrn->depth);
		return FALSE;
	}

	xf86SetGamma(pScrn,zeros);

	pScrn->progClock = TRUE;
	if (pScrn->depth == 8)
		pScrn->rgbBits = 6;
	else 
		pScrn->rgbBits   = 8;
	pScrn->chipset   = "wsfb";
	pScrn->videoRam  = fPtr->linebytes * fPtr->info.height;

	xf86DrvMsg(pScrn->scrnIndex, X_INFO, "Vidmem: %dk\n",
		   pScrn->videoRam/1024);

	/* handle options */
	xf86CollectOptions(pScrn, NULL);
	if (!(fPtr->Options = xalloc(sizeof(WsfbOptions))))
		return FALSE;
	memcpy(fPtr->Options, WsfbOptions, sizeof(WsfbOptions));
	xf86ProcessOptions(pScrn->scrnIndex, fPtr->pEnt->device->options,
			   fPtr->Options);

	/* use shadow framebuffer by default, on depth >= 8 */
	if (pScrn->depth >= 8)
		fPtr->shadowFB = xf86ReturnOptValBool(fPtr->Options,
						      OPTION_SHADOW_FB, TRUE);
	else
		if (xf86ReturnOptValBool(fPtr->Options,
					 OPTION_SHADOW_FB, FALSE)) {
			xf86DrvMsg(pScrn->scrnIndex, X_WARNING,
				   "Shadow FB option ignored on depth < 8");
		}

	/* rotation */
	fPtr->rotate = WSFB_ROTATE_NONE;
	if ((s = xf86GetOptValString(fPtr->Options, OPTION_ROTATE))) {
		if (pScrn->depth >= 8) {
			if (!xf86NameCmp(s, "CW")) {
				fPtr->shadowFB = TRUE;
				fPtr->rotate = WSFB_ROTATE_CW;
				xf86DrvMsg(pScrn->scrnIndex, X_CONFIG,
				    "Rotating screen clockwise\n");
			} else if (!xf86NameCmp(s, "CCW")) {
				fPtr->shadowFB = TRUE;
				fPtr->rotate = WSFB_ROTATE_CCW;
				xf86DrvMsg(pScrn->scrnIndex, X_CONFIG,
				    "Rotating screen counter clockwise\n");
			} else if (!xf86NameCmp(s, "UD")) {
				fPtr->shadowFB = TRUE;
				fPtr->rotate = WSFB_ROTATE_UD;
				xf86DrvMsg(pScrn->scrnIndex, X_CONFIG,
				    "Rotating screen upside down\n");
			} else {
				xf86DrvMsg(pScrn->scrnIndex, X_CONFIG,
				    "\"%s\" is not a valid value for Option "
				    "\"Rotate\"\n", s);
				xf86DrvMsg(pScrn->scrnIndex, X_INFO,
				    "Valid options are \"CW\", \"CCW\","
				    " or \"UD\"\n");
			}
		} else {
			xf86DrvMsg(pScrn->scrnIndex, X_WARNING,
			    "Option \"Rotate\" ignored on depth < 8");
		}
	}
	
	/* fake video mode struct */
	mode = (DisplayModePtr)xalloc(sizeof(DisplayModeRec));
	mode->prev = mode;
	mode->next = mode;
	mode->name = "wsfb current mode";
	mode->status = MODE_OK;
	mode->type = M_T_BUILTIN;
	mode->Clock = 0;
	mode->HDisplay = fPtr->info.width;
	mode->HSyncStart = 0;
	mode->HSyncEnd = 0;
	mode->HTotal = 0;
	mode->HSkew = 0;
	mode->VDisplay = fPtr->info.height;
	mode->VSyncStart = 0;
	mode->VSyncEnd = 0;
	mode->VTotal = 0;
	mode->VScan = 0;
	mode->Flags = 0;

	pScrn->currentMode = pScrn->modes = mode;
	pScrn->virtualX = fPtr->info.width;
	pScrn->virtualY = fPtr->info.height;
	pScrn->displayWidth = pScrn->virtualX;

	/* Set the display resolution */
	xf86SetDpi(pScrn, 0, 0);

	/* Load bpp-specific modules */
	switch(pScrn->bitsPerPixel) {
	case 1:
		mod = "xf1bpp";
		reqSym = "xf1bppScreenInit";
		break;
	case 4:
		mod = "xf4bpp";
		reqSym = "xf4bppScreenInit";
		break;
	default:
		mod = "fb";
		break;
	}


	/* Load shadow if needed */
	if (fPtr->shadowFB) {
		xf86DrvMsg(pScrn->scrnIndex, X_CONFIG,
			   "Using \"Shadow Framebuffer\"\n");
		if (xf86LoadSubModule(pScrn, "shadow") == NULL) {
			WsfbFreeRec(pScrn);
			return FALSE;
		}
		xf86LoaderReqSymLists(shadowSymbols, NULL);
	}
	if (mod && xf86LoadSubModule(pScrn, mod) == NULL) {
		WsfbFreeRec(pScrn);
		return FALSE;
	}
	if (mod) {
		if (reqSym) {
			xf86LoaderReqSymbols(reqSym, NULL);
		} else {
			xf86LoaderReqSymLists(fbSymbols, NULL);
		}
	}
	TRACE_EXIT("PreInit");
	return TRUE;
}

static Bool
WsfbScreenInit(int scrnIndex, ScreenPtr pScreen, int argc, char **argv)
{
	ScrnInfoPtr pScrn = xf86Screens[pScreen->myNum];
	WsfbPtr fPtr = WSFBPTR(pScrn);
	VisualPtr visual;
	int ret, flags, width, height, ncolors;
	int wsmode = WSDISPLAYIO_MODE_DUMBFB;
	size_t len;

	TRACE_ENTER("WsfbScreenInit");
#if DEBUG
	ErrorF("\tbitsPerPixel=%d, depth=%d, defaultVisual=%s\n"
	       "\tmask: %x,%x,%x, offset: %u,%u,%u\n",
	       pScrn->bitsPerPixel,
	       pScrn->depth,
	       xf86GetVisualName(pScrn->defaultVisual),
	       pScrn->mask.red,pScrn->mask.green,pScrn->mask.blue,
	       pScrn->offset.red,pScrn->offset.green,pScrn->offset.blue);
#endif
	switch (fPtr->info.depth) {
	case 1:
	case 4:
	case 8:
		len = fPtr->linebytes*fPtr->info.height;
		break;
	case 16:
		if (fPtr->linebytes == fPtr->info.width) {
			len = fPtr->info.width*fPtr->info.height*sizeof(short);
		} else {
			len = fPtr->linebytes*fPtr->info.height;
		}
		break;
	case 24:
		if (fPtr->linebytes == fPtr->info.width) {
			len = fPtr->info.width*fPtr->info.height*3;
		} else {
			len = fPtr->linebytes*fPtr->info.height;
		}
		break;
	case 32:
		if (fPtr->linebytes == fPtr->info.width) {
			len = fPtr->info.width*fPtr->info.height*sizeof(int);
		} else {
			len = fPtr->linebytes*fPtr->info.height;
		}
		break;
	default:
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			   "unsupported depth %d\n", fPtr->info.depth);
		return FALSE;
	}
	/* Switch to graphics mode - required before mmap */
	if (ioctl(fPtr->fd, WSDISPLAYIO_SMODE, &wsmode) == -1) {
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			   "ioctl WSDISPLAYIO_SMODE: %s\n",
			   strerror(errno));
		return FALSE;
	}
	fPtr->fbmem = wsfb_mmap(len, 0, fPtr->fd);

	if (fPtr->fbmem == NULL) {
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			   "wsfb_mmap: %s\n", strerror(errno));
		return FALSE;
	}
	fPtr->fbmem_len = len;

	WsfbSave(pScrn);
	pScrn->vtSema = TRUE;

	/* mi layer */
	miClearVisualTypes();
	if (pScrn->bitsPerPixel > 8) {
		if (!miSetVisualTypes(pScrn->depth, TrueColorMask,
				      pScrn->rgbBits, TrueColor))
			return FALSE;
	} else {
		if (!miSetVisualTypes(pScrn->depth,
				      miGetDefaultVisualMask(pScrn->depth),
				      pScrn->rgbBits, pScrn->defaultVisual))
			return FALSE;
	}
	if (!miSetPixmapDepths())
		return FALSE;

	if (fPtr->rotate == WSFB_ROTATE_CW 
	    || fPtr->rotate == WSFB_ROTATE_CCW) {
		height = pScrn->virtualX;
		width = pScrn->displayWidth = pScrn->virtualY;
	} else {
		height = pScrn->virtualY;
		width = pScrn->virtualX;
	}
	if (fPtr->rotate && !fPtr->PointerMoved) {
		fPtr->PointerMoved = pScrn->PointerMoved;
		pScrn->PointerMoved = WsfbPointerMoved;
	}

	fPtr->fbstart = fPtr->fbmem;

	switch (pScrn->bitsPerPixel) {
	case 1:
		ret = xf1bppScreenInit(pScreen, fPtr->fbstart,
				       width, height,
				       pScrn->xDpi, pScrn->yDpi,
				       fPtr->linebytes * 8);
		break;
	case 4:
		ret = xf4bppScreenInit(pScreen, fPtr->fbstart,
				       width, height,
				       pScrn->xDpi, pScrn->yDpi,
				       fPtr->linebytes * 2);
		break;
	case 8:
	case 16:
	case 24:
	case 32:
		ret = fbScreenInit(pScreen,
				   fPtr->fbstart,
				   width, height,
				   pScrn->xDpi, pScrn->yDpi,
				   pScrn->displayWidth,
				   pScrn->bitsPerPixel);
		break;
	default:
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			   "Unsupported bpp: %d", pScrn->bitsPerPixel);
		return FALSE;
	} /* case */

	if (!ret) {
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
		    "fbScreenInit error");
		return FALSE;
	}

	if (pScrn->bitsPerPixel > 8) {
		/* Fixup RGB ordering */
		visual = pScreen->visuals + pScreen->numVisuals;
		while (--visual >= pScreen->visuals) {
			if ((visual->class | DynamicClass) == DirectColor) {
				visual->offsetRed   = pScrn->offset.red;
				visual->offsetGreen = pScrn->offset.green;
				visual->offsetBlue  = pScrn->offset.blue;
				visual->redMask     = pScrn->mask.red;
				visual->greenMask   = pScrn->mask.green;
				visual->blueMask    = pScrn->mask.blue;
			}
		}
	}

	if (pScrn->bitsPerPixel >= 8) {
		if (!fbPictureInit(pScreen, NULL, 0))
			xf86DrvMsg(pScrn->scrnIndex, X_WARNING,
				   "RENDER extension initialisation failed.");
	}
	if (fPtr->shadowFB) {
		PixmapPtr pPixmap;

		if (pScrn->bitsPerPixel < 8) {
			xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
				   "Shadow FB not available on < 8 depth");
		} else {
			pPixmap = pScreen->CreatePixmap(pScreen, 
			    pScreen->width, pScreen->height,
			    pScreen->rootDepth);
			if (!pPixmap)
				return FALSE;
    			if (!shadowSetup(pScreen) ||
			    !shadowAdd(pScreen, pPixmap,
				fPtr->rotate ? shadowUpdateRotatePackedWeak() :
				shadowUpdatePackedWeak(),
				WsfbWindowLinear, fPtr->rotate, NULL)) {
				xf86DrvMsg(scrnIndex, X_ERROR,
				    "Shadow FB initialization failed\n");
				pScreen->DestroyPixmap(pPixmap);
				return FALSE;
			}
		}
	}

#ifdef XFreeXDGA
	if (!fPtr->rotate) 
		WsfbDGAInit(pScrn, pScreen);
	else 
		xf86DrvMsg(scrnIndex, X_INFO, "Rotated display, "
		    "disabling DGA\n");
#endif
	if (fPtr->rotate) {
		xf86DrvMsg(scrnIndex, X_INFO, "Enabling Driver Rotation, "
		    "disabling RandR\n");
		xf86DisableRandR();
		if (pScrn->bitsPerPixel == 24) 
			xf86DrvMsg(scrnIndex, X_WARNING, 
			    "Rotation might be broken in 24 bpp\n");
	}

	xf86SetBlackWhitePixels(pScreen);
	miInitializeBackingStore(pScreen);
	xf86SetBackingStore(pScreen);

	/* software cursor */
	miDCInitialize(pScreen, xf86GetPointerScreenFuncs());

	/*
	 * Colormap
	 *
	 * Note that, even on less than 8 bit depth frame buffers, we
	 * expect the colormap to be programmable with 8 bit values.
	 * As of now, this is indeed the case on all OpenBSD supported
	 * graphics hardware.
	 */
	if (!miCreateDefColormap(pScreen))
		return FALSE;
	flags = CMAP_RELOAD_ON_MODE_SWITCH;
	ncolors = fPtr->info.cmsize;
	/* on StaticGray visuals, fake a 256 entries colormap */
	if (ncolors == 0)
		ncolors = 256;
	if(!xf86HandleColormaps(pScreen, ncolors, 8, WsfbLoadPalette,
				NULL, flags))
		return FALSE;

	pScreen->SaveScreen = WsfbSaveScreen;

#ifdef XvExtension
	{
		XF86VideoAdaptorPtr *ptr;

		int n = xf86XVListGenericAdaptors(pScrn,&ptr);
		if (n) {
			xf86XVScreenInit(pScreen,ptr,n);
		}
	}
#endif

	/* Wrap the current CloseScreen function */
	fPtr->CloseScreen = pScreen->CloseScreen;
	pScreen->CloseScreen = WsfbCloseScreen;

	TRACE_EXIT("WsfbScreenInit");
	return TRUE;
}

static Bool
WsfbCloseScreen(int scrnIndex, ScreenPtr pScreen)
{
	ScrnInfoPtr pScrn = xf86Screens[scrnIndex];
	WsfbPtr fPtr = WSFBPTR(pScrn);

	TRACE_ENTER("WsfbCloseScreen");

	if (pScrn->vtSema) {
		WsfbRestore(pScrn);
		if (munmap(fPtr->fbmem, fPtr->fbmem_len) == -1) {
			xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
				   "munmap: %s\n", strerror(errno));
		}

		fPtr->fbmem = NULL;
	}
#ifdef XFreeXDGA
	if (fPtr->pDGAMode) {
		xfree(fPtr->pDGAMode);
		fPtr->pDGAMode = NULL;
		fPtr->nDGAMode = 0;
	}
#endif
	pScrn->vtSema = FALSE;

	/* unwrap CloseScreen */
	pScreen->CloseScreen = fPtr->CloseScreen;
	return (*pScreen->CloseScreen)(scrnIndex, pScreen);
}

static void *
WsfbWindowLinear(ScreenPtr pScreen, CARD32 row, CARD32 offset, int mode,
		CARD32 *size, void *closure)
{
	ScrnInfoPtr pScrn = xf86Screens[pScreen->myNum];
	WsfbPtr fPtr = WSFBPTR(pScrn);

	if (fPtr->linebytes)
		*size = fPtr->linebytes;
	else {
		if (ioctl(fPtr->fd, WSDISPLAYIO_LINEBYTES, size) == -1)
			return NULL;
		fPtr->linebytes = *size;
	}
	return ((CARD8 *)fPtr->fbmem + row *fPtr->linebytes + offset);
}

static void
WsfbPointerMoved(int index, int x, int y)
{
    ScrnInfoPtr pScrn = xf86Screens[index];
    WsfbPtr fPtr = WSFBPTR(pScrn);
    int newX, newY;

    switch (fPtr->rotate)
    {
    case WSFB_ROTATE_CW:
	/* 90 degrees CW rotation. */
	newX = pScrn->pScreen->height - y - 1;
	newY = x;
	break;

    case WSFB_ROTATE_CCW:
	/* 90 degrees CCW rotation. */
	newX = y;
	newY = pScrn->pScreen->width - x - 1;
	break;

    case WSFB_ROTATE_UD:
	/* 180 degrees UD rotation. */
	newX = pScrn->pScreen->width - x - 1;
	newY = pScrn->pScreen->height - y - 1;
	break;

    default:
	/* No rotation. */
	newX = x;
	newY = y;
	break;
    }

    /* Pass adjusted pointer coordinates to wrapped PointerMoved function. */
    (*fPtr->PointerMoved)(index, newX, newY);
}

static Bool
WsfbEnterVT(int scrnIndex, int flags)
{
	ScrnInfoPtr pScrn = xf86Screens[scrnIndex];
	WsfbPtr fPtr = WSFBPTR(pScrn);
	int wsmode = WSDISPLAYIO_MODE_DUMBFB;

	TRACE_ENTER("EnterVT");
	
	/* Switch to graphics mode */
	if (ioctl(fPtr->fd, WSDISPLAYIO_SMODE, &wsmode) == -1) {
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
		    "ioctl WSDISPLAYIO_SMODE: %s\n",
		    strerror(errno));
		return FALSE;
	}

	pScrn->vtSema = TRUE;
	TRACE_EXIT("EnterVT");
	return TRUE;
}

static void
WsfbLeaveVT(int scrnIndex, int flags)
{
	ScrnInfoPtr pScrn = xf86Screens[scrnIndex];

	TRACE_ENTER("LeaveVT");

	WsfbRestore(pScrn);

	TRACE_EXIT("LeaveVT");
}

static Bool
WsfbSwitchMode(int scrnIndex, DisplayModePtr mode, int flags)
{
#if DEBUG
	ScrnInfoPtr pScrn = xf86Screens[scrnIndex];
#endif

	TRACE_ENTER("SwitchMode");
	/* Nothing else to do */
	return TRUE;
}

static int
WsfbValidMode(int scrnIndex, DisplayModePtr mode, Bool verbose, int flags)
{
#if DEBUG
	ScrnInfoPtr pScrn = xf86Screens[scrnIndex];
#endif

	TRACE_ENTER("ValidMode");
	return MODE_OK;
}

static void
WsfbLoadPalette(ScrnInfoPtr pScrn, int numColors, int *indices,
	       LOCO *colors, VisualPtr pVisual)
{
	WsfbPtr fPtr = WSFBPTR(pScrn);
	struct wsdisplay_cmap cmap;
	unsigned char red[256],green[256],blue[256];
	int i, indexMin=256, indexMax=0;

	TRACE_ENTER("LoadPalette");

	cmap.count   = 1;
	cmap.red   = red;
	cmap.green = green;
	cmap.blue  = blue;

	if (numColors == 1) {
		/* Optimisation */
		cmap.index = indices[0];
		red[0]   = colors[indices[0]].red;
		green[0] = colors[indices[0]].green;
		blue[0]  = colors[indices[0]].blue;
		if (ioctl(fPtr->fd,WSDISPLAYIO_PUTCMAP, &cmap) == -1)
			ErrorF("ioctl FBIOPUTCMAP: %s\n", strerror(errno));
	} else {
		/* Change all colors in 2 ioctls */
		/* and limit the data to be transfered */
		for (i = 0; i < numColors; i++) {
			if (indices[i] < indexMin)
				indexMin = indices[i];
			if (indices[i] > indexMax)
				indexMax = indices[i];
		}
		cmap.index = indexMin;
		cmap.count = indexMax - indexMin + 1;
		cmap.red = &red[indexMin];
		cmap.green = &green[indexMin];
		cmap.blue = &blue[indexMin];
		/* Get current map */
		if (ioctl(fPtr->fd, WSDISPLAYIO_GETCMAP, &cmap) == -1)
			ErrorF("ioctl FBIOGETCMAP: %s\n", strerror(errno));
		/* Change the colors that require updating */
		for (i = 0; i < numColors; i++) {
			red[indices[i]]   = colors[indices[i]].red;
			green[indices[i]] = colors[indices[i]].green;
			blue[indices[i]]  = colors[indices[i]].blue;
		}
		/* Write the colormap back */
		if (ioctl(fPtr->fd,WSDISPLAYIO_PUTCMAP, &cmap) == -1)
			ErrorF("ioctl FBIOPUTCMAP: %s\n", strerror(errno));
	}
	TRACE_EXIT("LoadPalette");
}

static Bool
WsfbSaveScreen(ScreenPtr pScreen, int mode)
{
	ScrnInfoPtr pScrn = xf86Screens[pScreen->myNum];
	WsfbPtr fPtr = WSFBPTR(pScrn);
	int state;

	TRACE_ENTER("SaveScreen");

	if (!pScrn->vtSema)
		return TRUE;

	if (mode != SCREEN_SAVER_FORCER) {
		state = xf86IsUnblank(mode)?WSDISPLAYIO_VIDEO_ON:
		                            WSDISPLAYIO_VIDEO_OFF;
		ioctl(fPtr->fd,
		      WSDISPLAYIO_SVIDEO, &state);
	}
	return TRUE;
}


static void
WsfbSave(ScrnInfoPtr pScrn)
{
	WsfbPtr fPtr = WSFBPTR(pScrn);

	TRACE_ENTER("WsfbSave");

	if (fPtr->info.cmsize == 0)
		return;

	fPtr->saved_cmap.index = 0;
	fPtr->saved_cmap.count = fPtr->info.cmsize;
	if (ioctl(fPtr->fd, WSDISPLAYIO_GETCMAP,
		  &(fPtr->saved_cmap)) == -1) {
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			   "error saving colormap %s\n", strerror(errno));
	}

}

static void
WsfbRestore(ScrnInfoPtr pScrn)
{
	WsfbPtr fPtr = WSFBPTR(pScrn);
	int mode;

	TRACE_ENTER("WsfbRestore");

	if (fPtr->info.cmsize != 0) {
		/* reset colormap for text mode */
		if (ioctl(fPtr->fd, WSDISPLAYIO_PUTCMAP,
			  &(fPtr->saved_cmap)) == -1) {
			xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
				   "error restoring colormap %s\n",
				   strerror(errno));
		}
	}

	/* Clear the screen */
	memset(fPtr->fbmem, 0, fPtr->fbmem_len);

	/* Restore the text mode */
	mode = WSDISPLAYIO_MODE_EMUL;
	if (ioctl(fPtr->fd, WSDISPLAYIO_SMODE, &mode) == -1) {
		xf86DrvMsg(pScrn->scrnIndex, X_ERROR,
			   "error setting text mode %s\n", strerror(errno));
	}
	TRACE_EXIT("WsfbRestore");
}

#ifdef XFreeXDGA
/***********************************************************************
 * DGA stuff
 ***********************************************************************/

static Bool
WsfbDGAOpenFramebuffer(ScrnInfoPtr pScrn, char **DeviceName,
		       unsigned char **ApertureBase, int *ApertureSize,
		       int *ApertureOffset, int *flags)
{
	*DeviceName = NULL;		/* No special device */
	*ApertureBase = (unsigned char *)(pScrn->memPhysBase);
	*ApertureSize = pScrn->videoRam;
	*ApertureOffset = pScrn->fbOffset;
	*flags = 0;

	return TRUE;
}

static Bool
WsfbDGASetMode(ScrnInfoPtr pScrn, DGAModePtr pDGAMode)
{
	DisplayModePtr pMode;
	int scrnIdx = pScrn->pScreen->myNum;
	int frameX0, frameY0;

	if (pDGAMode) {
		pMode = pDGAMode->mode;
		frameX0 = frameY0 = 0;
	} else {
		if (!(pMode = pScrn->currentMode))
			return TRUE;

		frameX0 = pScrn->frameX0;
		frameY0 = pScrn->frameY0;
	}

	if (!(*pScrn->SwitchMode)(scrnIdx, pMode, 0))
		return FALSE;
	(*pScrn->AdjustFrame)(scrnIdx, frameX0, frameY0, 0);

	return TRUE;
}

static void
WsfbDGASetViewport(ScrnInfoPtr pScrn, int x, int y, int flags)
{
	(*pScrn->AdjustFrame)(pScrn->pScreen->myNum, x, y, flags);
}

static int
WsfbDGAGetViewport(ScrnInfoPtr pScrn)
{
	return (0);
}

static DGAFunctionRec WsfbDGAFunctions =
{
	WsfbDGAOpenFramebuffer,
	NULL,       /* CloseFramebuffer */
	WsfbDGASetMode,
	WsfbDGASetViewport,
	WsfbDGAGetViewport,
	NULL,       /* Sync */
	NULL,       /* FillRect */
	NULL,       /* BlitRect */
	NULL,       /* BlitTransRect */
};

static void
WsfbDGAAddModes(ScrnInfoPtr pScrn)
{
	WsfbPtr fPtr = WSFBPTR(pScrn);
	DisplayModePtr pMode = pScrn->modes;
	DGAModePtr pDGAMode;

	do {
		pDGAMode = xrealloc(fPtr->pDGAMode,
				    (fPtr->nDGAMode + 1) * sizeof(DGAModeRec));
		if (!pDGAMode)
			break;

		fPtr->pDGAMode = pDGAMode;
		pDGAMode += fPtr->nDGAMode;
		(void)memset(pDGAMode, 0, sizeof(DGAModeRec));

		++fPtr->nDGAMode;
		pDGAMode->mode = pMode;
		pDGAMode->flags = DGA_CONCURRENT_ACCESS | DGA_PIXMAP_AVAILABLE;
		pDGAMode->byteOrder = pScrn->imageByteOrder;
		pDGAMode->depth = pScrn->depth;
		pDGAMode->bitsPerPixel = pScrn->bitsPerPixel;
		pDGAMode->red_mask = pScrn->mask.red;
		pDGAMode->green_mask = pScrn->mask.green;
		pDGAMode->blue_mask = pScrn->mask.blue;
		pDGAMode->visualClass = pScrn->bitsPerPixel > 8 ?
			TrueColor : PseudoColor;
		pDGAMode->xViewportStep = 1;
		pDGAMode->yViewportStep = 1;
		pDGAMode->viewportWidth = pMode->HDisplay;
		pDGAMode->viewportHeight = pMode->VDisplay;

		if (fPtr->linebytes)
			pDGAMode->bytesPerScanline = fPtr->linebytes;
		else {
			ioctl(fPtr->fd, WSDISPLAYIO_LINEBYTES,
			      &fPtr->linebytes);
			pDGAMode->bytesPerScanline = fPtr->linebytes;
		}

		pDGAMode->imageWidth = pMode->HDisplay;
		pDGAMode->imageHeight =  pMode->VDisplay;
		pDGAMode->pixmapWidth = pDGAMode->imageWidth;
		pDGAMode->pixmapHeight = pDGAMode->imageHeight;
		pDGAMode->maxViewportX = pScrn->virtualX -
			pDGAMode->viewportWidth;
		pDGAMode->maxViewportY = pScrn->virtualY -
			pDGAMode->viewportHeight;

		pDGAMode->address = fPtr->fbstart;

		pMode = pMode->next;
	} while (pMode != pScrn->modes);
}

static Bool
WsfbDGAInit(ScrnInfoPtr pScrn, ScreenPtr pScreen)
{
	WsfbPtr fPtr = WSFBPTR(pScrn);

	if (pScrn->depth < 8)
		return FALSE;

	if (!fPtr->nDGAMode)
		WsfbDGAAddModes(pScrn);

	return (DGAInit(pScreen, &WsfbDGAFunctions,
			fPtr->pDGAMode, fPtr->nDGAMode));
}
#endif

static Bool
WsfbDriverFunc(ScrnInfoPtr pScrn, xorgDriverFuncOp op,
    pointer ptr)
{
	xorgHWFlags *flag;
	
	switch (op) {
	case GET_REQUIRED_HW_INTERFACES:
		flag = (CARD32*)ptr;
		(*flag) = 0;
		return TRUE;
	default:
		return FALSE;
	}
}

