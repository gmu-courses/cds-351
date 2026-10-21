! Measure how fast large amounts of data move to and from a file
!
! Bandwidth is the rate at which data flow once a transfer is under way:
!
!     bandwidth = bytes moved / time
!
! The program writes a 1 GiB array to a file in one large write, then reads it
! back in one large read. A single large request pays the fixed cost (latency)
! only once, so the time is dominated by bandwidth. Compare with io_latency.f90,
! which sends many tiny requests.
!
! Two things to notice:
!   - The write may finish before the data reach the disk: the operating system
!     keeps recently written data in memory (the "page cache") and writes them
!     out later.
!   - The read right after the write is usually served from that same cache,
!     so it can run at close to memory bandwidth instead of disk bandwidth.
!     Both effects are part of the I/O hierarchy, just as caches are for memory.
!
! Usage:  ./io_bandwidth.x [directory]      (default: current directory)
!   Try a local and a shared file system, e.g. /tmp and your home directory.
!
! Build:  gfortran -O3 io_bandwidth.f90 -o io_bandwidth.x
!
program io_bandwidth
   use iso_fortran_env, only: real64, int64  ! for portability
   implicit none

   integer, parameter :: n = 256 * 1024 * 1024   ! 256 Mi default reals = 1 GiB
   real, allocatable :: data(:)
   character(len=256) :: dir
   character(len=300) :: fname
   real(real64) :: gbytes, t_write, t_read
   integer(int64) :: t1, t2, rate
   integer :: u

   ! Directory to test (default: current directory)
   if (command_argument_count() >= 1) then
      call get_command_argument(1, dir)
   else
      dir = '.'
   end if
   fname = trim(dir) // '/test.bin'

   allocate(data(n))
   call random_number(data)      ! real data, so nothing can be skipped

   ! storage_size gives bits per element
   gbytes = real(n, real64) * storage_size(data) / 8.0_real64 / 1.0e9_real64

   ! Write the whole array in one request
   call system_clock(t1, rate)
   open(newunit=u, file=fname, access='stream', form='unformatted', &
        status='replace', action='write')
   write(u) data
   close(u)
   call system_clock(t2)
   t_write = real(t2 - t1, real64) / real(rate, real64)

   ! Read it back in one request
   data = 0.0
   call system_clock(t1)
   open(newunit=u, file=fname, access='stream', form='unformatted', &
        status='old', action='read')
   read(u) data
   call system_clock(t2)
   close(u, status='delete')     ! remove the test file
   t_read = real(t2 - t1, real64) / real(rate, real64)

   print '(2a)',          'Directory: ', trim(dir)
   print '(a, f6.2, a)',  '  file size:       ', gbytes, ' GB'
   print '(a, f8.2, a, f7.3, a)', '  write bandwidth: ', gbytes / t_write, &
         ' GB/s   (', t_write, ' s)'
   print '(a, f8.2, a, f7.3, a)', '  read bandwidth:  ', gbytes / t_read, &
         ' GB/s   (', t_read, ' s)'

end program io_bandwidth
