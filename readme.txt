CCPA v4.1.3 Instructions: 

1. Checkout GitHub Tags:

   git clone -b tags/ccpa.v4.1.3  https://github.com/NOAA-EMC/ccpa

2. Download the static binary files for the fix directory and copy the directory back to the ccpa code: 

   ftp://ftp.emc.ncep.noaa.gov/static_files/public/CCPA/ccpa.v4_fixdir_from_ftp.tar.gz

3. Set up the Package
   After copying this ccpa directory to "(your file location)", you need to do the following:
   (1) Check ecf/ccpa/jccpa_conus.ecf and jccpa_gempak.ecf to make sure the following modules
and tags are available:

    /gpfs/dell1/nco/ops/nwprod/modulefiles

    prod_envir/1.0.2

    grib_util/1.0.6

    prod_util/1.1.4

    lsf/10.1

    EnvVars/1.0.3

    CFP/2.0.1

    gempak/7.3.1
   

   (2) Build the executables of CCPA
       Go to the sorc sub-directory, following the instructions in README.build file, all the 
executables will be generated and saved in the exec sub-directory.


4.  Start the Test Run, on Dell
    Please check and modify (if it is necessary) the ecf/ccpa/ccpa_test.def, ecf/ccpa/jccpa_conus.ecf
&jccpa_gempak.ecf, jobs/JCCPA_CONUS&JCCPA_GEMPAK, to make sure the paths of the source and output files
are correct. 
    Run ecf/ccpa/jccpa_conus.ecf twice at 16:10Z and 00:10Z to launch CCPA jobs.
jobs/JCCPA_GEMPAK is triggered by partial completion of the JCCPA_CONUS job.

   
5.  No Change to Resources Requirements 

   (1) No change to compute resource information:

      The cpu requirement is 1 node 5 tasks. Run time is about 10-15 minutes. 

   (2) No change to disk space
         
      IBM Disk: 300 MB/day, latest 20days of output residing in /com

      IBM Tape: 300 MB/day, save the day before 8 day's output in HPSS. 


6.  Product Changes: The 1-hour CCPA files in the 00Z directory will be corrected for the 
    GRIB1/2 reference date.

