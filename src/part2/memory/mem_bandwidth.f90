! Measure memory bandwidth with the STREAM "triad" kernel
!
!    a = b + s*c
!
! The same loop is timed twice:
!   1. on small arrays that fit in cache, and
!   2. on large arrays that do not fit in any cache, so every element
!      has to come from main memory.
! The arithmetic per element is identical; only where the data live changes.
!
! What to expect: on a typical x86 cluster node, one core reads its own cache
! several times faster than it can stream from main memory. On Apple Silicon
! laptops a single core can use most of the memory bandwidth, so the two
! numbers are much closer. You may run it on both and compare.
!
! Bandwidth = bytes moved / time. Each element reads b and c and writes a:
! 3 x 8 bytes. (The hardware may move a little more than this, as STREAM
! also notes; we count the bytes the program asks for.)
!
! Build:  gfortran -O3 mem_bandwidth.f90 -o mem_bandwidth.x
!
program mem_bandwidth
   use iso_fortran_env, only: real64, int64  ! for portability
   implicit none

   integer, parameter :: n_small = 2**11   ! 3 arrays x 16 KiB: fits in cache
   integer, parameter :: n_large = 2**25   ! 3 arrays x 256 MiB: main memory
   real(real64) :: gbs_small, gbs_large

   ! Repeat the small case many times so both cases move the same total data
   call triad(n_small, n_large / n_small, gbs_small)
   call triad(n_large, 1, gbs_large)

   print '(a)',          'Triad a = b + s*c'
   print '(a, f8.1, a)', '  arrays in cache  (3 x 16 KiB):  ', gbs_small, ' GB/s'
   print '(a, f8.1, a)', '  arrays in memory (3 x 256 MiB): ', gbs_large, ' GB/s'
   print '(a, f8.1)',    '  ratio cache / memory:          ', gbs_small / gbs_large

contains

   subroutine triad(n, reps, gbs)
      integer, intent(in) :: n, reps
      real(real64), intent(out) :: gbs
      real(real64), allocatable :: a(:), b(:), c(:)
      real(real64) :: s, elapsed, best, bytes
      integer(int64) :: t1, t2, rate
      integer :: trial, r

      allocate(a(n), b(n), c(n))
      a = 0.0_real64        ! touch every element before timing
      b = 1.0_real64
      c = 2.0_real64
      s = 3.0_real64

      best = huge(1.0_real64)
      do trial = 1, 5                  ! keep the best of five trials
         call system_clock(t1, rate)
         do r = 1, reps
            a = b + s*c
            s = s + 1.0e-12_real64 * a(n)   ! makes every repetition needed
         end do
         call system_clock(t2)
         elapsed = real(t2 - t1, real64) / real(rate, real64)
         best = min(best, elapsed)
      end do

      bytes = 3.0_real64 * 8.0_real64 * real(n, real64) * real(reps, real64)
      gbs = bytes / best / 1.0e9_real64

      if (sum(a) < 0.0_real64) print *, 'impossible'   ! keep the result live
   end subroutine triad

end program mem_bandwidth
