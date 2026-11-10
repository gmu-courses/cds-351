program simd_example
   implicit none
   integer, dimension(8) :: data = [1, 2, 3, 4, 5, 0, 0, 0] ! Padded to a multiple of 4
   integer :: sum_val, i

   ! Fortran array syntax (highly optimized by compiler for SIMD)
   sum_val = sum(data)

   print *, "SIMD Sum (via sum function): ", sum_val

   ! Explicit loop with SIMD directive (requires -fopenmp)
   sum_val = 0
   !$omp simd reduction(+:sum_val)
   do i = 1, size(data)
      sum_val = sum_val + data(i)
   end do

   print *, "SIMD Sum (via OpenMP SIMD): ", sum_val

end program simd_example

! Unlike C++ where you need low-level architecture-specific intrinsics
! modern Fortran compilers (like gfortran) inherently excel at array 
! syntax and vectorization automatically mapping operations directly
! to the machine's execution units
