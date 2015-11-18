CCPA v3.0.0 Implementation Instructions: 

1. Checkout svn tags:

   https://svnemc.ncep.noaa.gov/projects/ccpa/tags/ccpa.v3.0.0 


2. Set up the package
   After  copying this directory to "(your file location)", you need to do the following:
   (1) Check jobs/JCCPA_CONUS to make sure the following modules and tags are available:

    /nwprod2/modulefiles

    prod_util.v1.0.1

    grib_util.v1.0.1

    ics.v13.1p

   (2) Build the executables of CCPA
       Go to the sorc sub-directory, following the instructions in README.build file, all the executables 
will be generated and saved in the exec sub-directory.


3.  Start the test run, on wcoss
    Please check and modify (if it is necessary) the ecf/jccpa_conus_00.ecf, ecf/jccpa_conus_12.ecf, 
jobs/JCCPA_CONUS, to make sure the paths of the source and output files are correct. 
    Run ecf/jccpa_conus_00.ecf and ecf/jccpa_conus_12.ecf to launch CCPA jobs.

   
4.  Resources requirements 

   (1) Compute resource information:

       Continue to use 1 node. Run time increases from 10 to 20-25 minutes.  

   (2) Disk space
         
      IBM Disk: 104 MB/day, latest 20days of output residing in /com2

      IBM Tape: 104 MB/day, save the day before 8 day's output in HPSS. 


5.  Product changes

   (1) Additional 2.5 km NDGD grid product

   (2) Product directory structure change
         Current:    /com/gens/prod/gefs.yyyymmdd/cyc/ccpa
         Upgrade:    /com2/ccpa/prod/ccpa.yyyymmdd/cyc

   (3) NCEP FTP/NOMADS:
         ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/ccpa/prod/ccpa.YYYYMMDD/HH
         http://nomads.ncep.noaa.gov/pub/data/nccf/com/ccpa/prod/ccpa.YYYYMMDD/HH 
        
   (4) File name change by following NCO filename conventions
       e.g.,
         ccpa_conus_0.5d_t21z_03h_gb2 -> ccpa.t21z.03h.0p5.conus.gb2
