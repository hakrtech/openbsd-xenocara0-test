# generated automatically by aclocal 1.13.4 -*- Autoconf -*-

# Copyright (C) 1996-2013 Free Software Foundation, Inc.

# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

m4_ifndef([AC_CONFIG_MACRO_DIRS], [m4_defun([_AM_CONFIG_MACRO_DIRS], [])m4_defun([AC_CONFIG_MACRO_DIRS], [_AM_CONFIG_MACRO_DIRS($@)])])
m4_ifndef([AC_AUTOCONF_VERSION],
  [m4_copy([m4_PACKAGE_VERSION], [AC_AUTOCONF_VERSION])])dnl
m4_if(m4_defn([AC_AUTOCONF_VERSION]), [2.69],,
[m4_warning([this file was generated for autoconf 2.69.
You have another version of autoconf.  It may work, but is not guaranteed to.
If you have problems, you may need to regenerate the build system entirely.
To do so, use the procedure documented by the package, typically 'autoreconf'.])])

# gettext.m4 serial 66 (gettext-0.18.2)
dnl Copyright (C) 1995-2013 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.
dnl
dnl This file can can be used in projects which are not available under
dnl the GNU General Public License or the GNU Library General Public
dnl License but which still want to provide support for the GNU gettext
dnl functionality.
dnl Please note that the actual code of the GNU gettext library is covered
dnl by the GNU Library General Public License, and the rest of the GNU
dnl gettext package package is covered by the GNU General Public License.
dnl They are *not* in the public domain.

dnl Authors:
dnl   Ulrich Drepper <drepper@cygnus.com>, 1995-2000.
dnl   Bruno Haible <haible@clisp.cons.org>, 2000-2006, 2008-2010.

dnl Macro to add for using GNU gettext.

dnl Usage: AM_GNU_GETTEXT([INTLSYMBOL], [NEEDSYMBOL], [INTLDIR]).
dnl INTLSYMBOL can be one of 'external', 'no-libtool', 'use-libtool'. The
dnl    default (if it is not specified or empty) is 'no-libtool'.
dnl    INTLSYMBOL should be 'external' for packages with no intl directory,
dnl    and 'no-libtool' or 'use-libtool' for packages with an intl directory.
dnl    If INTLSYMBOL is 'use-libtool', then a libtool library
dnl    $(top_builddir)/intl/libintl.la will be created (shared and/or static,
dnl    depending on --{enable,disable}-{shared,static} and on the presence of
dnl    AM-DISABLE-SHARED). If INTLSYMBOL is 'no-libtool', a static library
dnl    $(top_builddir)/intl/libintl.a will be created.
dnl If NEEDSYMBOL is specified and is 'need-ngettext', then GNU gettext
dnl    implementations (in libc or libintl) without the ngettext() function
dnl    will be ignored.  If NEEDSYMBOL is specified and is
dnl    'need-formatstring-macros', then GNU gettext implementations that don't
dnl    support the ISO C 99 <inttypes.h> formatstring macros will be ignored.
dnl INTLDIR is used to find the intl libraries.  If empty,
dnl    the value '$(top_builddir)/intl/' is used.
dnl
dnl The result of the configuration is one of three cases:
dnl 1) GNU gettext, as included in the intl subdirectory, will be compiled
dnl    and used.
dnl    Catalog format: GNU --> install in $(datadir)
dnl    Catalog extension: .mo after installation, .gmo in source tree
dnl 2) GNU gettext has been found in the system's C library.
dnl    Catalog format: GNU --> install in $(datadir)
dnl    Catalog extension: .mo after installation, .gmo in source tree
dnl 3) No internationalization, always use English msgid.
dnl    Catalog format: none
dnl    Catalog extension: none
dnl If INTLSYMBOL is 'external', only cases 2 and 3 can occur.
dnl The use of .gmo is historical (it was needed to avoid overwriting the
dnl GNU format catalogs when building on a platform with an X/Open gettext),
dnl but we keep it in order not to force irrelevant filename changes on the
dnl maintainers.
dnl
AC_DEFUN([AM_GNU_GETTEXT],
[
  dnl Argument checking.
  ifelse([$1], [], , [ifelse([$1], [external], , [ifelse([$1], [no-libtool], , [ifelse([$1], [use-libtool], ,
    [errprint([ERROR: invalid first argument to AM_GNU_GETTEXT
])])])])])
  ifelse(ifelse([$1], [], [old])[]ifelse([$1], [no-libtool], [old]), [old],
    [AC_DIAGNOSE([obsolete], [Use of AM_GNU_GETTEXT without [external] argument is deprecated.])])
  ifelse([$2], [], , [ifelse([$2], [need-ngettext], , [ifelse([$2], [need-formatstring-macros], ,
    [errprint([ERROR: invalid second argument to AM_GNU_GETTEXT
])])])])
  define([gt_included_intl],
    ifelse([$1], [external],
      ifdef([AM_GNU_GETTEXT_][INTL_SUBDIR], [yes], [no]),
      [yes]))
  define([gt_libtool_suffix_prefix], ifelse([$1], [use-libtool], [l], []))
  gt_NEEDS_INIT
  AM_GNU_GETTEXT_NEED([$2])

  AC_REQUIRE([AM_PO_SUBDIRS])dnl
  ifelse(gt_included_intl, yes, [
    AC_REQUIRE([AM_INTL_SUBDIR])dnl
  ])

  dnl Prerequisites of AC_LIB_LINKFLAGS_BODY.
  AC_REQUIRE([AC_LIB_PREPARE_PREFIX])
  AC_REQUIRE([AC_LIB_RPATH])

  dnl Sometimes libintl requires libiconv, so first search for libiconv.
  dnl Ideally we would do this search only after the
  dnl      if test "$USE_NLS" = "yes"; then
  dnl        if { eval "gt_val=\$$gt_func_gnugettext_libc"; test "$gt_val" != "yes"; }; then
  dnl tests. But if configure.in invokes AM_ICONV after AM_GNU_GETTEXT
  dnl the configure script would need to contain the same shell code
  dnl again, outside any 'if'. There are two solutions:
  dnl - Invoke AM_ICONV_LINKFLAGS_BODY here, outside any 'if'.
  dnl - Control the expansions in more detail using AC_PROVIDE_IFELSE.
  dnl Since AC_PROVIDE_IFELSE is only in autoconf >= 2.52 and not
  dnl documented, we avoid it.
  ifelse(gt_included_intl, yes, , [
    AC_REQUIRE([AM_ICONV_LINKFLAGS_BODY])
  ])

  dnl Sometimes, on Mac OS X, libintl requires linking with CoreFoundation.
  gt_INTL_MACOSX

  dnl Set USE_NLS.
  AC_REQUIRE([AM_NLS])

  ifelse(gt_included_intl, yes, [
    BUILD_INCLUDED_LIBINTL=no
    USE_INCLUDED_LIBINTL=no
  ])
  LIBINTL=
  LTLIBINTL=
  POSUB=

  dnl Add a version number to the cache macros.
  case " $gt_needs " in
    *" need-formatstring-macros "*) gt_api_version=3 ;;
    *" need-ngettext "*) gt_api_version=2 ;;
    *) gt_api_version=1 ;;
  esac
  gt_func_gnugettext_libc="gt_cv_func_gnugettext${gt_api_version}_libc"
  gt_func_gnugettext_libintl="gt_cv_func_gnugettext${gt_api_version}_libintl"

  dnl If we use NLS figure out what method
  if test "$USE_NLS" = "yes"; then
    gt_use_preinstalled_gnugettext=no
    ifelse(gt_included_intl, yes, [
      AC_MSG_CHECKING([whether included gettext is requested])
      AC_ARG_WITH([included-gettext],
        [  --with-included-gettext use the GNU gettext library included here],
        nls_cv_force_use_gnu_gettext=$withval,
        nls_cv_force_use_gnu_gettext=no)
      AC_MSG_RESULT([$nls_cv_force_use_gnu_gettext])

      nls_cv_use_gnu_gettext="$nls_cv_force_use_gnu_gettext"
      if test "$nls_cv_force_use_gnu_gettext" != "yes"; then
    ])
        dnl User does not insist on using GNU NLS library.  Figure out what
        dnl to use.  If GNU gettext is available we use this.  Else we have
        dnl to fall back to GNU NLS library.

        if test $gt_api_version -ge 3; then
          gt_revision_test_code='
#ifndef __GNU_GETTEXT_SUPPORTED_REVISION
#define __GNU_GETTEXT_SUPPORTED_REVISION(major) ((major) == 0 ? 0 : -1)
#endif
changequote(,)dnl
typedef int array [2 * (__GNU_GETTEXT_SUPPORTED_REVISION(0) >= 1) - 1];
changequote([,])dnl
'
        else
          gt_revision_test_code=
        fi
        if test $gt_api_version -ge 2; then
          gt_expression_test_code=' + * ngettext ("", "", 0)'
        else
          gt_expression_test_code=
        fi

        AC_CACHE_CHECK([for GNU gettext in libc], [$gt_func_gnugettext_libc],
         [AC_LINK_IFELSE(
            [AC_LANG_PROGRAM(
               [[
#include <libintl.h>
$gt_revision_test_code
extern int _nl_msg_cat_cntr;
extern int *_nl_domain_bindings;
               ]],
               [[
bindtextdomain ("", "");
return * gettext ("")$gt_expression_test_code + _nl_msg_cat_cntr + *_nl_domain_bindings
               ]])],
            [eval "$gt_func_gnugettext_libc=yes"],
            [eval "$gt_func_gnugettext_libc=no"])])

        if { eval "gt_val=\$$gt_func_gnugettext_libc"; test "$gt_val" != "yes"; }; then
          dnl Sometimes libintl requires libiconv, so first search for libiconv.
          ifelse(gt_included_intl, yes, , [
            AM_ICONV_LINK
          ])
          dnl Search for libintl and define LIBINTL, LTLIBINTL and INCINTL
          dnl accordingly. Don't use AC_LIB_LINKFLAGS_BODY([intl],[iconv])
          dnl because that would add "-liconv" to LIBINTL and LTLIBINTL
          dnl even if libiconv doesn't exist.
          AC_LIB_LINKFLAGS_BODY([intl])
          AC_CACHE_CHECK([for GNU gettext in libintl],
            [$gt_func_gnugettext_libintl],
           [gt_save_CPPFLAGS="$CPPFLAGS"
            CPPFLAGS="$CPPFLAGS $INCINTL"
            gt_save_LIBS="$LIBS"
            LIBS="$LIBS $LIBINTL"
            dnl Now see whether libintl exists and does not depend on libiconv.
            AC_LINK_IFELSE(
              [AC_LANG_PROGRAM(
                 [[
#include <libintl.h>
$gt_revision_test_code
extern int _nl_msg_cat_cntr;
extern
#ifdef __cplusplus
"C"
#endif
const char *_nl_expand_alias (const char *);
                 ]],
                 [[
bindtextdomain ("", "");
return * gettext ("")$gt_expression_test_code + _nl_msg_cat_cntr + *_nl_expand_alias ("")
                 ]])],
              [eval "$gt_func_gnugettext_libintl=yes"],
              [eval "$gt_func_gnugettext_libintl=no"])
            dnl Now see whether libintl exists and depends on libiconv.
            if { eval "gt_val=\$$gt_func_gnugettext_libintl"; test "$gt_val" != yes; } && test -n "$LIBICONV"; then
              LIBS="$LIBS $LIBICONV"
              AC_LINK_IFELSE(
                [AC_LANG_PROGRAM(
                   [[
#include <libintl.h>
$gt_revision_test_code
extern int _nl_msg_cat_cntr;
extern
#ifdef __cplusplus
"C"
#endif
const char *_nl_expand_alias (const char *);
                   ]],
                   [[
bindtextdomain ("", "");
return * gettext ("")$gt_expression_test_code + _nl_msg_cat_cntr + *_nl_expand_alias ("")
                   ]])],
                [LIBINTL="$LIBINTL $LIBICONV"
                 LTLIBINTL="$LTLIBINTL $LTLIBICONV"
                 eval "$gt_func_gnugettext_libintl=yes"
                ])
            fi
            CPPFLAGS="$gt_save_CPPFLAGS"
            LIBS="$gt_save_LIBS"])
        fi

        dnl If an already present or preinstalled GNU gettext() is found,
        dnl use it.  But if this macro is used in GNU gettext, and GNU
        dnl gettext is already preinstalled in libintl, we update this
        dnl libintl.  (Cf. the install rule in intl/Makefile.in.)
        if { eval "gt_val=\$$gt_func_gnugettext_libc"; test "$gt_val" = "yes"; } \
           || { { eval "gt_val=\$$gt_func_gnugettext_libintl"; test "$gt_val" = "yes"; } \
                && test "$PACKAGE" != gettext-runtime \
                && test "$PACKAGE" != gettext-tools; }; then
          gt_use_preinstalled_gnugettext=yes
        else
          dnl Reset the values set by searching for libintl.
          LIBINTL=
          LTLIBINTL=
          INCINTL=
        fi

    ifelse(gt_included_intl, yes, [
        if test "$gt_use_preinstalled_gnugettext" != "yes"; then
          dnl GNU gettext is not found in the C library.
          dnl Fall back on included GNU gettext library.
          nls_cv_use_gnu_gettext=yes
        fi
      fi

      if test "$nls_cv_use_gnu_gettext" = "yes"; then
        dnl Mark actions used to generate GNU NLS library.
        BUILD_INCLUDED_LIBINTL=yes
        USE_INCLUDED_LIBINTL=yes
        LIBINTL="ifelse([$3],[],\${top_builddir}/intl,[$3])/libintl.[]gt_libtool_suffix_prefix[]a $LIBICONV $LIBTHREAD"
        LTLIBINTL="ifelse([$3],[],\${top_builddir}/intl,[$3])/libintl.[]gt_libtool_suffix_prefix[]a $LTLIBICONV $LTLIBTHREAD"
        LIBS=`echo " $LIBS " | sed -e 's/ -lintl / /' -e 's/^ //' -e 's/ $//'`
      fi

      CATOBJEXT=
      if test "$gt_use_preinstalled_gnugettext" = "yes" \
         || test "$nls_cv_use_gnu_gettext" = "yes"; then
        dnl Mark actions to use GNU gettext tools.
        CATOBJEXT=.gmo
      fi
    ])

    if test -n "$INTL_MACOSX_LIBS"; then
      if test "$gt_use_preinstalled_gnugettext" = "yes" \
         || test "$nls_cv_use_gnu_gettext" = "yes"; then
        dnl Some extra flags are needed during linking.
        LIBINTL="$LIBINTL $INTL_MACOSX_LIBS"
        LTLIBINTL="$LTLIBINTL $INTL_MACOSX_LIBS"
      fi
    fi

    if test "$gt_use_preinstalled_gnugettext" = "yes" \
       || test "$nls_cv_use_gnu_gettext" = "yes"; then
      AC_DEFINE([ENABLE_NLS], [1],
        [Define to 1 if translation of program messages to the user's native language
   is requested.])
    else
      USE_NLS=no
    fi
  fi

  AC_MSG_CHECKING([whether to use NLS])
  AC_MSG_RESULT([$USE_NLS])
  if test "$USE_NLS" = "yes"; then
    AC_MSG_CHECKING([where the gettext function comes from])
    if test "$gt_use_preinstalled_gnugettext" = "yes"; then
      if { eval "gt_val=\$$gt_func_gnugettext_libintl"; test "$gt_val" = "yes"; }; then
        gt_source="external libintl"
      else
        gt_source="libc"
      fi
    else
      gt_source="included intl directory"
    fi
    AC_MSG_RESULT([$gt_source])
  fi

  if test "$USE_NLS" = "yes"; then

    if test "$gt_use_preinstalled_gnugettext" = "yes"; then
      if { eval "gt_val=\$$gt_func_gnugettext_libintl"; test "$gt_val" = "yes"; }; then
        AC_MSG_CHECKING([how to link with libintl])
        AC_MSG_RESULT([$LIBINTL])
        AC_LIB_APPENDTOVAR([CPPFLAGS], [$INCINTL])
      fi

      dnl For backward compatibility. Some packages may be using this.
      AC_DEFINE([HAVE_GETTEXT], [1],
       [Define if the GNU gettext() function is already present or preinstalled.])
      AC_DEFINE([HAVE_DCGETTEXT], [1],
       [Define if the GNU dcgettext() function is already present or preinstalled.])
    fi

    dnl We need to process the po/ directory.
    POSUB=po
  fi

  ifelse(gt_included_intl, yes, [
    dnl If this is used in GNU gettext we have to set BUILD_INCLUDED_LIBINTL
    dnl to 'yes' because some of the testsuite requires it.
    if test "$PACKAGE" = gettext-runtime || test "$PACKAGE" = gettext-tools; then
      BUILD_INCLUDED_LIBINTL=yes
    fi

    dnl Make all variables we use known to autoconf.
    AC_SUBST([BUILD_INCLUDED_LIBINTL])
    AC_SUBST([USE_INCLUDED_LIBINTL])
    AC_SUBST([CATOBJEXT])

    dnl For backward compatibility. Some configure.ins may be using this.
    nls_cv_header_intl=
    nls_cv_header_libgt=

    dnl For backward compatibility. Some Makefiles may be using this.
    DATADIRNAME=share
    AC_SUBST([DATADIRNAME])

    dnl For backward compatibility. Some Makefiles may be using this.
    INSTOBJEXT=.mo
    AC_SUBST([INSTOBJEXT])

    dnl For backward compatibility. Some Makefiles may be using this.
    GENCAT=gencat
    AC_SUBST([GENCAT])

    dnl For backward compatibility. Some Makefiles may be using this.
    INTLOBJS=
    if test "$USE_INCLUDED_LIBINTL" = yes; then
      INTLOBJS="\$(GETTOBJS)"
    fi
    AC_SUBST([INTLOBJS])

    dnl Enable libtool support if the surrounding package wishes it.
    INTL_LIBTOOL_SUFFIX_PREFIX=gt_libtool_suffix_prefix
    AC_SUBST([INTL_LIBTOOL_SUFFIX_PREFIX])
  ])

  dnl For backward compatibility. Some Makefiles may be using this.
  INTLLIBS="$LIBINTL"
  AC_SUBST([INTLLIBS])

  dnl Make all documented variables known to autoconf.
  AC_SUBST([LIBINTL])
  AC_SUBST([LTLIBINTL])
  AC_SUBST([POSUB])
])


dnl gt_NEEDS_INIT ensures that the gt_needs variable is initialized.
m4_define([gt_NEEDS_INIT],
[
  m4_divert_text([DEFAULTS], [gt_needs=])
  m4_define([gt_NEEDS_INIT], [])
])


dnl Usage: AM_GNU_GETTEXT_NEED([NEEDSYMBOL])
AC_DEFUN([AM_GNU_GETTEXT_NEED],
[
  m4_divert_text([INIT_PREPARE], [gt_needs="$gt_needs $1"])
])


dnl Usage: AM_GNU_GETTEXT_VERSION([gettext-version])
AC_DEFUN([AM_GNU_GETTEXT_VERSION], [])

# iconv.m4 serial 18 (gettext-0.18.2)
dnl Copyright (C) 2000-2002, 2007-2013 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl From Bruno Haible.

AC_DEFUN([AM_ICONV_LINKFLAGS_BODY],
[
  dnl Prerequisites of AC_LIB_LINKFLAGS_BODY.
  AC_REQUIRE([AC_LIB_PREPARE_PREFIX])
  AC_REQUIRE([AC_LIB_RPATH])

  dnl Search for libiconv and define LIBICONV, LTLIBICONV and INCICONV
  dnl accordingly.
  AC_LIB_LINKFLAGS_BODY([iconv])
])

AC_DEFUN([AM_ICONV_LINK],
[
  dnl Some systems have iconv in libc, some have it in libiconv (OSF/1 and
  dnl those with the standalone portable GNU libiconv installed).
  AC_REQUIRE([AC_CANONICAL_HOST]) dnl for cross-compiles

  dnl Search for libiconv and define LIBICONV, LTLIBICONV and INCICONV
  dnl accordingly.
  AC_REQUIRE([AM_ICONV_LINKFLAGS_BODY])

  dnl Add $INCICONV to CPPFLAGS before performing the following checks,
  dnl because if the user has installed libiconv and not disabled its use
  dnl via --without-libiconv-prefix, he wants to use it. The first
  dnl AC_LINK_IFELSE will then fail, the second AC_LINK_IFELSE will succeed.
  am_save_CPPFLAGS="$CPPFLAGS"
  AC_LIB_APPENDTOVAR([CPPFLAGS], [$INCICONV])

  AC_CACHE_CHECK([for iconv], [am_cv_func_iconv], [
    am_cv_func_iconv="no, consider installing GNU libiconv"
    am_cv_lib_iconv=no
    AC_LINK_IFELSE(
      [AC_LANG_PROGRAM(
         [[
#include <stdlib.h>
#include <iconv.h>
         ]],
         [[iconv_t cd = iconv_open("","");
           iconv(cd,NULL,NULL,NULL,NULL);
           iconv_close(cd);]])],
      [am_cv_func_iconv=yes])
    if test "$am_cv_func_iconv" != yes; then
      am_save_LIBS="$LIBS"
      LIBS="$LIBS $LIBICONV"
      AC_LINK_IFELSE(
        [AC_LANG_PROGRAM(
           [[
#include <stdlib.h>
#include <iconv.h>
           ]],
           [[iconv_t cd = iconv_open("","");
             iconv(cd,NULL,NULL,NULL,NULL);
             iconv_close(cd);]])],
        [am_cv_lib_iconv=yes]
        [am_cv_func_iconv=yes])
      LIBS="$am_save_LIBS"
    fi
  ])
  if test "$am_cv_func_iconv" = yes; then
    AC_CACHE_CHECK([for working iconv], [am_cv_func_iconv_works], [
      dnl This tests against bugs in AIX 5.1, AIX 6.1..7.1, HP-UX 11.11,
      dnl Solaris 10.
      am_save_LIBS="$LIBS"
      if test $am_cv_lib_iconv = yes; then
        LIBS="$LIBS $LIBICONV"
      fi
      AC_RUN_IFELSE(
        [AC_LANG_SOURCE([[
#include <iconv.h>
#include <string.h>
int main ()
{
  int result = 0;
  /* Test against AIX 5.1 bug: Failures are not distinguishable from successful
     returns.  */
  {
    iconv_t cd_utf8_to_88591 = iconv_open ("ISO8859-1", "UTF-8");
    if (cd_utf8_to_88591 != (iconv_t)(-1))
      {
        static const char input[] = "\342\202\254"; /* EURO SIGN */
        char buf[10];
        const char *inptr = input;
        size_t inbytesleft = strlen (input);
        char *outptr = buf;
        size_t outbytesleft = sizeof (buf);
        size_t res = iconv (cd_utf8_to_88591,
                            (char **) &inptr, &inbytesleft,
                            &outptr, &outbytesleft);
        if (res == 0)
          result |= 1;
        iconv_close (cd_utf8_to_88591);
      }
  }
  /* Test against Solaris 10 bug: Failures are not distinguishable from
     successful returns.  */
  {
    iconv_t cd_ascii_to_88591 = iconv_open ("ISO8859-1", "646");
    if (cd_ascii_to_88591 != (iconv_t)(-1))
      {
        static const char input[] = "\263";
        char buf[10];
        const char *inptr = input;
        size_t inbytesleft = strlen (input);
        char *outptr = buf;
        size_t outbytesleft = sizeof (buf);
        size_t res = iconv (cd_ascii_to_88591,
                            (char **) &inptr, &inbytesleft,
                            &outptr, &outbytesleft);
        if (res == 0)
          result |= 2;
        iconv_close (cd_ascii_to_88591);
      }
  }
  /* Test against AIX 6.1..7.1 bug: Buffer overrun.  */
  {
    iconv_t cd_88591_to_utf8 = iconv_open ("UTF-8", "ISO-8859-1");
    if (cd_88591_to_utf8 != (iconv_t)(-1))
      {
        static const char input[] = "\304";
        static char buf[2] = { (char)0xDE, (char)0xAD };
        const char *inptr = input;
        size_t inbytesleft = 1;
        char *outptr = buf;
        size_t outbytesleft = 1;
        size_t res = iconv (cd_88591_to_utf8,
                            (char **) &inptr, &inbytesleft,
                            &outptr, &outbytesleft);
        if (res != (size_t)(-1) || outptr - buf > 1 || buf[1] != (char)0xAD)
          result |= 4;
        iconv_close (cd_88591_to_utf8);
      }
  }
#if 0 /* This bug could be worked around by the caller.  */
  /* Test against HP-UX 11.11 bug: Positive return value instead of 0.  */
  {
    iconv_t cd_88591_to_utf8 = iconv_open ("utf8", "iso88591");
    if (cd_88591_to_utf8 != (iconv_t)(-1))
      {
        static const char input[] = "\304rger mit b\366sen B\374bchen ohne Augenma\337";
        char buf[50];
        const char *inptr = input;
        size_t inbytesleft = strlen (input);
        char *outptr = buf;
        size_t outbytesleft = sizeof (buf);
        size_t res = iconv (cd_88591_to_utf8,
                            (char **) &inptr, &inbytesleft,
                            &outptr, &outbytesleft);
        if ((int)res > 0)
          result |= 8;
        iconv_close (cd_88591_to_utf8);
      }
  }
#endif
  /* Test against HP-UX 11.11 bug: No converter from EUC-JP to UTF-8 is
     provided.  */
  if (/* Try standardized names.  */
      iconv_open ("UTF-8", "EUC-JP") == (iconv_t)(-1)
      /* Try IRIX, OSF/1 names.  */
      && iconv_open ("UTF-8", "eucJP") == (iconv_t)(-1)
      /* Try AIX names.  */
      && iconv_open ("UTF-8", "IBM-eucJP") == (iconv_t)(-1)
      /* Try HP-UX names.  */
      && iconv_open ("utf8", "eucJP") == (iconv_t)(-1))
    result |= 16;
  return result;
}]])],
        [am_cv_func_iconv_works=yes],
        [am_cv_func_iconv_works=no],
        [
changequote(,)dnl
         case "$host_os" in
           aix* | hpux*) am_cv_func_iconv_works="guessing no" ;;
           *)            am_cv_func_iconv_works="guessing yes" ;;
         esac
changequote([,])dnl
        ])
      LIBS="$am_save_LIBS"
    ])
    case "$am_cv_func_iconv_works" in
      *no) am_func_iconv=no am_cv_lib_iconv=no ;;
      *)   am_func_iconv=yes ;;
    esac
  else
    am_func_iconv=no am_cv_lib_iconv=no
  fi
  if test "$am_func_iconv" = yes; then
    AC_DEFINE([HAVE_ICONV], [1],
      [Define if you have the iconv() function and it works.])
  fi
  if test "$am_cv_lib_iconv" = yes; then
    AC_MSG_CHECKING([how to link with libiconv])
    AC_MSG_RESULT([$LIBICONV])
  else
    dnl If $LIBICONV didn't lead to a usable library, we don't need $INCICONV
    dnl either.
    CPPFLAGS="$am_save_CPPFLAGS"
    LIBICONV=
    LTLIBICONV=
  fi
  AC_SUBST([LIBICONV])
  AC_SUBST([LTLIBICONV])
])

dnl Define AM_ICONV using AC_DEFUN_ONCE for Autoconf >= 2.64, in order to
dnl avoid warnings like
dnl "warning: AC_REQUIRE: `AM_ICONV' was expanded before it was required".
dnl This is tricky because of the way 'aclocal' is implemented:
dnl - It requires defining an auxiliary macro whose name ends in AC_DEFUN.
dnl   Otherwise aclocal's initial scan pass would miss the macro definition.
dnl - It requires a line break inside the AC_DEFUN_ONCE and AC_DEFUN expansions.
dnl   Otherwise aclocal would emit many "Use of uninitialized value $1"
dnl   warnings.
m4_define([gl_iconv_AC_DEFUN],
  m4_version_prereq([2.64],
    [[AC_DEFUN_ONCE(
        [$1], [$2])]],
    [m4_ifdef([gl_00GNULIB],
       [[AC_DEFUN_ONCE(
           [$1], [$2])]],
       [[AC_DEFUN(
           [$1], [$2])]])]))
gl_iconv_AC_DEFUN([AM_ICONV],
[
  AM_ICONV_LINK
  if test "$am_cv_func_iconv" = yes; then
    AC_MSG_CHECKING([for iconv declaration])
    AC_CACHE_VAL([am_cv_proto_iconv], [
      AC_COMPILE_IFELSE(
        [AC_LANG_PROGRAM(
           [[
#include <stdlib.h>
#include <iconv.h>
extern
#ifdef __cplusplus
"C"
#endif
#if defined(__STDC__) || defined(_MSC_VER) || defined(__cplusplus)
size_t iconv (iconv_t cd, char * *inbuf, size_t *inbytesleft, char * *outbuf, size_t *outbytesleft);
#else
size_t iconv();
#endif
           ]],
           [[]])],
        [am_cv_proto_iconv_arg1=""],
        [am_cv_proto_iconv_arg1="const"])
      am_cv_proto_iconv="extern size_t iconv (iconv_t cd, $am_cv_proto_iconv_arg1 char * *inbuf, size_t *inbytesleft, char * *outbuf, size_t *outbytesleft);"])
    am_cv_proto_iconv=`echo "[$]am_cv_proto_iconv" | tr -s ' ' | sed -e 's/( /(/'`
    AC_MSG_RESULT([
         $am_cv_proto_iconv])
    AC_DEFINE_UNQUOTED([ICONV_CONST], [$am_cv_proto_iconv_arg1],
      [Define as const if the declaration of iconv() needs const.])
    dnl Also substitute ICONV_CONST in the gnulib generated <iconv.h>.
    m4_ifdef([gl_ICONV_H_DEFAULTS],
      [AC_REQUIRE([gl_ICONV_H_DEFAULTS])
       if test -n "$am_cv_proto_iconv_arg1"; then
         ICONV_CONST="const"
       fi
      ])
  fi
])

# intlmacosx.m4 serial 5 (gettext-0.18.2)
dnl Copyright (C) 2004-2013 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.
dnl
dnl This file can can be used in projects which are not available under
dnl the GNU General Public License or the GNU Library General Public
dnl License but which still want to provide support for the GNU gettext
dnl functionality.
dnl Please note that the actual code of the GNU gettext library is covered
dnl by the GNU Library General Public License, and the rest of the GNU
dnl gettext package package is covered by the GNU General Public License.
dnl They are *not* in the public domain.

