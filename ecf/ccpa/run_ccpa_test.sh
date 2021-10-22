# Test retrospective runs with NCO canned data:

# rm -fr /lfs/h2/emc/ptmp/Yan.Luo/canned/com/ccpa/v4.2/nwges

# submit job one by one in this order

qsub jccpa_conus_00.ecf
qsub jccpa_conus_12.ecf

qsub jccpa_gempak_00.ecf
qsub jccpa_gempak_12.ecf


# check job running status

qstat | grep Yan 

