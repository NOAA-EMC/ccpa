CCPA v4.2.0 Instructions: 

1. Checkout GitHub Tags:

   git clone -b tags/ccpa.v4.2.0  https://github.com/NOAA-EMC/ccpa

2. Download the static binary files for the fix directory and copy the directory back to the ccpa code: 

   ftp://ftp.emc.ncep.noaa.gov/static_files/public/CCPA/ccpa.v4_fixdir_from_ftp.tar.gz

3. Set up the Package
   After copying this ccpa directory to "(your file location)", you need to do the following:
   (1) Check ecf/ccpa/jccpa_conus.ecf and jccpa_gempak.ecf to make sure the following modules
and tags are available:

   module purge
   module load envvar/1.0

   module load PrgEnv-intel/8.1.0
   module load craype/2.7.8
   module load intel/19.1.3.304
   module load cray-pals/1.0.12
   module load cfp/2.0.4

   module load libjpeg/9c
   module load prod_envir/2.0.5
   module load grib_util/1.2.3
   module load prod_util/2.0.9
   module load wgrib2/2.0.8
  
   module load gempak/7.14.0

   (2) Build the executables of CCPA
       Go to the sorc sub-directory, following the instructions in README.build file, all the 
executables will be generated and saved in the exec sub-directory.


4.  Start the Test Run, on WCOSS2
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

      IBM Tape: 300 MB/day, save the day before 9 day's output in HPSS. 


6.  No product Changes


7.  No change to up and downstream dependencies
