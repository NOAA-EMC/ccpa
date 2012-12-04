#SHELL=	/bin/sh
SHELL=	/bin/bash
LIBS=   -L/nwprod/lib/ -lbacio_4 -lw3nco_4 -lip_4 -lsp_4
#LIBS=   -L/nwprod/lib/ -lbacio_4 -lw3nco_4 -lw3emc_4 -lip_4 -lsp_4
SRCS=   CCPA_comp_st4_st2_3h_files.f90	
CMD=    ccpa_comp_st4_st2_3h_files	
FC=	ifort
FFLAGS= -assume byterecl -convert big_endian -g -traceback
#FFLAGS=	-O3 -qsuffix=f=f90 -qlist -qsource -bnoquiet 

$(CMD):	$(SRCS)
	$(FC) $(SRCS) $(FFLAGS) -o $(@) $(OBJS) $(LIBS)