dnl Checks for special options needed on Mac OS X.
dnl Defines INTL_MACOSX_LIBS.
AC_DEFUN([gt_INTL_MACOSX],
[
  dnl Check for API introduced in Mac OS X 10.2.
  AC_CACHE_CHECK([for CFPreferencesCopyAppValue],
    [gt_cv_func_CFPreferencesCopyAppValue],
    [gt_save_LIBS="$LIBS"
     LIBS="$LIBS -Wl,-framework -Wl,CoreFoundation"
     AC_LINK_IFELSE(
       [AC_LANG_PROGRAM(
          [[#include <CoreFoundation/CFPreferences.h>]],
          [[CFPreferencesCopyAppValue(NULL, NULL)]])],
       [gt_cv_func_CFPreferencesCopyAppValue=yes],
       [gt_cv_func_CFPreferencesCopyAppValue=no])
     LIBS="$gt_save_LIBS"])
  if test $gt_cv_func_CFPreferencesCopyAppValue = yes; then
    AC_DEFINE([HAVE_CFPREFERENCESCOPYAPPVALUE], [1],
      [Define to 1 if you have the Mac OS X function CFPreferencesCopyAppValue in the CoreFoundation framework.])
  fi
  dnl Check for API introduced in Mac OS X 10.3.
  AC_CACHE_CHECK([for CFLocaleCopyCurrent], [gt_cv_func_CFLocaleCopyCurrent],
    [gt_save_LIBS="$LIBS"
     LIBS="$LIBS -Wl,-framework -Wl,CoreFoundation"
     AC_LINK_IFELSE(
       [AC_LANG_PROGRAM(
          [[#include <CoreFoundation/CFLocale.h>]],
          [[CFLocaleCopyCurrent();]])],
       [gt_cv_func_CFLocaleCopyCurrent=yes],
       [gt_cv_func_CFLocaleCopyCurrent=no])
     LIBS="$gt_save_LIBS"])
  if test $gt_cv_func_CFLocaleCopyCurrent = yes; then
    AC_DEFINE([HAVE_CFLOCALECOPYCURRENT], [1],
      [Define to 1 if you have the Mac OS X function CFLocaleCopyCurrent in the CoreFoundation framework.])
  fi
  INTL_MACOSX_LIBS=
  if test $gt_cv_func_CFPreferencesCopyAppValue = yes || test $gt_cv_func_CFLocaleCopyCurrent = yes; then
    INTL_MACOSX_LIBS="-Wl,-framework -Wl,CoreFoundation"
  fi
  AC_SUBST([INTL_MACOSX_LIBS])
])


dnl IT_PROG_INTLTOOL([MINIMUM-VERSION], [no-xml])
# serial 42 IT_PROG_INTLTOOL
AC_DEFUN([IT_PROG_INTLTOOL], [
AC_PREREQ([2.50])dnl
AC_REQUIRE([AM_NLS])dnl

case "$am__api_version" in
    1.[01234])
	AC_MSG_ERROR([Automake 1.5 or newer is required to use intltool])
    ;;
    *)
    ;;
esac

INTLTOOL_REQUIRED_VERSION_AS_INT=`echo $1 | awk -F. '{ print $ 1 * 1000 + $ 2 * 100 + $ 3; }'`
INTLTOOL_APPLIED_VERSION=`intltool-update --version | head -1 | cut -d" " -f3`
INTLTOOL_APPLIED_VERSION_AS_INT=`echo $INTLTOOL_APPLIED_VERSION | awk -F. '{ print $ 1 * 1000 + $ 2 * 100 + $ 3; }'`
if test -n "$1"; then
    AC_MSG_CHECKING([for intltool >= $1])
    AC_MSG_RESULT([$INTLTOOL_APPLIED_VERSION found])
    test "$INTLTOOL_APPLIED_VERSION_AS_INT" -ge "$INTLTOOL_REQUIRED_VERSION_AS_INT" ||
	AC_MSG_ERROR([Your intltool is too old.  You need intltool $1 or later.])
fi

AC_PATH_PROG(INTLTOOL_UPDATE, [intltool-update])
AC_PATH_PROG(INTLTOOL_MERGE, [intltool-merge])
AC_PATH_PROG(INTLTOOL_EXTRACT, [intltool-extract])
if test -z "$INTLTOOL_UPDATE" -o -z "$INTLTOOL_MERGE" -o -z "$INTLTOOL_EXTRACT"; then
    AC_MSG_ERROR([The intltool scripts were not found. Please install intltool.])
fi

if test -z "$AM_DEFAULT_VERBOSITY"; then
  AM_DEFAULT_VERBOSITY=1
fi
AC_SUBST([AM_DEFAULT_VERBOSITY])

INTLTOOL_V_MERGE='$(INTLTOOL__v_MERGE_$(V))'
INTLTOOL__v_MERGE_='$(INTLTOOL__v_MERGE_$(AM_DEFAULT_VERBOSITY))'
INTLTOOL__v_MERGE_0='@echo "  ITMRG " [$]@;'
AC_SUBST(INTLTOOL_V_MERGE)
AC_SUBST(INTLTOOL__v_MERGE_)
AC_SUBST(INTLTOOL__v_MERGE_0)

INTLTOOL_V_MERGE_OPTIONS='$(intltool__v_merge_options_$(V))'
intltool__v_merge_options_='$(intltool__v_merge_options_$(AM_DEFAULT_VERBOSITY))'
intltool__v_merge_options_0='-q'
AC_SUBST(INTLTOOL_V_MERGE_OPTIONS)
AC_SUBST(intltool__v_merge_options_)
AC_SUBST(intltool__v_merge_options_0)

  INTLTOOL_DESKTOP_RULE='%.desktop:   %.desktop.in   $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -d -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
INTLTOOL_DIRECTORY_RULE='%.directory: %.directory.in $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -d -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
     INTLTOOL_KEYS_RULE='%.keys:      %.keys.in      $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -k -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
     INTLTOOL_PROP_RULE='%.prop:      %.prop.in      $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -d -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
      INTLTOOL_OAF_RULE='%.oaf:       %.oaf.in       $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -o -p $(top_srcdir)/po $< [$]@'
     INTLTOOL_PONG_RULE='%.pong:      %.pong.in      $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -x -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
   INTLTOOL_SERVER_RULE='%.server:    %.server.in    $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -o -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
    INTLTOOL_SHEET_RULE='%.sheet:     %.sheet.in     $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -x -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
INTLTOOL_SOUNDLIST_RULE='%.soundlist: %.soundlist.in $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -d -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
       INTLTOOL_UI_RULE='%.ui:        %.ui.in        $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -x -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
      INTLTOOL_XML_RULE='%.xml:       %.xml.in       $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -x -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
if test "$INTLTOOL_APPLIED_VERSION_AS_INT" -ge 5000; then
      INTLTOOL_XML_NOMERGE_RULE='%.xml:       %.xml.in       $(INTLTOOL_MERGE) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -x -u --no-translations $< [$]@'
else
      INTLTOOL_XML_NOMERGE_RULE='%.xml:       %.xml.in       $(INTLTOOL_MERGE) ; $(INTLTOOL_V_MERGE)_it_tmp_dir=tmp.intltool.[$][$]RANDOM && mkdir [$][$]_it_tmp_dir && LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -x -u [$][$]_it_tmp_dir $< [$]@ && rmdir [$][$]_it_tmp_dir'
fi
      INTLTOOL_XAM_RULE='%.xam:       %.xml.in       $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -x -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
      INTLTOOL_KBD_RULE='%.kbd:       %.kbd.in       $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -x -u -m -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
    INTLTOOL_CAVES_RULE='%.caves:     %.caves.in     $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -d -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
  INTLTOOL_SCHEMAS_RULE='%.schemas:   %.schemas.in   $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -s -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
    INTLTOOL_THEME_RULE='%.theme:     %.theme.in     $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -d -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@' 
    INTLTOOL_SERVICE_RULE='%.service: %.service.in   $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -d -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@'
   INTLTOOL_POLICY_RULE='%.policy:    %.policy.in    $(INTLTOOL_MERGE) $(wildcard $(top_srcdir)/po/*.po) ; $(INTLTOOL_V_MERGE)LC_ALL=C $(INTLTOOL_MERGE) $(INTLTOOL_V_MERGE_OPTIONS) -x -u -c $(top_builddir)/po/.intltool-merge-cache $(top_srcdir)/po $< [$]@'

_IT_SUBST(INTLTOOL_DESKTOP_RULE)
_IT_SUBST(INTLTOOL_DIRECTORY_RULE)
_IT_SUBST(INTLTOOL_KEYS_RULE)
_IT_SUBST(INTLTOOL_PROP_RULE)
_IT_SUBST(INTLTOOL_OAF_RULE)
_IT_SUBST(INTLTOOL_PONG_RULE)
_IT_SUBST(INTLTOOL_SERVER_RULE)
_IT_SUBST(INTLTOOL_SHEET_RULE)
_IT_SUBST(INTLTOOL_SOUNDLIST_RULE)
_IT_SUBST(INTLTOOL_UI_RULE)
_IT_SUBST(INTLTOOL_XAM_RULE)
_IT_SUBST(INTLTOOL_KBD_RULE)
_IT_SUBST(INTLTOOL_XML_RULE)
_IT_SUBST(INTLTOOL_XML_NOMERGE_RULE)
_IT_SUBST(INTLTOOL_CAVES_RULE)
_IT_SUBST(INTLTOOL_SCHEMAS_RULE)
_IT_SUBST(INTLTOOL_THEME_RULE)
_IT_SUBST(INTLTOOL_SERVICE_RULE)
_IT_SUBST(INTLTOOL_POLICY_RULE)

# Check the gettext tools to make sure they are GNU
AC_PATH_PROG(XGETTEXT, xgettext)
AC_PATH_PROG(MSGMERGE, msgmerge)
AC_PATH_PROG(MSGFMT, msgfmt)
AC_PATH_PROG(GMSGFMT, gmsgfmt, $MSGFMT)
if test -z "$XGETTEXT" -o -z "$MSGMERGE" -o -z "$MSGFMT"; then
    AC_MSG_ERROR([GNU gettext tools not found; required for intltool])
fi
xgversion="`$XGETTEXT --version|grep '(GNU ' 2> /dev/null`"
mmversion="`$MSGMERGE --version|grep '(GNU ' 2> /dev/null`"
mfversion="`$MSGFMT --version|grep '(GNU ' 2> /dev/null`"
if test -z "$xgversion" -o -z "$mmversion" -o -z "$mfversion"; then
    AC_MSG_ERROR([GNU gettext tools not found; required for intltool])
fi

AC_PATH_PROG(INTLTOOL_PERL, perl)
if test -z "$INTLTOOL_PERL"; then
   AC_MSG_ERROR([perl not found])
fi
AC_MSG_CHECKING([for perl >= 5.8.1])
$INTLTOOL_PERL -e "use 5.8.1;" > /dev/null 2>&1
if test $? -ne 0; then
   AC_MSG_ERROR([perl 5.8.1 is required for intltool])
else
   IT_PERL_VERSION=`$INTLTOOL_PERL -e "printf '%vd', $^V"`
   AC_MSG_RESULT([$IT_PERL_VERSION])
fi
if test "x$2" != "xno-xml"; then
   AC_MSG_CHECKING([for XML::Parser])
   if `$INTLTOOL_PERL -e "require XML::Parser" 2>/dev/null`; then
       AC_MSG_RESULT([ok])
   else
       AC_MSG_ERROR([XML::Parser perl module is required for intltool])
   fi
fi

# Substitute ALL_LINGUAS so we can use it in po/Makefile
AC_SUBST(ALL_LINGUAS)

# Set DATADIRNAME correctly if it is not set yet
# (copied from glib-gettext.m4)
if test -z "$DATADIRNAME"; then
  AC_LINK_IFELSE(
    [AC_LANG_PROGRAM([[]],
                     [[extern int _nl_msg_cat_cntr;
                       return _nl_msg_cat_cntr]])],
    [DATADIRNAME=share],
    [case $host in
    *-*-solaris*)
    dnl On Solaris, if bind_textdomain_codeset is in libc,
    dnl GNU format message catalog is always supported,
    dnl since both are added to the libc all together.
    dnl Hence, we'd like to go with DATADIRNAME=share
    dnl in this case.
    AC_CHECK_FUNC(bind_textdomain_codeset,
      [DATADIRNAME=share], [DATADIRNAME=lib])
    ;;
    *)
    [DATADIRNAME=lib]
    ;;
    esac])
fi
AC_SUBST(DATADIRNAME)

IT_PO_SUBDIR([po])

])


# IT_PO_SUBDIR(DIRNAME)
# ---------------------
# All po subdirs have to be declared with this macro; the subdir "po" is
# declared by IT_PROG_INTLTOOL.
#
AC_DEFUN([IT_PO_SUBDIR],
[AC_PREREQ([2.53])dnl We use ac_top_srcdir inside AC_CONFIG_COMMANDS.
dnl
dnl The following CONFIG_COMMANDS should be executed at the very end
dnl of config.status.
AC_CONFIG_COMMANDS_PRE([
  AC_CONFIG_COMMANDS([$1/stamp-it], [
    if [ ! grep "^# INTLTOOL_MAKEFILE$" "$1/Makefile.in" > /dev/null ]; then
       AC_MSG_ERROR([$1/Makefile.in.in was not created by intltoolize.])
    fi
    rm -f "$1/stamp-it" "$1/stamp-it.tmp" "$1/POTFILES" "$1/Makefile.tmp"
    >"$1/stamp-it.tmp"
    [sed '/^#/d
	 s/^[[].*] *//
	 /^[ 	]*$/d
	'"s|^|	$ac_top_srcdir/|" \
      "$srcdir/$1/POTFILES.in" | sed '$!s/$/ \\/' >"$1/POTFILES"
    ]
    [sed '/^POTFILES =/,/[^\\]$/ {
		/^POTFILES =/!d
		r $1/POTFILES
	  }
	 ' "$1/Makefile.in" >"$1/Makefile"]
    rm -f "$1/Makefile.tmp"
    mv "$1/stamp-it.tmp" "$1/stamp-it"
  ])
])dnl
])

# _IT_SUBST(VARIABLE)
# -------------------
# Abstract macro to do either _AM_SUBST_NOTMAKE or AC_SUBST
#
AC_DEFUN([_IT_SUBST],
[
AC_SUBST([$1])
m4_ifdef([_AM_SUBST_NOTMAKE], [_AM_SUBST_NOTMAKE([$1])])
]
)

# deprecated macros
AU_ALIAS([AC_PROG_INTLTOOL], [IT_PROG_INTLTOOL])
# A hint is needed for aclocal from Automake <= 1.9.4:
# AC_DEFUN([AC_PROG_INTLTOOL], ...)


# lib-ld.m4 serial 6
dnl Copyright (C) 1996-2003, 2009-2013 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl Subroutines of libtool.m4,
dnl with replacements s/_*LT_PATH/AC_LIB_PROG/ and s/lt_/acl_/ to avoid
dnl collision with libtool.m4.

dnl From libtool-2.4. Sets the variable with_gnu_ld to yes or no.
AC_DEFUN([AC_LIB_PROG_LD_GNU],
[AC_CACHE_CHECK([if the linker ($LD) is GNU ld], [acl_cv_prog_gnu_ld],
[# I'd rather use --version here, but apparently some GNU lds only accept -v.
case `$LD -v 2>&1 </dev/null` in
*GNU* | *'with BFD'*)
  acl_cv_prog_gnu_ld=yes
  ;;
*)
  acl_cv_prog_gnu_ld=no
  ;;
esac])
with_gnu_ld=$acl_cv_prog_gnu_ld
])

dnl From libtool-2.4. Sets the variable LD.
AC_DEFUN([AC_LIB_PROG_LD],
[AC_REQUIRE([AC_PROG_CC])dnl
AC_REQUIRE([AC_CANONICAL_HOST])dnl

AC_ARG_WITH([gnu-ld],
    [AS_HELP_STRING([--with-gnu-ld],
        [assume the C compiler uses GNU ld [default=no]])],
    [test "$withval" = no || with_gnu_ld=yes],
    [with_gnu_ld=no])dnl

# Prepare PATH_SEPARATOR.
# The user is always right.
if test "${PATH_SEPARATOR+set}" != set; then
  # Determine PATH_SEPARATOR by trying to find /bin/sh in a PATH which
  # contains only /bin. Note that ksh looks also at the FPATH variable,
  # so we have to set that as well for the test.
  PATH_SEPARATOR=:
  (PATH='/bin;/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 \
    && { (PATH='/bin:/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 \
           || PATH_SEPARATOR=';'
       }
fi

ac_prog=ld
if test "$GCC" = yes; then
  # Check if gcc -print-prog-name=ld gives a path.
  AC_MSG_CHECKING([for ld used by $CC])
  case $host in
  *-*-mingw*)
    # gcc leaves a trailing carriage return which upsets mingw
    ac_prog=`($CC -print-prog-name=ld) 2>&5 | tr -d '\015'` ;;
  *)
    ac_prog=`($CC -print-prog-name=ld) 2>&5` ;;
  esac
  case $ac_prog in
    # Accept absolute paths.
    [[\\/]]* | ?:[[\\/]]*)
      re_direlt='/[[^/]][[^/]]*/\.\./'
      # Canonicalize the pathname of ld
      ac_prog=`echo "$ac_prog"| sed 's%\\\\%/%g'`
      while echo "$ac_prog" | grep "$re_direlt" > /dev/null 2>&1; do
        ac_prog=`echo $ac_prog| sed "s%$re_direlt%/%"`
      done
      test -z "$LD" && LD="$ac_prog"
      ;;
  "")
    # If it fails, then pretend we aren't using GCC.
    ac_prog=ld
    ;;
  *)
    # If it is relative, then search for the first ld in PATH.
    with_gnu_ld=unknown
    ;;
  esac
elif test "$with_gnu_ld" = yes; then
  AC_MSG_CHECKING([for GNU ld])
else
  AC_MSG_CHECKING([for non-GNU ld])
fi
AC_CACHE_VAL([acl_cv_path_LD],
[if test -z "$LD"; then
  acl_save_ifs="$IFS"; IFS=$PATH_SEPARATOR
  for ac_dir in $PATH; do
    IFS="$acl_save_ifs"
    test -z "$ac_dir" && ac_dir=.
    if test -f "$ac_dir/$ac_prog" || test -f "$ac_dir/$ac_prog$ac_exeext"; then
      acl_cv_path_LD="$ac_dir/$ac_prog"
      # Check to see if the program is GNU ld.  I'd rather use --version,
      # but apparently some variants of GNU ld only accept -v.
      # Break only if it was the GNU/non-GNU ld that we prefer.
      case `"$acl_cv_path_LD" -v 2>&1 </dev/null` in
      *GNU* | *'with BFD'*)
        test "$with_gnu_ld" != no && break
        ;;
      *)
        test "$with_gnu_ld" != yes && break
        ;;
      esac
    fi
  done
  IFS="$acl_save_ifs"
else
  acl_cv_path_LD="$LD" # Let the user override the test with a path.
fi])
LD="$acl_cv_path_LD"
if test -n "$LD"; then
  AC_MSG_RESULT([$LD])
else
  AC_MSG_RESULT([no])
fi
test -z "$LD" && AC_MSG_ERROR([no acceptable ld found in \$PATH])
AC_LIB_PROG_LD_GNU
])

# lib-link.m4 serial 26 (gettext-0.18.2)
dnl Copyright (C) 2001-2013 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl From Bruno Haible.

AC_PREREQ([2.54])

dnl AC_LIB_LINKFLAGS(name [, dependencies]) searches for libname and
dnl the libraries corresponding to explicit and implicit dependencies.
dnl Sets and AC_SUBSTs the LIB${NAME} and LTLIB${NAME} variables and
dnl augments the CPPFLAGS variable.
dnl Sets and AC_SUBSTs the LIB${NAME}_PREFIX variable to nonempty if libname
dnl was found in ${LIB${NAME}_PREFIX}/$acl_libdirstem.
AC_DEFUN([AC_LIB_LINKFLAGS],
[
  AC_REQUIRE([AC_LIB_PREPARE_PREFIX])
  AC_REQUIRE([AC_LIB_RPATH])
  pushdef([Name],[m4_translit([$1],[./+-], [____])])
  pushdef([NAME],[m4_translit([$1],[abcdefghijklmnopqrstuvwxyz./+-],
                                   [ABCDEFGHIJKLMNOPQRSTUVWXYZ____])])
  AC_CACHE_CHECK([how to link with lib[]$1], [ac_cv_lib[]Name[]_libs], [
    AC_LIB_LINKFLAGS_BODY([$1], [$2])
    ac_cv_lib[]Name[]_libs="$LIB[]NAME"
    ac_cv_lib[]Name[]_ltlibs="$LTLIB[]NAME"
    ac_cv_lib[]Name[]_cppflags="$INC[]NAME"
    ac_cv_lib[]Name[]_prefix="$LIB[]NAME[]_PREFIX"
  ])
  LIB[]NAME="$ac_cv_lib[]Name[]_libs"
  LTLIB[]NAME="$ac_cv_lib[]Name[]_ltlibs"
  INC[]NAME="$ac_cv_lib[]Name[]_cppflags"
  LIB[]NAME[]_PREFIX="$ac_cv_lib[]Name[]_prefix"
  AC_LIB_APPENDTOVAR([CPPFLAGS], [$INC]NAME)
  AC_SUBST([LIB]NAME)
  AC_SUBST([LTLIB]NAME)
  AC_SUBST([LIB]NAME[_PREFIX])
  dnl Also set HAVE_LIB[]NAME so that AC_LIB_HAVE_LINKFLAGS can reuse the
  dnl results of this search when this library appears as a dependency.
  HAVE_LIB[]NAME=yes
  popdef([NAME])
  popdef([Name])
])

dnl AC_LIB_HAVE_LINKFLAGS(name, dependencies, includes, testcode, [missing-message])
dnl searches for libname and the libraries corresponding to explicit and
dnl implicit dependencies, together with the specified include files and
dnl the ability to compile and link the specified testcode. The missing-message
dnl defaults to 'no' and may contain additional hints for the user.
dnl If found, it sets and AC_SUBSTs HAVE_LIB${NAME}=yes and the LIB${NAME}
dnl and LTLIB${NAME} variables and augments the CPPFLAGS variable, and
dnl #defines HAVE_LIB${NAME} to 1. Otherwise, it sets and AC_SUBSTs
dnl HAVE_LIB${NAME}=no and LIB${NAME} and LTLIB${NAME} to empty.
dnl Sets and AC_SUBSTs the LIB${NAME}_PREFIX variable to nonempty if libname
dnl was found in ${LIB${NAME}_PREFIX}/$acl_libdirstem.
AC_DEFUN([AC_LIB_HAVE_LINKFLAGS],
[
  AC_REQUIRE([AC_LIB_PREPARE_PREFIX])
  AC_REQUIRE([AC_LIB_RPATH])
  pushdef([Name],[m4_translit([$1],[./+-], [____])])
  pushdef([NAME],[m4_translit([$1],[abcdefghijklmnopqrstuvwxyz./+-],
                                   [ABCDEFGHIJKLMNOPQRSTUVWXYZ____])])

  dnl Search for lib[]Name and define LIB[]NAME, LTLIB[]NAME and INC[]NAME
  dnl accordingly.
  AC_LIB_LINKFLAGS_BODY([$1], [$2])

  dnl Add $INC[]NAME to CPPFLAGS before performing the following checks,
  dnl because if the user has installed lib[]Name and not disabled its use
  dnl via --without-lib[]Name-prefix, he wants to use it.
  ac_save_CPPFLAGS="$CPPFLAGS"
  AC_LIB_APPENDTOVAR([CPPFLAGS], [$INC]NAME)

  AC_CACHE_CHECK([for lib[]$1], [ac_cv_lib[]Name], [
    ac_save_LIBS="$LIBS"
    dnl If $LIB[]NAME contains some -l options, add it to the end of LIBS,
    dnl because these -l options might require -L options that are present in
    dnl LIBS. -l options benefit only from the -L options listed before it.
    dnl Otherwise, add it to the front of LIBS, because it may be a static
    dnl library that depends on another static library that is present in LIBS.
    dnl Static libraries benefit only from the static libraries listed after
    dnl it.
    case " $LIB[]NAME" in
      *" -l"*) LIBS="$LIBS $LIB[]NAME" ;;
      *)       LIBS="$LIB[]NAME $LIBS" ;;
    esac
    AC_LINK_IFELSE(
      [AC_LANG_PROGRAM([[$3]], [[$4]])],
      [ac_cv_lib[]Name=yes],
      [ac_cv_lib[]Name='m4_if([$5], [], [no], [[$5]])'])
    LIBS="$ac_save_LIBS"
  ])
  if test "$ac_cv_lib[]Name" = yes; then
    HAVE_LIB[]NAME=yes
    AC_DEFINE([HAVE_LIB]NAME, 1, [Define if you have the lib][$1 library.])
    AC_MSG_CHECKING([how to link with lib[]$1])
    AC_MSG_RESULT([$LIB[]NAME])
  else
    HAVE_LIB[]NAME=no
    dnl If $LIB[]NAME didn't lead to a usable library, we don't need
    dnl $INC[]NAME either.
    CPPFLAGS="$ac_save_CPPFLAGS"
    LIB[]NAME=
    LTLIB[]NAME=
    LIB[]NAME[]_PREFIX=
  fi
  AC_SUBST([HAVE_LIB]NAME)
  AC_SUBST([LIB]NAME)
  AC_SUBST([LTLIB]NAME)
  AC_SUBST([LIB]NAME[_PREFIX])
  popdef([NAME])
  popdef([Name])
])

dnl Determine the platform dependent parameters needed to use rpath:
dnl   acl_libext,
dnl   acl_shlibext,
dnl   acl_libname_spec,
dnl   acl_library_names_spec,
dnl   acl_hardcode_libdir_flag_spec,
dnl   acl_hardcode_libdir_separator,
dnl   acl_hardcode_direct,
dnl   acl_hardcode_minus_L.
AC_DEFUN([AC_LIB_RPATH],
[
  dnl Tell automake >= 1.10 to complain if config.rpath is missing.
  m4_ifdef([AC_REQUIRE_AUX_FILE], [AC_REQUIRE_AUX_FILE([config.rpath])])
  AC_REQUIRE([AC_PROG_CC])                dnl we use $CC, $GCC, $LDFLAGS
  AC_REQUIRE([AC_LIB_PROG_LD])            dnl we use $LD, $with_gnu_ld
  AC_REQUIRE([AC_CANONICAL_HOST])         dnl we use $host
  AC_REQUIRE([AC_CONFIG_AUX_DIR_DEFAULT]) dnl we use $ac_aux_dir
  AC_CACHE_CHECK([for shared library run path origin], [acl_cv_rpath], [
    CC="$CC" GCC="$GCC" LDFLAGS="$LDFLAGS" LD="$LD" with_gnu_ld="$with_gnu_ld" \
    ${CONFIG_SHELL-/bin/sh} "$ac_aux_dir/config.rpath" "$host" > conftest.sh
    . ./conftest.sh
    rm -f ./conftest.sh
    acl_cv_rpath=done
  ])
  wl="$acl_cv_wl"
  acl_libext="$acl_cv_libext"
  acl_shlibext="$acl_cv_shlibext"
  acl_libname_spec="$acl_cv_libname_spec"
  acl_library_names_spec="$acl_cv_library_names_spec"
  acl_hardcode_libdir_flag_spec="$acl_cv_hardcode_libdir_flag_spec"
  acl_hardcode_libdir_separator="$acl_cv_hardcode_libdir_separator"
  acl_hardcode_direct="$acl_cv_hardcode_direct"
  acl_hardcode_minus_L="$acl_cv_hardcode_minus_L"
  dnl Determine whether the user wants rpath handling at all.
  AC_ARG_ENABLE([rpath],
    [  --disable-rpath         do not hardcode runtime library paths],
    :, enable_rpath=yes)
])

dnl AC_LIB_FROMPACKAGE(name, package)
dnl declares that libname comes from the given package. The configure file
dnl will then not have a --with-libname-prefix option but a
dnl --with-package-prefix option. Several libraries can come from the same
dnl package. This declaration must occur before an AC_LIB_LINKFLAGS or similar
dnl macro call that searches for libname.
AC_DEFUN([AC_LIB_FROMPACKAGE],
[
  pushdef([NAME],[m4_translit([$1],[abcdefghijklmnopqrstuvwxyz./+-],
                                   [ABCDEFGHIJKLMNOPQRSTUVWXYZ____])])
  define([acl_frompackage_]NAME, [$2])
  popdef([NAME])
  pushdef([PACK],[$2])
  pushdef([PACKUP],[m4_translit(PACK,[abcdefghijklmnopqrstuvwxyz./+-],
                                     [ABCDEFGHIJKLMNOPQRSTUVWXYZ____])])
  define([acl_libsinpackage_]PACKUP,
    m4_ifdef([acl_libsinpackage_]PACKUP, [m4_defn([acl_libsinpackage_]PACKUP)[, ]],)[lib$1])
  popdef([PACKUP])
  popdef([PACK])
])

