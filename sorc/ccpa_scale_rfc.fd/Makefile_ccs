SHELL=  /bin/sh
ISIZE = 4
RSIZE = 8
#COMP=   g95
COMP=   xlf90_r7
#LIBS=   -L/export/lnx305/wd20mch/griblib -lw3 -lbacio
LIBS=   /nwprod/lib/libbacio_4.a \
        /nwprod/lib/libw3_4.a \
        /nwprod/lib/libip_4.a \
        /nwprod/lib/libsp_4.a \
        -l essl
LDFLAGS= 
FFLAGS=

CCPA_scale_rfc:    CCPA_scale_rfc.f90
	$(COMP) $(FFLAGS) -o ccpa_scale_rfc CCPA_scale_rfc.f90 $(LIBS)
