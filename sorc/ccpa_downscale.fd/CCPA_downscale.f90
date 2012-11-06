program downscale
!###########################################################
!HISTORY:
!01/04/2010: Program created by Mike Charles in 2008
!03/24/2010: Program modified by Dingchen Hou for CCPA initial implementation
!###########################################################

!$$$ MAIN PROGRAM DOCUMENTATION BLOCK
!
! Main program: downscale
! Programmer: Mike Charles     Org: XXXX     Date: 2008-11-03
!
! Abstract: This program reads in the scaled RFC 24h accum. precip (output from scale_rfc)
!           and downscale it back to RFC resolution
!           The downscaling is done by using the ratio of the original 24h RFC precip to
!           that with informnation loss (through copygb to CPC grid and then copygb back.
!
! Program history log:
!
! Input files: file_RFCscaled, file_RFCh, file_RFCl.  all grib files
!              Their file names are passed in as command line arguments
! Output files: file_out, grib file whose name is passed in as command line argument.

! Attributes:
!   Languate: Fortran 90
!
!$$$

implicit none

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! DECLARE VARIABLES
!
integer, dimension(200) :: jpds, jgds, kpds, kgds, kg, kf
integer :: iargc
real, dimension(:,:), allocatable :: grid_RFCscaled, grid_RFCh, grid_RFCl, grid_out, grid_vect, grid_mask, scld_mask
real, dimension(:), allocatable :: tempArray, temp_mask
logical*1, dimension(:), allocatable :: lb
character(120) :: file_RFCscaled, file_RFCh, file_RFCl, file_out, file_mask
integer :: nx, ny, stat, k, max_precip

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! SET CONSTANTS
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! GET COMMAND LINE ARGUMENTS
!
! Call getarg
call getarg(1,file_RFCscaled)
call getarg(2,file_RFCh)
call getarg(3,file_RFCl)
call getarg(4,file_out)
print *, file_RFCscaled 
print *, file_RFCh
print *, file_RFCl
print *, file_out
! Die if user doesn't supply files
if (iargc() < 4) then
   print *, 'Usage: ./downscale rfc_scaled_fle rfc_highres_file rfc_lowres_file out_file'
   stop
endif

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
print *, 'READ from file',file_RFCscaled
call baopen(1,trim(file_RFCscaled),stat)
if (stat .ne. 0) then
	print *, 'Problem opening grib file ', trim(file_RFCscaled) ; STOP
endif
! Read grib header to get dimensions
call getgbh(1,0,-1,jpds,jgds,kg,kf,k,kpds,kgds,stat)
if (stat .ne. 0) then
	print *, 'Problem reading from grib file ', trim(file_RFCscaled) ; STOP
endif
! Close grib file
call baclose(1,stat)
if (stat .ne. 0) then
	print *, 'Problem closing grib file ', trim(file_RFCscaled) ; STOP
endif
! Get grib dimensions
nx = kgds(2)
ny = kgds(3)

print *, 'Using dimensions (',nx,',',ny,')'

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! ALLOCATE MEMORY FOR ARRAYS
!
allocate(lb(nx*ny),tempArray(nx*ny),grid_RFCscaled(nx,ny),grid_RFCh(nx,ny),  &
         grid_RFCl(nx,ny),grid_out(nx,ny),grid_vect(nx,ny),grid_mask(nx,ny), &
         scld_mask(nx,ny),temp_mask(nx*ny))

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! OPEN GRIDS
!

! --- scaled RFC (grib) --- !
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
print *, 'READ from file', file_RFCscaled
call baopen(1,trim(file_RFCscaled),stat)
! Die if grib cannot be opened
if (stat .ne. 0) then
	print *, 'Problem opening grib file ', trim(file_RFCscaled) ; STOP
endif
! Read in grib data
CALL getgb(1,0,nx*ny,-1,jpds,jgds,nx*ny,k,kpds,kgds,lb,tempArray,stat)
if (stat .ne. 0) then
	print *, 'Problem reading grib file ', trim(file_RFCscaled) ; STOP
endif
! Get mask
temp_mask = 0 ; where(lb) temp_mask = 1
scld_mask = reshape(temp_mask,(/nx,ny/))
! Transform into 2-D matrix
grid_RFCscaled=reshape(tempArray,(/nx,ny/))
! Close grib file
close(1)

tempArray=0.0
! --- orig RFC (grib) --- !
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
print *, 'READ from file ', file_RFCh
call baopen(3,trim(file_RFCh),stat)
! Die if grib cannot be opened
if (stat .ne. 0) STOP 'Problem opening grib file'
! Read in grib data
CALL getgb(3,0,nx*ny,-1,jpds,jgds,nx*ny,k,kpds,kgds,lb,tempArray,stat)
if (stat .ne. 0) then
	print *, 'Problem reading grib file ', trim(file_RFCh) 
	print *, 'error code is code=', stat ; STOP
endif
! Get mask
temp_mask = 0 ; where(lb) temp_mask = 1
grid_mask = reshape(temp_mask,(/nx,ny/))
! Transform into 2-D matrix
grid_RFCh=reshape(tempArray,(/nx,ny/))
! Close grib file
close(3)

tempArray=0.0
! --- RFC with information loss (grib) --- !
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
print *, 'READ from file ', file_RFCl
call baopen(2,trim(file_RFCl),stat)
! Die if grib cannot be opened
if (stat .ne. 0) STOP 'Problem opening grib file'
! Read in grib data
CALL getgb(2,0,nx*ny,-1,jpds,jgds,nx*ny,k,kpds,kgds,lb,tempArray,stat)
if (stat .ne. 0) then
	print *, 'Problem reading grib file ', trim(file_RFCl) 
	print *, 'error code is code=', stat ; STOP
endif
! Transform into 2-D matrix
grid_RFCl=reshape(tempArray,(/nx,ny/))
! Close grib file
close(2)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Check the fields
  call maxmin(grid_RFCl,nx,ny,'L',grid_mask)
  call maxmin(grid_RFCh,nx,ny,'H',grid_mask)
  call maxmin(grid_RFCscaled,nx,ny,'S',grid_mask)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! DOWNSCALE
!
!grid_out  = -999
!where (grid_mask == 1)  grid_out = grid_RFCh
!!grid_vect = 1.0
!grid_vect = 0.0
!!where (grid_RFCl >= 0.0001 .and. grid_RFCh >= 0.0001 .and. scld_mask == 1)  grid_vect = grid_RFCh/grid_RFCl
!where (grid_RFCl >= 0.0 .and. scld_mask == 1)  grid_vect = grid_RFCh/grid_RFCl
!where (grid_vect > 100.0 .and. grid_mask == 1) grid_vect = 100.0
!where (grid_RFCscaled < 9999 .and. grid_RFCh < 9999 .and. grid_RFCl < 9999 .and. scld_mask == 1) & 
!& grid_out = grid_RFCscaled * grid_vect

grid_out  = -999
where (grid_mask == 1)  grid_out = grid_RFCh
grid_vect = 1.0
where (grid_RFCl > 0.0 .and. scld_mask == 1)  grid_vect = grid_RFCscaled/grid_RFCl
where (grid_mask == 1)  grid_out = grid_out * grid_vect

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Check the fields
  call maxmin(grid_RFCl,nx,ny,'L',grid_mask)
  call maxmin(grid_RFCh,nx,ny,'H',grid_mask)
  call maxmin(grid_RFCscaled,nx,ny,'S',grid_mask)
  call maxmin(grid_out,nx,ny,'O',grid_mask)
  call maxmin(grid_vect,nx,ny,'V',grid_mask)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! OUTPUT GRIB
!
! Open grid output file
call baopen(1,trim(file_out),stat)
if (stat .ne. 0) then
    print *, 'Problem opening',trim(file_out)
    STOP
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

call putgb(1,nx*ny,kpds,kgds,lb,tempArray,stat)
! Did it write the data successfully?
if (stat .ne. 0) then
    print *, 'Problem writing grib data, error status code =',stat
    STOP
endif

! Close grib file
call baclose(1,stat)
! Did it close successfully?
if (stat .ne. 0) then
    print *, 'Problem closing grib file, status code =',stat
    STOP
endif

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! DEALLOCATE ARRAY MEMORY
!
deallocate(lb,tempArray,grid_RFCscaled,grid_RFCh,grid_RFCl,grid_out,grid_vect,grid_mask,scld_mask)

end program downscale

 subroutine maxmin(a,nx,ny,C,m)
 integer nx,ny
 real a(nx,ny)
!integer m(nx,ny)
 real m(nx,ny)
 character*1 C
 integer i,j,npt,nm0
 real amax,amin
  print *, 'start maxmin',nx,ny
  npt=0
  nm0=0
  amax=-10000.0
  amin=10000.0
  do i=1,nx
  do j=1,ny
   if (a(i,j).gt.210.0) then
    print *,i,j,a(i,j),m(i,j)
   endif
   if (m(i,j).gt.0) then
    nm0=nm0+1
   endif
   if (m(i,j).eq.1.and.a(i,j).gt.-999.0) then
!  if (m(i,j).eq.1) then
    if (a(i,j).gt.amax) amax=a(i,j)
    if (a(i,j).lt.amin) amin=a(i,j)
    npt=npt+1
   endif
  enddo
  enddo
 print *,'For ', C, ': amax=',amax,'amin=',amin,'NPT= ',npt,' NM0=',nm0
 return
  end