dnl AC_LIB_LINKFLAGS_BODY(name [, dependencies]) searches for libname and
dnl the libraries corresponding to explicit and implicit dependencies.
dnl Sets the LIB${NAME}, LTLIB${NAME} and INC${NAME} variables.
dnl Also, sets the LIB${NAME}_PREFIX variable to nonempty if libname was found
dnl in ${LIB${NAME}_PREFIX}/$acl_libdirstem.
AC_DEFUN([AC_LIB_LINKFLAGS_BODY],
[
  AC_REQUIRE([AC_LIB_PREPARE_MULTILIB])
  pushdef([NAME],[m4_translit([$1],[abcdefghijklmnopqrstuvwxyz./+-],
                                   [ABCDEFGHIJKLMNOPQRSTUVWXYZ____])])
  pushdef([PACK],[m4_ifdef([acl_frompackage_]NAME, [acl_frompackage_]NAME, lib[$1])])
  pushdef([PACKUP],[m4_translit(PACK,[abcdefghijklmnopqrstuvwxyz./+-],
                                     [ABCDEFGHIJKLMNOPQRSTUVWXYZ____])])
  pushdef([PACKLIBS],[m4_ifdef([acl_frompackage_]NAME, [acl_libsinpackage_]PACKUP, lib[$1])])
  dnl Autoconf >= 2.61 supports dots in --with options.
  pushdef([P_A_C_K],[m4_if(m4_version_compare(m4_defn([m4_PACKAGE_VERSION]),[2.61]),[-1],[m4_translit(PACK,[.],[_])],PACK)])
  dnl By default, look in $includedir and $libdir.
  use_additional=yes
  AC_LIB_WITH_FINAL_PREFIX([
    eval additional_includedir=\"$includedir\"
    eval additional_libdir=\"$libdir\"
  ])
  AC_ARG_WITH(P_A_C_K[-prefix],
[[  --with-]]P_A_C_K[[-prefix[=DIR]  search for ]PACKLIBS[ in DIR/include and DIR/lib
  --without-]]P_A_C_K[[-prefix     don't search for ]PACKLIBS[ in includedir and libdir]],
[
    if test "X$withval" = "Xno"; then
      use_additional=no
    else
      if test "X$withval" = "X"; then
        AC_LIB_WITH_FINAL_PREFIX([
          eval additional_includedir=\"$includedir\"
          eval additional_libdir=\"$libdir\"
        ])
      else
        additional_includedir="$withval/include"
        additional_libdir="$withval/$acl_libdirstem"
        if test "$acl_libdirstem2" != "$acl_libdirstem" \
           && ! test -d "$withval/$acl_libdirstem"; then
          additional_libdir="$withval/$acl_libdirstem2"
        fi
      fi
    fi
])
  dnl Search the library and its dependencies in $additional_libdir and
  dnl $LDFLAGS. Using breadth-first-seach.
  LIB[]NAME=
  LTLIB[]NAME=
  INC[]NAME=
  LIB[]NAME[]_PREFIX=
  dnl HAVE_LIB${NAME} is an indicator that LIB${NAME}, LTLIB${NAME} have been
  dnl computed. So it has to be reset here.
  HAVE_LIB[]NAME=
  rpathdirs=
  ltrpathdirs=
  names_already_handled=
  names_next_round='$1 $2'
  while test -n "$names_next_round"; do
    names_this_round="$names_next_round"
    names_next_round=
    for name in $names_this_round; do
      already_handled=
      for n in $names_already_handled; do
        if test "$n" = "$name"; then
          already_handled=yes
          break
        fi
      done
      if test -z "$already_handled"; then
        names_already_handled="$names_already_handled $name"
        dnl See if it was already located by an earlier AC_LIB_LINKFLAGS
        dnl or AC_LIB_HAVE_LINKFLAGS call.
        uppername=`echo "$name" | sed -e 'y|abcdefghijklmnopqrstuvwxyz./+-|ABCDEFGHIJKLMNOPQRSTUVWXYZ____|'`
        eval value=\"\$HAVE_LIB$uppername\"
        if test -n "$value"; then
          if test "$value" = yes; then
            eval value=\"\$LIB$uppername\"
            test -z "$value" || LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }$value"
            eval value=\"\$LTLIB$uppername\"
            test -z "$value" || LTLIB[]NAME="${LTLIB[]NAME}${LTLIB[]NAME:+ }$value"
          else
            dnl An earlier call to AC_LIB_HAVE_LINKFLAGS has determined
            dnl that this library doesn't exist. So just drop it.
            :
          fi
        else
          dnl Search the library lib$name in $additional_libdir and $LDFLAGS
          dnl and the already constructed $LIBNAME/$LTLIBNAME.
          found_dir=
          found_la=
          found_so=
          found_a=
          eval libname=\"$acl_libname_spec\"    # typically: libname=lib$name
          if test -n "$acl_shlibext"; then
            shrext=".$acl_shlibext"             # typically: shrext=.so
          else
            shrext=
          fi
          if test $use_additional = yes; then
            dir="$additional_libdir"
            dnl The same code as in the loop below:
            dnl First look for a shared library.
            if test -n "$acl_shlibext"; then
              if test -f "$dir/$libname$shrext"; then
                found_dir="$dir"
                found_so="$dir/$libname$shrext"
              else
                if test "$acl_library_names_spec" = '$libname$shrext$versuffix'; then
                  ver=`(cd "$dir" && \
                        for f in "$libname$shrext".*; do echo "$f"; done \
                        | sed -e "s,^$libname$shrext\\\\.,," \
                        | sort -t '.' -n -r -k1,1 -k2,2 -k3,3 -k4,4 -k5,5 \
                        | sed 1q ) 2>/dev/null`
                  if test -n "$ver" && test -f "$dir/$libname$shrext.$ver"; then
                    found_dir="$dir"
                    found_so="$dir/$libname$shrext.$ver"
                  fi
                else
                  eval library_names=\"$acl_library_names_spec\"
                  for f in $library_names; do
                    if test -f "$dir/$f"; then
                      found_dir="$dir"
                      found_so="$dir/$f"
                      break
                    fi
                  done
                fi
              fi
            fi
            dnl Then look for a static library.
            if test "X$found_dir" = "X"; then
              if test -f "$dir/$libname.$acl_libext"; then
                found_dir="$dir"
                found_a="$dir/$libname.$acl_libext"
              fi
            fi
            if test "X$found_dir" != "X"; then
              if test -f "$dir/$libname.la"; then
                found_la="$dir/$libname.la"
              fi
            fi
          fi
          if test "X$found_dir" = "X"; then
            for x in $LDFLAGS $LTLIB[]NAME; do
              AC_LIB_WITH_FINAL_PREFIX([eval x=\"$x\"])
              case "$x" in
                -L*)
                  dir=`echo "X$x" | sed -e 's/^X-L//'`
                  dnl First look for a shared library.
                  if test -n "$acl_shlibext"; then
                    if test -f "$dir/$libname$shrext"; then
                      found_dir="$dir"
                      found_so="$dir/$libname$shrext"
                    else
                      if test "$acl_library_names_spec" = '$libname$shrext$versuffix'; then
                        ver=`(cd "$dir" && \
                              for f in "$libname$shrext".*; do echo "$f"; done \
                              | sed -e "s,^$libname$shrext\\\\.,," \
                              | sort -t '.' -n -r -k1,1 -k2,2 -k3,3 -k4,4 -k5,5 \
                              | sed 1q ) 2>/dev/null`
                        if test -n "$ver" && test -f "$dir/$libname$shrext.$ver"; then
                          found_dir="$dir"
                          found_so="$dir/$libname$shrext.$ver"
                        fi
                      else
                        eval library_names=\"$acl_library_names_spec\"
                        for f in $library_names; do
                          if test -f "$dir/$f"; then
                            found_dir="$dir"
                            found_so="$dir/$f"
                            break
                          fi
                        done
                      fi
                    fi
                  fi
                  dnl Then look for a static library.
                  if test "X$found_dir" = "X"; then
                    if test -f "$dir/$libname.$acl_libext"; then
                      found_dir="$dir"
                      found_a="$dir/$libname.$acl_libext"
                    fi
                  fi
                  if test "X$found_dir" != "X"; then
                    if test -f "$dir/$libname.la"; then
                      found_la="$dir/$libname.la"
                    fi
                  fi
                  ;;
              esac
              if test "X$found_dir" != "X"; then
                break
              fi
            done
          fi
          if test "X$found_dir" != "X"; then
            dnl Found the library.
            LTLIB[]NAME="${LTLIB[]NAME}${LTLIB[]NAME:+ }-L$found_dir -l$name"
            if test "X$found_so" != "X"; then
              dnl Linking with a shared library. We attempt to hardcode its
              dnl directory into the executable's runpath, unless it's the
              dnl standard /usr/lib.
              if test "$enable_rpath" = no \
                 || test "X$found_dir" = "X/usr/$acl_libdirstem" \
                 || test "X$found_dir" = "X/usr/$acl_libdirstem2"; then
                dnl No hardcoding is needed.
                LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }$found_so"
              else
                dnl Use an explicit option to hardcode DIR into the resulting
                dnl binary.
                dnl Potentially add DIR to ltrpathdirs.
                dnl The ltrpathdirs will be appended to $LTLIBNAME at the end.
                haveit=
                for x in $ltrpathdirs; do
                  if test "X$x" = "X$found_dir"; then
                    haveit=yes
                    break
                  fi
                done
                if test -z "$haveit"; then
                  ltrpathdirs="$ltrpathdirs $found_dir"
                fi
                dnl The hardcoding into $LIBNAME is system dependent.
                if test "$acl_hardcode_direct" = yes; then
                  dnl Using DIR/libNAME.so during linking hardcodes DIR into the
                  dnl resulting binary.
                  LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }$found_so"
                else
                  if test -n "$acl_hardcode_libdir_flag_spec" && test "$acl_hardcode_minus_L" = no; then
                    dnl Use an explicit option to hardcode DIR into the resulting
                    dnl binary.
                    LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }$found_so"
                    dnl Potentially add DIR to rpathdirs.
                    dnl The rpathdirs will be appended to $LIBNAME at the end.
                    haveit=
                    for x in $rpathdirs; do
                      if test "X$x" = "X$found_dir"; then
                        haveit=yes
                        break
                      fi
                    done
                    if test -z "$haveit"; then
                      rpathdirs="$rpathdirs $found_dir"
                    fi
                  else
                    dnl Rely on "-L$found_dir".
                    dnl But don't add it if it's already contained in the LDFLAGS
                    dnl or the already constructed $LIBNAME
                    haveit=
                    for x in $LDFLAGS $LIB[]NAME; do
                      AC_LIB_WITH_FINAL_PREFIX([eval x=\"$x\"])
                      if test "X$x" = "X-L$found_dir"; then
                        haveit=yes
                        break
                      fi
                    done
                    if test -z "$haveit"; then
                      LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }-L$found_dir"
                    fi
                    if test "$acl_hardcode_minus_L" != no; then
                      dnl FIXME: Not sure whether we should use
                      dnl "-L$found_dir -l$name" or "-L$found_dir $found_so"
                      dnl here.
                      LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }$found_so"
                    else
                      dnl We cannot use $acl_hardcode_runpath_var and LD_RUN_PATH
                      dnl here, because this doesn't fit in flags passed to the
                      dnl compiler. So give up. No hardcoding. This affects only
                      dnl very old systems.
                      dnl FIXME: Not sure whether we should use
                      dnl "-L$found_dir -l$name" or "-L$found_dir $found_so"
                      dnl here.
                      LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }-l$name"
                    fi
                  fi
                fi
              fi
            else
              if test "X$found_a" != "X"; then
                dnl Linking with a static library.
                LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }$found_a"
              else
                dnl We shouldn't come here, but anyway it's good to have a
                dnl fallback.
                LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }-L$found_dir -l$name"
              fi
            fi
            dnl Assume the include files are nearby.
            additional_includedir=
            case "$found_dir" in
              */$acl_libdirstem | */$acl_libdirstem/)
                basedir=`echo "X$found_dir" | sed -e 's,^X,,' -e "s,/$acl_libdirstem/"'*$,,'`
                if test "$name" = '$1'; then
                  LIB[]NAME[]_PREFIX="$basedir"
                fi
                additional_includedir="$basedir/include"
                ;;
              */$acl_libdirstem2 | */$acl_libdirstem2/)
                basedir=`echo "X$found_dir" | sed -e 's,^X,,' -e "s,/$acl_libdirstem2/"'*$,,'`
                if test "$name" = '$1'; then
                  LIB[]NAME[]_PREFIX="$basedir"
                fi
                additional_includedir="$basedir/include"
                ;;
            esac
            if test "X$additional_includedir" != "X"; then
              dnl Potentially add $additional_includedir to $INCNAME.
              dnl But don't add it
              dnl   1. if it's the standard /usr/include,
              dnl   2. if it's /usr/local/include and we are using GCC on Linux,
              dnl   3. if it's already present in $CPPFLAGS or the already
              dnl      constructed $INCNAME,
              dnl   4. if it doesn't exist as a directory.
              if test "X$additional_includedir" != "X/usr/include"; then
                haveit=
                if test "X$additional_includedir" = "X/usr/local/include"; then
                  if test -n "$GCC"; then
                    case $host_os in
                      linux* | gnu* | k*bsd*-gnu) haveit=yes;;
                    esac
                  fi
                fi
                if test -z "$haveit"; then
                  for x in $CPPFLAGS $INC[]NAME; do
                    AC_LIB_WITH_FINAL_PREFIX([eval x=\"$x\"])
                    if test "X$x" = "X-I$additional_includedir"; then
                      haveit=yes
                      break
                    fi
                  done
                  if test -z "$haveit"; then
                    if test -d "$additional_includedir"; then
                      dnl Really add $additional_includedir to $INCNAME.
                      INC[]NAME="${INC[]NAME}${INC[]NAME:+ }-I$additional_includedir"
                    fi
                  fi
                fi
              fi
            fi
            dnl Look for dependencies.
            if test -n "$found_la"; then
              dnl Read the .la file. It defines the variables
              dnl dlname, library_names, old_library, dependency_libs, current,
              dnl age, revision, installed, dlopen, dlpreopen, libdir.
              save_libdir="$libdir"
              case "$found_la" in
                */* | *\\*) . "$found_la" ;;
                *) . "./$found_la" ;;
              esac
              libdir="$save_libdir"
              dnl We use only dependency_libs.
              for dep in $dependency_libs; do
                case "$dep" in
                  -L*)
                    additional_libdir=`echo "X$dep" | sed -e 's/^X-L//'`
                    dnl Potentially add $additional_libdir to $LIBNAME and $LTLIBNAME.
                    dnl But don't add it
                    dnl   1. if it's the standard /usr/lib,
                    dnl   2. if it's /usr/local/lib and we are using GCC on Linux,
                    dnl   3. if it's already present in $LDFLAGS or the already
                    dnl      constructed $LIBNAME,
                    dnl   4. if it doesn't exist as a directory.
                    if test "X$additional_libdir" != "X/usr/$acl_libdirstem" \
                       && test "X$additional_libdir" != "X/usr/$acl_libdirstem2"; then
                      haveit=
                      if test "X$additional_libdir" = "X/usr/local/$acl_libdirstem" \
                         || test "X$additional_libdir" = "X/usr/local/$acl_libdirstem2"; then
                        if test -n "$GCC"; then
                          case $host_os in
                            linux* | gnu* | k*bsd*-gnu) haveit=yes;;
                          esac
                        fi
                      fi
                      if test -z "$haveit"; then
                        haveit=
                        for x in $LDFLAGS $LIB[]NAME; do
                          AC_LIB_WITH_FINAL_PREFIX([eval x=\"$x\"])
                          if test "X$x" = "X-L$additional_libdir"; then
                            haveit=yes
                            break
                          fi
                        done
                        if test -z "$haveit"; then
                          if test -d "$additional_libdir"; then
                            dnl Really add $additional_libdir to $LIBNAME.
                            LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }-L$additional_libdir"
                          fi
                        fi
                        haveit=
                        for x in $LDFLAGS $LTLIB[]NAME; do
                          AC_LIB_WITH_FINAL_PREFIX([eval x=\"$x\"])
                          if test "X$x" = "X-L$additional_libdir"; then
                            haveit=yes
                            break
                          fi
                        done
                        if test -z "$haveit"; then
                          if test -d "$additional_libdir"; then
                            dnl Really add $additional_libdir to $LTLIBNAME.
                            LTLIB[]NAME="${LTLIB[]NAME}${LTLIB[]NAME:+ }-L$additional_libdir"
                          fi
                        fi
                      fi
                    fi
                    ;;
                  -R*)
                    dir=`echo "X$dep" | sed -e 's/^X-R//'`
                    if test "$enable_rpath" != no; then
                      dnl Potentially add DIR to rpathdirs.
                      dnl The rpathdirs will be appended to $LIBNAME at the end.
                      haveit=
                      for x in $rpathdirs; do
                        if test "X$x" = "X$dir"; then
                          haveit=yes
                          break
                        fi
                      done
                      if test -z "$haveit"; then
                        rpathdirs="$rpathdirs $dir"
                      fi
                      dnl Potentially add DIR to ltrpathdirs.
                      dnl The ltrpathdirs will be appended to $LTLIBNAME at the end.
                      haveit=
                      for x in $ltrpathdirs; do
                        if test "X$x" = "X$dir"; then
                          haveit=yes
                          break
                        fi
                      done
                      if test -z "$haveit"; then
                        ltrpathdirs="$ltrpathdirs $dir"
                      fi
                    fi
                    ;;
                  -l*)
                    dnl Handle this in the next round.
                    names_next_round="$names_next_round "`echo "X$dep" | sed -e 's/^X-l//'`
                    ;;
                  *.la)
                    dnl Handle this in the next round. Throw away the .la's
                    dnl directory; it is already contained in a preceding -L
                    dnl option.
                    names_next_round="$names_next_round "`echo "X$dep" | sed -e 's,^X.*/,,' -e 's,^lib,,' -e 's,\.la$,,'`
                    ;;
                  *)
                    dnl Most likely an immediate library name.
                    LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }$dep"
                    LTLIB[]NAME="${LTLIB[]NAME}${LTLIB[]NAME:+ }$dep"
                    ;;
                esac
              done
            fi
          else
            dnl Didn't find the library; assume it is in the system directories
            dnl known to the linker and runtime loader. (All the system
            dnl directories known to the linker should also be known to the
            dnl runtime loader, otherwise the system is severely misconfigured.)
            LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }-l$name"
            LTLIB[]NAME="${LTLIB[]NAME}${LTLIB[]NAME:+ }-l$name"
          fi
        fi
      fi
    done
  done
  if test "X$rpathdirs" != "X"; then
    if test -n "$acl_hardcode_libdir_separator"; then
      dnl Weird platform: only the last -rpath option counts, the user must
      dnl pass all path elements in one option. We can arrange that for a
      dnl single library, but not when more than one $LIBNAMEs are used.
      alldirs=
      for found_dir in $rpathdirs; do
        alldirs="${alldirs}${alldirs:+$acl_hardcode_libdir_separator}$found_dir"
      done
      dnl Note: acl_hardcode_libdir_flag_spec uses $libdir and $wl.
      acl_save_libdir="$libdir"
      libdir="$alldirs"
      eval flag=\"$acl_hardcode_libdir_flag_spec\"
      libdir="$acl_save_libdir"
      LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }$flag"
    else
      dnl The -rpath options are cumulative.
      for found_dir in $rpathdirs; do
        acl_save_libdir="$libdir"
        libdir="$found_dir"
        eval flag=\"$acl_hardcode_libdir_flag_spec\"
        libdir="$acl_save_libdir"
        LIB[]NAME="${LIB[]NAME}${LIB[]NAME:+ }$flag"
      done
    fi
  fi
  if test "X$ltrpathdirs" != "X"; then
    dnl When using libtool, the option that works for both libraries and
    dnl executables is -R. The -R options are cumulative.
    for found_dir in $ltrpathdirs; do
      LTLIB[]NAME="${LTLIB[]NAME}${LTLIB[]NAME:+ }-R$found_dir"
    done
  fi
  popdef([P_A_C_K])
  popdef([PACKLIBS])
  popdef([PACKUP])
  popdef([PACK])
  popdef([NAME])
])

dnl AC_LIB_APPENDTOVAR(VAR, CONTENTS) appends the elements of CONTENTS to VAR,
dnl unless already present in VAR.
dnl Works only for CPPFLAGS, not for LIB* variables because that sometimes
dnl contains two or three consecutive elements that belong together.
AC_DEFUN([AC_LIB_APPENDTOVAR],
[
  for element in [$2]; do
    haveit=
    for x in $[$1]; do
      AC_LIB_WITH_FINAL_PREFIX([eval x=\"$x\"])
      if test "X$x" = "X$element"; then
        haveit=yes
        break
      fi
    done
    if test -z "$haveit"; then
      [$1]="${[$1]}${[$1]:+ }$element"
    fi
  done
])

dnl For those cases where a variable contains several -L and -l options
dnl referring to unknown libraries and directories, this macro determines the
dnl necessary additional linker options for the runtime path.
dnl AC_LIB_LINKFLAGS_FROM_LIBS([LDADDVAR], [LIBSVALUE], [USE-LIBTOOL])
dnl sets LDADDVAR to linker options needed together with LIBSVALUE.
dnl If USE-LIBTOOL evaluates to non-empty, linking with libtool is assumed,
dnl otherwise linking without libtool is assumed.
AC_DEFUN([AC_LIB_LINKFLAGS_FROM_LIBS],
[
  AC_REQUIRE([AC_LIB_RPATH])
  AC_REQUIRE([AC_LIB_PREPARE_MULTILIB])
  $1=
  if test "$enable_rpath" != no; then
    if test -n "$acl_hardcode_libdir_flag_spec" && test "$acl_hardcode_minus_L" = no; then
      dnl Use an explicit option to hardcode directories into the resulting
      dnl binary.
      rpathdirs=
      next=
      for opt in $2; do
        if test -n "$next"; then
          dir="$next"
          dnl No need to hardcode the standard /usr/lib.
          if test "X$dir" != "X/usr/$acl_libdirstem" \
             && test "X$dir" != "X/usr/$acl_libdirstem2"; then
            rpathdirs="$rpathdirs $dir"
          fi
          next=
        else
          case $opt in
            -L) next=yes ;;
            -L*) dir=`echo "X$opt" | sed -e 's,^X-L,,'`
                 dnl No need to hardcode the standard /usr/lib.
                 if test "X$dir" != "X/usr/$acl_libdirstem" \
                    && test "X$dir" != "X/usr/$acl_libdirstem2"; then
                   rpathdirs="$rpathdirs $dir"
                 fi
                 next= ;;
            *) next= ;;
          esac
        fi
      done
      if test "X$rpathdirs" != "X"; then
        if test -n ""$3""; then
          dnl libtool is used for linking. Use -R options.
          for dir in $rpathdirs; do
            $1="${$1}${$1:+ }-R$dir"
          done
        else
          dnl The linker is used for linking directly.
          if test -n "$acl_hardcode_libdir_separator"; then
            dnl Weird platform: only the last -rpath option counts, the user
            dnl must pass all path elements in one option.
            alldirs=
            for dir in $rpathdirs; do
              alldirs="${alldirs}${alldirs:+$acl_hardcode_libdir_separator}$dir"
            done
            acl_save_libdir="$libdir"
            libdir="$alldirs"
            eval flag=\"$acl_hardcode_libdir_flag_spec\"
            libdir="$acl_save_libdir"
            $1="$flag"
          else
            dnl The -rpath options are cumulative.
            for dir in $rpathdirs; do
              acl_save_libdir="$libdir"
              libdir="$dir"
              eval flag=\"$acl_hardcode_libdir_flag_spec\"
              libdir="$acl_save_libdir"
              $1="${$1}${$1:+ }$flag"
            done
          fi
        fi
      fi
    fi
  fi
  AC_SUBST([$1])
])

# lib-prefix.m4 serial 7 (gettext-0.18)
dnl Copyright (C) 2001-2005, 2008-2013 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

dnl From Bruno Haible.

dnl AC_LIB_ARG_WITH is synonymous to AC_ARG_WITH in autoconf-2.13, and
dnl similar to AC_ARG_WITH in autoconf 2.52...2.57 except that is doesn't
dnl require excessive bracketing.
ifdef([AC_HELP_STRING],
[AC_DEFUN([AC_LIB_ARG_WITH], [AC_ARG_WITH([$1],[[$2]],[$3],[$4])])],
[AC_DEFUN([AC_][LIB_ARG_WITH], [AC_ARG_WITH([$1],[$2],[$3],[$4])])])

dnl AC_LIB_PREFIX adds to the CPPFLAGS and LDFLAGS the flags that are needed
dnl to access previously installed libraries. The basic assumption is that
dnl a user will want packages to use other packages he previously installed
dnl with the same --prefix option.
dnl This macro is not needed if only AC_LIB_LINKFLAGS is used to locate
dnl libraries, but is otherwise very convenient.
AC_DEFUN([AC_LIB_PREFIX],
[
  AC_BEFORE([$0], [AC_LIB_LINKFLAGS])
  AC_REQUIRE([AC_PROG_CC])
  AC_REQUIRE([AC_CANONICAL_HOST])
  AC_REQUIRE([AC_LIB_PREPARE_MULTILIB])
  AC_REQUIRE([AC_LIB_PREPARE_PREFIX])
  dnl By default, look in $includedir and $libdir.
  use_additional=yes
  AC_LIB_WITH_FINAL_PREFIX([
    eval additional_includedir=\"$includedir\"
    eval additional_libdir=\"$libdir\"
  ])
  AC_LIB_ARG_WITH([lib-prefix],
[  --with-lib-prefix[=DIR] search for libraries in DIR/include and DIR/lib
  --without-lib-prefix    don't search for libraries in includedir and libdir],
[
    if test "X$withval" = "Xno"; then
      use_additional=no
    else
      if test "X$withval" = "X"; then
        AC_LIB_WITH_FINAL_PREFIX([
          eval additional_includedir=\"$includedir\"
          eval additional_libdir=\"$libdir\"
        ])
      else
        additional_includedir="$withval/include"
        additional_libdir="$withval/$acl_libdirstem"
      fi
    fi
])
  if test $use_additional = yes; then
    dnl Potentially add $additional_includedir to $CPPFLAGS.
    dnl But don't add it
    dnl   1. if it's the standard /usr/include,
    dnl   2. if it's already present in $CPPFLAGS,
    dnl   3. if it's /usr/local/include and we are using GCC on Linux,
    dnl   4. if it doesn't exist as a directory.
    if test "X$additional_includedir" != "X/usr/include"; then
      haveit=
      for x in $CPPFLAGS; do
        AC_LIB_WITH_FINAL_PREFIX([eval x=\"$x\"])
        if test "X$x" = "X-I$additional_includedir"; then
          haveit=yes
          break
        fi
      done
      if test -z "$haveit"; then
        if test "X$additional_includedir" = "X/usr/local/include"; then
          if test -n "$GCC"; then
            case $host_os in
              linux* | gnu* | k*bsd*-gnu) haveit=yes;;
            esac
          fi
        fi
        if test -z "$haveit"; then
          if test -d "$additional_includedir"; then
            dnl Really add $additional_includedir to $CPPFLAGS.
            CPPFLAGS="${CPPFLAGS}${CPPFLAGS:+ }-I$additional_includedir"
          fi
        fi
      fi
    fi
    dnl Potentially add $additional_libdir to $LDFLAGS.
    dnl But don't add it
    dnl   1. if it's the standard /usr/lib,
    dnl   2. if it's already present in $LDFLAGS,
    dnl   3. if it's /usr/local/lib and we are using GCC on Linux,
    dnl   4. if it doesn't exist as a directory.
    if test "X$additional_libdir" != "X/usr/$acl_libdirstem"; then
      haveit=
      for x in $LDFLAGS; do
        AC_LIB_WITH_FINAL_PREFIX([eval x=\"$x\"])
        if test "X$x" = "X-L$additional_libdir"; then
          haveit=yes
          break
        fi
      done
      if test -z "$haveit"; then
        if test "X$additional_libdir" = "X/usr/local/$acl_libdirstem"; then
          if test -n "$GCC"; then
            case $host_os in
              linux*) haveit=yes;;
            esac
          fi
        fi
        if test -z "$haveit"; then
          if test -d "$additional_libdir"; then
            dnl Really add $additional_libdir to $LDFLAGS.
            LDFLAGS="${LDFLAGS}${LDFLAGS:+ }-L$additional_libdir"
          fi
        fi
      fi
    fi
  fi
])

dnl AC_LIB_PREPARE_PREFIX creates variables acl_final_prefix,
dnl acl_final_exec_prefix, containing the values to which $prefix and
dnl $exec_prefix will expand at the end of the configure script.
AC_DEFUN([AC_LIB_PREPARE_PREFIX],
[
  dnl Unfortunately, prefix and exec_prefix get only finally determined
  dnl at the end of configure.
  if test "X$prefix" = "XNONE"; then
    acl_final_prefix="$ac_default_prefix"
  else
    acl_final_prefix="$prefix"
  fi
  if test "X$exec_prefix" = "XNONE"; then
    acl_final_exec_prefix='${prefix}'
  else
    acl_final_exec_prefix="$exec_prefix"
  fi
  acl_save_prefix="$prefix"
  prefix="$acl_final_prefix"
  eval acl_final_exec_prefix=\"$acl_final_exec_prefix\"
  prefix="$acl_save_prefix"
])

dnl AC_LIB_WITH_FINAL_PREFIX([statement]) evaluates statement, with the
dnl variables prefix and exec_prefix bound to the values they will have
dnl at the end of the configure script.
AC_DEFUN([AC_LIB_WITH_FINAL_PREFIX],
[
  acl_save_prefix="$prefix"
  prefix="$acl_final_prefix"
  acl_save_exec_prefix="$exec_prefix"
  exec_prefix="$acl_final_exec_prefix"
  $1
  exec_prefix="$acl_save_exec_prefix"
  prefix="$acl_save_prefix"
])

dnl AC_LIB_PREPARE_MULTILIB creates
dnl - a variable acl_libdirstem, containing the basename of the libdir, either
dnl   "lib" or "lib64" or "lib/64",
dnl - a variable acl_libdirstem2, as a secondary possible value for
dnl   acl_libdirstem, either the same as acl_libdirstem or "lib/sparcv9" or
dnl   "lib/amd64".
AC_DEFUN([AC_LIB_PREPARE_MULTILIB],
[
  dnl There is no formal standard regarding lib and lib64.
  dnl On glibc systems, the current practice is that on a system supporting
  dnl 32-bit and 64-bit instruction sets or ABIs, 64-bit libraries go under
  dnl $prefix/lib64 and 32-bit libraries go under $prefix/lib. We determine
  dnl the compiler's default mode by looking at the compiler's library search
  dnl path. If at least one of its elements ends in /lib64 or points to a
  dnl directory whose absolute pathname ends in /lib64, we assume a 64-bit ABI.
  dnl Otherwise we use the default, namely "lib".
  dnl On Solaris systems, the current practice is that on a system supporting
  dnl 32-bit and 64-bit instruction sets or ABIs, 64-bit libraries go under
  dnl $prefix/lib/64 (which is a symlink to either $prefix/lib/sparcv9 or
  dnl $prefix/lib/amd64) and 32-bit libraries go under $prefix/lib.
  AC_REQUIRE([AC_CANONICAL_HOST])
  acl_libdirstem=lib
  acl_libdirstem2=
  case "$host_os" in
    solaris*)
      dnl See Solaris 10 Software Developer Collection > Solaris 64-bit Developer's Guide > The Development Environment
      dnl <http://docs.sun.com/app/docs/doc/816-5138/dev-env?l=en&a=view>.
      dnl "Portable Makefiles should refer to any library directories using the 64 symbolic link."
      dnl But we want to recognize the sparcv9 or amd64 subdirectory also if the
      dnl symlink is missing, so we set acl_libdirstem2 too.
      AC_CACHE_CHECK([for 64-bit host], [gl_cv_solaris_64bit],
        [AC_EGREP_CPP([sixtyfour bits], [
#ifdef _LP64
sixtyfour bits
#endif
           ], [gl_cv_solaris_64bit=yes], [gl_cv_solaris_64bit=no])
        ])
      if test $gl_cv_solaris_64bit = yes; then
        acl_libdirstem=lib/64
        case "$host_cpu" in
          sparc*)        acl_libdirstem2=lib/sparcv9 ;;
          i*86 | x86_64) acl_libdirstem2=lib/amd64 ;;
        esac
      fi
      ;;
    *)
      searchpath=`(LC_ALL=C $CC -print-search-dirs) 2>/dev/null | sed -n -e 's,^libraries: ,,p' | sed -e 's,^=,,'`
      if test -n "$searchpath"; then
        acl_save_IFS="${IFS= 	}"; IFS=":"
        for searchdir in $searchpath; do
          if test -d "$searchdir"; then
            case "$searchdir" in
              */lib64/ | */lib64 ) acl_libdirstem=lib64 ;;
              */../ | */.. )
                # Better ignore directories of this form. They are misleading.
                ;;
              *) searchdir=`cd "$searchdir" && pwd`
                 case "$searchdir" in
                   */lib64 ) acl_libdirstem=lib64 ;;
                 esac ;;
            esac
          fi
        done
        IFS="$acl_save_IFS"
      fi
      ;;
  esac
  test -n "$acl_libdirstem2" || acl_libdirstem2="$acl_libdirstem"
])

# nls.m4 serial 5 (gettext-0.18)
dnl Copyright (C) 1995-2003, 2005-2006, 2008-2013 Free Software Foundation,
dnl Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.
dnl
dnl This file can can be used in projects which are not available under
dnl the GNU General Public License or the GNU Library General Public
dnl License but which still want to provide support for the GNU gettext
dnl functionality.
dnl Please note that the actual code of the GNU gettext library is covered
dnl by the GNU Library General Public License, and the rest of the GNU
dnl gettext package package is covered by the GNU General Public License.
dnl They are *not* in the public domain.

dnl Authors:
dnl   Ulrich Drepper <drepper@cygnus.com>, 1995-2000.
dnl   Bruno Haible <haible@clisp.cons.org>, 2000-2003.

AC_PREREQ([2.50])

AC_DEFUN([AM_NLS],
[
  AC_MSG_CHECKING([whether NLS is requested])
  dnl Default is enabled NLS
  AC_ARG_ENABLE([nls],
    [  --disable-nls           do not use Native Language Support],
    USE_NLS=$enableval, USE_NLS=yes)
  AC_MSG_RESULT([$USE_NLS])
  AC_SUBST([USE_NLS])
])

# pkg.m4 - Macros to locate and utilise pkg-config.            -*- Autoconf -*-
# serial 1 (pkg-config-0.24)
# 
# Copyright © 2004 Scott James Remnant <scott@netsplit.com>.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
# As a special exception to the GNU General Public License, if you
# distribute this file as part of a program that contains a
# configuration script generated by Autoconf, you may include it under
# the same distribution terms that you use for the rest of that program.

