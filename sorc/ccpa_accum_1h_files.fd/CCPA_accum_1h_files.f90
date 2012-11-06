program accum_precip_files
!###########################################################
!HISTORY:
!01/04/2010: Program (CCPA_accum_6h_files.f90) created by Mike Charles in 2008
!03/24/2010: Program (CCPA_accum_6h_files.f90) modified by Dingchen Hou for CCPA initial implementation
!02/18/2011: Program originated from CCPA_accum_6h_files.f90, adopted and modified by Yan Luo
!###########################################################

!$$$ MAIN PROGRAM DOCUMENTATION BLOCK
!
! Main program: accum_precip_files
! Programmer: Yan Luo     Org: XXXX     Date: 2011-02-18
!
! Abstract: This program reads in 1-hour RFC QPE precipitation
!    grids and sums them into 3-hour precip
!
! Program history log:
!
! Input files: rfc_01h.1.grb, rfc_01h.2.grb, rfc_01h.3.grb
! 
! Output files: rfc_3h.grb

! Attributes:
!   Languate: Fortran 90
!
!$$$

implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! SETUP
!
! Initialize
character(100) :: filename
character(4) :: inyyyy
character(2) :: inmm, indd, inhh
integer :: i, j, k, stat, kf, kg, nx, ny, yyyy, mm, dd, hh, grid_def
integer, dimension(:,:), allocatable :: missing
real, dimension(:), allocatable :: temp_array
real, dimension(:,:), allocatable :: pcp_1hr, test
real, dimension(:,:), allocatable :: pcp_3hr
logical*1, dimension(:), allocatable :: lb
logical, dimension(:,:,:), allocatable :: bitmap
logical, dimension(:,:), allocatable :: bitmap_final
integer, dimension(200) :: jpds, jgds, kpds, kgds

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! READ COMMAND LINE ARGS
!
! Make sure the user supplied all args
if (command_argument_count() < 4) then
	print *, 'Usage: accum_precip_files yyyy mm dd hh'
	print *, '   where yyyy, mm, dd, and hh are the year, month,'
	print *, '   day, and hour at the end of the accum period...'
	stop
endif
! Read in args
call getarg(1,inyyyy) ; read(inyyyy,*) yyyy
call getarg(2,inmm)   ; read(inmm,*)   mm
call getarg(3,indd)   ; read(indd,*)   dd
call getarg(4,inhh)   ; read(inhh,*)   hh

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! GET DIMENSIONS OF INPUT GRIBS
!
! Set some grib reading properties
jpds = -1 ! PDS input to getgb
jgds = -1 ! GDS input to getgb
kpds = -1 ! PDS output from getgb
kgds = -1 ! GDS output from getgb
jpds(5) = 61 ! Total Precip - kg/m^2 - APCP
jpds(6) = 1  ! Ground or water surface - SFC
jpds(7) = 0

! Open grib file
call baopen(1,'rfc_01h_1.grb',stat)
if (stat .ne. 0) STOP 'Problem opening grib file rfc_01h_1.grb'
		
! Read grib header to get dimensions
call getgbh(1,0,-1,jpds,jgds,kg,kf,k,kpds,kgds,stat)
if (stat .ne. 0) STOP 'Problem reading from grib file'
! print *, 'Grib dimensions: (',kgds(2),',',kgds(3),')'

! Close grib file
call baclose(1,stat)
if (stat .ne. 0) STOP 'Problem closing grib file rfc_01h_1.grb'

! Get grib dimensions
nx = kgds(2)
ny = kgds(3)

! Get grid definition
grid_def = kpds(3)

! print *, 'Grid size:',nx,'by',ny

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! ALLOCATE MEMORY FOR ARRAYS
!
allocate(temp_array(nx*ny),lb(nx*ny),pcp_1hr(nx,ny),pcp_3hr(nx,ny),&
bitmap(nx,ny,3),bitmap_final(nx,ny),missing(nx,ny),test(nx,ny))

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! READ IN ALL 1-HOUR PRECIP GRIDS
!
! Set some grib reading properties
jpds = -1 ! PDS input to getgb
jgds = -1 ! GDS input to getgb
kpds = -1 ! PDS output from getgb
kgds = -1 ! GDS output from getgb
jpds(5) = 61 ! Total Precip - kg/m^2 - APCP
jpds(6) = 1  ! Ground or water surface - SFC
jpds(7) = 0

