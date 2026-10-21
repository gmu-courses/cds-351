! Measure the fixed cost of an I/O request
!
! Latency is the cost paid per request, however little data it carries.
! Three tests write the same tiny amount of data per request:
!
!   1. many tiny files:     open, write 8 bytes, close   (per file)
!   2. many small writes:   write 8 bytes, then flush     (per write)
!   3. one large write:     all the same values at once   (for comparison)
!
! Tests 1 and 2 are dominated by latency; test 3 by bandwidth.
!
! Note: 'flush' hands the data to the operating system, which may keep it in
! memory before it reaches the disk. So this measures the latency of the file
! system as your program sees it. That is what matters in practice, and it
! differs a lot between file systems. Try a local and a shared one, e.g.
!
!   ./io_latency.x /tmp        (local disk)
!   ./io_latency.x .           (home directory: often a network file system)
!
! Build:  gfortran -O3 io_latency.f90 -o io_latency.x
!
program io_latency
   use iso_fortran_env, only: real64, int64  ! for portability
   implicit none

   integer, parameter :: nfiles = 1000
   integer, parameter :: nwrites = 100000
   character(len=256) :: dir
   character(len=300) :: fname
   real(real64) :: values(nwrites), t_files, t_small, t_large
   integer(int64) :: t1, t2, rate
   integer :: k, u

   ! Directory to test (default: current directory)
   if (command_argument_count() >= 1) then
      call get_command_argument(1, dir)
   else
      dir = '.'
   end if
   call random_number(values)

   ! Test 1: many tiny files
   call system_clock(t1, rate)
   do k = 1, nfiles
      write(fname, '(a, a, i0, a)') trim(dir), '/io_lat_', k, '.bin'
      open(newunit=u, file=fname, access='stream', form='unformatted', &
           status='replace', action='write')
      write(u) values(k)
      close(u)
   end do
   call system_clock(t2)
   t_files = real(t2 - t1, real64) / real(rate, real64)

   do k = 1, nfiles                      ! clean up (not timed)
      write(fname, '(a, a, i0, a)') trim(dir), '/io_lat_', k, '.bin'
      open(newunit=u, file=fname, status='old')
      close(u, status='delete')
   end do

   fname = trim(dir) // '/io_lat_data.bin'

   ! Test 2: many small writes, each pushed to the file system
   open(newunit=u, file=fname, access='stream', form='unformatted', &
        status='replace', action='write')
   call system_clock(t1, rate)
   do k = 1, nwrites
      write(u) values(k)
      flush(u)
   end do
   call system_clock(t2)
   close(u)
   t_small = real(t2 - t1, real64) / real(rate, real64)

   ! Test 3: the same values in a single write
   open(newunit=u, file=fname, access='stream', form='unformatted', &
        status='replace', action='write')
   call system_clock(t1, rate)
   write(u) values
   flush(u)
   call system_clock(t2)
   close(u, status='delete')
   t_large = real(t2 - t1, real64) / real(rate, real64)

   print '(2a)', 'Directory: ', trim(dir)
   print '(a, i0, a, f9.2, a)', '  ', nfiles, ' tiny files:        ', &
         1.0e6_real64 * t_files / nfiles, ' us per file'
   print '(a, i0, a, f9.2, a)', '  ', nwrites, ' flushed writes:  ', &
         1.0e6_real64 * t_small / nwrites, ' us per write'
   print '(a, i0, a, f9.2, a)', '  1 write of ', nwrites, ' values: ', &
         1.0e6_real64 * t_large, ' us in total'
   print '(a, f9.0)', '  small writes / one large write, total time: ', &
         t_small / t_large

end program io_latency
