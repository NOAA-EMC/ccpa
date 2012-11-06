program scale_rfc
!###########################################################
!HISTORY:
!01/04/2010: Program created by Mike Charles in 2008
!03/24/2010: Program modified by Dingchen Hou for CCPA initial implementation
!###########################################################

!$$$ MAIN PROGRAM DOCUMENTATION BLOCK
!
! Main program: scale-rfc
! Programmer: Mike Charles     Org: XXXX     Date: 2008-11-03
!
! Abstract: This program reads in 24-hour RFC QPE precipitation
!    grids and scales them  for adjustment
!
! Program history log:
!
! Input files:  file_precip, file_a, file_b
!        they are input precip (grib), regression coefficients a and b (bin)
!        file names are passed in as command line arguments
! Input file : file_mask define the mask of input/output precip files, 
!              mask=1: Precip data is available for this pint   
!              mask=0: Precip data is NOT available for this pint   
!              The name of the file is hard wired. 
! Output files: file_out
!    for output precip (grib), file name passed in as command line argument
!
! Attributes:
!   Languate: Fortran 90
!
!$$$

implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! DECLARE VARIABLES
!
integer, dimension(200) :: jpds, jgds, kpds, kgds
integer :: iargc
integer :: i,j,imax,jmax, npt
real, dimension(:,:), allocatable :: grid_precip, grid_a, grid_b, grid_out
integer, dimension(:,:), allocatable :: grid_mask
!real, dimension(:,:), allocatable :: grid_precip, grid_a, grid_b, grid_out, grid_mask
real, dimension(:), allocatable :: tempArray
logical*1, dimension(:), allocatable :: lb
character(120) :: file_precip, file_a, file_b, file_out, file_mask
integer :: nx, ny, stat, k, max_precip
real :: key_precip, alt_precip

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! SET CONSTANTS
nx = 464; ! Number of gridpoints in x dir
ny = 224; ! Number of gridpoints in y dir
max_precip = 500 ! mm, largest allowable precip value
key_precip = 0.5 ! mm, the threshold value of original precip. 
                 ! If original precip is over this amount, the adjustment will use the alternative scheme
                 ! i.e. weighted combination of the original value and the regression adjustment

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! ALLOCATE MEMORY FOR ARRAYS
!
allocate(lb(nx*ny),tempArray(nx*ny),grid_precip(nx,ny),grid_a(nx,ny),&
grid_b(nx,ny),grid_out(nx,ny),grid_mask(nx,ny))

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! GET COMMAND LINE ARGUMENTS
!
! Call getarg
call getarg(1,file_precip)
call getarg(2,file_a)
call getarg(3,file_b)
call getarg(4,file_out)
file_mask = 'mask_0125deg.bin' ! CONUS mask
! Die if user doesn't supply files
if (iargc() < 4) then
   print *, 'Usage: ./scale_rfc pcp_file alpha_file beta_file out_file'
   stop
endif

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! PRINT OUT DEBUGGING INFO
!
!print *, ''
!print *, ' ========== Files =========='
!print *, ' RFC Precip            : ',trim(file_precip)
!print *, ' Alpha scaling factor  : ',trim(file_a)
!print *, ' Beta scaling factor   : ',trim(file_b)
!print *, ' Mask file             : ',trim(file_mask)
!print *, ' Resulting precip file : ',trim(file_out)
!print *, ' ==========================='

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! OPEN GRIDS
!

! --- RFC Precip (grib) --- !
! Set some grid reading parms
jpds = -1 ! PDS input to getgb
jgds = -1 ! GDS input to getgb
jpds(4) = 192
jpds(5) = 61
jpds(6) = 1
jpds(7) = 0
kpds = -1
kgds = -1

! Open grib file
call baopen(1,trim(file_precip),stat)
! Die if grib cannot be opened
if (stat .ne. 0) then
	print *, 'Problem opening grib file ', trim(file_precip) ; STOP
endif

! Read in grib data
CALL getgb(1,0,nx*ny,-1,jpds,jgds,nx*ny,k,kpds,kgds,lb,tempArray,stat)
! Die if grib info cannot be read
if (stat .ne. 0) then
	print *, 'Problem reading grib header for ', trim(file_precip) ; STOP