# PKG_PROG_PKG_CONFIG([MIN-VERSION])
# ----------------------------------
AC_DEFUN([PKG_PROG_PKG_CONFIG],
[m4_pattern_forbid([^_?PKG_[A-Z_]+$])
m4_pattern_allow([^PKG_CONFIG(_(PATH|LIBDIR|SYSROOT_DIR|ALLOW_SYSTEM_(CFLAGS|LIBS)))?$])
m4_pattern_allow([^PKG_CONFIG_(DISABLE_UNINSTALLED|TOP_BUILD_DIR|DEBUG_SPEW)$])
AC_ARG_VAR([PKG_CONFIG], [path to pkg-config utility])
AC_ARG_VAR([PKG_CONFIG_PATH], [directories to add to pkg-config's search path])
AC_ARG_VAR([PKG_CONFIG_LIBDIR], [path overriding pkg-config's built-in search path])

if test "x$ac_cv_env_PKG_CONFIG_set" != "xset"; then
	AC_PATH_TOOL([PKG_CONFIG], [pkg-config])
fi
if test -n "$PKG_CONFIG"; then
	_pkg_min_version=m4_default([$1], [0.9.0])
	AC_MSG_CHECKING([pkg-config is at least version $_pkg_min_version])
	if $PKG_CONFIG --atleast-pkgconfig-version $_pkg_min_version; then
		AC_MSG_RESULT([yes])
	else
		AC_MSG_RESULT([no])
		PKG_CONFIG=""
	fi
fi[]dnl
])# PKG_PROG_PKG_CONFIG

# PKG_CHECK_EXISTS(MODULES, [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
#
# Check to see whether a particular set of modules exists.  Similar
# to PKG_CHECK_MODULES(), but does not set variables or print errors.
#
# Please remember that m4 expands AC_REQUIRE([PKG_PROG_PKG_CONFIG])
# only at the first occurence in configure.ac, so if the first place
# it's called might be skipped (such as if it is within an "if", you
# have to call PKG_CHECK_EXISTS manually
# --------------------------------------------------------------
AC_DEFUN([PKG_CHECK_EXISTS],
[AC_REQUIRE([PKG_PROG_PKG_CONFIG])dnl
if test -n "$PKG_CONFIG" && \
    AC_RUN_LOG([$PKG_CONFIG --exists --print-errors "$1"]); then
  m4_default([$2], [:])
m4_ifvaln([$3], [else
  $3])dnl
fi])

# _PKG_CONFIG([VARIABLE], [COMMAND], [MODULES])
# ---------------------------------------------
m4_define([_PKG_CONFIG],
[if test -n "$$1"; then
    pkg_cv_[]$1="$$1"
 elif test -n "$PKG_CONFIG"; then
    PKG_CHECK_EXISTS([$3],
                     [pkg_cv_[]$1=`$PKG_CONFIG --[]$2 "$3" 2>/dev/null`
		      test "x$?" != "x0" && pkg_failed=yes ],
		     [pkg_failed=yes])
 else
    pkg_failed=untried
fi[]dnl
])# _PKG_CONFIG

# _PKG_SHORT_ERRORS_SUPPORTED
# -----------------------------
AC_DEFUN([_PKG_SHORT_ERRORS_SUPPORTED],
[AC_REQUIRE([PKG_PROG_PKG_CONFIG])
if $PKG_CONFIG --atleast-pkgconfig-version 0.20; then
        _pkg_short_errors_supported=yes
else
        _pkg_short_errors_supported=no
fi[]dnl
])# _PKG_SHORT_ERRORS_SUPPORTED


# PKG_CHECK_MODULES(VARIABLE-PREFIX, MODULES, [ACTION-IF-FOUND],
# [ACTION-IF-NOT-FOUND])
#
#
# Note that if there is a possibility the first call to
# PKG_CHECK_MODULES might not happen, you should be sure to include an
# explicit call to PKG_PROG_PKG_CONFIG in your configure.ac
#
#
# --------------------------------------------------------------
AC_DEFUN([PKG_CHECK_MODULES],
[AC_REQUIRE([PKG_PROG_PKG_CONFIG])dnl
AC_ARG_VAR([$1][_CFLAGS], [C compiler flags for $1, overriding pkg-config])dnl
AC_ARG_VAR([$1][_LIBS], [linker flags for $1, overriding pkg-config])dnl

pkg_failed=no
AC_MSG_CHECKING([for $1])

_PKG_CONFIG([$1][_CFLAGS], [cflags], [$2])
_PKG_CONFIG([$1][_LIBS], [libs], [$2])

m4_define([_PKG_TEXT], [Alternatively, you may set the environment variables $1[]_CFLAGS
and $1[]_LIBS to avoid the need to call pkg-config.
See the pkg-config man page for more details.])

if test $pkg_failed = yes; then
   	AC_MSG_RESULT([no])
        _PKG_SHORT_ERRORS_SUPPORTED
        if test $_pkg_short_errors_supported = yes; then
	        $1[]_PKG_ERRORS=`$PKG_CONFIG --short-errors --print-errors --cflags --libs "$2" 2>&1`
        else 
	        $1[]_PKG_ERRORS=`$PKG_CONFIG --print-errors --cflags --libs "$2" 2>&1`
        fi
	# Put the nasty error message in config.log where it belongs
	echo "$$1[]_PKG_ERRORS" >&AS_MESSAGE_LOG_FD

	m4_default([$4], [AC_MSG_ERROR(
[Package requirements ($2) were not met:

$$1_PKG_ERRORS

Consider adjusting the PKG_CONFIG_PATH environment variable if you
installed software in a non-standard prefix.

_PKG_TEXT])[]dnl
        ])
elif test $pkg_failed = untried; then
     	AC_MSG_RESULT([no])
	m4_default([$4], [AC_MSG_FAILURE(
[The pkg-config script could not be found or is too old.  Make sure it
is in your PATH or set the PKG_CONFIG environment variable to the full
path to pkg-config.

_PKG_TEXT

To get pkg-config, see <http://pkg-config.freedesktop.org/>.])[]dnl
        ])
else
	$1[]_CFLAGS=$pkg_cv_[]$1[]_CFLAGS
	$1[]_LIBS=$pkg_cv_[]$1[]_LIBS
        AC_MSG_RESULT([yes])
	$3
fi[]dnl
])# PKG_CHECK_MODULES


# PKG_INSTALLDIR(DIRECTORY)
# -------------------------
# Substitutes the variable pkgconfigdir as the location where a module
# should install pkg-config .pc files. By default the directory is
# $libdir/pkgconfig, but the default can be changed by passing
# DIRECTORY. The user can override through the --with-pkgconfigdir
# parameter.
AC_DEFUN([PKG_INSTALLDIR],
[m4_pushdef([pkg_default], [m4_default([$1], ['${libdir}/pkgconfig'])])
m4_pushdef([pkg_description],
    [pkg-config installation directory @<:@]pkg_default[@:>@])
AC_ARG_WITH([pkgconfigdir],
    [AS_HELP_STRING([--with-pkgconfigdir], pkg_description)],,
    [with_pkgconfigdir=]pkg_default)
AC_SUBST([pkgconfigdir], [$with_pkgconfigdir])
m4_popdef([pkg_default])
m4_popdef([pkg_description])
]) dnl PKG_INSTALLDIR


# PKG_NOARCH_INSTALLDIR(DIRECTORY)
# -------------------------
# Substitutes the variable noarch_pkgconfigdir as the location where a
# module should install arch-independent pkg-config .pc files. By
# default the directory is $datadir/pkgconfig, but the default can be
# changed by passing DIRECTORY. The user can override through the
# --with-noarch-pkgconfigdir parameter.
AC_DEFUN([PKG_NOARCH_INSTALLDIR],
[m4_pushdef([pkg_default], [m4_default([$1], ['${datadir}/pkgconfig'])])
m4_pushdef([pkg_description],
    [pkg-config arch-independent installation directory @<:@]pkg_default[@:>@])
AC_ARG_WITH([noarch-pkgconfigdir],
    [AS_HELP_STRING([--with-noarch-pkgconfigdir], pkg_description)],,
    [with_noarch_pkgconfigdir=]pkg_default)
AC_SUBST([noarch_pkgconfigdir], [$with_noarch_pkgconfigdir])
m4_popdef([pkg_default])
m4_popdef([pkg_description])
]) dnl PKG_NOARCH_INSTALLDIR

# po.m4 serial 20 (gettext-0.18.2)
dnl Copyright (C) 1995-2013 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.
dnl
dnl This file can can be used in projects which are not available under
dnl the GNU General Public License or the GNU Library General Public
dnl License but which still want to provide support for the GNU gettext
dnl functionality.
dnl Please note that the actual code of the GNU gettext library is covered
dnl by the GNU Library General Public License, and the rest of the GNU
dnl gettext package package is covered by the GNU General Public License.
dnl They are *not* in the public domain.

dnl Authors:
dnl   Ulrich Drepper <drepper@cygnus.com>, 1995-2000.
dnl   Bruno Haible <haible@clisp.cons.org>, 2000-2003.

AC_PREREQ([2.60])

dnl Checks for all prerequisites of the po subdirectory.
AC_DEFUN([AM_PO_SUBDIRS],
[
  AC_REQUIRE([AC_PROG_MAKE_SET])dnl
  AC_REQUIRE([AC_PROG_INSTALL])dnl
  AC_REQUIRE([AC_PROG_MKDIR_P])dnl
  AC_REQUIRE([AM_NLS])dnl

  dnl Release version of the gettext macros. This is used to ensure that
  dnl the gettext macros and po/Makefile.in.in are in sync.
  AC_SUBST([GETTEXT_MACRO_VERSION], [0.18])

  dnl Perform the following tests also if --disable-nls has been given,
  dnl because they are needed for "make dist" to work.

  dnl Search for GNU msgfmt in the PATH.
  dnl The first test excludes Solaris msgfmt and early GNU msgfmt versions.
  dnl The second test excludes FreeBSD msgfmt.
  AM_PATH_PROG_WITH_TEST(MSGFMT, msgfmt,
    [$ac_dir/$ac_word --statistics /dev/null >&]AS_MESSAGE_LOG_FD[ 2>&1 &&
     (if $ac_dir/$ac_word --statistics /dev/null 2>&1 >/dev/null | grep usage >/dev/null; then exit 1; else exit 0; fi)],
    :)
  AC_PATH_PROG([GMSGFMT], [gmsgfmt], [$MSGFMT])

  dnl Test whether it is GNU msgfmt >= 0.15.
changequote(,)dnl
  case `$MSGFMT --version | sed 1q | sed -e 's,^[^0-9]*,,'` in
    '' | 0.[0-9] | 0.[0-9].* | 0.1[0-4] | 0.1[0-4].*) MSGFMT_015=: ;;
    *) MSGFMT_015=$MSGFMT ;;
  esac
changequote([,])dnl
  AC_SUBST([MSGFMT_015])
changequote(,)dnl
  case `$GMSGFMT --version | sed 1q | sed -e 's,^[^0-9]*,,'` in
    '' | 0.[0-9] | 0.[0-9].* | 0.1[0-4] | 0.1[0-4].*) GMSGFMT_015=: ;;
    *) GMSGFMT_015=$GMSGFMT ;;
  esac
changequote([,])dnl
  AC_SUBST([GMSGFMT_015])

  dnl Search for GNU xgettext 0.12 or newer in the PATH.
  dnl The first test excludes Solaris xgettext and early GNU xgettext versions.
  dnl The second test excludes FreeBSD xgettext.
  AM_PATH_PROG_WITH_TEST(XGETTEXT, xgettext,
    [$ac_dir/$ac_word --omit-header --copyright-holder= --msgid-bugs-address= /dev/null >&]AS_MESSAGE_LOG_FD[ 2>&1 &&
     (if $ac_dir/$ac_word --omit-header --copyright-holder= --msgid-bugs-address= /dev/null 2>&1 >/dev/null | grep usage >/dev/null; then exit 1; else exit 0; fi)],
    :)
  dnl Remove leftover from FreeBSD xgettext call.
  rm -f messages.po

  dnl Test whether it is GNU xgettext >= 0.15.
changequote(,)dnl
  case `$XGETTEXT --version | sed 1q | sed -e 's,^[^0-9]*,,'` in
    '' | 0.[0-9] | 0.[0-9].* | 0.1[0-4] | 0.1[0-4].*) XGETTEXT_015=: ;;
    *) XGETTEXT_015=$XGETTEXT ;;
  esac
changequote([,])dnl
  AC_SUBST([XGETTEXT_015])

  dnl Search for GNU msgmerge 0.11 or newer in the PATH.
  AM_PATH_PROG_WITH_TEST(MSGMERGE, msgmerge,
    [$ac_dir/$ac_word --update -q /dev/null /dev/null >&]AS_MESSAGE_LOG_FD[ 2>&1], :)

  dnl Installation directories.
  dnl Autoconf >= 2.60 defines localedir. For older versions of autoconf, we
  dnl have to define it here, so that it can be used in po/Makefile.
  test -n "$localedir" || localedir='${datadir}/locale'
  AC_SUBST([localedir])

  dnl Support for AM_XGETTEXT_OPTION.
  test -n "${XGETTEXT_EXTRA_OPTIONS+set}" || XGETTEXT_EXTRA_OPTIONS=
  AC_SUBST([XGETTEXT_EXTRA_OPTIONS])

  AC_CONFIG_COMMANDS([po-directories], [[
    for ac_file in $CONFIG_FILES; do
      # Support "outfile[:infile[:infile...]]"
      case "$ac_file" in
        *:*) ac_file=`echo "$ac_file"|sed 's%:.*%%'` ;;
      esac
      # PO directories have a Makefile.in generated from Makefile.in.in.
      case "$ac_file" in */Makefile.in)
        # Adjust a relative srcdir.
        ac_dir=`echo "$ac_file"|sed 's%/[^/][^/]*$%%'`
        ac_dir_suffix=/`echo "$ac_dir"|sed 's%^\./%%'`
        ac_dots=`echo "$ac_dir_suffix"|sed 's%/[^/]*%../%g'`
        # In autoconf-2.13 it is called $ac_given_srcdir.
        # In autoconf-2.50 it is called $srcdir.
        test -n "$ac_given_srcdir" || ac_given_srcdir="$srcdir"
        case "$ac_given_srcdir" in
          .)  top_srcdir=`echo $ac_dots|sed 's%/$%%'` ;;
          /*) top_srcdir="$ac_given_srcdir" ;;
          *)  top_srcdir="$ac_dots$ac_given_srcdir" ;;
        esac
        # Treat a directory as a PO directory if and only if it has a
        # POTFILES.in file. This allows packages to have multiple PO
        # directories under different names or in different locations.
        if test -f "$ac_given_srcdir/$ac_dir/POTFILES.in"; then
          rm -f "$ac_dir/POTFILES"
          test -n "$as_me" && echo "$as_me: creating $ac_dir/POTFILES" || echo "creating $ac_dir/POTFILES"
          gt_tab=`printf '\t'`
          cat "$ac_given_srcdir/$ac_dir/POTFILES.in" | sed -e "/^#/d" -e "/^[ ${gt_tab}]*\$/d" -e "s,.*,     $top_srcdir/& \\\\," | sed -e "\$s/\(.*\) \\\\/\1/" > "$ac_dir/POTFILES"
          POMAKEFILEDEPS="POTFILES.in"
          # ALL_LINGUAS, POFILES, UPDATEPOFILES, DUMMYPOFILES, GMOFILES depend
          # on $ac_dir but don't depend on user-specified configuration
          # parameters.
          if test -f "$ac_given_srcdir/$ac_dir/LINGUAS"; then
            # The LINGUAS file contains the set of available languages.
            if test -n "$OBSOLETE_ALL_LINGUAS"; then
              test -n "$as_me" && echo "$as_me: setting ALL_LINGUAS in configure.in is obsolete" || echo "setting ALL_LINGUAS in configure.in is obsolete"
            fi
            ALL_LINGUAS_=`sed -e "/^#/d" -e "s/#.*//" "$ac_given_srcdir/$ac_dir/LINGUAS"`
            # Hide the ALL_LINGUAS assignment from automake < 1.5.
            eval 'ALL_LINGUAS''=$ALL_LINGUAS_'
            POMAKEFILEDEPS="$POMAKEFILEDEPS LINGUAS"
          else
            # The set of available languages was given in configure.in.
            # Hide the ALL_LINGUAS assignment from automake < 1.5.
            eval 'ALL_LINGUAS''=$OBSOLETE_ALL_LINGUAS'
          fi
          # Compute POFILES
          # as      $(foreach lang, $(ALL_LINGUAS), $(srcdir)/$(lang).po)
          # Compute UPDATEPOFILES
          # as      $(foreach lang, $(ALL_LINGUAS), $(lang).po-update)
          # Compute DUMMYPOFILES
          # as      $(foreach lang, $(ALL_LINGUAS), $(lang).nop)
          # Compute GMOFILES
          # as      $(foreach lang, $(ALL_LINGUAS), $(srcdir)/$(lang).gmo)
          case "$ac_given_srcdir" in
            .) srcdirpre= ;;
            *) srcdirpre='$(srcdir)/' ;;
          esac
          POFILES=
          UPDATEPOFILES=
          DUMMYPOFILES=
          GMOFILES=
          for lang in $ALL_LINGUAS; do
            POFILES="$POFILES $srcdirpre$lang.po"
            UPDATEPOFILES="$UPDATEPOFILES $lang.po-update"
            DUMMYPOFILES="$DUMMYPOFILES $lang.nop"
            GMOFILES="$GMOFILES $srcdirpre$lang.gmo"
          done
          # CATALOGS depends on both $ac_dir and the user's LINGUAS
          # environment variable.
          INST_LINGUAS=
          if test -n "$ALL_LINGUAS"; then
            for presentlang in $ALL_LINGUAS; do
              useit=no
              if test "%UNSET%" != "$LINGUAS"; then
                desiredlanguages="$LINGUAS"
              else
                desiredlanguages="$ALL_LINGUAS"
              fi
              for desiredlang in $desiredlanguages; do
                # Use the presentlang catalog if desiredlang is
                #   a. equal to presentlang, or
                #   b. a variant of presentlang (because in this case,
                #      presentlang can be used as a fallback for messages
                #      which are not translated in the desiredlang catalog).
                case "$desiredlang" in
                  "$presentlang"*) useit=yes;;
                esac
              done
              if test $useit = yes; then
                INST_LINGUAS="$INST_LINGUAS $presentlang"
              fi
            done
          fi
          CATALOGS=
          if test -n "$INST_LINGUAS"; then
            for lang in $INST_LINGUAS; do
              CATALOGS="$CATALOGS $lang.gmo"
            done
          fi
          test -n "$as_me" && echo "$as_me: creating $ac_dir/Makefile" || echo "creating $ac_dir/Makefile"
          sed -e "/^POTFILES =/r $ac_dir/POTFILES" -e "/^# Makevars/r $ac_given_srcdir/$ac_dir/Makevars" -e "s|@POFILES@|$POFILES|g" -e "s|@UPDATEPOFILES@|$UPDATEPOFILES|g" -e "s|@DUMMYPOFILES@|$DUMMYPOFILES|g" -e "s|@GMOFILES@|$GMOFILES|g" -e "s|@CATALOGS@|$CATALOGS|g" -e "s|@POMAKEFILEDEPS@|$POMAKEFILEDEPS|g" "$ac_dir/Makefile.in" > "$ac_dir/Makefile"
          for f in "$ac_given_srcdir/$ac_dir"/Rules-*; do
            if test -f "$f"; then
              case "$f" in
                *.orig | *.bak | *~) ;;
                *) cat "$f" >> "$ac_dir/Makefile" ;;
              esac
            fi
          done
        fi
        ;;
      esac
    done]],
   [# Capture the value of obsolete ALL_LINGUAS because we need it to compute
    # POFILES, UPDATEPOFILES, DUMMYPOFILES, GMOFILES, CATALOGS. But hide it
    # from automake < 1.5.
    eval 'OBSOLETE_ALL_LINGUAS''="$ALL_LINGUAS"'
    # Capture the value of LINGUAS because we need it to compute CATALOGS.
    LINGUAS="${LINGUAS-%UNSET%}"
   ])
])

dnl Postprocesses a Makefile in a directory containing PO files.
AC_DEFUN([AM_POSTPROCESS_PO_MAKEFILE],
[
  # When this code is run, in config.status, two variables have already been
  # set:
  # - OBSOLETE_ALL_LINGUAS is the value of LINGUAS set in configure.in,
  # - LINGUAS is the value of the environment variable LINGUAS at configure
  #   time.

changequote(,)dnl
  # Adjust a relative srcdir.
  ac_dir=`echo "$ac_file"|sed 's%/[^/][^/]*$%%'`
  ac_dir_suffix=/`echo "$ac_dir"|sed 's%^\./%%'`
  ac_dots=`echo "$ac_dir_suffix"|sed 's%/[^/]*%../%g'`
  # In autoconf-2.13 it is called $ac_given_srcdir.
  # In autoconf-2.50 it is called $srcdir.
  test -n "$ac_given_srcdir" || ac_given_srcdir="$srcdir"
  case "$ac_given_srcdir" in
    .)  top_srcdir=`echo $ac_dots|sed 's%/$%%'` ;;
    /*) top_srcdir="$ac_given_srcdir" ;;
    *)  top_srcdir="$ac_dots$ac_given_srcdir" ;;
  esac

  # Find a way to echo strings without interpreting backslash.
  if test "X`(echo '\t') 2>/dev/null`" = 'X\t'; then
    gt_echo='echo'
  else
    if test "X`(printf '%s\n' '\t') 2>/dev/null`" = 'X\t'; then
      gt_echo='printf %s\n'
    else
      echo_func () {
        cat <<EOT
$*
EOT
      }
      gt_echo='echo_func'
    fi
  fi

  # A sed script that extracts the value of VARIABLE from a Makefile.
  tab=`printf '\t'`
  sed_x_variable='
# Test if the hold space is empty.
x
s/P/P/
x
ta
# Yes it was empty. Look if we have the expected variable definition.
/^['"${tab}"' ]*VARIABLE['"${tab}"' ]*=/{
  # Seen the first line of the variable definition.
  s/^['"${tab}"' ]*VARIABLE['"${tab}"' ]*=//
  ba
}
bd
:a
# Here we are processing a line from the variable definition.
# Remove comment, more precisely replace it with a space.
s/#.*$/ /
# See if the line ends in a backslash.
tb
:b
s/\\$//
# Print the line, without the trailing backslash.
p
tc
# There was no trailing backslash. The end of the variable definition is
# reached. Clear the hold space.
s/^.*$//
x
bd
:c
# A trailing backslash means that the variable definition continues in the
# next line. Put a nonempty string into the hold space to indicate this.
s/^.*$/P/
x
:d
'
changequote([,])dnl

  # Set POTFILES to the value of the Makefile variable POTFILES.
  sed_x_POTFILES=`$gt_echo "$sed_x_variable" | sed -e '/^ *#/d' -e 's/VARIABLE/POTFILES/g'`
  POTFILES=`sed -n -e "$sed_x_POTFILES" < "$ac_file"`
  # Compute POTFILES_DEPS as
  #   $(foreach file, $(POTFILES), $(top_srcdir)/$(file))
  POTFILES_DEPS=
  for file in $POTFILES; do
    POTFILES_DEPS="$POTFILES_DEPS "'$(top_srcdir)/'"$file"
  done
  POMAKEFILEDEPS=""

  if test -n "$OBSOLETE_ALL_LINGUAS"; then
    test -n "$as_me" && echo "$as_me: setting ALL_LINGUAS in configure.in is obsolete" || echo "setting ALL_LINGUAS in configure.in is obsolete"
  fi
  if test -f "$ac_given_srcdir/$ac_dir/LINGUAS"; then
    # The LINGUAS file contains the set of available languages.
    ALL_LINGUAS_=`sed -e "/^#/d" -e "s/#.*//" "$ac_given_srcdir/$ac_dir/LINGUAS"`
    POMAKEFILEDEPS="$POMAKEFILEDEPS LINGUAS"
  else
    # Set ALL_LINGUAS to the value of the Makefile variable LINGUAS.
    sed_x_LINGUAS=`$gt_echo "$sed_x_variable" | sed -e '/^ *#/d' -e 's/VARIABLE/LINGUAS/g'`
    ALL_LINGUAS_=`sed -n -e "$sed_x_LINGUAS" < "$ac_file"`
  fi
  # Hide the ALL_LINGUAS assignment from automake < 1.5.
  eval 'ALL_LINGUAS''=$ALL_LINGUAS_'
  # Compute POFILES
  # as      $(foreach lang, $(ALL_LINGUAS), $(srcdir)/$(lang).po)
  # Compute UPDATEPOFILES
  # as      $(foreach lang, $(ALL_LINGUAS), $(lang).po-update)
  # Compute DUMMYPOFILES
  # as      $(foreach lang, $(ALL_LINGUAS), $(lang).nop)
  # Compute GMOFILES
  # as      $(foreach lang, $(ALL_LINGUAS), $(srcdir)/$(lang).gmo)
  # Compute PROPERTIESFILES
  # as      $(foreach lang, $(ALL_LINGUAS), $(top_srcdir)/$(DOMAIN)_$(lang).properties)
  # Compute CLASSFILES
  # as      $(foreach lang, $(ALL_LINGUAS), $(top_srcdir)/$(DOMAIN)_$(lang).class)
  # Compute QMFILES
  # as      $(foreach lang, $(ALL_LINGUAS), $(srcdir)/$(lang).qm)
  # Compute MSGFILES
  # as      $(foreach lang, $(ALL_LINGUAS), $(srcdir)/$(frob $(lang)).msg)
  # Compute RESOURCESDLLFILES
  # as      $(foreach lang, $(ALL_LINGUAS), $(srcdir)/$(frob $(lang))/$(DOMAIN).resources.dll)
  case "$ac_given_srcdir" in
    .) srcdirpre= ;;
    *) srcdirpre='$(srcdir)/' ;;
  esac
  POFILES=
  UPDATEPOFILES=
  DUMMYPOFILES=
  GMOFILES=
  PROPERTIESFILES=
  CLASSFILES=
  QMFILES=
  MSGFILES=
  RESOURCESDLLFILES=
  for lang in $ALL_LINGUAS; do
    POFILES="$POFILES $srcdirpre$lang.po"
    UPDATEPOFILES="$UPDATEPOFILES $lang.po-update"
    DUMMYPOFILES="$DUMMYPOFILES $lang.nop"
    GMOFILES="$GMOFILES $srcdirpre$lang.gmo"
    PROPERTIESFILES="$PROPERTIESFILES \$(top_srcdir)/\$(DOMAIN)_$lang.properties"
    CLASSFILES="$CLASSFILES \$(top_srcdir)/\$(DOMAIN)_$lang.class"
    QMFILES="$QMFILES $srcdirpre$lang.qm"
    frobbedlang=`echo $lang | sed -e 's/\..*$//' -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`
    MSGFILES="$MSGFILES $srcdirpre$frobbedlang.msg"
    frobbedlang=`echo $lang | sed -e 's/_/-/g' -e 's/^sr-CS/sr-SP/' -e 's/@latin$/-Latn/' -e 's/@cyrillic$/-Cyrl/' -e 's/^sr-SP$/sr-SP-Latn/' -e 's/^uz-UZ$/uz-UZ-Latn/'`
    RESOURCESDLLFILES="$RESOURCESDLLFILES $srcdirpre$frobbedlang/\$(DOMAIN).resources.dll"
  done
  # CATALOGS depends on both $ac_dir and the user's LINGUAS
  # environment variable.
  INST_LINGUAS=
  if test -n "$ALL_LINGUAS"; then
    for presentlang in $ALL_LINGUAS; do
      useit=no
      if test "%UNSET%" != "$LINGUAS"; then
        desiredlanguages="$LINGUAS"
      else
        desiredlanguages="$ALL_LINGUAS"
      fi
      for desiredlang in $desiredlanguages; do
        # Use the presentlang catalog if desiredlang is
        #   a. equal to presentlang, or
        #   b. a variant of presentlang (because in this case,
        #      presentlang can be used as a fallback for messages
        #      which are not translated in the desiredlang catalog).
        case "$desiredlang" in
          "$presentlang"*) useit=yes;;
        esac
      done
      if test $useit = yes; then
        INST_LINGUAS="$INST_LINGUAS $presentlang"
      fi
    done
  fi
  CATALOGS=
  JAVACATALOGS=
  QTCATALOGS=
  TCLCATALOGS=
  CSHARPCATALOGS=
  if test -n "$INST_LINGUAS"; then
    for lang in $INST_LINGUAS; do
      CATALOGS="$CATALOGS $lang.gmo"
      JAVACATALOGS="$JAVACATALOGS \$(DOMAIN)_$lang.properties"
      QTCATALOGS="$QTCATALOGS $lang.qm"
      frobbedlang=`echo $lang | sed -e 's/\..*$//' -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`
      TCLCATALOGS="$TCLCATALOGS $frobbedlang.msg"
      frobbedlang=`echo $lang | sed -e 's/_/-/g' -e 's/^sr-CS/sr-SP/' -e 's/@latin$/-Latn/' -e 's/@cyrillic$/-Cyrl/' -e 's/^sr-SP$/sr-SP-Latn/' -e 's/^uz-UZ$/uz-UZ-Latn/'`
      CSHARPCATALOGS="$CSHARPCATALOGS $frobbedlang/\$(DOMAIN).resources.dll"
    done
  fi

  sed -e "s|@POTFILES_DEPS@|$POTFILES_DEPS|g" -e "s|@POFILES@|$POFILES|g" -e "s|@UPDATEPOFILES@|$UPDATEPOFILES|g" -e "s|@DUMMYPOFILES@|$DUMMYPOFILES|g" -e "s|@GMOFILES@|$GMOFILES|g" -e "s|@PROPERTIESFILES@|$PROPERTIESFILES|g" -e "s|@CLASSFILES@|$CLASSFILES|g" -e "s|@QMFILES@|$QMFILES|g" -e "s|@MSGFILES@|$MSGFILES|g" -e "s|@RESOURCESDLLFILES@|$RESOURCESDLLFILES|g" -e "s|@CATALOGS@|$CATALOGS|g" -e "s|@JAVACATALOGS@|$JAVACATALOGS|g" -e "s|@QTCATALOGS@|$QTCATALOGS|g" -e "s|@TCLCATALOGS@|$TCLCATALOGS|g" -e "s|@CSHARPCATALOGS@|$CSHARPCATALOGS|g" -e 's,^#distdir:,distdir:,' < "$ac_file" > "$ac_file.tmp"
  tab=`printf '\t'`
  if grep -l '@TCLCATALOGS@' "$ac_file" > /dev/null; then
    # Add dependencies that cannot be formulated as a simple suffix rule.
    for lang in $ALL_LINGUAS; do
      frobbedlang=`echo $lang | sed -e 's/\..*$//' -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`
      cat >> "$ac_file.tmp" <<EOF
$frobbedlang.msg: $lang.po
${tab}@echo "\$(MSGFMT) -c --tcl -d \$(srcdir) -l $lang $srcdirpre$lang.po"; \
${tab}\$(MSGFMT) -c --tcl -d "\$(srcdir)" -l $lang $srcdirpre$lang.po || { rm -f "\$(srcdir)/$frobbedlang.msg"; exit 1; }
EOF
    done
  fi
  if grep -l '@CSHARPCATALOGS@' "$ac_file" > /dev/null; then
    # Add dependencies that cannot be formulated as a simple suffix rule.
    for lang in $ALL_LINGUAS; do
      frobbedlang=`echo $lang | sed -e 's/_/-/g' -e 's/^sr-CS/sr-SP/' -e 's/@latin$/-Latn/' -e 's/@cyrillic$/-Cyrl/' -e 's/^sr-SP$/sr-SP-Latn/' -e 's/^uz-UZ$/uz-UZ-Latn/'`
      cat >> "$ac_file.tmp" <<EOF
$frobbedlang/\$(DOMAIN).resources.dll: $lang.po
${tab}@echo "\$(MSGFMT) -c --csharp -d \$(srcdir) -l $lang $srcdirpre$lang.po -r \$(DOMAIN)"; \
${tab}\$(MSGFMT) -c --csharp -d "\$(srcdir)" -l $lang $srcdirpre$lang.po -r "\$(DOMAIN)" || { rm -f "\$(srcdir)/$frobbedlang.msg"; exit 1; }
EOF
    done
  fi
  if test -n "$POMAKEFILEDEPS"; then
    cat >> "$ac_file.tmp" <<EOF
Makefile: $POMAKEFILEDEPS
EOF
  fi
  mv "$ac_file.tmp" "$ac_file"
])

dnl Initializes the accumulator used by AM_XGETTEXT_OPTION.
AC_DEFUN([AM_XGETTEXT_OPTION_INIT],
[
  XGETTEXT_EXTRA_OPTIONS=
])

dnl Registers an option to be passed to xgettext in the po subdirectory.
AC_DEFUN([AM_XGETTEXT_OPTION],
[
  AC_REQUIRE([AM_XGETTEXT_OPTION_INIT])
  XGETTEXT_EXTRA_OPTIONS="$XGETTEXT_EXTRA_OPTIONS $1"
])

