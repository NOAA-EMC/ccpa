########################################################################################
# Makefile for ccpa_ccpa_comp_st4_st2_3h_files <This is the Documentation Block containing instructions and use>
# Use:
# make - build the executable
#####################################################################
SHELL=	/bin/bash

FC       = ifort
CPP      = icpc
CPPFLAGS =
W3LIBDIR = /nwprod/lib

FFLAGS   = -assume byterecl -convert big_endian -g -traceback 
#LIBS     = -L/$(W3LIBDIR) -lw3nco_4 -lw3emc_4 -lbacio_4 -lip_4 -lsp_4 
#LIBS     = -L/$(W3LIBDIR) -lbacio_4 -lw3nco_4 -lw3emc_4 -lip_4 -lsp_4 
#LIBS     = -L/$(W3LIBDIR) -lbacio_4 -lw3nco_4 -lw3emc_4 
LIBS     = -L$(W3LIBDIR) -lbacio_4 -lw3nco_4  
SRCS     = CCPA_comp_st4_st2_3h_files.f90
CMD      = ccpa_comp_st4_st2_3h_files
OBJS     =

$(CMD):	$(SRCS)
	$(FC) $(SRCS) $(FFLAGS) -o $(@) $(OBJS) $(LIBS)
