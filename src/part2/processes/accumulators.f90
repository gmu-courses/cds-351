! Breaking a dependency chain with several accumulators
!
! Summing an array with one accumulator,
!
!     s = s + x(i)
!
! makes every addition wait for the previous one: a single long dependency
! chain. Splitting the sum into four independent partial sums gives the
! processor four chains it can work on at the same time, so their additions
! overlap in the pipeline. The partial sums are combined at the end.
!
! The compiler does not make this change for you: floating-point addition is
! not associative, so reordering a sum can change the last digits of the
! result. (Compiler options such as -ffast-math allow it to do so.)
!
! This is the same idea as an OpenMP reduction, where each thread keeps its
! own partial sum.
!
! Build:  gfortran -O2 accumulators.f90 -o accumulators.x
!
program accumulators
   use iso_fortran_env, only: real64, int64
   implicit none

   integer, parameter :: n = 4096          ! 32 KiB: fits in L1 cache
   integer, parameter :: reps = 100000     ! about 4 x 10**8 additions
   real(real64) :: x(n), s, s1, s2, s3, s4
   real(real64) :: t_one, t_four
   integer(int64) :: t1, t2, rate
   integer :: i, r

   call random_number(x)

   ! One accumulator: one long dependency chain
   s = 0.0_real64
   call system_clock(t1, rate)
   do r = 1, reps
      do i = 1, n
         s = s + x(i)
      end do
   end do
   call system_clock(t2)
   t_one = real(t2 - t1, real64) / real(rate, real64)

   ! Four accumulators: four independent chains
   s1 = 0.0_real64
   s2 = 0.0_real64
   s3 = 0.0_real64
   s4 = 0.0_real64
   call system_clock(t1)
   do r = 1, reps
      do i = 1, n, 4                       ! n is a multiple of 4
         s1 = s1 + x(i)
         s2 = s2 + x(i+1)
         s3 = s3 + x(i+2)
         s4 = s4 + x(i+3)
      end do
   end do
   call system_clock(t2)
   t_four = real(t2 - t1, real64) / real(rate, real64)

   print '(a, f8.3, a)', 'One accumulator:   ', t_one,  ' s'
   print '(a, f8.3, a)', 'Four accumulators: ', t_four, ' s'
   print '(a, f8.1)',    'Speedup:           ', t_one / t_four
   print '(a, es22.14)', 'Sum (one):  ', s
   print '(a, es22.14)', 'Sum (four): ', (s1 + s2) + (s3 + s4)

end program accumulators
