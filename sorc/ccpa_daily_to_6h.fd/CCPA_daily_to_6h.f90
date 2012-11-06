PROGRAM daily_to_6hourly
!###########################################################
!HISTORY:
!01/04/2010: Program created by Mike Charles in 2008
!03/24/2010: Program modified by Dingchen Hou for CCPA initial implementation
!###########################################################

!$$$ MAIN PROGRAM DOCUMENTATION BLOCK
!
! Main program: daily_to_6hourly
! Programmer: Mike Charles     Org: XXXX     Date: 2008-11-03
!
! Abstract: This program reads in 6-hour RFC QPE precipitation
!    grids and sums them into 24-hour precip
!
! Program history log:
!
! Input files: rfc_orig_T.grb for T=1,2,3,4
!
! Output files: adjusted_6hr.T.grb, for T=1,2,3,4
!
! Attributes:
!   Languate: Fortran 90
!   Command Line Arguments: 4 strings with the following format:
!   YYYYMMDDHHT1T2 (Precip accum. from T1(hours) to T2(hours) after HH(Z) of data YYYYMMMDD 
!
!$$$

implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! INITIALIZE VARIABLES
!
! Characters
character(5) xdim_str, ydim_str
character(14) date1,date2,date3,date4,date_str
integer ::  year, month, day, hour
integer ::  t1, t2
integer ::  iargc
character(100) file_name
! Integers
integer :: stat, xdim, ydim, tdim, x, y, t, num_pts, k, kf, kg
integer  , dimension(200) :: jpds, jgds, kpds, kgds
logical*1, dimension(:)    , allocatable :: lb
logical  , dimension(:,:)  , allocatable :: temp_mask
logical  , dimension(:,:,:), allocatable :: mask
! Arrays
real :: temp
real, dimension(:)    , allocatable :: temp_array
real, dimension(:,:)  , allocatable :: temp_grid, daily_grid, daily_rfc_scaled
real, dimension(:,:,:), allocatable :: pcp, percent, rfc_scaled
! Constants
tdim = 4

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
call baopen(1,'rfc_orig_1.grb',stat)
if (stat .ne. 0) STOP 'Problem opening grib file'
! Read grib header to get dimensions
call getgbh(1,0,-1,jpds,jgds,kg,kf,k,kpds,kgds,stat)
if (stat .ne. 0) STOP 'Problem reading from grib file'
! Close grib file
call baclose(1,stat)
if (stat .ne. 0) STOP 'Problem closing grib file'
! Get grib dimensions
xdim = kgds(2)
ydim = kgds(3)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! COMMAND LINE ARGS
!
! Did the user supply any?
if (iargc() < 4) then
	print *, 'Usage: daily_to_6hourly date1 date2 date3 date4'
	print *, 'where date(n) is the start date of the precip in the nth 6-hour slot'
        print *, 'with the following format:'
        print *, 'YYYYMMDDHHt1t2 where t1~t2 (hours) are the accoumalation period' 
	stop
endif
! Read in the args
call getarg(1,date1)
call getarg(2,date2)
call getarg(3,date3)
call getarg(4,date4)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! ALLOCATE MEMORY FOR ARRAYS
!
allocate(pcp(xdim,ydim,tdim), daily_grid(xdim,ydim), temp_array(xdim*ydim),&
         mask(xdim,ydim,tdim),lb(xdim*ydim),percent(xdim,ydim,tdim),       & 
         rfc_scaled(xdim,ydim,tdim), daily_rfc_scaled(xdim,ydim),          &
         temp_mask(xdim,ydim))

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! OPEN AND READ IN ALL PRECIP GRIDS
!
! Loop over the time dimension
!print *, ' - Loading all precip grids...'
do t=1,tdim
	! Set file name
	write (file_name,fmt='(A,I1,A)') 'rfc_orig_',t,'.grb'
	! Read in grib data
	call read_grib(t,file_name,pcp(:,:,t),mask(:,:,t))
        rfc_scaled(:,:,t)=pcp(:,:,t)
end do

   temp_mask=mask(:,:,1)
do t=2,tdim
        where (temp_mask) temp_mask=mask(:,:,t)
end do
do t=1,tdim
        mask(:,:,t)=temp_mask
end do
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! CONVERT EACH GRID INTO A '%' OF THE DAILY TOTAL
!
!print *, ' - Determining 6-hourly percentages...'
! Sum daily precip
daily_grid = 0
do t=1,tdim
!	daily_grid = daily_grid + pcp(:,:,t)
	where (temp_mask) daily_grid = daily_grid + pcp(:,:,t)
end do

! Calculate percent of daily total
percent    = -999
do t=1,tdim
	where (temp_mask .and. daily_grid <  0.01) percent(:,:,t) = 0
	where (temp_mask .and. daily_grid >= 0.01) percent(:,:,t) = pcp(:,:,t) / daily_grid
end do

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! READ IN RFC_SCALED GRID
!
! Set file name
!print *, ' - Reading in 24-hour RFC precip...'
file_name = 'rfc_scaled_downscaled.grb'
! Read in grib data
call read_grib(5,file_name,daily_rfc_scaled,temp_mask)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! GET 6 HOURLY RFC_SCALED PRECIP BY MULTIPLYING BY EACH '%'
!
!print *, ' - Determining 6-hourly RFC precip...'
do t=1,tdim
 	where (temp_mask .and. percent(:,:,t).gt.0.0) rfc_scaled(:,:,t) = percent(:,:,t) * daily_rfc_scaled
 	where (temp_mask .and. rfc_scaled(:,:,t).lt.0.01 .and. rfc_scaled(:,:,t).gt.0.001) rfc_scaled(:,:,t) = 0.01 
end do

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! WRITE OUT 6 HOURLY RFC_SCALED GRIDS
!
!print *, ' - Writing 6-hourly RFC precip to grib files:'
do t=1,tdim
	! Set file name
	write (file_name,fmt='(A,I1,A)') 'rfc_adjusted_6hr.',t,'.grb'
!	print *, file_name
	! Open grib file
	call baopen(1,trim(file_name),stat)
	! Did it open successfully?
	if (stat .ne. 0) then
	    print *, 'Problem opening',trim(file_name)
	    STOP
	endif
	! Reshape pcp and mask to a 1D array for grib files
	temp_array = reshape(rfc_scaled(:,:,t),(/xdim*ydim/))
	lb         = reshape(mask(:,:,t),(/xdim*ydim/))
	!----------------------------------------------------------
	! SET GRIB DATE
	!
	if (t==1) then
		date_str = date1
	else if (t==2) then
		date_str = date2
	else if (t==3) then
		date_str = date3
	else
		date_str = date4
	end if
	read(date_str(1:4),*)  year
	read(date_str(5:6),*)  month
	read(date_str(7:8),*)  day
	read(date_str(9:10),*) hour
	read(date_str(11:12),*) t1
	read(date_str(13:14),*) t2
	! Set new date
	kpds(4)  = 192
	kpds(5)  = 61
	kpds(6)  = 1
	kpds(7)  = 0
	kpds(8)  = year-2000
	kpds(9)  = month
	kpds(10) = day
	kpds(11) = hour
	kpds(12) = 0
	kpds(13) = 1  ! time unit = hour
	kpds(14) = t1  ! time1
	kpds(15) = t2  ! time2
	kpds(16) = 4  ! analysis
	! Write to grib
	call putgb(1,xdim*ydim,kpds,kgds,lb,temp_array,stat)
	! Did it write the data successfully?
	if (stat .ne. 0) then
	    print *, 'Problem writing grib data, error status code =',stat
	    STOP
	endif
end do

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! WRITE OUT PERCENTAGE GRIDS
!do t=1,tdim
!	! Open output file
!	write (file_name,fmt='(AI1A)') 'pcnt.',t,'.bin'
!	open(t,file=trim(file_name),status='unknown',form='unformatted',access='direct',recl=xdim*ydim*4,iostat=stat)
!	if (stat .ne. 0) then
!		print *, 'Problem opening output file ',trim(file_name),'... Error code:',stat
!		STOP
!	end if
!	! Write data to output file
!	write(t,rec=1) percent(:,:,t)
!	! Close output file
!	close(t)
!end do

! DEALLOCATE MEMORY FOR ARRAYS
deallocate(pcp,daily_grid,temp_array,mask,lb,percent,rfc_scaled,daily_rfc_scaled,temp_mask)

CONTAINS

SUBROUTINE read_grib(handle,file_name,grid,mask)

	character(*), intent(in) :: file_name
	real   , dimension(xdim,ydim), intent(out) :: grid
	logical, dimension(xdim,ydim), intent(out) :: mask
	integer :: stat, handle

	grid = 0

!	print *, 'Processing grib file:',file_name

	! Open file
	call baopen(handle,trim(file_name),stat)
	! Did it open successfully?
	if (stat .ne. 0) then ! Problem reading file
		print *, 'File', file_name, 'could not be opened... Error code:', stat
		return 
!		return -1
	endif
	! Set some grib reading properties
	jpds = -1 ! PDS input to getgb
	jgds = -1 ! GDS input to getgb
!	jpds(4) = 192
	jpds(5) = 61
	jpds(6) = 1
	jpds(7) = 0
	kpds = -1
	kgds = -1
	! Read in data
	call getgb(handle,0,xdim*ydim,-1,jpds,jgds,num_pts,k,kpds,kgds,lb,temp_array,stat)
	! Did it read in data successfully?
	if (stat .ne. 0) then
	    print *, 'Problem reading grib data, error status code =',stat
		return 
!		return -1
	endif
	! Close file
	call baclose(handle,stat)
	! Did it close successfully?
	if (stat .ne. 0) then
	    print *, 'Problem closing grib file, status code =',stat
	endif

	grid = reshape(temp_array,(/xdim,ydim/))
	mask = reshape(lb,(/xdim,ydim/))

        Return
END SUBROUTINE


END PROGRAM
