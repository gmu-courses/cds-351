! Time per element as the working set grows (Assignment 4, Exercise 4.4)
!
! For each array size from 4 KiB to 256 MiB the array is swept repeatedly so
! that every size performs about the same total number of updates, 2**28.
! While the array fits in a cache level, the sweeps run at that level's speed;
! when it no longer fits, every sweep must come from the next level down.
! Output is CSV: size in KiB, ns per element.
!
program working_set
   use iso_fortran_env, only: real64, int64
   implicit none

   integer(int64), parameter :: total_updates = 2_int64**28
   real(real64), allocatable :: a(:)
   real(real64) :: seconds, best, checksum
   integer(int64) :: t1, t2, rate
   integer :: p, n, reps, r, i, trial

   checksum = 0.0_real64
   print '(a)', 'size_kib,ns_per_element'
   do p = 9, 25                                 ! 2**9 .. 2**25 elements
      n = 2**p
      reps = int(total_updates / n)
      allocate(a(n))
      a = 1.0_real64

      best = huge(best)
      do trial = 1, 3
         call system_clock(t1, rate)
         do r = 1, reps
            do i = 1, n
               a(i) = 0.5_real64 * a(i) + 1.0_real64   ! values stay near 2
            end do
         end do
         call system_clock(t2)
         seconds = real(t2 - t1, real64) / real(rate, real64)
         best = min(best, seconds)
      end do

      print '(i0, ",", f0.3)', 8 * n / 1024, 1.0e9_real64 * best / (real(n, real64) * reps)
      checksum = checksum + sum(a)
      deallocate(a)
   end do

   ! Use the results so the compiler cannot skip the loops
   if (checksum < 0.0_real64) print *, 'impossible'

end program working_set