! Loop over all 3 1-hr precip files
pcp_3hr = 0
do i=1,3
	! Set filename
	write (filename,'(A8,I1,A4)') 'rfc_01h_',i,'.grb'
        print *, 'read file:', filename
	! Open grib file
	call baopen(i+1,trim(filename),stat)
	if (stat .ne. 0) STOP 'Problem opening grib file'
	
	! Read grib file
	call getgb(i+1,0,nx*ny,-1,jpds,jgds,kf,k,kpds,kgds,lb,temp_array,stat)
	if (stat .ne. 0) STOP 'Problem reading from grib file'

	! Close grib file
	call baclose(i+1,stat)
	if (stat .ne. 0) STOP 'Problem closing grib file' 
	
	! Reshape stream of data into 2D matrix
	pcp_1hr        = reshape(temp_array,(/nx,ny/))
!	where (pcp_6hr >= 0) pcp_24hr=pcp_24hr+pcp_6hr
 	where (pcp_1hr >= 0.001) pcp_3hr=pcp_3hr+pcp_1hr  !results same as previous statement
! DHOU: Tests show that the accuracy of the 6h files is 0.1mm, so 0.01 is used as threshold
end do

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! CREATE BITMAP FOR GRIB FILE
!
!bitmap_final = .false.
!where(pcp_24hr >= 0) bitmap_final = .true.

!open(10,file='mask.bin',form='unformatted',access='direct',&
!status='replace',action='write',recl=nx*ny*4,iostat=stat)
!write(10,rec=1,iostat=stat) test
!close(10)

! Set some grib writing properties
kpds     = jpds     ! PDS output to getgb
kpds(1)  = 7        ! ID of center (US National Weather Service - NCEP (WMC))
kpds(2)  = 192      ! Generating process ID (Analysis product from NCEP/AWC)
kpds(3)  = grid_def ! Grid definition (HRAP grid) 
kpds(4)  = 192      !
kpds(5)  = 61       ! Total Precip - kg/m^2 - APCP
kpds(6)  = 1        ! Ground or water surface - SFC
kpds(7)  = 0
kpds(8)  = yyyy-2000
kpds(9)  = mm
kpds(10) = dd
kpds(11) = hh
kpds(12) = 0
kpds(13) = 1        ! time unit = hour
kpds(14) = 0        ! time1
kpds(15) = 3        ! time2
kpds(16) = 4        ! accumulation
kpds(17) = 0        ! # included in avg/accum
kpds(18) = 0        ! Version # of grib specs
kpds(19) = 2        ! Version # of parm table
kpds(20) = 0        ! @ missing from avg/accumt
kpds(21) = 21       ! Century (21)
kpds(22) = 2        ! Units decimal scale factor
kpds(23) = 4        ! Subcenter, 2 for NCEP ensemble, 4 for EMC, 
                    ! 4 is used in STAGE IV data 

! DHOU:  03/11/2010, Change pds parameters
kpds(2)  = 184      ! Generating process ID (MC used 192, Analysis product from NCEP/AWC)
                    ! 182 is used in STAGE IV data; 184 for CCPA, application filed on 03/24/2010 

! Open grib file
call baopen(6,'rfc_3h.grb',stat)

! Did it open successfully?
if (stat .ne. 0) STOP 'Problem opening grib file'

! Reshape grids back to a 1d array
!lb         = reshape(bitmap_final,(/nx*ny/))
temp_array = reshape(pcp_3hr,(/nx*ny/))

! Write to grib
call putgb(6,nx*ny,kpds,kgds,lb,temp_array,stat)
! Did it write the data successfully?
if (stat .ne. 0) then
    print *, 'Problem writing grib data, error status code =',stat
    STOP
endif

! Close grib file
call baclose(6,stat)
! Did it close successfully?
if (stat .ne. 0) then
    print *, 'Problem closing grib file, status code =',stat
    STOP
endif

deallocate(temp_array,lb)


end program