# progtest.m4 serial 7 (gettext-0.18.2)
dnl Copyright (C) 1996-2003, 2005, 2008-2013 Free Software Foundation, Inc.
dnl This file is free software; the Free Software Foundation
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.
dnl
dnl This file can can be used in projects which are not available under
dnl the GNU General Public License or the GNU Library General Public
dnl License but which still want to provide support for the GNU gettext
dnl functionality.
dnl Please note that the actual code of the GNU gettext library is covered
dnl by the GNU Library General Public License, and the rest of the GNU
dnl gettext package package is covered by the GNU General Public License.
dnl They are *not* in the public domain.

dnl Authors:
dnl   Ulrich Drepper <drepper@cygnus.com>, 1996.

AC_PREREQ([2.50])

# Search path for a program which passes the given test.

dnl AM_PATH_PROG_WITH_TEST(VARIABLE, PROG-TO-CHECK-FOR,
dnl   TEST-PERFORMED-ON-FOUND_PROGRAM [, VALUE-IF-NOT-FOUND [, PATH]])
AC_DEFUN([AM_PATH_PROG_WITH_TEST],
[
# Prepare PATH_SEPARATOR.
# The user is always right.
if test "${PATH_SEPARATOR+set}" != set; then
  # Determine PATH_SEPARATOR by trying to find /bin/sh in a PATH which
  # contains only /bin. Note that ksh looks also at the FPATH variable,
  # so we have to set that as well for the test.
  PATH_SEPARATOR=:
  (PATH='/bin;/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 \
    && { (PATH='/bin:/bin'; FPATH=$PATH; sh -c :) >/dev/null 2>&1 \
           || PATH_SEPARATOR=';'
       }
fi

# Find out how to test for executable files. Don't use a zero-byte file,
# as systems may use methods other than mode bits to determine executability.
cat >conf$$.file <<_ASEOF
#! /bin/sh
exit 0
_ASEOF
chmod +x conf$$.file
if test -x conf$$.file >/dev/null 2>&1; then
  ac_executable_p="test -x"
else
  ac_executable_p="test -f"
fi
rm -f conf$$.file

# Extract the first word of "$2", so it can be a program name with args.
set dummy $2; ac_word=[$]2
AC_MSG_CHECKING([for $ac_word])
AC_CACHE_VAL([ac_cv_path_$1],
[case "[$]$1" in
  [[\\/]]* | ?:[[\\/]]*)
    ac_cv_path_$1="[$]$1" # Let the user override the test with a path.
    ;;
  *)
    ac_save_IFS="$IFS"; IFS=$PATH_SEPARATOR
    for ac_dir in ifelse([$5], , $PATH, [$5]); do
      IFS="$ac_save_IFS"
      test -z "$ac_dir" && ac_dir=.
      for ac_exec_ext in '' $ac_executable_extensions; do
        if $ac_executable_p "$ac_dir/$ac_word$ac_exec_ext"; then
          echo "$as_me: trying $ac_dir/$ac_word..." >&AS_MESSAGE_LOG_FD
          if [$3]; then
            ac_cv_path_$1="$ac_dir/$ac_word$ac_exec_ext"
            break 2
          fi
        fi
      done
    done
    IFS="$ac_save_IFS"
dnl If no 4th arg is given, leave the cache variable unset,
dnl so AC_PATH_PROGS will keep looking.
ifelse([$4], , , [  test -z "[$]ac_cv_path_$1" && ac_cv_path_$1="$4"
])dnl
    ;;
esac])dnl
$1="$ac_cv_path_$1"
if test ifelse([$4], , [-n "[$]$1"], ["[$]$1" != "$4"]); then
  AC_MSG_RESULT([$][$1])
else
  AC_MSG_RESULT([no])
fi
AC_SUBST([$1])dnl
])

dnl xorg-macros.m4.  Generated from xorg-macros.m4.in xorgversion.m4 by configure.
dnl
dnl Copyright (c) 2005, 2006, Oracle and/or its affiliates. All rights reserved.
dnl 
dnl Permission is hereby granted, free of charge, to any person obtaining a
dnl copy of this software and associated documentation files (the "Software"),
dnl to deal in the Software without restriction, including without limitation
dnl the rights to use, copy, modify, merge, publish, distribute, sublicense,
dnl and/or sell copies of the Software, and to permit persons to whom the
dnl Software is furnished to do so, subject to the following conditions:
dnl
dnl The above copyright notice and this permission notice (including the next
dnl paragraph) shall be included in all copies or substantial portions of the
dnl Software.
dnl
dnl THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
dnl IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
dnl FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
dnl THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
dnl LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
dnl FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
dnl DEALINGS IN THE SOFTWARE.

# XORG_MACROS_VERSION(required-version)
# -------------------------------------
# Minimum version: 1.1.0
#
# If you're using a macro added in Version 1.1 or newer, include this in
# your configure.ac with the minimum required version, such as:
# XORG_MACROS_VERSION(1.1)
#
# To ensure that this macro is defined, also add:
# m4_ifndef([XORG_MACROS_VERSION],
#     [m4_fatal([must install xorg-macros 1.1 or later before running autoconf/autogen])])
#
#
# See the "minimum version" comment for each macro you use to see what 
# version you require.
m4_defun([XORG_MACROS_VERSION],[
m4_define([vers_have], [1.17])
m4_define([maj_have], m4_substr(vers_have, 0, m4_index(vers_have, [.])))
m4_define([maj_needed], m4_substr([$1], 0, m4_index([$1], [.])))
m4_if(m4_cmp(maj_have, maj_needed), 0,,
    [m4_fatal([xorg-macros major version ]maj_needed[ is required but ]vers_have[ found])])
m4_if(m4_version_compare(vers_have, [$1]), -1,
    [m4_fatal([xorg-macros version $1 or higher is required but ]vers_have[ found])])
m4_undefine([vers_have])
m4_undefine([maj_have])
m4_undefine([maj_needed])
]) # XORG_MACROS_VERSION

# XORG_PROG_RAWCPP()
# ------------------
# Minimum version: 1.0.0
#
# Find cpp program and necessary flags for use in pre-processing text files
# such as man pages and config files
AC_DEFUN([XORG_PROG_RAWCPP],[
AC_REQUIRE([AC_PROG_CPP])
AC_PATH_PROGS(RAWCPP, [cpp], [${CPP}], 
   [$PATH:/bin:/usr/bin:/usr/lib:/usr/libexec:/usr/ccs/lib:/usr/ccs/lbin:/lib])

# Check for flag to avoid builtin definitions - assumes unix is predefined,
# which is not the best choice for supporting other OS'es, but covers most
# of the ones we need for now.
AC_MSG_CHECKING([if $RAWCPP requires -undef])
AC_LANG_CONFTEST([AC_LANG_SOURCE([[Does cpp redefine unix ?]])])
if test `${RAWCPP} < conftest.$ac_ext | grep -c 'unix'` -eq 1 ; then
	AC_MSG_RESULT([no])
else
	if test `${RAWCPP} -undef < conftest.$ac_ext | grep -c 'unix'` -eq 1 ; then
		RAWCPPFLAGS=-undef
		AC_MSG_RESULT([yes])
	# under Cygwin unix is still defined even with -undef
	elif test `${RAWCPP} -undef -ansi < conftest.$ac_ext | grep -c 'unix'` -eq 1 ; then
		RAWCPPFLAGS="-undef -ansi"
		AC_MSG_RESULT([yes, with -ansi])
	else
		AC_MSG_ERROR([${RAWCPP} defines unix with or without -undef.  I don't know what to do.])
	fi
fi
rm -f conftest.$ac_ext

AC_MSG_CHECKING([if $RAWCPP requires -traditional])
AC_LANG_CONFTEST([AC_LANG_SOURCE([[Does cpp preserve   "whitespace"?]])])
if test `${RAWCPP} < conftest.$ac_ext | grep -c 'preserve   \"'` -eq 1 ; then
	AC_MSG_RESULT([no])
else
	if test `${RAWCPP} -traditional < conftest.$ac_ext | grep -c 'preserve   \"'` -eq 1 ; then
		RAWCPPFLAGS="${RAWCPPFLAGS} -traditional"
		AC_MSG_RESULT([yes])
	else
		AC_MSG_ERROR([${RAWCPP} does not preserve whitespace with or without -traditional.  I don't know what to do.])
	fi
fi
rm -f conftest.$ac_ext
AC_SUBST(RAWCPPFLAGS)
]) # XORG_PROG_RAWCPP

# XORG_MANPAGE_SECTIONS()
# -----------------------
# Minimum version: 1.0.0
#
# Determine which sections man pages go in for the different man page types
# on this OS - replaces *ManSuffix settings in old Imake *.cf per-os files.
# Not sure if there's any better way than just hardcoding by OS name.
# Override default settings by setting environment variables
# Added MAN_SUBSTS in version 1.8
# Added AC_PROG_SED in version 1.8

AC_DEFUN([XORG_MANPAGE_SECTIONS],[
AC_REQUIRE([AC_CANONICAL_HOST])
AC_REQUIRE([AC_PROG_SED])

if test x$APP_MAN_SUFFIX = x    ; then
    APP_MAN_SUFFIX=1
fi
if test x$APP_MAN_DIR = x    ; then
    APP_MAN_DIR='$(mandir)/man$(APP_MAN_SUFFIX)'
fi

if test x$LIB_MAN_SUFFIX = x    ; then
    LIB_MAN_SUFFIX=3
fi
if test x$LIB_MAN_DIR = x    ; then
    LIB_MAN_DIR='$(mandir)/man$(LIB_MAN_SUFFIX)'
fi

if test x$FILE_MAN_SUFFIX = x    ; then
    case $host_os in
	solaris*)	FILE_MAN_SUFFIX=4  ;;
	*)		FILE_MAN_SUFFIX=5  ;;
    esac
fi
if test x$FILE_MAN_DIR = x    ; then
    FILE_MAN_DIR='$(mandir)/man$(FILE_MAN_SUFFIX)'
fi

if test x$MISC_MAN_SUFFIX = x    ; then
    case $host_os in
	solaris*)	MISC_MAN_SUFFIX=5  ;;
	*)		MISC_MAN_SUFFIX=7  ;;
    esac
fi
if test x$MISC_MAN_DIR = x    ; then
    MISC_MAN_DIR='$(mandir)/man$(MISC_MAN_SUFFIX)'
fi

if test x$DRIVER_MAN_SUFFIX = x    ; then
    case $host_os in
	solaris*)	DRIVER_MAN_SUFFIX=7  ;;
	*)		DRIVER_MAN_SUFFIX=4  ;;
    esac
fi
if test x$DRIVER_MAN_DIR = x    ; then
    DRIVER_MAN_DIR='$(mandir)/man$(DRIVER_MAN_SUFFIX)'
fi

if test x$ADMIN_MAN_SUFFIX = x    ; then
    case $host_os in
	solaris*)	ADMIN_MAN_SUFFIX=1m ;;
	*)		ADMIN_MAN_SUFFIX=8  ;;
    esac
fi
if test x$ADMIN_MAN_DIR = x    ; then
    ADMIN_MAN_DIR='$(mandir)/man$(ADMIN_MAN_SUFFIX)'
fi


AC_SUBST([APP_MAN_SUFFIX])
AC_SUBST([LIB_MAN_SUFFIX])
AC_SUBST([FILE_MAN_SUFFIX])
AC_SUBST([MISC_MAN_SUFFIX])
AC_SUBST([DRIVER_MAN_SUFFIX])
AC_SUBST([ADMIN_MAN_SUFFIX])
AC_SUBST([APP_MAN_DIR])
AC_SUBST([LIB_MAN_DIR])
AC_SUBST([FILE_MAN_DIR])
AC_SUBST([MISC_MAN_DIR])
AC_SUBST([DRIVER_MAN_DIR])
AC_SUBST([ADMIN_MAN_DIR])

XORG_MAN_PAGE="X Version 11"
AC_SUBST([XORG_MAN_PAGE])
MAN_SUBSTS="\
	-e 's|__vendorversion__|\"\$(PACKAGE_STRING)\" \"\$(XORG_MAN_PAGE)\"|' \
	-e 's|__xorgversion__|\"\$(PACKAGE_STRING)\" \"\$(XORG_MAN_PAGE)\"|' \
	-e 's|__xservername__|Xorg|g' \
	-e 's|__xconfigfile__|xorg.conf|g' \
	-e 's|__projectroot__|\$(prefix)|g' \
	-e 's|__apploaddir__|\$(appdefaultdir)|g' \
	-e 's|__appmansuffix__|\$(APP_MAN_SUFFIX)|g' \
	-e 's|__drivermansuffix__|\$(DRIVER_MAN_SUFFIX)|g' \
	-e 's|__adminmansuffix__|\$(ADMIN_MAN_SUFFIX)|g' \
	-e 's|__libmansuffix__|\$(LIB_MAN_SUFFIX)|g' \
	-e 's|__miscmansuffix__|\$(MISC_MAN_SUFFIX)|g' \
	-e 's|__filemansuffix__|\$(FILE_MAN_SUFFIX)|g'"
AC_SUBST([MAN_SUBSTS])

]) # XORG_MANPAGE_SECTIONS

# XORG_CHECK_SGML_DOCTOOLS([MIN-VERSION])
# ------------------------
# Minimum version: 1.7.0
#
# Defines the variable XORG_SGML_PATH containing the location of X11/defs.ent
# provided by xorg-sgml-doctools, if installed.
AC_DEFUN([XORG_CHECK_SGML_DOCTOOLS],[
AC_MSG_CHECKING([for X.Org SGML entities m4_ifval([$1],[>= $1])])
XORG_SGML_PATH=
PKG_CHECK_EXISTS([xorg-sgml-doctools m4_ifval([$1],[>= $1])],
    [XORG_SGML_PATH=`$PKG_CONFIG --variable=sgmlrootdir xorg-sgml-doctools`],
    [m4_ifval([$1],[:],
        [if test x"$cross_compiling" != x"yes" ; then
            AC_CHECK_FILE([$prefix/share/sgml/X11/defs.ent],
                          [XORG_SGML_PATH=$prefix/share/sgml])
         fi])
    ])

# Define variables STYLESHEET_SRCDIR and XSL_STYLESHEET containing
# the path and the name of the doc stylesheet
if test "x$XORG_SGML_PATH" != "x" ; then
   AC_MSG_RESULT([$XORG_SGML_PATH])
   STYLESHEET_SRCDIR=$XORG_SGML_PATH/X11
   XSL_STYLESHEET=$STYLESHEET_SRCDIR/xorg.xsl
else
   AC_MSG_RESULT([no])
fi

AC_SUBST(XORG_SGML_PATH)
AC_SUBST(STYLESHEET_SRCDIR)
AC_SUBST(XSL_STYLESHEET)
AM_CONDITIONAL([HAVE_STYLESHEETS], [test "x$XSL_STYLESHEET" != "x"])
]) # XORG_CHECK_SGML_DOCTOOLS

# XORG_CHECK_LINUXDOC
# -------------------
# Minimum version: 1.0.0
#
# Defines the variable MAKE_TEXT if the necessary tools and
# files are found. $(MAKE_TEXT) blah.sgml will then produce blah.txt.
# Whether or not the necessary tools and files are found can be checked
# with the AM_CONDITIONAL "BUILD_LINUXDOC"
AC_DEFUN([XORG_CHECK_LINUXDOC],[
AC_REQUIRE([XORG_CHECK_SGML_DOCTOOLS])
AC_REQUIRE([XORG_WITH_PS2PDF])

AC_PATH_PROG(LINUXDOC, linuxdoc)

AC_MSG_CHECKING([whether to build documentation])

if test x$XORG_SGML_PATH != x && test x$LINUXDOC != x ; then
   BUILDDOC=yes
else
   BUILDDOC=no
fi

AM_CONDITIONAL(BUILD_LINUXDOC, [test x$BUILDDOC = xyes])

AC_MSG_RESULT([$BUILDDOC])

AC_MSG_CHECKING([whether to build pdf documentation])

if test x$have_ps2pdf != xno && test x$BUILD_PDFDOC != xno; then
   BUILDPDFDOC=yes
else
   BUILDPDFDOC=no
fi

AM_CONDITIONAL(BUILD_PDFDOC, [test x$BUILDPDFDOC = xyes])

AC_MSG_RESULT([$BUILDPDFDOC])

MAKE_TEXT="SGML_SEARCH_PATH=$XORG_SGML_PATH GROFF_NO_SGR=y $LINUXDOC -B txt -f"
MAKE_PS="SGML_SEARCH_PATH=$XORG_SGML_PATH $LINUXDOC -B latex --papersize=letter --output=ps"
MAKE_PDF="$PS2PDF"
MAKE_HTML="SGML_SEARCH_PATH=$XORG_SGML_PATH $LINUXDOC  -B html --split=0"

AC_SUBST(MAKE_TEXT)
AC_SUBST(MAKE_PS)
AC_SUBST(MAKE_PDF)
AC_SUBST(MAKE_HTML)
]) # XORG_CHECK_LINUXDOC

# XORG_CHECK_DOCBOOK
# -------------------
# Minimum version: 1.0.0
#
# Checks for the ability to build output formats from SGML DocBook source.
# For XXX in {TXT, PDF, PS, HTML}, the AM_CONDITIONAL "BUILD_XXXDOC"
# indicates whether the necessary tools and files are found and, if set,
# $(MAKE_XXX) blah.sgml will produce blah.xxx.
AC_DEFUN([XORG_CHECK_DOCBOOK],[
AC_REQUIRE([XORG_CHECK_SGML_DOCTOOLS])

BUILDTXTDOC=no
BUILDPDFDOC=no
BUILDPSDOC=no
BUILDHTMLDOC=no

AC_PATH_PROG(DOCBOOKPS, docbook2ps)
AC_PATH_PROG(DOCBOOKPDF, docbook2pdf)
AC_PATH_PROG(DOCBOOKHTML, docbook2html)
AC_PATH_PROG(DOCBOOKTXT, docbook2txt)

AC_MSG_CHECKING([whether to build text documentation])
if test x$XORG_SGML_PATH != x && test x$DOCBOOKTXT != x &&
   test x$BUILD_TXTDOC != xno; then
	BUILDTXTDOC=yes
fi
AM_CONDITIONAL(BUILD_TXTDOC, [test x$BUILDTXTDOC = xyes])
AC_MSG_RESULT([$BUILDTXTDOC])

AC_MSG_CHECKING([whether to build PDF documentation])
if test x$XORG_SGML_PATH != x && test x$DOCBOOKPDF != x &&
   test x$BUILD_PDFDOC != xno; then
	BUILDPDFDOC=yes
fi
AM_CONDITIONAL(BUILD_PDFDOC, [test x$BUILDPDFDOC = xyes])
AC_MSG_RESULT([$BUILDPDFDOC])

AC_MSG_CHECKING([whether to build PostScript documentation])
if test x$XORG_SGML_PATH != x && test x$DOCBOOKPS != x &&
   test x$BUILD_PSDOC != xno; then
	BUILDPSDOC=yes
fi
AM_CONDITIONAL(BUILD_PSDOC, [test x$BUILDPSDOC = xyes])
AC_MSG_RESULT([$BUILDPSDOC])

AC_MSG_CHECKING([whether to build HTML documentation])
if test x$XORG_SGML_PATH != x && test x$DOCBOOKHTML != x &&
   test x$BUILD_HTMLDOC != xno; then
	BUILDHTMLDOC=yes
fi
AM_CONDITIONAL(BUILD_HTMLDOC, [test x$BUILDHTMLDOC = xyes])
AC_MSG_RESULT([$BUILDHTMLDOC])

MAKE_TEXT="SGML_SEARCH_PATH=$XORG_SGML_PATH $DOCBOOKTXT"
MAKE_PS="SGML_SEARCH_PATH=$XORG_SGML_PATH $DOCBOOKPS"
MAKE_PDF="SGML_SEARCH_PATH=$XORG_SGML_PATH $DOCBOOKPDF"
MAKE_HTML="SGML_SEARCH_PATH=$XORG_SGML_PATH $DOCBOOKHTML"

AC_SUBST(MAKE_TEXT)
AC_SUBST(MAKE_PS)
AC_SUBST(MAKE_PDF)
AC_SUBST(MAKE_HTML)
]) # XORG_CHECK_DOCBOOK

# XORG_WITH_XMLTO([MIN-VERSION], [DEFAULT])
# ----------------
# Minimum version: 1.5.0
# Minimum version for optional DEFAULT argument: 1.11.0
#
# Documentation tools are not always available on all platforms and sometimes
# not at the appropriate level. This macro enables a module to test for the
# presence of the tool and obtain it's path in separate variables. Coupled with
# the --with-xmlto option, it allows maximum flexibilty in making decisions
# as whether or not to use the xmlto package. When DEFAULT is not specified,
# --with-xmlto assumes 'auto'.
#
# Interface to module:
# HAVE_XMLTO: 	used in makefiles to conditionally generate documentation
# XMLTO:	returns the path of the xmlto program found
#		returns the path set by the user in the environment
# --with-xmlto:	'yes' user instructs the module to use xmlto
#		'no' user instructs the module not to use xmlto
#
# Added in version 1.10.0
# HAVE_XMLTO_TEXT: used in makefiles to conditionally generate text documentation
#                  xmlto for text output requires either lynx, links, or w3m browsers
#
# If the user sets the value of XMLTO, AC_PATH_PROG skips testing the path.
#
AC_DEFUN([XORG_WITH_XMLTO],[
AC_ARG_VAR([XMLTO], [Path to xmlto command])
m4_define([_defopt], m4_default([$2], [auto]))
AC_ARG_WITH(xmlto,
	AS_HELP_STRING([--with-xmlto],
	   [Use xmlto to regenerate documentation (default: ]_defopt[)]),
	   [use_xmlto=$withval], [use_xmlto=]_defopt)
m4_undefine([_defopt])

if test "x$use_xmlto" = x"auto"; then
   AC_PATH_PROG([XMLTO], [xmlto])
   if test "x$XMLTO" = "x"; then
        AC_MSG_WARN([xmlto not found - documentation targets will be skipped])
	have_xmlto=no
   else
        have_xmlto=yes
   fi
elif test "x$use_xmlto" = x"yes" ; then
   AC_PATH_PROG([XMLTO], [xmlto])
   if test "x$XMLTO" = "x"; then
        AC_MSG_ERROR([--with-xmlto=yes specified but xmlto not found in PATH])
   fi
   have_xmlto=yes
elif test "x$use_xmlto" = x"no" ; then
   if test "x$XMLTO" != "x"; then
      AC_MSG_WARN([ignoring XMLTO environment variable since --with-xmlto=no was specified])
   fi
   have_xmlto=no
else
   AC_MSG_ERROR([--with-xmlto expects 'yes' or 'no'])
fi

# Test for a minimum version of xmlto, if provided.
m4_ifval([$1],
[if test "$have_xmlto" = yes; then
    # scrape the xmlto version
    AC_MSG_CHECKING([the xmlto version])
    xmlto_version=`$XMLTO --version 2>/dev/null | cut -d' ' -f3`
    AC_MSG_RESULT([$xmlto_version])
    AS_VERSION_COMPARE([$xmlto_version], [$1],
        [if test "x$use_xmlto" = xauto; then
            AC_MSG_WARN([xmlto version $xmlto_version found, but $1 needed])
            have_xmlto=no
        else
            AC_MSG_ERROR([xmlto version $xmlto_version found, but $1 needed])
        fi])
fi])

# Test for the ability of xmlto to generate a text target
have_xmlto_text=no
cat > conftest.xml << "EOF"
EOF
AS_IF([test "$have_xmlto" = yes],
      [AS_IF([$XMLTO --skip-validation txt conftest.xml >/dev/null 2>&1],
             [have_xmlto_text=yes],
             [AC_MSG_WARN([xmlto cannot generate text format, this format skipped])])])
rm -f conftest.xml
AM_CONDITIONAL([HAVE_XMLTO_TEXT], [test $have_xmlto_text = yes])
AM_CONDITIONAL([HAVE_XMLTO], [test "$have_xmlto" = yes])
]) # XORG_WITH_XMLTO

# XORG_WITH_XSLTPROC([MIN-VERSION], [DEFAULT])
# --------------------------------------------
# Minimum version: 1.12.0
# Minimum version for optional DEFAULT argument: 1.12.0
#
# XSLT (Extensible Stylesheet Language Transformations) is a declarative,
# XML-based language used for the transformation of XML documents.
# The xsltproc command line tool is for applying XSLT stylesheets to XML documents.
# It is used under the cover by xmlto to generate html files from DocBook/XML.
# The XSLT processor is often used as a standalone tool for transformations.
# It should not be assumed that this tool is used only to work with documnetation.
# When DEFAULT is not specified, --with-xsltproc assumes 'auto'.
#
# Interface to module:
# HAVE_XSLTPROC: used in makefiles to conditionally generate documentation
# XSLTPROC:	 returns the path of the xsltproc program found
#		 returns the path set by the user in the environment
# --with-xsltproc: 'yes' user instructs the module to use xsltproc
#		  'no' user instructs the module not to use xsltproc
# have_xsltproc: returns yes if xsltproc found in PATH or no
#
# If the user sets the value of XSLTPROC, AC_PATH_PROG skips testing the path.
#
AC_DEFUN([XORG_WITH_XSLTPROC],[
AC_ARG_VAR([XSLTPROC], [Path to xsltproc command])
# Preserves the interface, should it be implemented later
m4_ifval([$1], [m4_warn([syntax], [Checking for xsltproc MIN-VERSION is not implemented])])
m4_define([_defopt], m4_default([$2], [auto]))
AC_ARG_WITH(xsltproc,
	AS_HELP_STRING([--with-xsltproc],
	   [Use xsltproc for the transformation of XML documents (default: ]_defopt[)]),
	   [use_xsltproc=$withval], [use_xsltproc=]_defopt)
m4_undefine([_defopt])

if test "x$use_xsltproc" = x"auto"; then
   AC_PATH_PROG([XSLTPROC], [xsltproc])
   if test "x$XSLTPROC" = "x"; then
        AC_MSG_WARN([xsltproc not found - cannot transform XML documents])
	have_xsltproc=no
   else
        have_xsltproc=yes
   fi
elif test "x$use_xsltproc" = x"yes" ; then
   AC_PATH_PROG([XSLTPROC], [xsltproc])
   if test "x$XSLTPROC" = "x"; then
        AC_MSG_ERROR([--with-xsltproc=yes specified but xsltproc not found in PATH])
   fi
   have_xsltproc=yes
elif test "x$use_xsltproc" = x"no" ; then
   if test "x$XSLTPROC" != "x"; then
      AC_MSG_WARN([ignoring XSLTPROC environment variable since --with-xsltproc=no was specified])
   fi
   have_xsltproc=no
else
   AC_MSG_ERROR([--with-xsltproc expects 'yes' or 'no'])
fi

AM_CONDITIONAL([HAVE_XSLTPROC], [test "$have_xsltproc" = yes])
]) # XORG_WITH_XSLTPROC

# XORG_WITH_PERL([MIN-VERSION], [DEFAULT])
# ----------------------------------------
# Minimum version: 1.15.0
#
# PERL (Practical Extraction and Report Language) is a language optimized for
# scanning arbitrary text files, extracting information from those text files,
# and printing reports based on that information.
#
# When DEFAULT is not specified, --with-perl assumes 'auto'.
#
# Interface to module:
# HAVE_PERL: used in makefiles to conditionally scan text files
# PERL:	     returns the path of the perl program found
#	     returns the path set by the user in the environment
# --with-perl: 'yes' user instructs the module to use perl
#	       'no' user instructs the module not to use perl
# have_perl: returns yes if perl found in PATH or no
#
# If the user sets the value of PERL, AC_PATH_PROG skips testing the path.
#
AC_DEFUN([XORG_WITH_PERL],[
AC_ARG_VAR([PERL], [Path to perl command])
# Preserves the interface, should it be implemented later
m4_ifval([$1], [m4_warn([syntax], [Checking for perl MIN-VERSION is not implemented])])
m4_define([_defopt], m4_default([$2], [auto]))
AC_ARG_WITH(perl,
	AS_HELP_STRING([--with-perl],
	   [Use perl for extracting information from files (default: ]_defopt[)]),
	   [use_perl=$withval], [use_perl=]_defopt)
m4_undefine([_defopt])

if test "x$use_perl" = x"auto"; then
   AC_PATH_PROG([PERL], [perl])
   if test "x$PERL" = "x"; then
        AC_MSG_WARN([perl not found - cannot extract information and report])
	have_perl=no
   else
        have_perl=yes
   fi
elif test "x$use_perl" = x"yes" ; then
   AC_PATH_PROG([PERL], [perl])
   if test "x$PERL" = "x"; then
        AC_MSG_ERROR([--with-perl=yes specified but perl not found in PATH])
   fi
   have_perl=yes
elif test "x$use_perl" = x"no" ; then
   if test "x$PERL" != "x"; then
      AC_MSG_WARN([ignoring PERL environment variable since --with-perl=no was specified])
   fi
   have_perl=no
else
   AC_MSG_ERROR([--with-perl expects 'yes' or 'no'])
fi

AM_CONDITIONAL([HAVE_PERL], [test "$have_perl" = yes])
]) # XORG_WITH_PERL

# XORG_WITH_ASCIIDOC([MIN-VERSION], [DEFAULT])
# ----------------
# Minimum version: 1.5.0
# Minimum version for optional DEFAULT argument: 1.11.0
#
# Documentation tools are not always available on all platforms and sometimes
# not at the appropriate level. This macro enables a module to test for the
# presence of the tool and obtain it's path in separate variables. Coupled with
# the --with-asciidoc option, it allows maximum flexibilty in making decisions
# as whether or not to use the asciidoc package. When DEFAULT is not specified,
# --with-asciidoc assumes 'auto'.
#
# Interface to module:
# HAVE_ASCIIDOC: used in makefiles to conditionally generate documentation
# ASCIIDOC:	 returns the path of the asciidoc program found
#		 returns the path set by the user in the environment
# --with-asciidoc: 'yes' user instructs the module to use asciidoc
#		  'no' user instructs the module not to use asciidoc
#
# If the user sets the value of ASCIIDOC, AC_PATH_PROG skips testing the path.
#
AC_DEFUN([XORG_WITH_ASCIIDOC],[
AC_ARG_VAR([ASCIIDOC], [Path to asciidoc command])
m4_define([_defopt], m4_default([$2], [auto]))
AC_ARG_WITH(asciidoc,
	AS_HELP_STRING([--with-asciidoc],
	   [Use asciidoc to regenerate documentation (default: ]_defopt[)]),
	   [use_asciidoc=$withval], [use_asciidoc=]_defopt)
m4_undefine([_defopt])

if test "x$use_asciidoc" = x"auto"; then
   AC_PATH_PROG([ASCIIDOC], [asciidoc])
   if test "x$ASCIIDOC" = "x"; then
        AC_MSG_WARN([asciidoc not found - documentation targets will be skipped])
	have_asciidoc=no
   else
        have_asciidoc=yes
   fi
elif test "x$use_asciidoc" = x"yes" ; then
   AC_PATH_PROG([ASCIIDOC], [asciidoc])
   if test "x$ASCIIDOC" = "x"; then
        AC_MSG_ERROR([--with-asciidoc=yes specified but asciidoc not found in PATH])
   fi
   have_asciidoc=yes
elif test "x$use_asciidoc" = x"no" ; then
   if test "x$ASCIIDOC" != "x"; then
      AC_MSG_WARN([ignoring ASCIIDOC environment variable since --with-asciidoc=no was specified])
   fi
   have_asciidoc=no
else
   AC_MSG_ERROR([--with-asciidoc expects 'yes' or 'no'])
fi
m4_ifval([$1],
[if test "$have_asciidoc" = yes; then
    # scrape the asciidoc version
    AC_MSG_CHECKING([the asciidoc version])
    asciidoc_version=`$ASCIIDOC --version 2>/dev/null | cut -d' ' -f2`
    AC_MSG_RESULT([$asciidoc_version])
    AS_VERSION_COMPARE([$asciidoc_version], [$1],
        [if test "x$use_asciidoc" = xauto; then
            AC_MSG_WARN([asciidoc version $asciidoc_version found, but $1 needed])
            have_asciidoc=no
        else
            AC_MSG_ERROR([asciidoc version $asciidoc_version found, but $1 needed])
        fi])
fi])
AM_CONDITIONAL([HAVE_ASCIIDOC], [test "$have_asciidoc" = yes])
]) # XORG_WITH_ASCIIDOC

