! Heat diffusion on a square plate: parallel loops with work-sharing
!
! The same computation as heat_serial.f90 (read that file first). Three loops
! are parallelized, each with a combined "parallel do":
!
!   1. the stencil update   every cell of unew is computed from the old u,
!                           so the iterations are independent; the largest
!                           change is combined with reduction(max:diff)
!   2. the copy u = unew    independent iterations
!   3. the mean temperature a sum, combined with reduction(+:total)
!
! Only the outer loop (over j, the columns) is divided among the threads. Each
! thread gets a block of whole columns, and its inner loop runs down a column,
! which is contiguous in memory (Fortran is column-major).
!
! default(none) makes us list every variable. n, r and the other named
! constants are parameters, so they need not be listed.
!
! Try:
!   - compare the output with heat_serial.x for 1, 2, 4 and 8 threads
!   - add collapse(2) to the update loop; does anything change?
!   - remove reduction(max:diff); what happens to the number of steps?
!
! Build:  gfortran -O3 -fopenmp heat_do.f90 -o heat_do.x
! Run:    OMP_NUM_THREADS=4 ./heat_do.x
!
program heat_do
   use iso_fortran_env, only: real64
   use omp_lib, only: omp_get_wtime, omp_get_max_threads
   implicit none

   integer, parameter :: n = 10000             ! interior cells per side
   integer, parameter :: max_steps = 1000
   integer, parameter :: print_every = 100
   real(real64), parameter :: r = 0.2_real64
   real(real64), parameter :: tol = 1.0e-2_real64
   real(real64), parameter :: t_hot = 100.0_real64

   real(real64), allocatable :: u(:,:), unew(:,:)
   real(real64) :: diff, total
   real(real64) :: t0, t1, t2, t3, t_compute, t_setup
   integer :: i, j, step

   t0 = omp_get_wtime()

   allocate(u(0:n+1, 0:n+1), unew(0:n+1, 0:n+1))
   u = 0.0_real64
   u(:, n+1) = t_hot
   unew = u

   t1 = omp_get_wtime()

   do step = 1, max_steps
      diff = 0.0_real64

      ! 1. Stencil update: each thread writes its own columns of unew and only
      !    reads u, so there is no race. Each thread keeps a private diff;
      !    the largest is copied into diff at the end of the loop.
      !$omp parallel do default(none) shared(u, unew) private(i, j) &
      !$omp&   reduction(max:diff)
      do j = 1, n
         do i = 1, n
            unew(i,j) = u(i,j) + r * (u(i-1,j) + u(i+1,j) + u(i,j-1) + u(i,j+1) &
                                      - 4.0_real64 * u(i,j))
            diff = max(diff, abs(unew(i,j) - u(i,j)))
         end do
      end do
      !$omp end parallel do

      ! 2. Copy the new step into u. The implicit barrier at the end of the
      !    update loop guarantees that unew is complete.
      !$omp parallel do default(none) shared(u, unew) private(i, j)
      do j = 1, n
         do i = 1, n
            u(i,j) = unew(i,j)
         end do
      end do
      !$omp end parallel do

      if (mod(step, print_every) == 0) print '(a, i6, a, es10.3)', 'step ', step, '   max change ', diff
      if (diff < tol) exit
   end do

   t2 = omp_get_wtime() 


   ! 3. Mean temperature: a sum over all cells
   total = 0.0_real64
   !$omp parallel do default(none) shared(u) private(i, j) reduction(+:total)
   do j = 1, n
      do i = 1, n
         total = total + u(i,j)
      end do
   end do
   !$omp end parallel do

   t3 = omp_get_wtime()

   t_setup = (t1 - t0) + (t3 - t2)
   t_compute = t2 - t1

   print '(a, i0)',      'threads:          ', omp_get_max_threads()
   print '(a, i0)',      'steps:            ', min(step, max_steps)
   print '(a, f18.12)',  'mean temperature: ', total / real(n, real64)**2
   print '(a, f8.3, a)', 'setup+post time:  ', t_setup, ' s'
   print '(a, f8.3, a)', 'compute time:     ', t_compute, ' s'
   print '(a, f8.3, a)', 'total time:       ', t_setup+t_compute, ' s'

end program heat_do