endif
where (lb .eqv. .false.) tempArray = -999
! Transform into 2-D matrix
grid_precip=reshape(tempArray,(/nx,ny/))
! Close grib file
close(1)

! --- Alpha grid (bin) --- !
! Open binary file
!open(2,file=trim(file_a),form='unformatted',access='direct',&
!status='old',action='read',recl=nx*ny*4,iostat=stat)
open(2,file=trim(file_a),form='unformatted',&
status='old',action='read',iostat=stat)
! Die if file cannot be opened
if (stat .ne. 0) then
	print *, 'Problem opening ',trim(file_b) ; STOP
endif
! Read in data
!read(2,rec=1) grid_a
read(2) grid_a
! Close file
close(2)

! --- Beta grid (bin) --- !
! Open binary file
open(3,file=trim(file_b),form='unformatted',&
status='old',action='read',iostat=stat)
!open(3,file=trim(file_b),form='unformatted',access='direct',&
!status='old',action='read',recl=nx*ny*4,iostat=stat)
! Die if file cannot be opened
if (stat .ne. 0) then
	print *, 'Problem opening ',trim(file_b) ; STOP
endif
! Read in data
!read(3,rec=1) grid_b
read(3) grid_b
! Close file
close(3)

! --- Mask file (bin) --- !
! Open binary file
open(4,file=trim(file_mask),form='unformatted',&
status='old',action='read',iostat=stat)
!access='direct',status='old',action='read',recl=nx*ny*4,iostat=stat)
! Die if file cannot be opened
if (stat .ne. 0) then
	print *, 'Problem opening ',trim(file_mask) ; STOP
endif
! Read in data
!read(4,rec=1) grid_mask
read(4) grid_mask
! Close file
close(4)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 npt=0
 do i=1,nx
 do j=1,ny
! if (grid_a(i,j).gt.10.0) grid_a(i,j)=10.0
  if (grid_precip(i,j).gt.127.3.and.grid_precip(i,j).lt.127.4) then
   imax=i
   jmax=j
  endif
  if (grid_precip(i,j).lt.-0.0) then
!  print *,i,j,grid_precip(i,j)
 npt=npt+1
  endif
 enddo
 enddo
  print *,'npt=',npt
!i=imax
!j=jmax
!print *,i,j,grid_mask(i,j),grid_precip(i,j),grid_a(i,j),grid_b(i,j),grid_out(i,j) 
 i=10
 j=220
 print *,i,j,grid_mask(i,j),grid_precip(i,j),grid_a(i,j),grid_b(i,j),grid_out(i,j) 
 i=10
 j=10
 print *,i,j,grid_mask(i,j),grid_precip(i,j),grid_a(i,j),grid_b(i,j),grid_out(i,j) 
 i=460
 j=220
 print *,i,j,grid_mask(i,j),grid_precip(i,j),grid_a(i,j),grid_b(i,j),grid_out(i,j) 
 i=460
 j=10
 print *,i,j,grid_mask(i,j),grid_precip(i,j),grid_a(i,j),grid_b(i,j),grid_out(i,j) 
 call maxminI(grid_mask,nx,ny,'M',grid_mask)
 call maxmin(grid_precip,nx,ny,'P',grid_mask)
 call maxmin(grid_a,nx,ny,'A',grid_mask)
 call maxmin(grid_b,nx,ny,'B',grid_mask)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! CALCULATE SCALED RFC GRID
!
! RFC*=a*RFC+b
!
! Default grid
grid_out = -999;

!  The regression should Stay in  cpc mask
!where (grid_precip .ne. -999 .and. grid_a .ne. -999 .and. grid_b .ne. -999 .and. grid_mask==1) &
!grid_out = grid_a * grid_precip + grid_b
where ( grid_precip .gt. 0 .and. grid_mask==1)                                                  &
   grid_out = grid_a * grid_precip + grid_b
!  alternative to the regression to keep continuity
where ( grid_precip .gt. 0 .and. grid_precip .lt. key_precip .and.  grid_mask==1)               &
   grid_out = grid_out*(1.0-(key_precip-grid_precip)/key_precip)                                  &
            + grid_precip * (key_precip-grid_precip)/key_precip