# XORG_WITH_DOXYGEN([MIN-VERSION], [DEFAULT])
# --------------------------------
# Minimum version: 1.5.0
# Minimum version for optional DEFAULT argument: 1.11.0
#
# Documentation tools are not always available on all platforms and sometimes
# not at the appropriate level. This macro enables a module to test for the
# presence of the tool and obtain it's path in separate variables. Coupled with
# the --with-doxygen option, it allows maximum flexibilty in making decisions
# as whether or not to use the doxygen package. When DEFAULT is not specified,
# --with-doxygen assumes 'auto'.
#
# Interface to module:
# HAVE_DOXYGEN: used in makefiles to conditionally generate documentation
# DOXYGEN:	 returns the path of the doxygen program found
#		 returns the path set by the user in the environment
# --with-doxygen: 'yes' user instructs the module to use doxygen
#		  'no' user instructs the module not to use doxygen
#
# If the user sets the value of DOXYGEN, AC_PATH_PROG skips testing the path.
#
AC_DEFUN([XORG_WITH_DOXYGEN],[
AC_ARG_VAR([DOXYGEN], [Path to doxygen command])
m4_define([_defopt], m4_default([$2], [auto]))
AC_ARG_WITH(doxygen,
	AS_HELP_STRING([--with-doxygen],
	   [Use doxygen to regenerate documentation (default: ]_defopt[)]),
	   [use_doxygen=$withval], [use_doxygen=]_defopt)
m4_undefine([_defopt])

if test "x$use_doxygen" = x"auto"; then
   AC_PATH_PROG([DOXYGEN], [doxygen])
   if test "x$DOXYGEN" = "x"; then
        AC_MSG_WARN([doxygen not found - documentation targets will be skipped])
	have_doxygen=no
   else
        have_doxygen=yes
   fi
elif test "x$use_doxygen" = x"yes" ; then
   AC_PATH_PROG([DOXYGEN], [doxygen])
   if test "x$DOXYGEN" = "x"; then
        AC_MSG_ERROR([--with-doxygen=yes specified but doxygen not found in PATH])
   fi
   have_doxygen=yes
elif test "x$use_doxygen" = x"no" ; then
   if test "x$DOXYGEN" != "x"; then
      AC_MSG_WARN([ignoring DOXYGEN environment variable since --with-doxygen=no was specified])
   fi
   have_doxygen=no
else
   AC_MSG_ERROR([--with-doxygen expects 'yes' or 'no'])
fi
m4_ifval([$1],
[if test "$have_doxygen" = yes; then
    # scrape the doxygen version
    AC_MSG_CHECKING([the doxygen version])
    doxygen_version=`$DOXYGEN --version 2>/dev/null`
    AC_MSG_RESULT([$doxygen_version])
    AS_VERSION_COMPARE([$doxygen_version], [$1],
        [if test "x$use_doxygen" = xauto; then
            AC_MSG_WARN([doxygen version $doxygen_version found, but $1 needed])
            have_doxygen=no
        else
            AC_MSG_ERROR([doxygen version $doxygen_version found, but $1 needed])
        fi])
fi])
AM_CONDITIONAL([HAVE_DOXYGEN], [test "$have_doxygen" = yes])
]) # XORG_WITH_DOXYGEN

# XORG_WITH_GROFF([DEFAULT])
# ----------------
# Minimum version: 1.6.0
# Minimum version for optional DEFAULT argument: 1.11.0
#
# Documentation tools are not always available on all platforms and sometimes
# not at the appropriate level. This macro enables a module to test for the
# presence of the tool and obtain it's path in separate variables. Coupled with
# the --with-groff option, it allows maximum flexibilty in making decisions
# as whether or not to use the groff package. When DEFAULT is not specified,
# --with-groff assumes 'auto'.
#
# Interface to module:
# HAVE_GROFF:	 used in makefiles to conditionally generate documentation
# HAVE_GROFF_MM: the memorandum macros (-mm) package
# HAVE_GROFF_MS: the -ms macros package
# GROFF:	 returns the path of the groff program found
#		 returns the path set by the user in the environment
# --with-groff:	 'yes' user instructs the module to use groff
#		 'no' user instructs the module not to use groff
#
# Added in version 1.9.0:
# HAVE_GROFF_HTML: groff has dependencies to output HTML format:
#		   pnmcut pnmcrop pnmtopng pnmtops from the netpbm package.
#		   psselect from the psutils package.
#		   the ghostcript package. Refer to the grohtml man pages
#
# If the user sets the value of GROFF, AC_PATH_PROG skips testing the path.
#
# OS and distros often splits groff in a basic and full package, the former
# having the groff program and the later having devices, fonts and macros
# Checking for the groff executable is not enough.
#
# If macros are missing, we cannot assume that groff is useless, so we don't
# unset HAVE_GROFF or GROFF env variables.
# HAVE_GROFF_?? can never be true while HAVE_GROFF is false.
#
AC_DEFUN([XORG_WITH_GROFF],[
AC_ARG_VAR([GROFF], [Path to groff command])
m4_define([_defopt], m4_default([$1], [auto]))
AC_ARG_WITH(groff,
	AS_HELP_STRING([--with-groff],
	   [Use groff to regenerate documentation (default: ]_defopt[)]),
	   [use_groff=$withval], [use_groff=]_defopt)
m4_undefine([_defopt])

if test "x$use_groff" = x"auto"; then
   AC_PATH_PROG([GROFF], [groff])
   if test "x$GROFF" = "x"; then
        AC_MSG_WARN([groff not found - documentation targets will be skipped])
	have_groff=no
   else
        have_groff=yes
   fi
elif test "x$use_groff" = x"yes" ; then
   AC_PATH_PROG([GROFF], [groff])
   if test "x$GROFF" = "x"; then
        AC_MSG_ERROR([--with-groff=yes specified but groff not found in PATH])
   fi
   have_groff=yes
elif test "x$use_groff" = x"no" ; then
   if test "x$GROFF" != "x"; then
      AC_MSG_WARN([ignoring GROFF environment variable since --with-groff=no was specified])
   fi
   have_groff=no
else
   AC_MSG_ERROR([--with-groff expects 'yes' or 'no'])
fi

# We have groff, test for the presence of the macro packages
if test "x$have_groff" = x"yes"; then
    AC_MSG_CHECKING([for ${GROFF} -ms macros])
    if ${GROFF} -ms -I. /dev/null >/dev/null 2>&1 ; then
        groff_ms_works=yes
    else
        groff_ms_works=no
    fi
    AC_MSG_RESULT([$groff_ms_works])
    AC_MSG_CHECKING([for ${GROFF} -mm macros])
    if ${GROFF} -mm -I. /dev/null >/dev/null 2>&1 ; then
        groff_mm_works=yes
    else
        groff_mm_works=no
    fi
    AC_MSG_RESULT([$groff_mm_works])
fi

# We have groff, test for HTML dependencies, one command per package
if test "x$have_groff" = x"yes"; then
   AC_PATH_PROGS(GS_PATH, [gs gswin32c])
   AC_PATH_PROG(PNMTOPNG_PATH, [pnmtopng])
   AC_PATH_PROG(PSSELECT_PATH, [psselect])
   if test "x$GS_PATH" != "x" -a "x$PNMTOPNG_PATH" != "x" -a "x$PSSELECT_PATH" != "x"; then
      have_groff_html=yes
   else
      have_groff_html=no
      AC_MSG_WARN([grohtml dependencies not found - HTML Documentation skipped. Refer to grohtml man pages])
   fi
fi

# Set Automake conditionals for Makefiles
AM_CONDITIONAL([HAVE_GROFF], [test "$have_groff" = yes])
AM_CONDITIONAL([HAVE_GROFF_MS], [test "$groff_ms_works" = yes])
AM_CONDITIONAL([HAVE_GROFF_MM], [test "$groff_mm_works" = yes])
AM_CONDITIONAL([HAVE_GROFF_HTML], [test "$have_groff_html" = yes])
]) # XORG_WITH_GROFF

# XORG_WITH_FOP([MIN-VERSION], [DEFAULT])
# ---------------------------------------
# Minimum version: 1.6.0
# Minimum version for optional DEFAULT argument: 1.11.0
# Minimum version for optional MIN-VERSION argument: 1.15.0
#
# Documentation tools are not always available on all platforms and sometimes
# not at the appropriate level. This macro enables a module to test for the
# presence of the tool and obtain it's path in separate variables. Coupled with
# the --with-fop option, it allows maximum flexibilty in making decisions
# as whether or not to use the fop package. When DEFAULT is not specified,
# --with-fop assumes 'auto'.
#
# Interface to module:
# HAVE_FOP: 	used in makefiles to conditionally generate documentation
# FOP:	 	returns the path of the fop program found
#		returns the path set by the user in the environment
# --with-fop: 	'yes' user instructs the module to use fop
#		'no' user instructs the module not to use fop
#
# If the user sets the value of FOP, AC_PATH_PROG skips testing the path.
#
AC_DEFUN([XORG_WITH_FOP],[
AC_ARG_VAR([FOP], [Path to fop command])
m4_define([_defopt], m4_default([$2], [auto]))
AC_ARG_WITH(fop,
	AS_HELP_STRING([--with-fop],
	   [Use fop to regenerate documentation (default: ]_defopt[)]),
	   [use_fop=$withval], [use_fop=]_defopt)
m4_undefine([_defopt])

if test "x$use_fop" = x"auto"; then
   AC_PATH_PROG([FOP], [fop])
   if test "x$FOP" = "x"; then
        AC_MSG_WARN([fop not found - documentation targets will be skipped])
	have_fop=no
   else
        have_fop=yes
   fi
elif test "x$use_fop" = x"yes" ; then
   AC_PATH_PROG([FOP], [fop])
   if test "x$FOP" = "x"; then
        AC_MSG_ERROR([--with-fop=yes specified but fop not found in PATH])
   fi
   have_fop=yes
elif test "x$use_fop" = x"no" ; then
   if test "x$FOP" != "x"; then
      AC_MSG_WARN([ignoring FOP environment variable since --with-fop=no was specified])
   fi
   have_fop=no
else
   AC_MSG_ERROR([--with-fop expects 'yes' or 'no'])
fi

# Test for a minimum version of fop, if provided.
m4_ifval([$1],
[if test "$have_fop" = yes; then
    # scrape the fop version
    AC_MSG_CHECKING([for fop minimum version])
    fop_version=`$FOP -version 2>/dev/null | cut -d' ' -f3`
    AC_MSG_RESULT([$fop_version])
    AS_VERSION_COMPARE([$fop_version], [$1],
        [if test "x$use_fop" = xauto; then
            AC_MSG_WARN([fop version $fop_version found, but $1 needed])
            have_fop=no
        else
            AC_MSG_ERROR([fop version $fop_version found, but $1 needed])
        fi])
fi])
AM_CONDITIONAL([HAVE_FOP], [test "$have_fop" = yes])
]) # XORG_WITH_FOP

# XORG_WITH_PS2PDF([DEFAULT])
# ----------------
# Minimum version: 1.6.0
# Minimum version for optional DEFAULT argument: 1.11.0
#
# Documentation tools are not always available on all platforms and sometimes
# not at the appropriate level. This macro enables a module to test for the
# presence of the tool and obtain it's path in separate variables. Coupled with
# the --with-ps2pdf option, it allows maximum flexibilty in making decisions
# as whether or not to use the ps2pdf package. When DEFAULT is not specified,
# --with-ps2pdf assumes 'auto'.
#
# Interface to module:
# HAVE_PS2PDF: 	used in makefiles to conditionally generate documentation
# PS2PDF:	returns the path of the ps2pdf program found
#		returns the path set by the user in the environment
# --with-ps2pdf: 'yes' user instructs the module to use ps2pdf
#		 'no' user instructs the module not to use ps2pdf
#
# If the user sets the value of PS2PDF, AC_PATH_PROG skips testing the path.
#
AC_DEFUN([XORG_WITH_PS2PDF],[
AC_ARG_VAR([PS2PDF], [Path to ps2pdf command])
m4_define([_defopt], m4_default([$1], [auto]))
AC_ARG_WITH(ps2pdf,
	AS_HELP_STRING([--with-ps2pdf],
	   [Use ps2pdf to regenerate documentation (default: ]_defopt[)]),
	   [use_ps2pdf=$withval], [use_ps2pdf=]_defopt)
m4_undefine([_defopt])

if test "x$use_ps2pdf" = x"auto"; then
   AC_PATH_PROG([PS2PDF], [ps2pdf])
   if test "x$PS2PDF" = "x"; then
        AC_MSG_WARN([ps2pdf not found - documentation targets will be skipped])
	have_ps2pdf=no
   else
        have_ps2pdf=yes
   fi
elif test "x$use_ps2pdf" = x"yes" ; then
   AC_PATH_PROG([PS2PDF], [ps2pdf])
   if test "x$PS2PDF" = "x"; then
        AC_MSG_ERROR([--with-ps2pdf=yes specified but ps2pdf not found in PATH])
   fi
   have_ps2pdf=yes
elif test "x$use_ps2pdf" = x"no" ; then
   if test "x$PS2PDF" != "x"; then
      AC_MSG_WARN([ignoring PS2PDF environment variable since --with-ps2pdf=no was specified])
   fi
   have_ps2pdf=no
else
   AC_MSG_ERROR([--with-ps2pdf expects 'yes' or 'no'])
fi
AM_CONDITIONAL([HAVE_PS2PDF], [test "$have_ps2pdf" = yes])
]) # XORG_WITH_PS2PDF

# XORG_ENABLE_DOCS (enable_docs=yes)
# ----------------
# Minimum version: 1.6.0
#
# Documentation tools are not always available on all platforms and sometimes
# not at the appropriate level. This macro enables a builder to skip all
# documentation targets except traditional man pages.
# Combined with the specific tool checking macros XORG_WITH_*, it provides
# maximum flexibilty in controlling documentation building.
# Refer to:
# XORG_WITH_XMLTO         --with-xmlto
# XORG_WITH_ASCIIDOC      --with-asciidoc
# XORG_WITH_DOXYGEN       --with-doxygen
# XORG_WITH_FOP           --with-fop
# XORG_WITH_GROFF         --with-groff
# XORG_WITH_PS2PDF        --with-ps2pdf
#
# Interface to module:
# ENABLE_DOCS: 	  used in makefiles to conditionally generate documentation
# --enable-docs: 'yes' user instructs the module to generate docs
#		 'no' user instructs the module not to generate docs
# parm1:	specify the default value, yes or no.
#
AC_DEFUN([XORG_ENABLE_DOCS],[
m4_define([docs_default], m4_default([$1], [yes]))
AC_ARG_ENABLE(docs,
	AS_HELP_STRING([--enable-docs],
	   [Enable building the documentation (default: ]docs_default[)]),
	   [build_docs=$enableval], [build_docs=]docs_default)
m4_undefine([docs_default])
AM_CONDITIONAL(ENABLE_DOCS, [test x$build_docs = xyes])
AC_MSG_CHECKING([whether to build documentation])
AC_MSG_RESULT([$build_docs])
]) # XORG_ENABLE_DOCS

# XORG_ENABLE_DEVEL_DOCS (enable_devel_docs=yes)
# ----------------
# Minimum version: 1.6.0
#
# This macro enables a builder to skip all developer documentation.
# Combined with the specific tool checking macros XORG_WITH_*, it provides
# maximum flexibilty in controlling documentation building.
# Refer to:
# XORG_WITH_XMLTO         --with-xmlto
# XORG_WITH_ASCIIDOC      --with-asciidoc
# XORG_WITH_DOXYGEN       --with-doxygen
# XORG_WITH_FOP           --with-fop
# XORG_WITH_GROFF         --with-groff
# XORG_WITH_PS2PDF        --with-ps2pdf
#
# Interface to module:
# ENABLE_DEVEL_DOCS:	used in makefiles to conditionally generate developer docs
# --enable-devel-docs:	'yes' user instructs the module to generate developer docs
#			'no' user instructs the module not to generate developer docs
# parm1:		specify the default value, yes or no.
#
AC_DEFUN([XORG_ENABLE_DEVEL_DOCS],[
m4_define([devel_default], m4_default([$1], [yes]))
AC_ARG_ENABLE(devel-docs,
	AS_HELP_STRING([--enable-devel-docs],
	   [Enable building the developer documentation (default: ]devel_default[)]),
	   [build_devel_docs=$enableval], [build_devel_docs=]devel_default)
m4_undefine([devel_default])
AM_CONDITIONAL(ENABLE_DEVEL_DOCS, [test x$build_devel_docs = xyes])
AC_MSG_CHECKING([whether to build developer documentation])
AC_MSG_RESULT([$build_devel_docs])
]) # XORG_ENABLE_DEVEL_DOCS

# XORG_ENABLE_SPECS (enable_specs=yes)
# ----------------
# Minimum version: 1.6.0
#
# This macro enables a builder to skip all functional specification targets.
# Combined with the specific tool checking macros XORG_WITH_*, it provides
# maximum flexibilty in controlling documentation building.
# Refer to:
# XORG_WITH_XMLTO         --with-xmlto
# XORG_WITH_ASCIIDOC      --with-asciidoc
# XORG_WITH_DOXYGEN       --with-doxygen
# XORG_WITH_FOP           --with-fop
# XORG_WITH_GROFF         --with-groff
# XORG_WITH_PS2PDF        --with-ps2pdf
#
# Interface to module:
# ENABLE_SPECS:		used in makefiles to conditionally generate specs
# --enable-specs:	'yes' user instructs the module to generate specs
#			'no' user instructs the module not to generate specs
# parm1:		specify the default value, yes or no.
#
AC_DEFUN([XORG_ENABLE_SPECS],[
m4_define([spec_default], m4_default([$1], [yes]))
AC_ARG_ENABLE(specs,
	AS_HELP_STRING([--enable-specs],
	   [Enable building the specs (default: ]spec_default[)]),
	   [build_specs=$enableval], [build_specs=]spec_default)
m4_undefine([spec_default])
AM_CONDITIONAL(ENABLE_SPECS, [test x$build_specs = xyes])
AC_MSG_CHECKING([whether to build functional specifications])
AC_MSG_RESULT([$build_specs])
]) # XORG_ENABLE_SPECS

# XORG_ENABLE_UNIT_TESTS (enable_unit_tests=auto)
# ----------------------------------------------
# Minimum version: 1.13.0
#
# This macro enables a builder to enable/disable unit testing
# It makes no assumption about the test cases implementation
# Test cases may or may not use Automake "Support for test suites"
# They may or may not use the software utility library GLib
#
# When used in conjunction with XORG_WITH_GLIB, use both AM_CONDITIONAL
# ENABLE_UNIT_TESTS and HAVE_GLIB. Not all unit tests may use glib.
# The variable enable_unit_tests is used by other macros in this file.
#
# Interface to module:
# ENABLE_UNIT_TESTS:	used in makefiles to conditionally build tests
# enable_unit_tests:    used in configure.ac for additional configuration
# --enable-unit-tests:	'yes' user instructs the module to build tests
#			'no' user instructs the module not to build tests
# parm1:		specify the default value, yes or no.
#
AC_DEFUN([XORG_ENABLE_UNIT_TESTS],[
AC_BEFORE([$0], [XORG_WITH_GLIB])
AC_BEFORE([$0], [XORG_LD_WRAP])
AC_REQUIRE([XORG_MEMORY_CHECK_FLAGS])
m4_define([_defopt], m4_default([$1], [auto]))
AC_ARG_ENABLE(unit-tests, AS_HELP_STRING([--enable-unit-tests],
	[Enable building unit test cases (default: ]_defopt[)]),
	[enable_unit_tests=$enableval], [enable_unit_tests=]_defopt)
m4_undefine([_defopt])
AM_CONDITIONAL(ENABLE_UNIT_TESTS, [test "x$enable_unit_tests" != xno])
AC_MSG_CHECKING([whether to build unit test cases])
AC_MSG_RESULT([$enable_unit_tests])
]) # XORG_ENABLE_UNIT_TESTS

# XORG_ENABLE_INTEGRATION_TESTS (enable_unit_tests=auto)
# ------------------------------------------------------
# Minimum version: 1.17.0
#
# This macro enables a builder to enable/disable integration testing
# It makes no assumption about the test cases' implementation
# Test cases may or may not use Automake "Support for test suites"
#
# Please see XORG_ENABLE_UNIT_TESTS for unit test support. Unit test support
# usually requires less dependencies and may be built and run under less
# stringent environments than integration tests.
#
# Interface to module:
# ENABLE_INTEGRATION_TESTS:   used in makefiles to conditionally build tests
# enable_integration_tests:   used in configure.ac for additional configuration
# --enable-integration-tests: 'yes' user instructs the module to build tests
#                             'no' user instructs the module not to build tests
# parm1:                      specify the default value, yes or no.
#
AC_DEFUN([XORG_ENABLE_INTEGRATION_TESTS],[
AC_REQUIRE([XORG_MEMORY_CHECK_FLAGS])
m4_define([_defopt], m4_default([$1], [auto]))
AC_ARG_ENABLE(integration-tests, AS_HELP_STRING([--enable-integration-tests],
	[Enable building integration test cases (default: ]_defopt[)]),
	[enable_integration_tests=$enableval],
	[enable_integration_tests=]_defopt)
m4_undefine([_defopt])
AM_CONDITIONAL([ENABLE_INTEGRATION_TESTS],
	[test "x$enable_integration_tests" != xno])
AC_MSG_CHECKING([whether to build unit test cases])
AC_MSG_RESULT([$enable_integration_tests])
]) # XORG_ENABLE_INTEGRATION_TESTS

# XORG_WITH_GLIB([MIN-VERSION], [DEFAULT])
# ----------------------------------------
# Minimum version: 1.13.0
#
# GLib is a library which provides advanced data structures and functions.
# This macro enables a module to test for the presence of Glib.
#
# When used with ENABLE_UNIT_TESTS, it is assumed GLib is used for unit testing.
# Otherwise the value of $enable_unit_tests is blank.
#
# Please see XORG_ENABLE_INTEGRATION_TESTS for integration test support. Unit
# test support usually requires less dependencies and may be built and run under
# less stringent environments than integration tests.
#
# Interface to module:
# HAVE_GLIB: used in makefiles to conditionally build targets
# with_glib: used in configure.ac to know if GLib has been found
# --with-glib:	'yes' user instructs the module to use glib
#		'no' user instructs the module not to use glib
#
AC_DEFUN([XORG_WITH_GLIB],[
AC_REQUIRE([PKG_PROG_PKG_CONFIG])
m4_define([_defopt], m4_default([$2], [auto]))
AC_ARG_WITH(glib, AS_HELP_STRING([--with-glib],
	[Use GLib library for unit testing (default: ]_defopt[)]),
	[with_glib=$withval], [with_glib=]_defopt)
m4_undefine([_defopt])

have_glib=no
# Do not probe GLib if user explicitly disabled unit testing
if test "x$enable_unit_tests" != x"no"; then
  # Do not probe GLib if user explicitly disabled it
  if test "x$with_glib" != x"no"; then
    m4_ifval(
      [$1],
      [PKG_CHECK_MODULES([GLIB], [glib-2.0 >= $1], [have_glib=yes], [have_glib=no])],
      [PKG_CHECK_MODULES([GLIB], [glib-2.0], [have_glib=yes], [have_glib=no])]
    )
  fi
fi

# Not having GLib when unit testing has been explicitly requested is an error
if test "x$enable_unit_tests" = x"yes"; then
  if test "x$have_glib" = x"no"; then
    AC_MSG_ERROR([--enable-unit-tests=yes specified but glib-2.0 not found])
  fi
fi

# Having unit testing disabled when GLib has been explicitly requested is an error
if test "x$enable_unit_tests" = x"no"; then
  if test "x$with_glib" = x"yes"; then
    AC_MSG_ERROR([--enable-unit-tests=yes specified but glib-2.0 not found])
  fi
fi

# Not having GLib when it has been explicitly requested is an error
if test "x$with_glib" = x"yes"; then
  if test "x$have_glib" = x"no"; then
    AC_MSG_ERROR([--with-glib=yes specified but glib-2.0 not found])
  fi
fi

AM_CONDITIONAL([HAVE_GLIB], [test "$have_glib" = yes])
]) # XORG_WITH_GLIB

# XORG_LD_WRAP([required|optional])
# ---------------------------------
# Minimum version: 1.13.0
#
# Check if linker supports -wrap, passed via compiler flags
#
# When used with ENABLE_UNIT_TESTS, it is assumed -wrap is used for unit testing.
# Otherwise the value of $enable_unit_tests is blank.
#
# Argument added in 1.16.0 - default is "required", to match existing behavior
# of returning an error if enable_unit_tests is yes, and ld -wrap is not
# available, an argument of "optional" allows use when some unit tests require
# ld -wrap and others do not.
#
AC_DEFUN([XORG_LD_WRAP],[
XORG_CHECK_LINKER_FLAGS([-Wl,-wrap,exit],[have_ld_wrap=yes],[have_ld_wrap=no],
    [AC_LANG_PROGRAM([#include <stdlib.h>
                      void __wrap_exit(int status) { return; }],
                     [exit(0);])])
# Not having ld wrap when unit testing has been explicitly requested is an error
if test "x$enable_unit_tests" = x"yes" -a "x$1" != "xoptional"; then
  if test "x$have_ld_wrap" = x"no"; then
    AC_MSG_ERROR([--enable-unit-tests=yes specified but ld -wrap support is not available])
  fi
fi
AM_CONDITIONAL([HAVE_LD_WRAP], [test "$have_ld_wrap" = yes])
#
]) # XORG_LD_WRAP

# XORG_CHECK_LINKER_FLAGS
# -----------------------
# SYNOPSIS
#
#   XORG_CHECK_LINKER_FLAGS(FLAGS, [ACTION-SUCCESS], [ACTION-FAILURE], [PROGRAM-SOURCE])
#
# DESCRIPTION
#
#   Check whether the given linker FLAGS work with the current language's
#   linker, or whether they give an error.
#
#   ACTION-SUCCESS/ACTION-FAILURE are shell commands to execute on
#   success/failure.
#
#   PROGRAM-SOURCE is the program source to link with, if needed
#
#   NOTE: Based on AX_CHECK_COMPILER_FLAGS.
#
# LICENSE
#
#   Copyright (c) 2009 Mike Frysinger <vapier@gentoo.org>
#   Copyright (c) 2009 Steven G. Johnson <stevenj@alum.mit.edu>
#   Copyright (c) 2009 Matteo Frigo
#
#   This program is free software: you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation, either version 3 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <http://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Archive. When you make and distribute a
#   modified version of the Autoconf Macro, you may extend this special
#   exception to the GPL to apply to your modified version as well.#
AC_DEFUN([XORG_CHECK_LINKER_FLAGS],
[AC_MSG_CHECKING([whether the linker accepts $1])
dnl Some hackery here since AC_CACHE_VAL can't handle a non-literal varname:
AS_LITERAL_IF([$1],
  [AC_CACHE_VAL(AS_TR_SH(xorg_cv_linker_flags_[$1]), [
      ax_save_FLAGS=$LDFLAGS
      LDFLAGS="$1"
      AC_LINK_IFELSE([m4_default([$4],[AC_LANG_PROGRAM()])],
        AS_TR_SH(xorg_cv_linker_flags_[$1])=yes,
        AS_TR_SH(xorg_cv_linker_flags_[$1])=no)
      LDFLAGS=$ax_save_FLAGS])],
  [ax_save_FLAGS=$LDFLAGS
   LDFLAGS="$1"
   AC_LINK_IFELSE([AC_LANG_PROGRAM()],
     eval AS_TR_SH(xorg_cv_linker_flags_[$1])=yes,
     eval AS_TR_SH(xorg_cv_linker_flags_[$1])=no)
   LDFLAGS=$ax_save_FLAGS])
eval xorg_check_linker_flags=$AS_TR_SH(xorg_cv_linker_flags_[$1])
AC_MSG_RESULT($xorg_check_linker_flags)
if test "x$xorg_check_linker_flags" = xyes; then
	m4_default([$2], :)
else
	m4_default([$3], :)
fi
]) # XORG_CHECK_LINKER_FLAGS

# XORG_MEMORY_CHECK_FLAGS
# -----------------------
# Minimum version: 1.16.0
#
# This macro attempts to find appropriate memory checking functionality
# for various platforms which unit testing code may use to catch various
# forms of memory allocation and access errors in testing.
#
# Interface to module:
# XORG_MALLOC_DEBUG_ENV - environment variables to set to enable debugging
#                         Usually added to TESTS_ENVIRONMENT in Makefile.am
#
# If the user sets the value of XORG_MALLOC_DEBUG_ENV, it is used verbatim.
#
AC_DEFUN([XORG_MEMORY_CHECK_FLAGS],[

AC_REQUIRE([AC_CANONICAL_HOST])
AC_ARG_VAR([XORG_MALLOC_DEBUG_ENV],
           [Environment variables to enable memory checking in tests])

# Check for different types of support on different platforms
case $host_os in
    solaris*)
        AC_CHECK_LIB([umem], [umem_alloc],
            [malloc_debug_env='LD_PRELOAD=libumem.so UMEM_DEBUG=default'])
        ;;
    *-gnu*) # GNU libc - Value is used as a single byte bit pattern,
        # both directly and inverted, so should not be 0 or 255.
        malloc_debug_env='MALLOC_PERTURB_=15'
        ;;
    darwin*)
        malloc_debug_env='MallocPreScribble=1 MallocScribble=1 DYLD_INSERT_LIBRARIES=/usr/lib/libgmalloc.dylib'
        ;;
    *bsd*)
        malloc_debug_env='MallocPreScribble=1 MallocScribble=1'
        ;;
esac

# User supplied flags override default flags
if test "x$XORG_MALLOC_DEBUG_ENV" != "x"; then
    malloc_debug_env="$XORG_MALLOC_DEBUG_ENV"
fi

AC_SUBST([XORG_MALLOC_DEBUG_ENV],[$malloc_debug_env])
]) # XORG_WITH_LINT

# XORG_CHECK_MALLOC_ZERO
# ----------------------
# Minimum version: 1.0.0
#
# Defines {MALLOC,XMALLOC,XTMALLOC}_ZERO_CFLAGS appropriately if
# malloc(0) returns NULL.  Packages should add one of these cflags to
# their AM_CFLAGS (or other appropriate *_CFLAGS) to use them.
AC_DEFUN([XORG_CHECK_MALLOC_ZERO],[
AC_ARG_ENABLE(malloc0returnsnull,
	AS_HELP_STRING([--enable-malloc0returnsnull],
		       [malloc(0) returns NULL (default: auto)]),
	[MALLOC_ZERO_RETURNS_NULL=$enableval],
	[MALLOC_ZERO_RETURNS_NULL=auto])

AC_MSG_CHECKING([whether malloc(0) returns NULL])
if test "x$MALLOC_ZERO_RETURNS_NULL" = xauto; then
	AC_RUN_IFELSE([AC_LANG_PROGRAM([
#include <stdlib.h>
],[
    char *m0, *r0, *c0, *p;
    m0 = malloc(0);
    p = malloc(10);
    r0 = realloc(p,0);
    c0 = calloc(0,10);
    exit((m0 == 0 || r0 == 0 || c0 == 0) ? 0 : 1);
])],
		[MALLOC_ZERO_RETURNS_NULL=yes],
		[MALLOC_ZERO_RETURNS_NULL=no],
		[MALLOC_ZERO_RETURNS_NULL=yes])
fi
AC_MSG_RESULT([$MALLOC_ZERO_RETURNS_NULL])

if test "x$MALLOC_ZERO_RETURNS_NULL" = xyes; then
	MALLOC_ZERO_CFLAGS="-DMALLOC_0_RETURNS_NULL"
	XMALLOC_ZERO_CFLAGS=$MALLOC_ZERO_CFLAGS
	XTMALLOC_ZERO_CFLAGS="$MALLOC_ZERO_CFLAGS -DXTMALLOC_BC"
else
	MALLOC_ZERO_CFLAGS=""
	XMALLOC_ZERO_CFLAGS=""
	XTMALLOC_ZERO_CFLAGS=""
fi

AC_SUBST([MALLOC_ZERO_CFLAGS])
AC_SUBST([XMALLOC_ZERO_CFLAGS])
AC_SUBST([XTMALLOC_ZERO_CFLAGS])
]) # XORG_CHECK_MALLOC_ZERO

