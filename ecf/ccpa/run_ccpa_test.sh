# Test retrospective runs with NCO canned data:

# rm -fr /lfs/h2/emc/ptmp/Yan.Luo/canned/com/ccpa/v4.2/nwges

# submit jobs one by one in this order

1. qsub jccpa_conus_00.ecf

# if job1 finishes then
2. qsub jccpa_conus_12.ecf

# if job2 finishes then
3. qsub jccpa_gempak_00.ecf

# if job3 finishes then
4. qsub jccpa_gempak_12.ecf

