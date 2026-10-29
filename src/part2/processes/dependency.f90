! Same additions, different dependencies
!
! Both loops below perform exactly the same number of additions on the same
! data, and the arrays are small enough to stay in cache. The only difference
! is whether each addition needs the result of the previous one.
!
!   independent:  c(i) = c(i) + b(i)      ! every i is a separate update
!   dependent:    x(i) = x(i-1) + b(i)    ! a running sum: x(i) needs x(i-1)
!
! In the independent loop the processor can overlap many additions in its
! pipeline (instruction-level parallelism). In the dependent loop each
! addition must wait until the previous one has finished: a data hazard.
!
! Build:  gfortran -O2 dependency.f90 -o dependency.x
!
program dependency
   use iso_fortran_env, only: real64, int64
   implicit none

   integer, parameter :: n = 4096          ! 32 KiB per array: fits in L1 cache
   integer, parameter :: reps = 100000     ! about 4 x 10**8 additions per loop
   real(real64) :: b(n), c(n), x(0:n)
   real(real64) :: t_indep, t_dep
   integer(int64) :: t1, t2, rate
   integer :: i, r

   call random_number(b)
   c = 0.0_real64
   x = 0.0_real64

   ! Independent iterations
   call system_clock(t1, rate)
   do r = 1, reps
      do i = 1, n
         c(i) = c(i) + b(i)
      end do
   end do
   call system_clock(t2)
   t_indep = real(t2 - t1, real64) / real(rate, real64)

   ! Dependent iterations: each sum continues from the previous one
   call system_clock(t1)
   do r = 1, reps
      x(0) = x(n)
      do i = 1, n
         x(i) = x(i-1) + b(i)
      end do
   end do
   call system_clock(t2)
   t_dep = real(t2 - t1, real64) / real(rate, real64)

   print '(a, i0, a)',   'Additions per loop: ', int(n, int64) * reps
   print '(a, f8.3, a)', '  independent  c(i) = c(i) + b(i):   ', t_indep, ' s'
   print '(a, f8.3, a)', '  dependent    x(i) = x(i-1) + b(i): ', t_dep, ' s'
   print '(a, f8.1)',    '  ratio dependent / independent:     ', t_dep / t_indep
   print '(a, 2es12.4)', '  check values: ', sum(c), x(n)    ! use the results

end program dependency
