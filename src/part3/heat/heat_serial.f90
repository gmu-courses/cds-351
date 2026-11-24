! Heat diffusion on a square plate: the serial version
!
! A square metal plate starts at 0 degrees. Its top edge is held at 100
! degrees and the other three edges at 0. Heat flows in from the top edge
! until the plate reaches a steady state.
!
! The plate is a grid of n x n interior cells plus a ring of boundary cells.
! Each time step replaces every interior cell with a weighted average of
! itself and its four neighbors (the explicit 5-point stencil):
!
!   unew(i,j) = u(i,j) + r * (u(i-1,j) + u(i+1,j) + u(i,j-1) + u(i,j+1) - 4 u(i,j))
!
! r = alpha dt / dx^2 must be at most 0.25 for the method to be stable.
! The new values go into a second array, unew: every cell of the new step is
! computed from the OLD step only. The loop stops when the largest change in
! one step falls below tol, or after max_steps steps.
!
! Grids like this one (a stencil applied to every cell, step after step) are
! the core of the shallow-water, lattice SIR and Physarum projects.
!
! Build:  gfortran -O3 -fopenmp heat_serial.f90 -o heat_serial.x
! Run:    ./heat_serial.x
!
program heat_serial
   use iso_fortran_env, only: real64
   use omp_lib, only: omp_get_wtime
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

   ! Index 0 and n+1 are the boundary. u(i,j): i runs along x (contiguous in
   ! memory), j along y; j = n+1 is the top edge.
   allocate(u(0:n+1, 0:n+1), unew(0:n+1, 0:n+1))
   u = 0.0_real64
   u(:, n+1) = t_hot
   unew = u

   t1 = omp_get_wtime()

   do step = 1, max_steps
      diff = 0.0_real64
      do j = 1, n
         do i = 1, n
            unew(i,j) = u(i,j) + r * (u(i-1,j) + u(i+1,j) + u(i,j-1) + u(i,j+1) &
                                      - 4.0_real64 * u(i,j))
            diff = max(diff, abs(unew(i,j) - u(i,j)))
         end do
      end do

      do j = 1, n
         do i = 1, n
            u(i,j) = unew(i,j)
         end do
      end do

      if (mod(step, print_every) == 0) print '(a, i6, a, es10.3)', 'step ', step, '   max change ', diff
      if (diff < tol) exit
   end do

   t2 = omp_get_wtime() 

   ! Mean temperature of the interior: how much heat has flowed in
   total = 0.0_real64
   do j = 1, n
      do i = 1, n
         total = total + u(i,j)
      end do
   end do

   t3 = omp_get_wtime()

   t_setup = (t1 - t0) + (t3 - t2)
   t_compute = t2 - t1

   print '(a, i0)',      'steps:            ', min(step, max_steps)
   print '(a, f18.12)',  'mean temperature: ', total / real(n, real64)**2
   print '(a, f8.3, a)', 'setup+post time:  ', t_setup, ' s'
   print '(a, f8.3, a)', 'compute time:     ', t_compute, ' s'
   print '(a, f8.3, a)', 'total time:       ', t_setup+t_compute, ' s'

end program heat_serial
