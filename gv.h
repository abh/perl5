/*    gv.h
 *
 *    Copyright (C) 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999,
 *    2000, 2001, 2002, 2003, 2004, 2005, 2006, by Larry Wall and others
 *
 *    You may distribute under the terms of either the GNU General Public
 *    License or the Artistic License, as specified in the README file.
 *
 */

struct gp {
    SV *	gp_sv;		/* scalar value */
    U32		gp_refcnt;	/* how many globs point to this? */
    struct io *	gp_io;		/* filehandle value */
    CV *	gp_form;	/* format value */
    AV *	gp_av;		/* array value */
    HV *	gp_hv;		/* hash value */
    GV *	gp_egv;		/* effective gv, if *glob */
    CV *	gp_cv;		/* subroutine value */
    U32		gp_cvgen;	/* generational validity of cached gv_cv */
    line_t	gp_line;	/* line first declared at (for -w) */
    char *	gp_file;	/* file first declared in (for -w) */
};

#define GvXPVGV(gv)	((XPVGV*)SvANY(gv))

/* MSVC++ 6.0 (_MSC_VER == 1200) can't compile pp_hot.c with DEBUGGING enabled
 * if we include the following assert(). Must be a compiler bug because it
 * works fine with MSVC++ 7.0. Borland (5.5.1) has the same problem. */
#if defined(DEBUGGING) && \
    ((!defined(_MSC_VER) || _MSC_VER > 1200) && !defined(__BORLANDC__))
#  define GvGP(gv)	(*(assert(SvTYPE(gv) == SVt_PVGV || \
				  SvTYPE(gv) == SVt_PVLV), \
			assert(isGV_with_GP(gv)),	\
			   &((gv)->sv_u.svu_gp)))
#else
#  define GvGP(gv)	((gv)->sv_u.svu_gp)
#endif

#define GvNAME(gv)	(GvXPVGV(gv)->xgv_name)
#define GvNAMELEN(gv)	(GvXPVGV(gv)->xgv_namelen)
#define GvFLAGS(gv)	(GvXPVGV(gv)->xgv_flags)

#if defined (DEBUGGING) && defined(__GNUC__) && !defined(PERL_GCC_BRACE_GROUPS_FORBIDDEN)
#  define GvSTASH(gv)							\
	(*({ GV *_gv = (GV *) gv;					\
	    assert(SvTYPE(_gv) == SVt_PVGV || SvTYPE(_gv) >= SVt_PVLV);	\
	    &(GvXPVGV(_gv)->xgv_stash);					\
	 }))
#else
#define GvSTASH(gv)	(GvXPVGV(gv)->xgv_stash)
#endif
/*
=head1 GV Functions

=for apidoc Am|SV*|GvSV|GV* gv

Return the SV from the GV.

=cut
*/

#define GvSV(gv)	(GvGP(gv)->gp_sv)
#ifdef PERL_DONT_CREATE_GVSV
#define GvSVn(gv)	(*(GvGP(gv)->gp_sv ? \
			 &(GvGP(gv)->gp_sv) : \
			 &(GvGP(gv_SVadd(gv))->gp_sv)))
#else
#define GvSVn(gv)	GvSV(gv)
#endif

#define GvREFCNT(gv)	(GvGP(gv)->gp_refcnt)
#define GvIO(gv)	((gv) && SvTYPE((SV*)gv) == SVt_PVGV && GvGP(gv) ? GvIOp(gv) : 0)
#define GvIOp(gv)	(GvGP(gv)->gp_io)
#define GvIOn(gv)	(GvIO(gv) ? GvIOp(gv) : GvIOp(gv_IOadd(gv)))

#define GvFORM(gv)	(GvGP(gv)->gp_form)
#define GvAV(gv)	(GvGP(gv)->gp_av)

/* This macro is deprecated.  Do not use! */
#define GvREFCNT_inc(gv) ((GV*)SvREFCNT_inc(gv))	/* DO NOT USE */

#define GvAVn(gv)	(GvGP(gv)->gp_av ? \
			 GvGP(gv)->gp_av : \
			 GvGP(gv_AVadd(gv))->gp_av)
#define GvHV(gv)	((GvGP(gv))->gp_hv)

#define GvHVn(gv)	(GvGP(gv)->gp_hv ? \
			 GvGP(gv)->gp_hv : \
			 GvGP(gv_HVadd(gv))->gp_hv)

#define GvCV(gv)	(GvGP(gv)->gp_cv)
#define GvCVGEN(gv)	(GvGP(gv)->gp_cvgen)
#define GvCVu(gv)	(GvGP(gv)->gp_cvgen ? NULL : GvGP(gv)->gp_cv)

#define GvLINE(gv)	(GvGP(gv)->gp_line)
#define GvFILE(gv)	(GvGP(gv)->gp_file)
#define GvFILEGV(gv)	(gv_fetchfile(GvFILE(gv)))

#define GvEGV(gv)	(GvGP(gv)->gp_egv)
#define GvENAME(gv)	GvNAME(GvEGV(gv) ? GvEGV(gv) : gv)
#define GvESTASH(gv)	GvSTASH(GvEGV(gv) ? GvEGV(gv) : gv)

