########################################################################################
# Makefile for ccpa_6h_to_3h <This is the Documentation Block containing instructions and use>
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
SRCS     = CCPA_6h_to_3h.f90
CMD      = ccpa_6h_to_3h
OBJS     =

$(CMD):	$(SRCS)
	$(FC) $(SRCS) $(FFLAGS) -o $(@) $(OBJS) $(LIBS)
