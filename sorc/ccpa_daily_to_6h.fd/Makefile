SHELL=	/bin/sh
LIBS=   -L/nwprod/lib/ -lbacio_4 -lw3emc_4 -lw3nco_4  -lip_4 -lsp_4 
SRCS=   CCPA_daily_to_6h.f90
CMD=    ccpa_daily_to_6h	
FC=	ifort
FFLAGS=
#FFLAGS=	-O3 -qsuffix=f=f90 -qlist -qsource -bnoquiet 

$(CMD):	$(SRCS)
	$(FC) $(SRCS) $(FFLAGS) -o $(@) $(OBJS) $(LIBS)
