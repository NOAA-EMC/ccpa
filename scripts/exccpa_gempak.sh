#! /bin/sh
# exccpa_gempak.sh

# Created on: Dec 21, 2010
#     Author: bmabe

###################################################################
echo "CCPA_gempak.sh.sms ---------------------------------"
echo "- convert CCPA GRIB files into GEMPAK Grids"
echo "----------------------------------------------------"
echo "History: Oct 2010 - Converted exnawips script for CCPA."
echo "         Jan 2012 - Modify to run 2x per day."
#####################################################################
set -xa

cd $DATA

msg="Begin job for $job"
postmsg "$jlogfile" "$msg"

cpyfil=gds
garea=dset
gbtbls=
maxgrd=4999
kxky=
grdarea=
proj=
output=T

pdsext=no
NAGRIB=nagrib2

# Get current UTC hour
hour=`date -u "+%H"`

# Determine grid file name and CCPA files to access based upon the hour
# The processing as of 1/2012 is run 2 times per day, once ~1610Z and again at ~0010Z.  The 
# 0010Z run functions as an update to the earlier ~16Z run.

# If running the ~00Z, make sure to set the grid file name and 18Z file to D-2.
# Adding some leeway in case the job runs late. 
if [ `expr $hour + 0` -le 2 ]; then 
    fullddate=${PDYm1}
    fullddate1=${PDYm2}
    fullddate2=${PDYm3}
    fullddate3=${PDYm4}
    fullddate4=${PDYm5}
    fullddate5=${PDYm6}
    fullddate6=${PDYm7}
    fullddate7=${PDYm8}
else
    fullddate=${PDY}
    fullddate1=${PDYm1}  
    fullddate2=${PDYm2}
    fullddate3=${PDYm3}
    fullddate4=${PDYm4}
    fullddate5=${PDYm5}
    fullddate6=${PDYm6}
    fullddate7=${PDYm7}
fi

 for filin in hrap ndgd5p0 ndgd2p5 1p0 0p5 0p125
 do

  for ctime in 1 2 3 4 
  do
  
   case $ctime in

     1) fullddate_a=$fullddate1;fullddate_b=$fullddate;;
     2) fullddate_a=$fullddate3;fullddate_b=$fullddate2;;
     3) fullddate_a=$fullddate5;fullddate_b=$fullddate4;;
     4) fullddate_a=$fullddate7;fullddate_b=$fullddate6

   esac

    GEMGRD="ccpa_conus_${filin}_${fullddate_a}12"
 
   for cyc in 18 00 06 12
   do
    
     if [ "${cyc}" = "18" ]; then 
      cp ${COMIN}/ccpa.${fullddate_a}/${cyc}/ccpa.t${cyc}z.06h.${filin}.conus.gb2 ccpa.${fullddate_a}.t${cyc}z.06h.${filin}.conus.gb2
      GRIBIN="ccpa.${fullddate_a}.t${cyc}z.06h.${filin}.conus.gb2"      
     else
      cp ${COMIN}/ccpa.${fullddate_b}/${cyc}/ccpa.t${cyc}z.06h.${filin}.conus.gb2 ccpa.${fullddate_b}.t${cyc}z.06h.${filin}.conus.gb2
      GRIBIN="ccpa.${fullddate_b}.t${cyc}z.06h.${filin}.conus.gb2"      
     fi

$NAGRIB << EOF
   GBFILE   = $GRIBIN
   INDXFL   = 
   GDOUTF   = $GEMGRD
   PROJ     = $proj
   GRDAREA  = $grdarea
   KXKY     = $kxky
   MAXGRD   = $maxgrd
   CPYFIL   = $cpyfil
   GAREA    = $garea
   OUTPUT   = $output
   GBTBLS   = $gbtbls
   GBDIAG   = 
   PDSEXT   = $pdsext
   OVERWR   = yes
  l
  r
EOF
   done
  
gpend

   cp ${GEMGRD} ${COMOUT}/

   if [ -s ${COMOUT}/${GEMGRD} -a "$SENDDBN" = "YES" ]; then
     $DBNROOT/bin/dbn_alert MODEL $DBN_ALERT_TYPE $job ${COMOUT}/${GEMGRD}
   fi
  
  done

 done

#####################################################################
# GOOD RUN
set +x
echo "**************JOB CCPA_Gempak COMPLETED NORMALLY ON THE IBM"
echo "**************JOB CCPA_Gempak COMPLETED NORMALLY ON THE IBM"
echo "**************JOB CCPA_Gempak COMPLETED NORMALLY ON THE IBM"
set -x
#####################################################################

msg='Job completed normally.'
echo $msg
postmsg "$jlogfile" "$msg"

############################### END OF SCRIPT #######################