#define GVf_INTRO	0x01
#define GVf_MULTI	0x02
#define GVf_ASSUMECV	0x04
#define GVf_IN_PAD	0x08
#define GVf_IMPORTED	0xF0
#define GVf_IMPORTED_SV	  0x10
#define GVf_IMPORTED_AV	  0x20
#define GVf_IMPORTED_HV	  0x40
#define GVf_IMPORTED_CV	  0x80

#define GvINTRO(gv)		(GvFLAGS(gv) & GVf_INTRO)
#define GvINTRO_on(gv)		(GvFLAGS(gv) |= GVf_INTRO)
#define GvINTRO_off(gv)		(GvFLAGS(gv) &= ~GVf_INTRO)

#define GvMULTI(gv)		(GvFLAGS(gv) & GVf_MULTI)
#define GvMULTI_on(gv)		(GvFLAGS(gv) |= GVf_MULTI)
#define GvMULTI_off(gv)		(GvFLAGS(gv) &= ~GVf_MULTI)

#define GvASSUMECV(gv)		(GvFLAGS(gv) & GVf_ASSUMECV)
#define GvASSUMECV_on(gv)	(GvFLAGS(gv) |= GVf_ASSUMECV)
#define GvASSUMECV_off(gv)	(GvFLAGS(gv) &= ~GVf_ASSUMECV)

#define GvIMPORTED(gv)		(GvFLAGS(gv) & GVf_IMPORTED)
#define GvIMPORTED_on(gv)	(GvFLAGS(gv) |= GVf_IMPORTED)
#define GvIMPORTED_off(gv)	(GvFLAGS(gv) &= ~GVf_IMPORTED)

#define GvIMPORTED_SV(gv)	(GvFLAGS(gv) & GVf_IMPORTED_SV)
#define GvIMPORTED_SV_on(gv)	(GvFLAGS(gv) |= GVf_IMPORTED_SV)
#define GvIMPORTED_SV_off(gv)	(GvFLAGS(gv) &= ~GVf_IMPORTED_SV)

#define GvIMPORTED_AV(gv)	(GvFLAGS(gv) & GVf_IMPORTED_AV)
#define GvIMPORTED_AV_on(gv)	(GvFLAGS(gv) |= GVf_IMPORTED_AV)
#define GvIMPORTED_AV_off(gv)	(GvFLAGS(gv) &= ~GVf_IMPORTED_AV)

#define GvIMPORTED_HV(gv)	(GvFLAGS(gv) & GVf_IMPORTED_HV)
#define GvIMPORTED_HV_on(gv)	(GvFLAGS(gv) |= GVf_IMPORTED_HV)
#define GvIMPORTED_HV_off(gv)	(GvFLAGS(gv) &= ~GVf_IMPORTED_HV)

#define GvIMPORTED_CV(gv)	(GvFLAGS(gv) & GVf_IMPORTED_CV)
#define GvIMPORTED_CV_on(gv)	(GvFLAGS(gv) |= GVf_IMPORTED_CV)
#define GvIMPORTED_CV_off(gv)	(GvFLAGS(gv) &= ~GVf_IMPORTED_CV)

#define GvIN_PAD(gv)		(GvFLAGS(gv) & GVf_IN_PAD)
#define GvIN_PAD_on(gv)		(GvFLAGS(gv) |= GVf_IN_PAD)
#define GvIN_PAD_off(gv)	(GvFLAGS(gv) &= ~GVf_IN_PAD)

#define GvUNIQUE(gv)            0
#define GvUNIQUE_on(gv)
#define GvUNIQUE_off(gv)

#ifdef USE_ITHREADS
#define GV_UNIQUE_CHECK
#else
#undef  GV_UNIQUE_CHECK
#endif

#define Nullgv Null(GV*)

#define DM_UID   0x003
#define DM_RUID   0x001
#define DM_EUID   0x002
#define DM_GID   0x030
#define DM_RGID   0x010
#define DM_EGID   0x020
#define DM_DELAY 0x100

/*
 * symbol creation flags, for use in gv_fetchpv() and get_*v()
 */
#define GV_ADD		0x01	/* add, if symbol not already there */
#define GV_ADDMULTI	0x02	/* add, pretending it has been added already */
#define GV_ADDWARN	0x04	/* add, but warn if symbol wasn't already there */
#define GV_ADDINEVAL	0x08	/* add, as though we're doing so within an eval */
#define GV_NOINIT	0x10	/* add, but don't init symbol, if type != PVGV */
/* This is used by toke.c to avoid turing placeholder constants in the symbol
   table into full PVGVs with attached constant subroutines.  */
#define GV_NOADD_NOINIT	0x20	/* Don't add the symbol if it's not there.
				   Don't init it if it is there but ! PVGV */
#define GV_NOEXPAND	0x40	/* Don't expand SvOK() entries to PVGV */
#define GV_NOTQUAL	0x80	/* A plain symbol name, not qualified with a
				   package (so skip checks for :: and ')  */

/*      SVf_UTF8 (more accurately the return value from SvUTF8) is also valid
	as a flag to gv_fetch_pvn_flags, so ensure it lies outside this range.
*/
#define gv_fullname3(sv,gv,prefix) gv_fullname4(sv,gv,prefix,TRUE)
#define gv_efullname3(sv,gv,prefix) gv_efullname4(sv,gv,prefix,TRUE)
#define gv_fetchmethod(stash, name) gv_fetchmethod_autoload(stash, name, TRUE)
