/* !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
   This file is built by warnings.pl
   Any changes made here will be lost!
*/


#define Off(x)			((x) / 8)
#define Bit(x)			(1 << ((x) % 8))
#define IsSet(a, x)		((a)[Off(x)] & Bit(x))


#define G_WARN_OFF		0 	/* $^W == 0 */
#define G_WARN_ON		1	/* -w flag and $^W != 0 */
#define G_WARN_ALL_ON		2	/* -W flag */
#define G_WARN_ALL_OFF		4	/* -X flag */
#define G_WARN_ONCE		8	/* set if 'once' ever enabled */
#define G_WARN_ALL_MASK		(G_WARN_ALL_ON|G_WARN_ALL_OFF)

#define pWARN_STD		Nullsv
#define pWARN_ALL		(Nullsv+1)	/* use warnings 'all' */
#define pWARN_NONE		(Nullsv+2)	/* no  warnings 'all' */

#define specialWARN(x)		((x) == pWARN_STD || (x) == pWARN_ALL ||	\
				 (x) == pWARN_NONE)
#define WARN_ALL		0
#define WARN_CLOSURE		1
#define WARN_EXITING		2
#define WARN_GLOB		3
#define WARN_IO			4
#define WARN_CLOSED		5
#define WARN_EXEC		6
#define WARN_NEWLINE		7
#define WARN_PIPE		8
#define WARN_UNOPENED		9
#define WARN_MISC		10
#define WARN_NUMERIC		11
#define WARN_ONCE		12
#define WARN_OVERFLOW		13
#define WARN_PACK		14
#define WARN_PORTABLE		15
#define WARN_RECURSION		16
#define WARN_REDEFINE		17
#define WARN_REGEXP		18
#define WARN_SEVERE		19
#define WARN_DEBUGGING		20
#define WARN_INPLACE		21
#define WARN_INTERNAL		22
#define WARN_MALLOC		23
#define WARN_SIGNAL		24
#define WARN_SUBSTR		25
#define WARN_SYNTAX		26
#define WARN_AMBIGUOUS		27
#define WARN_BAREWORD		28
#define WARN_DEPRECATED		29
#define WARN_DIGIT		30
#define WARN_PARENTHESIS	31
#define WARN_PRECEDENCE		32
#define WARN_PRINTF		33
#define WARN_PROTOTYPE		34
#define WARN_QW			35
#define WARN_RESERVED		36
#define WARN_SEMICOLON		37
#define WARN_TAINT		38
#define WARN_UNINITIALIZED	39
#define WARN_UNPACK		40
#define WARN_UNTIE		41
#define WARN_UTF8		42
#define WARN_VOID		43
#define WARN_Y2K		44

#define WARNsize		12
#define WARN_ALLstring		"\125\125\125\125\125\125\125\125\125\125\125\125"
#define WARN_NONEstring		"\0\0\0\0\0\0\0\0\0\0\0\0"

#define isLEXWARN_on 	(PL_curcop->cop_warnings != pWARN_STD)
#define isLEXWARN_off	(PL_curcop->cop_warnings == pWARN_STD)
#define isWARN_ONCE	(PL_dowarn & (G_WARN_ON|G_WARN_ONCE))
#define isWARN_on(c,x)	(IsSet(SvPVX(c), 2*(x)))
#define isWARNf_on(c,x)	(IsSet(SvPVX(c), 2*(x)+1))

#define ckDEAD(x)							\
	   ( ! specialWARN(PL_curcop->cop_warnings) &&			\
	    ( isWARNf_on(PL_curcop->cop_warnings, WARN_ALL) || 		\
	      isWARNf_on(PL_curcop->cop_warnings, x)))

#define ckWARN(x)							\
	( (isLEXWARN_on && PL_curcop->cop_warnings != pWARN_NONE &&	\
	      (PL_curcop->cop_warnings == pWARN_ALL ||			\
	       isWARN_on(PL_curcop->cop_warnings, x) ) )		\
	  || (isLEXWARN_off && PL_dowarn & G_WARN_ON) )

#define ckWARN2(x,y)							\
	  ( (isLEXWARN_on && PL_curcop->cop_warnings != pWARN_NONE &&	\
	      (PL_curcop->cop_warnings == pWARN_ALL ||			\
	        isWARN_on(PL_curcop->cop_warnings, x)  ||		\
	        isWARN_on(PL_curcop->cop_warnings, y) ) ) 		\
	    ||	(isLEXWARN_off && PL_dowarn & G_WARN_ON) )

#define ckWARN_d(x)							\
	  (isLEXWARN_off || PL_curcop->cop_warnings == pWARN_ALL ||	\
	     (PL_curcop->cop_warnings != pWARN_NONE &&			\
	      isWARN_on(PL_curcop->cop_warnings, x) ) )

#define ckWARN2_d(x,y)							\
	  (isLEXWARN_off || PL_curcop->cop_warnings == pWARN_ALL ||	\
	     (PL_curcop->cop_warnings != pWARN_NONE &&			\
	        (isWARN_on(PL_curcop->cop_warnings, x)  ||		\
	         isWARN_on(PL_curcop->cop_warnings, y) ) ) )

/* end of file warnings.h */