# XORG_WITH_LINT()
# ----------------
# Minimum version: 1.1.0
#
# This macro enables the use of a tool that flags some suspicious and
# non-portable constructs (likely to be bugs) in C language source code.
# It will attempt to locate the tool and use appropriate options.
# There are various lint type tools on different platforms.
#
# Interface to module:
# LINT:		returns the path to the tool found on the platform
#		or the value set to LINT on the configure cmd line
#		also an Automake conditional
# LINT_FLAGS:	an Automake variable with appropriate flags
#
# --with-lint:	'yes' user instructs the module to use lint
#		'no' user instructs the module not to use lint (default)
#
# If the user sets the value of LINT, AC_PATH_PROG skips testing the path.
# If the user sets the value of LINT_FLAGS, they are used verbatim.
#
AC_DEFUN([XORG_WITH_LINT],[

AC_ARG_VAR([LINT], [Path to a lint-style command])
AC_ARG_VAR([LINT_FLAGS], [Flags for the lint-style command])
AC_ARG_WITH(lint, [AS_HELP_STRING([--with-lint],
		[Use a lint-style source code checker (default: disabled)])],
		[use_lint=$withval], [use_lint=no])

# Obtain platform specific info like program name and options
# The lint program on FreeBSD and NetBSD is different from the one on Solaris
case $host_os in
  *linux* | *openbsd* | kfreebsd*-gnu | darwin* | cygwin*)
	lint_name=splint
	lint_options="-badflag"
	;;
  *freebsd* | *netbsd*)
	lint_name=lint
	lint_options="-u -b"
	;;
  *solaris*)
	lint_name=lint
	lint_options="-u -b -h -erroff=E_INDISTING_FROM_TRUNC2"
	;;
esac

# Test for the presence of the program (either guessed by the code or spelled out by the user)
if test "x$use_lint" = x"yes" ; then
   AC_PATH_PROG([LINT], [$lint_name])
   if test "x$LINT" = "x"; then
        AC_MSG_ERROR([--with-lint=yes specified but lint-style tool not found in PATH])
   fi
elif test "x$use_lint" = x"no" ; then
   if test "x$LINT" != "x"; then
      AC_MSG_WARN([ignoring LINT environment variable since --with-lint=no was specified])
   fi
else
   AC_MSG_ERROR([--with-lint expects 'yes' or 'no'. Use LINT variable to specify path.])
fi

# User supplied flags override default flags
if test "x$LINT_FLAGS" != "x"; then
   lint_options=$LINT_FLAGS
fi

AC_SUBST([LINT_FLAGS],[$lint_options])
AM_CONDITIONAL(LINT, [test "x$LINT" != x])

]) # XORG_WITH_LINT

# XORG_LINT_LIBRARY(LIBNAME)
# --------------------------
# Minimum version: 1.1.0
#
# Sets up flags for building lint libraries for checking programs that call
# functions in the library.
#
# Interface to module:
# LINTLIB		- Automake variable with the name of lint library file to make
# MAKE_LINT_LIB		- Automake conditional
#
# --enable-lint-library:  - 'yes' user instructs the module to created a lint library
#			  - 'no' user instructs the module not to create a lint library (default)

AC_DEFUN([XORG_LINT_LIBRARY],[
AC_REQUIRE([XORG_WITH_LINT])
AC_ARG_ENABLE(lint-library, [AS_HELP_STRING([--enable-lint-library],
	[Create lint library (default: disabled)])],
	[make_lint_lib=$enableval], [make_lint_lib=no])

if test "x$make_lint_lib" = x"yes" ; then
   LINTLIB=llib-l$1.ln
   if test "x$LINT" = "x"; then
        AC_MSG_ERROR([Cannot make lint library without --with-lint])
   fi
elif test "x$make_lint_lib" != x"no" ; then
   AC_MSG_ERROR([--enable-lint-library expects 'yes' or 'no'.])
fi

AC_SUBST(LINTLIB)
AM_CONDITIONAL(MAKE_LINT_LIB, [test x$make_lint_lib != xno])

]) # XORG_LINT_LIBRARY

# XORG_COMPILER_BRAND
# -------------------
# Minimum version: 1.14.0
#
# Checks for various brands of compilers and sets flags as appropriate:
#   GNU gcc - relies on AC_PROG_CC (via AC_PROG_CC_C99) to set GCC to "yes"
#   GNU g++ - relies on AC_PROG_CXX to set GXX to "yes"
#   clang compiler - sets CLANGCC to "yes"
#   Intel compiler - sets INTELCC to "yes"
#   Sun/Oracle Solaris Studio cc - sets SUNCC to "yes"
#
AC_DEFUN([XORG_COMPILER_BRAND], [
AC_LANG_CASE(
	[C], [
		AC_REQUIRE([AC_PROG_CC_C99])
	],
	[C++], [
		AC_REQUIRE([AC_PROG_CXX])
	]
)
AC_CHECK_DECL([__clang__], [CLANGCC="yes"], [CLANGCC="no"])
AC_CHECK_DECL([__INTEL_COMPILER], [INTELCC="yes"], [INTELCC="no"])
AC_CHECK_DECL([__SUNPRO_C], [SUNCC="yes"], [SUNCC="no"])
]) # XORG_COMPILER_BRAND

# XORG_TESTSET_CFLAG(<variable>, <flag>, [<alternative flag>, ...])
# ---------------
# Minimum version: 1.16.0
#
# Test if the compiler works when passed the given flag as a command line argument.
# If it succeeds, the flag is appeneded to the given variable.  If not, it tries the
# next flag in the list until there are no more options.
#
# Note that this does not guarantee that the compiler supports the flag as some
# compilers will simply ignore arguments that they do not understand, but we do
# attempt to weed out false positives by using -Werror=unknown-warning-option and
# -Werror=unused-command-line-argument
#
AC_DEFUN([XORG_TESTSET_CFLAG], [
m4_if([$#], 0, [m4_fatal([XORG_TESTSET_CFLAG was given with an unsupported number of arguments])])
m4_if([$#], 1, [m4_fatal([XORG_TESTSET_CFLAG was given with an unsupported number of arguments])])

AC_LANG_COMPILER_REQUIRE

AC_LANG_CASE(
	[C], [
		AC_REQUIRE([AC_PROG_CC_C99])
		define([PREFIX], [C])
		define([CACHE_PREFIX], [cc])
		define([COMPILER], [$CC])
	],
	[C++], [
		define([PREFIX], [CXX])
		define([CACHE_PREFIX], [cxx])
		define([COMPILER], [$CXX])
	]
)

[xorg_testset_save_]PREFIX[FLAGS]="$PREFIX[FLAGS]"

if test "x$[xorg_testset_]CACHE_PREFIX[_unknown_warning_option]" = "x" ; then
	PREFIX[FLAGS]="$PREFIX[FLAGS] -Werror=unknown-warning-option"
	AC_CACHE_CHECK([if ]COMPILER[ supports -Werror=unknown-warning-option],
			[xorg_cv_]CACHE_PREFIX[_flag_unknown_warning_option],
			AC_COMPILE_IFELSE([AC_LANG_SOURCE([int i;])],
					  [xorg_cv_]CACHE_PREFIX[_flag_unknown_warning_option=yes],
					  [xorg_cv_]CACHE_PREFIX[_flag_unknown_warning_option=no]))
	[xorg_testset_]CACHE_PREFIX[_unknown_warning_option]=$[xorg_cv_]CACHE_PREFIX[_flag_unknown_warning_option]
	PREFIX[FLAGS]="$[xorg_testset_save_]PREFIX[FLAGS]"
fi

if test "x$[xorg_testset_]CACHE_PREFIX[_unused_command_line_argument]" = "x" ; then
	if test "x$[xorg_testset_]CACHE_PREFIX[_unknown_warning_option]" = "xyes" ; then
		PREFIX[FLAGS]="$PREFIX[FLAGS] -Werror=unknown-warning-option"
	fi
	PREFIX[FLAGS]="$PREFIX[FLAGS] -Werror=unused-command-line-argument"
	AC_CACHE_CHECK([if ]COMPILER[ supports -Werror=unused-command-line-argument],
			[xorg_cv_]CACHE_PREFIX[_flag_unused_command_line_argument],
			AC_COMPILE_IFELSE([AC_LANG_SOURCE([int i;])],
					  [xorg_cv_]CACHE_PREFIX[_flag_unused_command_line_argument=yes],
					  [xorg_cv_]CACHE_PREFIX[_flag_unused_command_line_argument=no]))
	[xorg_testset_]CACHE_PREFIX[_unused_command_line_argument]=$[xorg_cv_]CACHE_PREFIX[_flag_unused_command_line_argument]
	PREFIX[FLAGS]="$[xorg_testset_save_]PREFIX[FLAGS]"
fi

found="no"
m4_foreach([flag], m4_cdr($@), [
	if test $found = "no" ; then
		if test "x$xorg_testset_unknown_warning_option" = "xyes" ; then
			PREFIX[FLAGS]="$PREFIX[FLAGS] -Werror=unknown-warning-option"
		fi

		if test "x$xorg_testset_unused_command_line_argument" = "xyes" ; then
			PREFIX[FLAGS]="$PREFIX[FLAGS] -Werror=unused-command-line-argument"
		fi

		PREFIX[FLAGS]="$PREFIX[FLAGS] ]flag["

dnl Some hackery here since AC_CACHE_VAL can't handle a non-literal varname
		AC_MSG_CHECKING([if ]COMPILER[ supports]flag[])
		cacheid=AS_TR_SH([xorg_cv_]CACHE_PREFIX[_flag_]flag[])
		AC_CACHE_VAL($cacheid,
			     [AC_LINK_IFELSE([AC_LANG_PROGRAM([int i;])],
					     [eval $cacheid=yes],
					     [eval $cacheid=no])])

		PREFIX[FLAGS]="$[xorg_testset_save_]PREFIX[FLAGS]"

		eval supported=\$$cacheid
		AC_MSG_RESULT([$supported])
		if test "$supported" = "yes" ; then
			$1="$$1 ]flag["
			found="yes"
		fi
	fi
])
]) # XORG_TESTSET_CFLAG

# XORG_COMPILER_FLAGS
# ---------------
# Minimum version: 1.16.0
#
# Defines BASE_CFLAGS or BASE_CXXFLAGS to contain a set of command line
# arguments supported by the selected compiler which do NOT alter the generated
# code.  These arguments will cause the compiler to print various warnings
# during compilation AND turn a conservative set of warnings into errors.
#
# The set of flags supported by BASE_CFLAGS and BASE_CXXFLAGS will grow in
# future versions of util-macros as options are added to new compilers.
#
AC_DEFUN([XORG_COMPILER_FLAGS], [
AC_REQUIRE([XORG_COMPILER_BRAND])

AC_ARG_ENABLE(selective-werror,
              AS_HELP_STRING([--disable-selective-werror],
                             [Turn off selective compiler errors. (default: enabled)]),
              [SELECTIVE_WERROR=$enableval],
              [SELECTIVE_WERROR=yes])

AC_LANG_CASE(
        [C], [
                define([PREFIX], [C])
        ],
        [C++], [
                define([PREFIX], [CXX])
        ]
)
# -v is too short to test reliably with XORG_TESTSET_CFLAG
if test "x$SUNCC" = "xyes"; then
    [BASE_]PREFIX[FLAGS]="-v"
else
    [BASE_]PREFIX[FLAGS]=""
fi

# This chunk of warnings were those that existed in the legacy CWARNFLAGS
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wall])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wpointer-arith])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wmissing-declarations])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wformat=2], [-Wformat])

AC_LANG_CASE(
	[C], [
		XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wstrict-prototypes])
		XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wmissing-prototypes])
		XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wnested-externs])
		XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wbad-function-cast])
		XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wold-style-definition])
		XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wdeclaration-after-statement])
	]
)

# This chunk adds additional warnings that could catch undesired effects.
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wunused])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wuninitialized])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wshadow])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wcast-qual])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wmissing-noreturn])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wmissing-format-attribute])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wredundant-decls])

# These are currently disabled because they are noisy.  They will be enabled
# in the future once the codebase is sufficiently modernized to silence
# them.  For now, I don't want them to drown out the other warnings.
# XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wlogical-op])
# XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wparentheses])
# XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wcast-align])

# Turn some warnings into errors, so we don't accidently get successful builds
# when there are problems that should be fixed.

if test "x$SELECTIVE_WERROR" = "xyes" ; then
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=implicit], [-errwarn=E_NO_EXPLICIT_TYPE_GIVEN -errwarn=E_NO_IMPLICIT_DECL_ALLOWED])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=nonnull])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=init-self])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=main])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=missing-braces])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=sequence-point])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=return-type], [-errwarn=E_FUNC_HAS_NO_RETURN_STMT])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=trigraphs])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=array-bounds])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=write-strings])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=address])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=int-to-pointer-cast], [-errwarn=E_BAD_PTR_INT_COMBINATION])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Werror=pointer-to-int-cast]) # Also -errwarn=E_BAD_PTR_INT_COMBINATION
else
AC_MSG_WARN([You have chosen not to turn some select compiler warnings into errors.  This should not be necessary.  Please report why you needed to do so in a bug report at $PACKAGE_BUGREPORT])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wimplicit])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wnonnull])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Winit-self])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wmain])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wmissing-braces])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wsequence-point])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wreturn-type])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wtrigraphs])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Warray-bounds])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wwrite-strings])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Waddress])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wint-to-pointer-cast])
XORG_TESTSET_CFLAG([[BASE_]PREFIX[FLAGS]], [-Wpointer-to-int-cast])
fi

AC_SUBST([BASE_]PREFIX[FLAGS])
]) # XORG_COMPILER_FLAGS

# XORG_CWARNFLAGS
# ---------------
# Minimum version: 1.2.0
# Deprecated since: 1.16.0 (Use XORG_COMPILER_FLAGS instead)
#
# Defines CWARNFLAGS to enable C compiler warnings.
#
# This function is deprecated because it defines -fno-strict-aliasing
# which alters the code generated by the compiler.  If -fno-strict-aliasing
# is needed, then it should be added explicitly in the module when
# it is updated to use BASE_CFLAGS.
#
AC_DEFUN([XORG_CWARNFLAGS], [
AC_REQUIRE([XORG_COMPILER_FLAGS])
AC_REQUIRE([XORG_COMPILER_BRAND])
AC_LANG_CASE(
	[C], [
		CWARNFLAGS="$BASE_CFLAGS"
		if  test "x$GCC" = xyes ; then
		    CWARNFLAGS="$CWARNFLAGS -fno-strict-aliasing"
		fi
		AC_SUBST(CWARNFLAGS)
	]
)
]) # XORG_CWARNFLAGS

# XORG_STRICT_OPTION
# -----------------------
# Minimum version: 1.3.0
#
# Add configure option to enable strict compilation flags, such as treating
# warnings as fatal errors.
# If --enable-strict-compilation is passed to configure, adds strict flags to
# $BASE_CFLAGS or $BASE_CXXFLAGS and the deprecated $CWARNFLAGS.
#
# Starting in 1.14.0 also exports $STRICT_CFLAGS for use in other tests or
# when strict compilation is unconditionally desired.
AC_DEFUN([XORG_STRICT_OPTION], [
AC_REQUIRE([XORG_CWARNFLAGS])
AC_REQUIRE([XORG_COMPILER_FLAGS])

AC_ARG_ENABLE(strict-compilation,
			  AS_HELP_STRING([--enable-strict-compilation],
			  [Enable all warnings from compiler and make them errors (default: disabled)]),
			  [STRICT_COMPILE=$enableval], [STRICT_COMPILE=no])

AC_LANG_CASE(
        [C], [
                define([PREFIX], [C])
        ],
        [C++], [
                define([PREFIX], [CXX])
        ]
)

[STRICT_]PREFIX[FLAGS]=""
XORG_TESTSET_CFLAG([[STRICT_]PREFIX[FLAGS]], [-pedantic])
XORG_TESTSET_CFLAG([[STRICT_]PREFIX[FLAGS]], [-Werror], [-errwarn])

# Earlier versions of gcc (eg: 4.2) support -Werror=attributes, but do not
# activate it with -Werror, so we add it here explicitly.
XORG_TESTSET_CFLAG([[STRICT_]PREFIX[FLAGS]], [-Werror=attributes])

if test "x$STRICT_COMPILE" = "xyes"; then
    [BASE_]PREFIX[FLAGS]="$[BASE_]PREFIX[FLAGS] $[STRICT_]PREFIX[FLAGS]"
    AC_LANG_CASE([C], [CWARNFLAGS="$CWARNFLAGS $STRICT_CFLAGS"])
fi
AC_SUBST([STRICT_]PREFIX[FLAGS])
AC_SUBST([BASE_]PREFIX[FLAGS])
AC_LANG_CASE([C], AC_SUBST([CWARNFLAGS]))
]) # XORG_STRICT_OPTION

# XORG_DEFAULT_OPTIONS
# --------------------
# Minimum version: 1.3.0
#
# Defines default options for X.Org modules.
#
AC_DEFUN([XORG_DEFAULT_OPTIONS], [
AC_REQUIRE([AC_PROG_INSTALL])
XORG_COMPILER_FLAGS
XORG_CWARNFLAGS
XORG_STRICT_OPTION
XORG_RELEASE_VERSION
XORG_CHANGELOG
XORG_INSTALL
XORG_MANPAGE_SECTIONS
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])],
    [AC_SUBST([AM_DEFAULT_VERBOSITY], [1])])
]) # XORG_DEFAULT_OPTIONS

# XORG_INSTALL()
# ----------------
# Minimum version: 1.4.0
#
# Defines the variable INSTALL_CMD as the command to copy
# INSTALL from $prefix/share/util-macros.
#
AC_DEFUN([XORG_INSTALL], [
AC_REQUIRE([PKG_PROG_PKG_CONFIG])
macros_datadir=`$PKG_CONFIG --print-errors --variable=pkgdatadir xorg-macros`
INSTALL_CMD="(cp -f "$macros_datadir/INSTALL" \$(top_srcdir)/.INSTALL.tmp && \
mv \$(top_srcdir)/.INSTALL.tmp \$(top_srcdir)/INSTALL) \
|| (rm -f \$(top_srcdir)/.INSTALL.tmp; touch \$(top_srcdir)/INSTALL; \
echo 'util-macros \"pkgdatadir\" from xorg-macros.pc not found: installing possibly empty INSTALL.' >&2)"
AC_SUBST([INSTALL_CMD])
]) # XORG_INSTALL
dnl Copyright 2005 Red Hat, Inc
dnl
dnl Permission to use, copy, modify, distribute, and sell this software and its
dnl documentation for any purpose is hereby granted without fee, provided that
dnl the above copyright notice appear in all copies and that both that
dnl copyright notice and this permission notice appear in supporting
dnl documentation.
dnl
dnl The above copyright notice and this permission notice shall be included
dnl in all copies or substantial portions of the Software.
dnl
dnl THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
dnl OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
dnl MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
dnl IN NO EVENT SHALL THE OPEN GROUP BE LIABLE FOR ANY CLAIM, DAMAGES OR
dnl OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
dnl ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
dnl OTHER DEALINGS IN THE SOFTWARE.
dnl
dnl Except as contained in this notice, the name of the copyright holders shall
dnl not be used in advertising or otherwise to promote the sale, use or
dnl other dealings in this Software without prior written authorization
dnl from the copyright holders.
dnl

# XORG_RELEASE_VERSION
# --------------------
# Defines PACKAGE_VERSION_{MAJOR,MINOR,PATCHLEVEL} for modules to use.
 
AC_DEFUN([XORG_RELEASE_VERSION],[
	AC_DEFINE_UNQUOTED([PACKAGE_VERSION_MAJOR],
		[`echo $PACKAGE_VERSION | cut -d . -f 1`],
		[Major version of this package])
	PVM=`echo $PACKAGE_VERSION | cut -d . -f 2 | cut -d - -f 1`
	if test "x$PVM" = "x"; then
		PVM="0"
	fi
	AC_DEFINE_UNQUOTED([PACKAGE_VERSION_MINOR],
		[$PVM],
		[Minor version of this package])
	PVP=`echo $PACKAGE_VERSION | cut -d . -f 3 | cut -d - -f 1`
	if test "x$PVP" = "x"; then
		PVP="0"
	fi
	AC_DEFINE_UNQUOTED([PACKAGE_VERSION_PATCHLEVEL],
		[$PVP],
		[Patch version of this package])
])

# XORG_CHANGELOG()
# ----------------
# Minimum version: 1.2.0
#
# Defines the variable CHANGELOG_CMD as the command to generate
# ChangeLog from git.
#
#
AC_DEFUN([XORG_CHANGELOG], [
CHANGELOG_CMD="(GIT_DIR=\$(top_srcdir)/.git git log > \$(top_srcdir)/.changelog.tmp && \
mv \$(top_srcdir)/.changelog.tmp \$(top_srcdir)/ChangeLog) \
|| (rm -f \$(top_srcdir)/.changelog.tmp; touch \$(top_srcdir)/ChangeLog; \
echo 'git directory not found: installing possibly empty changelog.' >&2)"
AC_SUBST([CHANGELOG_CMD])
]) # XORG_CHANGELOG

# Copyright (C) 2002-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_AUTOMAKE_VERSION(VERSION)
# ----------------------------
# Automake X.Y traces this macro to ensure aclocal.m4 has been
# generated from the m4 files accompanying Automake X.Y.
# (This private macro should not be called outside this file.)
AC_DEFUN([AM_AUTOMAKE_VERSION],
[am__api_version='1.13'
dnl Some users find AM_AUTOMAKE_VERSION and mistake it for a way to
dnl require some minimum version.  Point them to the right macro.
m4_if([$1], [1.13.4], [],
      [AC_FATAL([Do not call $0, use AM_INIT_AUTOMAKE([$1]).])])dnl
])

# _AM_AUTOCONF_VERSION(VERSION)
# -----------------------------
# aclocal traces this macro to find the Autoconf version.
# This is a private macro too.  Using m4_define simplifies
# the logic in aclocal, which can simply ignore this definition.
m4_define([_AM_AUTOCONF_VERSION], [])

# AM_SET_CURRENT_AUTOMAKE_VERSION
# -------------------------------
# Call AM_AUTOMAKE_VERSION and AM_AUTOMAKE_VERSION so they can be traced.
# This function is AC_REQUIREd by AM_INIT_AUTOMAKE.
AC_DEFUN([AM_SET_CURRENT_AUTOMAKE_VERSION],
[AM_AUTOMAKE_VERSION([1.13.4])dnl
m4_ifndef([AC_AUTOCONF_VERSION],
  [m4_copy([m4_PACKAGE_VERSION], [AC_AUTOCONF_VERSION])])dnl
_AM_AUTOCONF_VERSION(m4_defn([AC_AUTOCONF_VERSION]))])

# AM_AUX_DIR_EXPAND                                         -*- Autoconf -*-

# Copyright (C) 2001-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# For projects using AC_CONFIG_AUX_DIR([foo]), Autoconf sets
# $ac_aux_dir to '$srcdir/foo'.  In other projects, it is set to
# '$srcdir', '$srcdir/..', or '$srcdir/../..'.
#
# Of course, Automake must honor this variable whenever it calls a
# tool from the auxiliary directory.  The problem is that $srcdir (and
# therefore $ac_aux_dir as well) can be either absolute or relative,
# depending on how configure is run.  This is pretty annoying, since
# it makes $ac_aux_dir quite unusable in subdirectories: in the top
# source directory, any form will work fine, but in subdirectories a
# relative path needs to be adjusted first.
#
# $ac_aux_dir/missing
#    fails when called from a subdirectory if $ac_aux_dir is relative
# $top_srcdir/$ac_aux_dir/missing
#    fails if $ac_aux_dir is absolute,
#    fails when called from a subdirectory in a VPATH build with
#          a relative $ac_aux_dir
#
# The reason of the latter failure is that $top_srcdir and $ac_aux_dir
# are both prefixed by $srcdir.  In an in-source build this is usually
# harmless because $srcdir is '.', but things will broke when you
# start a VPATH build or use an absolute $srcdir.
#
# So we could use something similar to $top_srcdir/$ac_aux_dir/missing,
# iff we strip the leading $srcdir from $ac_aux_dir.  That would be:
#   am_aux_dir='\$(top_srcdir)/'`expr "$ac_aux_dir" : "$srcdir//*\(.*\)"`
# and then we would define $MISSING as
#   MISSING="\${SHELL} $am_aux_dir/missing"
# This will work as long as MISSING is not called from configure, because
# unfortunately $(top_srcdir) has no meaning in configure.
# However there are other variables, like CC, which are often used in
# configure, and could therefore not use this "fixed" $ac_aux_dir.
#
# Another solution, used here, is to always expand $ac_aux_dir to an
# absolute PATH.  The drawback is that using absolute paths prevent a
# configured tree to be moved without reconfiguration.

AC_DEFUN([AM_AUX_DIR_EXPAND],
[dnl Rely on autoconf to set up CDPATH properly.
AC_PREREQ([2.50])dnl
# expand $ac_aux_dir to an absolute path
am_aux_dir=`cd $ac_aux_dir && pwd`
])

# AM_CONDITIONAL                                            -*- Autoconf -*-

# Copyright (C) 1997-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_CONDITIONAL(NAME, SHELL-CONDITION)
# -------------------------------------
# Define a conditional.
AC_DEFUN([AM_CONDITIONAL],
[AC_PREREQ([2.52])dnl
 m4_if([$1], [TRUE],  [AC_FATAL([$0: invalid condition: $1])],
       [$1], [FALSE], [AC_FATAL([$0: invalid condition: $1])])dnl
AC_SUBST([$1_TRUE])dnl
AC_SUBST([$1_FALSE])dnl
_AM_SUBST_NOTMAKE([$1_TRUE])dnl
_AM_SUBST_NOTMAKE([$1_FALSE])dnl
m4_define([_AM_COND_VALUE_$1], [$2])dnl
if $2; then
  $1_TRUE=
  $1_FALSE='#'
else
  $1_TRUE='#'
  $1_FALSE=
fi
AC_CONFIG_COMMANDS_PRE(
[if test -z "${$1_TRUE}" && test -z "${$1_FALSE}"; then
  AC_MSG_ERROR([[conditional "$1" was never defined.
Usually this means the macro was only invoked conditionally.]])
fi])])

# Copyright (C) 1999-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.


# There are a few dirty hacks below to avoid letting 'AC_PROG_CC' be
# written in clear, in which case automake, when reading aclocal.m4,
# will think it sees a *use*, and therefore will trigger all it's
# C support machinery.  Also note that it means that autoscan, seeing
# CC etc. in the Makefile, will ask for an AC_PROG_CC use...


# _AM_DEPENDENCIES(NAME)
# ----------------------
# See how the compiler implements dependency checking.
# NAME is "CC", "CXX", "OBJC", "OBJCXX", "UPC", or "GJC".
# We try a few techniques and use that to set a single cache variable.
#
# We don't AC_REQUIRE the corresponding AC_PROG_CC since the latter was
# modified to invoke _AM_DEPENDENCIES(CC); we would have a circular
# dependency, and given that the user is not expected to run this macro,
# just rely on AC_PROG_CC.
AC_DEFUN([_AM_DEPENDENCIES],
[AC_REQUIRE([AM_SET_DEPDIR])dnl
AC_REQUIRE([AM_OUTPUT_DEPENDENCY_COMMANDS])dnl
AC_REQUIRE([AM_MAKE_INCLUDE])dnl
AC_REQUIRE([AM_DEP_TRACK])dnl

m4_if([$1], [CC],   [depcc="$CC"   am_compiler_list=],
      [$1], [CXX],  [depcc="$CXX"  am_compiler_list=],
      [$1], [OBJC], [depcc="$OBJC" am_compiler_list='gcc3 gcc'],
      [$1], [OBJCXX], [depcc="$OBJCXX" am_compiler_list='gcc3 gcc'],
      [$1], [UPC],  [depcc="$UPC"  am_compiler_list=],
      [$1], [GCJ],  [depcc="$GCJ"  am_compiler_list='gcc3 gcc'],
                    [depcc="$$1"   am_compiler_list=])

AC_CACHE_CHECK([dependency style of $depcc],
               [am_cv_$1_dependencies_compiler_type],
[if test -z "$AMDEP_TRUE" && test -f "$am_depcomp"; then
  # We make a subdir and do the tests there.  Otherwise we can end up
  # making bogus files that we don't know about and never remove.  For
  # instance it was reported that on HP-UX the gcc test will end up
  # making a dummy file named 'D' -- because '-MD' means "put the output
  # in D".
  rm -rf conftest.dir
  mkdir conftest.dir
  # Copy depcomp to subdir because otherwise we won't find it if we're
  # using a relative directory.
  cp "$am_depcomp" conftest.dir
  cd conftest.dir
  # We will build objects and dependencies in a subdirectory because
  # it helps to detect inapplicable dependency modes.  For instance
  # both Tru64's cc and ICC support -MD to output dependencies as a
  # side effect of compilation, but ICC will put the dependencies in
  # the current directory while Tru64 will put them in the object
  # directory.
  mkdir sub

  am_cv_$1_dependencies_compiler_type=none
  if test "$am_compiler_list" = ""; then
     am_compiler_list=`sed -n ['s/^#*\([a-zA-Z0-9]*\))$/\1/p'] < ./depcomp`
  fi
  am__universal=false
  m4_case([$1], [CC],
    [case " $depcc " in #(
     *\ -arch\ *\ -arch\ *) am__universal=true ;;
     esac],
    [CXX],
    [case " $depcc " in #(
     *\ -arch\ *\ -arch\ *) am__universal=true ;;
     esac])

  for depmode in $am_compiler_list; do
    # Setup a source with many dependencies, because some compilers
    # like to wrap large dependency lists on column 80 (with \), and
    # we should not choose a depcomp mode which is confused by this.
    #
    # We need to recreate these files for each test, as the compiler may
    # overwrite some of them when testing with obscure command lines.
    # This happens at least with the AIX C compiler.
    : > sub/conftest.c
    for i in 1 2 3 4 5 6; do
      echo '#include "conftst'$i'.h"' >> sub/conftest.c
      # Using ": > sub/conftst$i.h" creates only sub/conftst1.h with
      # Solaris 10 /bin/sh.
      echo '/* dummy */' > sub/conftst$i.h
    done
    echo "${am__include} ${am__quote}sub/conftest.Po${am__quote}" > confmf

    # We check with '-c' and '-o' for the sake of the "dashmstdout"
    # mode.  It turns out that the SunPro C++ compiler does not properly
    # handle '-M -o', and we need to detect this.  Also, some Intel
    # versions had trouble with output in subdirs.
    am__obj=sub/conftest.${OBJEXT-o}
    am__minus_obj="-o $am__obj"
    case $depmode in
    gcc)
      # This depmode causes a compiler race in universal mode.
      test "$am__universal" = false || continue
      ;;
    nosideeffect)
      # After this tag, mechanisms are not by side-effect, so they'll
      # only be used when explicitly requested.
      if test "x$enable_dependency_tracking" = xyes; then
	continue
      else
	break
      fi
      ;;
    msvc7 | msvc7msys | msvisualcpp | msvcmsys)
      # This compiler won't grok '-c -o', but also, the minuso test has
      # not run yet.  These depmodes are late enough in the game, and
      # so weak that their functioning should not be impacted.
      am__obj=conftest.${OBJEXT-o}
      am__minus_obj=
      ;;
    none) break ;;
    esac
    if depmode=$depmode \
       source=sub/conftest.c object=$am__obj \
       depfile=sub/conftest.Po tmpdepfile=sub/conftest.TPo \
       $SHELL ./depcomp $depcc -c $am__minus_obj sub/conftest.c \
         >/dev/null 2>conftest.err &&
       grep sub/conftst1.h sub/conftest.Po > /dev/null 2>&1 &&
       grep sub/conftst6.h sub/conftest.Po > /dev/null 2>&1 &&
       grep $am__obj sub/conftest.Po > /dev/null 2>&1 &&
       ${MAKE-make} -s -f confmf > /dev/null 2>&1; then
      # icc doesn't choke on unknown options, it will just issue warnings
      # or remarks (even with -Werror).  So we grep stderr for any message
      # that says an option was ignored or not supported.
      # When given -MP, icc 7.0 and 7.1 complain thusly:
      #   icc: Command line warning: ignoring option '-M'; no argument required
      # The diagnosis changed in icc 8.0:
      #   icc: Command line remark: option '-MP' not supported
      if (grep 'ignoring option' conftest.err ||
          grep 'not supported' conftest.err) >/dev/null 2>&1; then :; else
        am_cv_$1_dependencies_compiler_type=$depmode
        break
      fi
    fi
  done

  cd ..
  rm -rf conftest.dir
