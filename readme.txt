CCPA v4.0.1 Transition Instructions: 

1. Checkout SVN Tags:

   https://svnemc.ncep.noaa.gov/projects/ccpa/tags/ccpa.v4.0.1


2. Set up the Package
   After copying this directory to "(your file location)", you need to do the following:
   (1) Check ecf/ccpa/jccpa_conus.ecf and jccpa_gempak.ecf to make sure the following modules
and tags are available:

    /gpfs/dell1/nco/ops/nwprod/modulefiles

    prod_envir/1.0.2

    grib_util/1.0.6

    prod_util/1.1.0

    lsf/10.1

    EnvVars/1.0.2

    CFP/2.0.1

    gempak/7.3.1
   

   (2) Build the executables of CCPA
       Go to the sorc sub-directory, following the instructions in README.build file, all the executables 
will be generated and saved in the exec sub-directory.


3.  Start the Test Run, on Dell
    Please check and modify (if it is necessary) the ecf/ccpa/ccpa_test.def, ecf/ccpa/jccpa_conus.ecf
&jccpa_gempak.ecf, jobs/JCCPA_CONUS&JCCPA_GEMPAK, to make sure the paths of the source and output files
are correct. 
    Run ecf/ccpa/jccpa_conus.ecf twice at 16:10Z and 00:10Z to launch CCPA jobs.
jobs/JCCPA_GEMPAK is triggered by partial completion of the JCCPA_CONUS job.

   
4.  No Change to Resources Requirements 

   (1) Compute resource information:

      The cpu requirement is 1 node 5 tasks. Run time decreases to 10-15 minutes. 
It is about 10 minutes faster than current production on Wcoss Phase 2 due to
computer resource improvement on Dell.   

   (2) No change to disk space
         
      IBM Disk: 300 MB/day, latest 20days of output residing in /com2

      IBM Tape: 300 MB/day, save the day before 8 day's output in HPSS. 


5.  No Product Changes
