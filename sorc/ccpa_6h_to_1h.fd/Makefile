########################################################################################
# Makefile for ccpa_6h_to_3h <This is the Documentation Block containing instructions and use>
# Use:
# make - build the executable
#####################################################################
SHELL=	/bin/bash

#FC       = ifort
#CPP      = icpc
#CPPFLAGS =
#W3LIBDIR = /nwprod/lib

#FFLAGS   = -assume byterecl -convert big_endian -g -traceback
#LIBS     = -L$(W3LIBDIR) -lbacio_4 -lw3nco_4  
SRCS     = CCPA_6h_to_1h.f90
CMD      = ccpa_6h_to_1h
OBJS     =

$(CMD):	$(SRCS)
	$(FC) $(SRCS) $(FFLAGS) -o $(@) $(OBJS) $(LIBS)

install:	
	mv $(CMD) ../../exec/$(CMD)
