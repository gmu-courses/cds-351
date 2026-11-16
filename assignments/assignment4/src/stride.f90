! Same work, different strides (Assignment 4, Exercise 4.3)
!
! Every element of a large array is updated exactly once for each stride s:
!
!     do offset = 1, s
!        do i = offset, n, s
!           a(i) = a(i) + 1
!
! The arithmetic never changes; only the distance between consecutive
! accesses does. Output is CSV: stride, best time (s), ns per element.
!
program stride
   use iso_fortran_env, only: real64, int64
   implicit none

   integer, parameter :: n = 2**24              ! 128 MiB: larger than any cache
   integer, parameter :: ntrials = 3
   integer, parameter :: strides(*) = [1, 2, 4, 8, 16, 32, 64, 128]
   real(real64), allocatable :: a(:)
   real(real64) :: seconds, best
   integer(int64) :: t1, t2, rate
   integer :: k, trial, offset, i, s

   allocate(a(n))
   a = 0.0_real64                               ! touch every page before timing

   print '(a)', 'stride,seconds,ns_per_element'
   do k = 1, size(strides)
      s = strides(k)
      best = huge(best)
      do trial = 1, ntrials
         call system_clock(t1, rate)
         do offset = 1, s
            do i = offset, n, s
               a(i) = a(i) + 1.0_real64
            end do
         end do
         call system_clock(t2)
         seconds = real(t2 - t1, real64) / real(rate, real64)
         best = min(best, seconds)
      end do
      print '(i0, ",", f0.5, ",", f0.3)', s, best, 1.0e9_real64 * best / n
   end do

   ! Use the result so the compiler cannot skip the loops
   if (sum(a) < 0.0_real64) print *, 'impossible'

end program stride
