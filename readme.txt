CCPA v4.0.0 Implementation Instructions: 

1. Checkout svn tags:

   https://svnemc.ncep.noaa.gov/projects/ccpa/tags/ccpa.v4.0.0 


2. Set up the package
   After copying this directory to "(your file location)", you need to do the following:
   (1) Check jobs/JCCPA_CONUS to make sure the following modules and tags are available:

    /nwprod2/modulefiles

    prod_util

    grib_util.v1.0.1

    ics.v13.1p

   (2) Build the executables of CCPA
       Go to the sorc sub-directory, following the instructions in README.build file, all the executables 
will be generated and saved in the exec sub-directory.


3.  Start the test run, on wcoss
    Please check and modify (if it is necessary) the ecf/ccpa_test.def, ecf/jccpa_conus.ecf, 
jobs/JCCPA_CONUS, to make sure the paths of the source and output files are correct. 
    Run ecf/jccpa_conus.ecf twice at 16:10Z and 00:10Z to launch CCPA jobs.
jobs/JCCPA_GEMPAK is triggered by completion of the JCCPA_CONUS job.

   
4.  Resources requirements 

   (1) Compute resource information:

       Increase cpu requirement from 1 node 1 task to 1 node 5 tasks. Run time remains about the same for 20-25 minutes.  

   (2) Disk space
         
      IBM Disk: 300 MB/day, latest 20days of output residing in /com2

      IBM Tape: 300 MB/day, save the day before 8 day's output in HPSS. 


5.  Product changes

   Additional 1-hourly products on 6 grids:
   (1) 0.125 degree 
       e.g., ccpa.t06z.01h.0p125.conus.gb2
   (2) 0.5 degree 
       e.g., ccpa.t06z.01h.0p5.conus.gb2
   (3) 1.0 degree 
       e.g., ccpa.t06z.01h.1p0.conus.gb2
   (4) hrap grid
       e.g., ccpa.t06z.01h.hrap.conus.gb2
   (5) 5.0km ndgd grid
       e.g., ccpa.t06z.01h.ndgd5p0.conus.gb2
   (6) 2.5km ndgd grid
       e.g., ccpa.t06z.01h.ndgd2p5.conus.gb2
       The 2.5km ndgd grid was modified to have the same grid specifications for the MDL's Blend 2.5km CONUS grid.