! keep the useful rfc values outside cpc mask
where (grid_precip .ne. -999 .and. grid_a .eq. -999 .and. grid_b .eq. -999 .and. grid_mask==0) &
grid_out = grid_precip 

! Can't have negative precip
 where (grid_out .ne. -999 .and. grid_out < 0) grid_out = 0

! Precip higher than this not good
where (grid_out > max_precip) grid_out = max_precip                           

! Keep precip at zero where originally zero
!where (grid_mask == 1 .and. grid_precip == 0) grid_out = 0
where (grid_precip == 0) grid_out = 0

 call maxmin(grid_out,nx,ny,'O',grid_mask)
!i=imax
!j=jmax
!print *,i,j,grid_mask(i,j),grid_precip(i,j),grid_a(i,j),grid_b(i,j),grid_out(i,j) 
 do i=1,nx
 do j=1,ny
  if (grid_out(i,j).gt.129.6.and.grid_out(i,j).lt.129.7) then
   imax=i
   jmax=j
  endif
 enddo
 enddo
!i=imax
!j=jmax
!print *,i,j,grid_mask(i,j),grid_precip(i,j),grid_a(i,j),grid_b(i,j),grid_out(i,j) 
 i=10
 j=220
 print *,i,j,grid_mask(i,j),grid_precip(i,j),grid_a(i,j),grid_b(i,j),grid_out(i,j) 
 i=10
 j=10
 print *,i,j,grid_mask(i,j),grid_precip(i,j),grid_a(i,j),grid_b(i,j),grid_out(i,j) 
 i=460
 j=220
 print *,i,j,grid_mask(i,j),grid_precip(i,j),grid_a(i,j),grid_b(i,j),grid_out(i,j) 
 i=460
 j=10
 print *,i,j,grid_mask(i,j),grid_precip(i,j),grid_a(i,j),grid_b(i,j),grid_out(i,j) 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! SAVE NEW SCALED RFC GRID
!
! Open grid output file
call baopen(9,trim(file_out),stat)
if (stat .ne. 0) then
    print *, 'Problem opening',trim(file_out) ; STOP
endif

! Reshape grid back to a 1d array
tempArray = reshape(grid_out,(/nx*ny/))
lb = .true.
where (tempArray==-999) lb=.false.

! Write to grib
kpds(4) = 192
kpds(5) = 61
kpds(6) = 1
kpds(7) = 0
call putgb(9,nx*ny,kpds,kgds,lb,tempArray,stat)
! Did it write the data successfully?
if (stat .ne. 0) then
    print *, 'Problem writing grib data, error status code =',stat ; STOP
endif

! Close grib file
call baclose(9,stat)
! Did it close successfully?
if (stat .ne. 0) then
    print *, 'Problem closing grib file, status code =',stat ; STOP
endif

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! DEALLOCATE ARRAY MEMORY
!
deallocate(lb,tempArray,grid_precip,grid_a,grid_b,grid_out,grid_mask)

end program

 subroutine maxmin(a,nx,ny,C,m)
 integer nx,ny
 real a(nx,ny)
 integer m(nx,ny)
 character*1 C
 integer i,j
 real amax,amin
  print *, 'start maxmin',nx,ny
  amax=-10000.0
  amin=10000.0
  do i=1,nx
  do j=1,ny
   if (m(i,j).eq.1.and.a(i,j).gt.-999.0) then
    if (a(i,j).gt.amax) amax=a(i,j)
    if (a(i,j).lt.amin) amin=a(i,j)
   endif
  enddo
  enddo
 print *,'For ', C, ': amax=',amax,'amin=',amin
 return
  end

 subroutine maxminI(n,nx,ny,C,m)
 integer nx,ny
 integer n(nx,ny)
 integer m(nx,ny)
 character*1 C
 integer i,j
 integer nmax,nmin
 print *, 'start maxmin',nx,ny
  nmax=-10000
  nmin=10000
  do i=1,nx
  do j=1,ny
!  if (m(i,j).eq.1) then
    if (n(i,j).gt.nmax) nmax=n(i,j)
    if (n(i,j).lt.nmin) nmin=n(i,j)
!  endif
  enddo
  enddo
 print *,'For ', C, ': nmax=',nmax,'nmin=',nmin
 return
  end

