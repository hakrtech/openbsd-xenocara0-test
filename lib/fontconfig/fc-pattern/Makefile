#	$OpenBSD: Makefile,v 1.2 2017/10/23 16:50:28 matthieu Exp $

FONTCONFIG=	${.CURDIR}/../../../dist/fontconfig

PROG=	fc-pattern
LDADD=	-L../src -L${X11BASE}/lib -lfontconfig -lfreetype -lexpat -lz

obj:	_xenocara_obj

.PATH: ${FONTCONFIG}/fc-pattern

.include <bsd.prog.mk>
.include <bsd.xorg.mk>