else
  am_cv_$1_dependencies_compiler_type=none
fi
])
AC_SUBST([$1DEPMODE], [depmode=$am_cv_$1_dependencies_compiler_type])
AM_CONDITIONAL([am__fastdep$1], [
  test "x$enable_dependency_tracking" != xno \
  && test "$am_cv_$1_dependencies_compiler_type" = gcc3])
])


# AM_SET_DEPDIR
# -------------
# Choose a directory name for dependency files.
# This macro is AC_REQUIREd in _AM_DEPENDENCIES.
AC_DEFUN([AM_SET_DEPDIR],
[AC_REQUIRE([AM_SET_LEADING_DOT])dnl
AC_SUBST([DEPDIR], ["${am__leading_dot}deps"])dnl
])


# AM_DEP_TRACK
# ------------
AC_DEFUN([AM_DEP_TRACK],
[AC_ARG_ENABLE([dependency-tracking], [dnl
AS_HELP_STRING(
  [--enable-dependency-tracking],
  [do not reject slow dependency extractors])
AS_HELP_STRING(
  [--disable-dependency-tracking],
  [speeds up one-time build])])
if test "x$enable_dependency_tracking" != xno; then
  am_depcomp="$ac_aux_dir/depcomp"
  AMDEPBACKSLASH='\'
  am__nodep='_no'
fi
AM_CONDITIONAL([AMDEP], [test "x$enable_dependency_tracking" != xno])
AC_SUBST([AMDEPBACKSLASH])dnl
_AM_SUBST_NOTMAKE([AMDEPBACKSLASH])dnl
AC_SUBST([am__nodep])dnl
_AM_SUBST_NOTMAKE([am__nodep])dnl
])

# Generate code to set up dependency tracking.              -*- Autoconf -*-

# Copyright (C) 1999-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.


# _AM_OUTPUT_DEPENDENCY_COMMANDS
# ------------------------------
AC_DEFUN([_AM_OUTPUT_DEPENDENCY_COMMANDS],
[{
  # Older Autoconf quotes --file arguments for eval, but not when files
  # are listed without --file.  Let's play safe and only enable the eval
  # if we detect the quoting.
  case $CONFIG_FILES in
  *\'*) eval set x "$CONFIG_FILES" ;;
  *)   set x $CONFIG_FILES ;;
  esac
  shift
  for mf
  do
    # Strip MF so we end up with the name of the file.
    mf=`echo "$mf" | sed -e 's/:.*$//'`
    # Check whether this is an Automake generated Makefile or not.
    # We used to match only the files named 'Makefile.in', but
    # some people rename them; so instead we look at the file content.
    # Grep'ing the first line is not enough: some people post-process
    # each Makefile.in and add a new line on top of each file to say so.
    # Grep'ing the whole file is not good either: AIX grep has a line
    # limit of 2048, but all sed's we know have understand at least 4000.
    if sed -n 's,^#.*generated by automake.*,X,p' "$mf" | grep X >/dev/null 2>&1; then
      dirpart=`AS_DIRNAME("$mf")`
    else
      continue
    fi
    # Extract the definition of DEPDIR, am__include, and am__quote
    # from the Makefile without running 'make'.
    DEPDIR=`sed -n 's/^DEPDIR = //p' < "$mf"`
    test -z "$DEPDIR" && continue
    am__include=`sed -n 's/^am__include = //p' < "$mf"`
    test -z "$am__include" && continue
    am__quote=`sed -n 's/^am__quote = //p' < "$mf"`
    # Find all dependency output files, they are included files with
    # $(DEPDIR) in their names.  We invoke sed twice because it is the
    # simplest approach to changing $(DEPDIR) to its actual value in the
    # expansion.
    for file in `sed -n "
      s/^$am__include $am__quote\(.*(DEPDIR).*\)$am__quote"'$/\1/p' <"$mf" | \
	 sed -e 's/\$(DEPDIR)/'"$DEPDIR"'/g'`; do
      # Make sure the directory exists.
      test -f "$dirpart/$file" && continue
      fdir=`AS_DIRNAME(["$file"])`
      AS_MKDIR_P([$dirpart/$fdir])
      # echo "creating $dirpart/$file"
      echo '# dummy' > "$dirpart/$file"
    done
  done
}
])# _AM_OUTPUT_DEPENDENCY_COMMANDS


# AM_OUTPUT_DEPENDENCY_COMMANDS
# -----------------------------
# This macro should only be invoked once -- use via AC_REQUIRE.
#
# This code is only required when automatic dependency tracking
# is enabled.  FIXME.  This creates each '.P' file that we will
# need in order to bootstrap the dependency handling code.
AC_DEFUN([AM_OUTPUT_DEPENDENCY_COMMANDS],
[AC_CONFIG_COMMANDS([depfiles],
     [test x"$AMDEP_TRUE" != x"" || _AM_OUTPUT_DEPENDENCY_COMMANDS],
     [AMDEP_TRUE="$AMDEP_TRUE" ac_aux_dir="$ac_aux_dir"])
])

# Do all the work for Automake.                             -*- Autoconf -*-

# Copyright (C) 1996-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This macro actually does too much.  Some checks are only needed if
# your package does certain things.  But this isn't really a big deal.

# AM_INIT_AUTOMAKE(PACKAGE, VERSION, [NO-DEFINE])
# AM_INIT_AUTOMAKE([OPTIONS])
# -----------------------------------------------
# The call with PACKAGE and VERSION arguments is the old style
# call (pre autoconf-2.50), which is being phased out.  PACKAGE
# and VERSION should now be passed to AC_INIT and removed from
# the call to AM_INIT_AUTOMAKE.
# We support both call styles for the transition.  After
# the next Automake release, Autoconf can make the AC_INIT
# arguments mandatory, and then we can depend on a new Autoconf
# release and drop the old call support.
AC_DEFUN([AM_INIT_AUTOMAKE],
[AC_PREREQ([2.65])dnl
dnl Autoconf wants to disallow AM_ names.  We explicitly allow
dnl the ones we care about.
m4_pattern_allow([^AM_[A-Z]+FLAGS$])dnl
AC_REQUIRE([AM_SET_CURRENT_AUTOMAKE_VERSION])dnl
AC_REQUIRE([AC_PROG_INSTALL])dnl
if test "`cd $srcdir && pwd`" != "`pwd`"; then
  # Use -I$(srcdir) only when $(srcdir) != ., so that make's output
  # is not polluted with repeated "-I."
  AC_SUBST([am__isrc], [' -I$(srcdir)'])_AM_SUBST_NOTMAKE([am__isrc])dnl
  # test to see if srcdir already configured
  if test -f $srcdir/config.status; then
    AC_MSG_ERROR([source directory already configured; run "make distclean" there first])
  fi
fi

# test whether we have cygpath
if test -z "$CYGPATH_W"; then
  if (cygpath --version) >/dev/null 2>/dev/null; then
    CYGPATH_W='cygpath -w'
  else
    CYGPATH_W=echo
  fi
fi
AC_SUBST([CYGPATH_W])

# Define the identity of the package.
dnl Distinguish between old-style and new-style calls.
m4_ifval([$2],
[AC_DIAGNOSE([obsolete],
             [$0: two- and three-arguments forms are deprecated.])
m4_ifval([$3], [_AM_SET_OPTION([no-define])])dnl
 AC_SUBST([PACKAGE], [$1])dnl
 AC_SUBST([VERSION], [$2])],
[_AM_SET_OPTIONS([$1])dnl
dnl Diagnose old-style AC_INIT with new-style AM_AUTOMAKE_INIT.
m4_if(
  m4_ifdef([AC_PACKAGE_NAME], [ok]):m4_ifdef([AC_PACKAGE_VERSION], [ok]),
  [ok:ok],,
  [m4_fatal([AC_INIT should be called with package and version arguments])])dnl
 AC_SUBST([PACKAGE], ['AC_PACKAGE_TARNAME'])dnl
 AC_SUBST([VERSION], ['AC_PACKAGE_VERSION'])])dnl

_AM_IF_OPTION([no-define],,
[AC_DEFINE_UNQUOTED([PACKAGE], ["$PACKAGE"], [Name of package])
 AC_DEFINE_UNQUOTED([VERSION], ["$VERSION"], [Version number of package])])dnl

# Some tools Automake needs.
AC_REQUIRE([AM_SANITY_CHECK])dnl
AC_REQUIRE([AC_ARG_PROGRAM])dnl
AM_MISSING_PROG([ACLOCAL], [aclocal-${am__api_version}])
AM_MISSING_PROG([AUTOCONF], [autoconf])
AM_MISSING_PROG([AUTOMAKE], [automake-${am__api_version}])
AM_MISSING_PROG([AUTOHEADER], [autoheader])
AM_MISSING_PROG([MAKEINFO], [makeinfo])
AC_REQUIRE([AM_PROG_INSTALL_SH])dnl
AC_REQUIRE([AM_PROG_INSTALL_STRIP])dnl
AC_REQUIRE([AC_PROG_MKDIR_P])dnl
# For better backward compatibility.  To be removed once Automake 1.9.x
# dies out for good.  For more background, see:
# <http://lists.gnu.org/archive/html/automake/2012-07/msg00001.html>
# <http://lists.gnu.org/archive/html/automake/2012-07/msg00014.html>
AC_SUBST([mkdir_p], ['$(MKDIR_P)'])
# We need awk for the "check" target.  The system "awk" is bad on
# some platforms.
AC_REQUIRE([AC_PROG_AWK])dnl
AC_REQUIRE([AC_PROG_MAKE_SET])dnl
AC_REQUIRE([AM_SET_LEADING_DOT])dnl
_AM_IF_OPTION([tar-ustar], [_AM_PROG_TAR([ustar])],
	      [_AM_IF_OPTION([tar-pax], [_AM_PROG_TAR([pax])],
			     [_AM_PROG_TAR([v7])])])
_AM_IF_OPTION([no-dependencies],,
[AC_PROVIDE_IFELSE([AC_PROG_CC],
		  [_AM_DEPENDENCIES([CC])],
		  [m4_define([AC_PROG_CC],
			     m4_defn([AC_PROG_CC])[_AM_DEPENDENCIES([CC])])])dnl
AC_PROVIDE_IFELSE([AC_PROG_CXX],
		  [_AM_DEPENDENCIES([CXX])],
		  [m4_define([AC_PROG_CXX],
			     m4_defn([AC_PROG_CXX])[_AM_DEPENDENCIES([CXX])])])dnl
AC_PROVIDE_IFELSE([AC_PROG_OBJC],
		  [_AM_DEPENDENCIES([OBJC])],
		  [m4_define([AC_PROG_OBJC],
			     m4_defn([AC_PROG_OBJC])[_AM_DEPENDENCIES([OBJC])])])dnl
AC_PROVIDE_IFELSE([AC_PROG_OBJCXX],
		  [_AM_DEPENDENCIES([OBJCXX])],
		  [m4_define([AC_PROG_OBJCXX],
			     m4_defn([AC_PROG_OBJCXX])[_AM_DEPENDENCIES([OBJCXX])])])dnl
])
AC_REQUIRE([AM_SILENT_RULES])dnl
dnl The testsuite driver may need to know about EXEEXT, so add the
dnl 'am__EXEEXT' conditional if _AM_COMPILER_EXEEXT was seen.  This
dnl macro is hooked onto _AC_COMPILER_EXEEXT early, see below.
AC_CONFIG_COMMANDS_PRE(dnl
[m4_provide_if([_AM_COMPILER_EXEEXT],
  [AM_CONDITIONAL([am__EXEEXT], [test -n "$EXEEXT"])])])dnl
])

dnl Hook into '_AC_COMPILER_EXEEXT' early to learn its expansion.  Do not
dnl add the conditional right here, as _AC_COMPILER_EXEEXT may be further
dnl mangled by Autoconf and run in a shell conditional statement.
m4_define([_AC_COMPILER_EXEEXT],
m4_defn([_AC_COMPILER_EXEEXT])[m4_provide([_AM_COMPILER_EXEEXT])])


# When config.status generates a header, we must update the stamp-h file.
# This file resides in the same directory as the config header
# that is generated.  The stamp files are numbered to have different names.

# Autoconf calls _AC_AM_CONFIG_HEADER_HOOK (when defined) in the
# loop where config.status creates the headers, so we can generate
# our stamp files there.
AC_DEFUN([_AC_AM_CONFIG_HEADER_HOOK],
[# Compute $1's index in $config_headers.
_am_arg=$1
_am_stamp_count=1
for _am_header in $config_headers :; do
  case $_am_header in
    $_am_arg | $_am_arg:* )
      break ;;
    * )
      _am_stamp_count=`expr $_am_stamp_count + 1` ;;
  esac
done
echo "timestamp for $_am_arg" >`AS_DIRNAME(["$_am_arg"])`/stamp-h[]$_am_stamp_count])

# Copyright (C) 2001-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_PROG_INSTALL_SH
# ------------------
# Define $install_sh.
AC_DEFUN([AM_PROG_INSTALL_SH],
[AC_REQUIRE([AM_AUX_DIR_EXPAND])dnl
if test x"${install_sh}" != xset; then
  case $am_aux_dir in
  *\ * | *\	*)
    install_sh="\${SHELL} '$am_aux_dir/install-sh'" ;;
  *)
    install_sh="\${SHELL} $am_aux_dir/install-sh"
  esac
fi
AC_SUBST([install_sh])])

# Copyright (C) 2003-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# Check whether the underlying file-system supports filenames
# with a leading dot.  For instance MS-DOS doesn't.
AC_DEFUN([AM_SET_LEADING_DOT],
[rm -rf .tst 2>/dev/null
mkdir .tst 2>/dev/null
if test -d .tst; then
  am__leading_dot=.
else
  am__leading_dot=_
fi
rmdir .tst 2>/dev/null
AC_SUBST([am__leading_dot])])

# Add --enable-maintainer-mode option to configure.         -*- Autoconf -*-
# From Jim Meyering

# Copyright (C) 1996-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_MAINTAINER_MODE([DEFAULT-MODE])
# ----------------------------------
# Control maintainer-specific portions of Makefiles.
# Default is to disable them, unless 'enable' is passed literally.
# For symmetry, 'disable' may be passed as well.  Anyway, the user
# can override the default with the --enable/--disable switch.
AC_DEFUN([AM_MAINTAINER_MODE],
[m4_case(m4_default([$1], [disable]),
       [enable], [m4_define([am_maintainer_other], [disable])],
       [disable], [m4_define([am_maintainer_other], [enable])],
       [m4_define([am_maintainer_other], [enable])
        m4_warn([syntax], [unexpected argument to AM@&t@_MAINTAINER_MODE: $1])])
AC_MSG_CHECKING([whether to enable maintainer-specific portions of Makefiles])
  dnl maintainer-mode's default is 'disable' unless 'enable' is passed
  AC_ARG_ENABLE([maintainer-mode],
    [AS_HELP_STRING([--]am_maintainer_other[-maintainer-mode],
      am_maintainer_other[ make rules and dependencies not useful
      (and sometimes confusing) to the casual installer])],
    [USE_MAINTAINER_MODE=$enableval],
    [USE_MAINTAINER_MODE=]m4_if(am_maintainer_other, [enable], [no], [yes]))
  AC_MSG_RESULT([$USE_MAINTAINER_MODE])
  AM_CONDITIONAL([MAINTAINER_MODE], [test $USE_MAINTAINER_MODE = yes])
  MAINT=$MAINTAINER_MODE_TRUE
  AC_SUBST([MAINT])dnl
]
)

# Check to see how 'make' treats includes.	            -*- Autoconf -*-

# Copyright (C) 2001-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_MAKE_INCLUDE()
# -----------------
# Check to see how make treats includes.
AC_DEFUN([AM_MAKE_INCLUDE],
[am_make=${MAKE-make}
cat > confinc << 'END'
am__doit:
	@echo this is the am__doit target
.PHONY: am__doit
END
# If we don't find an include directive, just comment out the code.
AC_MSG_CHECKING([for style of include used by $am_make])
am__include="#"
am__quote=
_am_result=none
# First try GNU make style include.
echo "include confinc" > confmf
# Ignore all kinds of additional output from 'make'.
case `$am_make -s -f confmf 2> /dev/null` in #(
*the\ am__doit\ target*)
  am__include=include
  am__quote=
  _am_result=GNU
  ;;
esac
# Now try BSD make style include.
if test "$am__include" = "#"; then
   echo '.include "confinc"' > confmf
   case `$am_make -s -f confmf 2> /dev/null` in #(
   *the\ am__doit\ target*)
     am__include=.include
     am__quote="\""
     _am_result=BSD
     ;;
   esac
fi
AC_SUBST([am__include])
AC_SUBST([am__quote])
AC_MSG_RESULT([$_am_result])
rm -f confinc confmf
])

# Fake the existence of programs that GNU maintainers use.  -*- Autoconf -*-

# Copyright (C) 1997-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_MISSING_PROG(NAME, PROGRAM)
# ------------------------------
AC_DEFUN([AM_MISSING_PROG],
[AC_REQUIRE([AM_MISSING_HAS_RUN])
$1=${$1-"${am_missing_run}$2"}
AC_SUBST($1)])

# AM_MISSING_HAS_RUN
# ------------------
# Define MISSING if not defined so far and test if it is modern enough.
# If it is, set am_missing_run to use it, otherwise, to nothing.
AC_DEFUN([AM_MISSING_HAS_RUN],
[AC_REQUIRE([AM_AUX_DIR_EXPAND])dnl
AC_REQUIRE_AUX_FILE([missing])dnl
if test x"${MISSING+set}" != xset; then
  case $am_aux_dir in
  *\ * | *\	*)
    MISSING="\${SHELL} \"$am_aux_dir/missing\"" ;;
  *)
    MISSING="\${SHELL} $am_aux_dir/missing" ;;
  esac
fi
# Use eval to expand $SHELL
if eval "$MISSING --is-lightweight"; then
  am_missing_run="$MISSING "
else
  am_missing_run=
  AC_MSG_WARN(['missing' script is too old or missing])
fi
])

# Helper functions for option handling.                     -*- Autoconf -*-

# Copyright (C) 2001-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_MANGLE_OPTION(NAME)
# -----------------------
AC_DEFUN([_AM_MANGLE_OPTION],
[[_AM_OPTION_]m4_bpatsubst($1, [[^a-zA-Z0-9_]], [_])])

# _AM_SET_OPTION(NAME)
# --------------------
# Set option NAME.  Presently that only means defining a flag for this option.
AC_DEFUN([_AM_SET_OPTION],
[m4_define(_AM_MANGLE_OPTION([$1]), [1])])

# _AM_SET_OPTIONS(OPTIONS)
# ------------------------
# OPTIONS is a space-separated list of Automake options.
AC_DEFUN([_AM_SET_OPTIONS],
[m4_foreach_w([_AM_Option], [$1], [_AM_SET_OPTION(_AM_Option)])])

# _AM_IF_OPTION(OPTION, IF-SET, [IF-NOT-SET])
# -------------------------------------------
# Execute IF-SET if OPTION is set, IF-NOT-SET otherwise.
AC_DEFUN([_AM_IF_OPTION],
[m4_ifset(_AM_MANGLE_OPTION([$1]), [$2], [$3])])

# Check to make sure that the build environment is sane.    -*- Autoconf -*-

# Copyright (C) 1996-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_SANITY_CHECK
# ---------------
AC_DEFUN([AM_SANITY_CHECK],
[AC_MSG_CHECKING([whether build environment is sane])
# Reject unsafe characters in $srcdir or the absolute working directory
# name.  Accept space and tab only in the latter.
am_lf='
'
case `pwd` in
  *[[\\\"\#\$\&\'\`$am_lf]]*)
    AC_MSG_ERROR([unsafe absolute working directory name]);;
esac
case $srcdir in
  *[[\\\"\#\$\&\'\`$am_lf\ \	]]*)
    AC_MSG_ERROR([unsafe srcdir value: '$srcdir']);;
esac

# Do 'set' in a subshell so we don't clobber the current shell's
# arguments.  Must try -L first in case configure is actually a
# symlink; some systems play weird games with the mod time of symlinks
# (eg FreeBSD returns the mod time of the symlink's containing
# directory).
if (
   am_has_slept=no
   for am_try in 1 2; do
     echo "timestamp, slept: $am_has_slept" > conftest.file
     set X `ls -Lt "$srcdir/configure" conftest.file 2> /dev/null`
     if test "$[*]" = "X"; then
	# -L didn't work.
	set X `ls -t "$srcdir/configure" conftest.file`
     fi
     if test "$[*]" != "X $srcdir/configure conftest.file" \
	&& test "$[*]" != "X conftest.file $srcdir/configure"; then

	# If neither matched, then we have a broken ls.  This can happen
	# if, for instance, CONFIG_SHELL is bash and it inherits a
	# broken ls alias from the environment.  This has actually
	# happened.  Such a system could not be considered "sane".
	AC_MSG_ERROR([ls -t appears to fail.  Make sure there is not a broken
  alias in your environment])
     fi
     if test "$[2]" = conftest.file || test $am_try -eq 2; then
       break
     fi
     # Just in case.
     sleep 1
     am_has_slept=yes
   done
   test "$[2]" = conftest.file
   )
then
   # Ok.
   :
else
   AC_MSG_ERROR([newly created file is older than distributed files!
Check your system clock])
fi
AC_MSG_RESULT([yes])
# If we didn't sleep, we still need to ensure time stamps of config.status and
# generated files are strictly newer.
am_sleep_pid=
if grep 'slept: no' conftest.file >/dev/null 2>&1; then
  ( sleep 1 ) &
  am_sleep_pid=$!
fi
AC_CONFIG_COMMANDS_PRE(
  [AC_MSG_CHECKING([that generated files are newer than configure])
   if test -n "$am_sleep_pid"; then
     # Hide warnings about reused PIDs.
     wait $am_sleep_pid 2>/dev/null
   fi
   AC_MSG_RESULT([done])])
rm -f conftest.file
])

# Copyright (C) 2009-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_SILENT_RULES([DEFAULT])
# --------------------------
# Enable less verbose build rules; with the default set to DEFAULT
# ("yes" being less verbose, "no" or empty being verbose).
AC_DEFUN([AM_SILENT_RULES],
[AC_ARG_ENABLE([silent-rules], [dnl
AS_HELP_STRING(
  [--enable-silent-rules],
  [less verbose build output (undo: "make V=1")])
AS_HELP_STRING(
  [--disable-silent-rules],
  [verbose build output (undo: "make V=0")])dnl
])
case $enable_silent_rules in @%:@ (((
  yes) AM_DEFAULT_VERBOSITY=0;;
   no) AM_DEFAULT_VERBOSITY=1;;
    *) AM_DEFAULT_VERBOSITY=m4_if([$1], [yes], [0], [1]);;
esac
dnl
dnl A few 'make' implementations (e.g., NonStop OS and NextStep)
dnl do not support nested variable expansions.
dnl See automake bug#9928 and bug#10237.
am_make=${MAKE-make}
AC_CACHE_CHECK([whether $am_make supports nested variables],
   [am_cv_make_support_nested_variables],
   [if AS_ECHO([['TRUE=$(BAR$(V))
BAR0=false
BAR1=true
V=1
am__doit:
	@$(TRUE)
.PHONY: am__doit']]) | $am_make -f - >/dev/null 2>&1; then
  am_cv_make_support_nested_variables=yes
else
  am_cv_make_support_nested_variables=no
fi])
if test $am_cv_make_support_nested_variables = yes; then
  dnl Using '$V' instead of '$(V)' breaks IRIX make.
  AM_V='$(V)'
  AM_DEFAULT_V='$(AM_DEFAULT_VERBOSITY)'
else
  AM_V=$AM_DEFAULT_VERBOSITY
  AM_DEFAULT_V=$AM_DEFAULT_VERBOSITY
fi
AC_SUBST([AM_V])dnl
AM_SUBST_NOTMAKE([AM_V])dnl
AC_SUBST([AM_DEFAULT_V])dnl
AM_SUBST_NOTMAKE([AM_DEFAULT_V])dnl
AC_SUBST([AM_DEFAULT_VERBOSITY])dnl
AM_BACKSLASH='\'
AC_SUBST([AM_BACKSLASH])dnl
_AM_SUBST_NOTMAKE([AM_BACKSLASH])dnl
])

# Copyright (C) 2001-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_PROG_INSTALL_STRIP
# ---------------------
# One issue with vendor 'install' (even GNU) is that you can't
# specify the program used to strip binaries.  This is especially
# annoying in cross-compiling environments, where the build's strip
# is unlikely to handle the host's binaries.
# Fortunately install-sh will honor a STRIPPROG variable, so we
# always use install-sh in "make install-strip", and initialize
# STRIPPROG with the value of the STRIP variable (set by the user).
AC_DEFUN([AM_PROG_INSTALL_STRIP],
[AC_REQUIRE([AM_PROG_INSTALL_SH])dnl
# Installed binaries are usually stripped using 'strip' when the user
# run "make install-strip".  However 'strip' might not be the right
# tool to use in cross-compilation environments, therefore Automake
# will honor the 'STRIP' environment variable to overrule this program.
dnl Don't test for $cross_compiling = yes, because it might be 'maybe'.
if test "$cross_compiling" != no; then
  AC_CHECK_TOOL([STRIP], [strip], :)
fi
INSTALL_STRIP_PROGRAM="\$(install_sh) -c -s"
AC_SUBST([INSTALL_STRIP_PROGRAM])])

# Copyright (C) 2006-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_SUBST_NOTMAKE(VARIABLE)
# ---------------------------
# Prevent Automake from outputting VARIABLE = @VARIABLE@ in Makefile.in.
# This macro is traced by Automake.
AC_DEFUN([_AM_SUBST_NOTMAKE])

# AM_SUBST_NOTMAKE(VARIABLE)
# --------------------------
# Public sister of _AM_SUBST_NOTMAKE.
AC_DEFUN([AM_SUBST_NOTMAKE], [_AM_SUBST_NOTMAKE($@)])

# Check how to create a tarball.                            -*- Autoconf -*-

# Copyright (C) 2004-2013 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# _AM_PROG_TAR(FORMAT)
# --------------------
# Check how to create a tarball in format FORMAT.
# FORMAT should be one of 'v7', 'ustar', or 'pax'.
#
# Substitute a variable $(am__tar) that is a command
# writing to stdout a FORMAT-tarball containing the directory
# $tardir.
#     tardir=directory && $(am__tar) > result.tar
#
# Substitute a variable $(am__untar) that extract such
# a tarball read from stdin.
#     $(am__untar) < result.tar
#
AC_DEFUN([_AM_PROG_TAR],
[# Always define AMTAR for backward compatibility.  Yes, it's still used
# in the wild :-(  We should find a proper way to deprecate it ...
AC_SUBST([AMTAR], ['$${TAR-tar}'])

# We'll loop over all known methods to create a tar archive until one works.
_am_tools='gnutar m4_if([$1], [ustar], [plaintar]) pax cpio none'

m4_if([$1], [v7],
  [am__tar='$${TAR-tar} chof - "$$tardir"' am__untar='$${TAR-tar} xf -'],

  [m4_case([$1],
    [ustar],
     [# The POSIX 1988 'ustar' format is defined with fixed-size fields.
      # There is notably a 21 bits limit for the UID and the GID.  In fact,
      # the 'pax' utility can hang on bigger UID/GID (see automake bug#8343
      # and bug#13588).
      am_max_uid=2097151 # 2^21 - 1
      am_max_gid=$am_max_uid
      # The $UID and $GID variables are not portable, so we need to resort
      # to the POSIX-mandated id(1) utility.  Errors in the 'id' calls
      # below are definitely unexpected, so allow the users to see them
      # (that is, avoid stderr redirection).
      am_uid=`id -u || echo unknown`
      am_gid=`id -g || echo unknown`
      AC_MSG_CHECKING([whether UID '$am_uid' is supported by ustar format])
      if test $am_uid -le $am_max_uid; then
         AC_MSG_RESULT([yes])
      else
         AC_MSG_RESULT([no])
         _am_tools=none
      fi
      AC_MSG_CHECKING([whether GID '$am_gid' is supported by ustar format])
      if test $am_gid -le $am_max_gid; then
         AC_MSG_RESULT([yes])
      else
        AC_MSG_RESULT([no])
        _am_tools=none
      fi],

  [pax],
    [],

  [m4_fatal([Unknown tar format])])

  AC_MSG_CHECKING([how to create a $1 tar archive])

  # Go ahead even if we have the value already cached.  We do so because we
  # need to set the values for the 'am__tar' and 'am__untar' variables.
  _am_tools=${am_cv_prog_tar_$1-$_am_tools}

  for _am_tool in $_am_tools; do
    case $_am_tool in
    gnutar)
      for _am_tar in tar gnutar gtar; do
        AM_RUN_LOG([$_am_tar --version]) && break
      done
      am__tar="$_am_tar --format=m4_if([$1], [pax], [posix], [$1]) -chf - "'"$$tardir"'
      am__tar_="$_am_tar --format=m4_if([$1], [pax], [posix], [$1]) -chf - "'"$tardir"'
      am__untar="$_am_tar -xf -"
      ;;
    plaintar)
      # Must skip GNU tar: if it does not support --format= it doesn't create
      # ustar tarball either.
      (tar --version) >/dev/null 2>&1 && continue
      am__tar='tar chf - "$$tardir"'
      am__tar_='tar chf - "$tardir"'
      am__untar='tar xf -'
      ;;
    pax)
      am__tar='pax -L -x $1 -w "$$tardir"'
      am__tar_='pax -L -x $1 -w "$tardir"'
      am__untar='pax -r'
      ;;
    cpio)
      am__tar='find "$$tardir" -print | cpio -o -H $1 -L'
      am__tar_='find "$tardir" -print | cpio -o -H $1 -L'
      am__untar='cpio -i -H $1 -d'
      ;;
    none)
      am__tar=false
      am__tar_=false
      am__untar=false
      ;;
    esac

    # If the value was cached, stop now.  We just wanted to have am__tar
    # and am__untar set.
    test -n "${am_cv_prog_tar_$1}" && break

    # tar/untar a dummy directory, and stop if the command works.
    rm -rf conftest.dir
    mkdir conftest.dir
    echo GrepMe > conftest.dir/file
    AM_RUN_LOG([tardir=conftest.dir && eval $am__tar_ >conftest.tar])
    rm -rf conftest.dir
    if test -s conftest.tar; then
      AM_RUN_LOG([$am__untar <conftest.tar])
      AM_RUN_LOG([cat conftest.dir/file])
      grep GrepMe conftest.dir/file >/dev/null 2>&1 && break
    fi
  done
  rm -rf conftest.dir

  AC_CACHE_VAL([am_cv_prog_tar_$1], [am_cv_prog_tar_$1=$_am_tool])
  AC_MSG_RESULT([$am_cv_prog_tar_$1])])

AC_SUBST([am__tar])
AC_SUBST([am__untar])
]) # _AM_PROG_TAR

