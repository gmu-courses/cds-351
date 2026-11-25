! Heat diffusion: heat_do.f90 without the copy, and with parallel first touch
!
! heat_do.f90 is limited by memory bandwidth, not by arithmetic: at n = 10000
! each array is 800 MB, far larger than any cache. Every step of heat_do
! streams through memory twice:
!
!   update   read u,    write unew     1.6 GB
!   copy     read unew, write u        1.6 GB    <- no new information
!
! Two changes:
!
!   1. No copy. The two arrays swap roles every step: odd steps compute b
!      from a, even steps compute a from b. Memory traffic per step is halved.
!      The update is a subroutine, so we can pass the arrays in either order.
!      (Fortran assumes two dummy arguments do not overlap, so the compiler
!      vectorizes the loop without run-time checks.)
!
!   2. Parallel first touch. Memory pages are placed in the memory of the
!      socket whose thread first writes them. Initializing with the same
!      parallel loop as the update puts each thread's columns near that
!      thread. This does nothing on a laptop (one memory) but matters on
!      multi-socket cluster nodes.
!
! Build:  gfortran -O3 -fopenmp heat_swap.f90 -o heat_swap.x
! Run:    OMP_NUM_THREADS=8 OMP_PROC_BIND=close OMP_PLACES=cores ./heat_swap.x
!
program heat_swap
   use iso_fortran_env, only: real64
   use omp_lib, only: omp_get_wtime, omp_get_max_threads
   implicit none

   integer, parameter :: n = 10000             ! interior cells per side
   integer, parameter :: max_steps = 1000
   integer, parameter :: print_every = 100
   real(real64), parameter :: r = 0.2_real64
   real(real64), parameter :: tol = 1.0e-2_real64
   real(real64), parameter :: t_hot = 100.0_real64

   real(real64), allocatable :: a(:,:), b(:,:)
   real(real64) :: diff, total
   real(real64) :: t0, t1, t2, t3, t_compute, t_setup
   integer :: i, j, step

   t0 = omp_get_wtime()

   allocate(a(0:n+1, 0:n+1), b(0:n+1, 0:n+1))

   ! First touch: each thread zeroes the columns it will update later
   !$omp parallel do default(none) shared(a, b) private(i, j)
   do j = 0, n+1
      do i = 0, n+1
         a(i,j) = 0.0_real64
         b(i,j) = 0.0_real64
      end do
   end do
   !$omp end parallel do
   a(:, n+1) = t_hot           ! the boundary is never updated, so both
   b(:, n+1) = t_hot           ! arrays need it

   t1 = omp_get_wtime()

   do step = 1, max_steps
      if (mod(step, 2) == 1) then
         call update(a, b, diff)     ! a is the old step, b the new one
      else
         call update(b, a, diff)
      end if

      if (mod(step, print_every) == 0) print '(a, i6, a, es10.3)', 'step ', step, '   max change ', diff
      if (diff < tol) exit
   end do

   t2 = omp_get_wtime()

   ! Mean temperature of the last step: in b after an odd step, in a after an even one
   step = min(step, max_steps)
   if (mod(step, 2) == 1) then
      total = sum_interior(b)
   else
      total = sum_interior(a)
   end if

   t3 = omp_get_wtime()

   t_setup = (t1 - t0) + (t3 - t2)
   t_compute = t2 - t1

   print '(a, i0)',      'threads:          ', omp_get_max_threads()
   print '(a, i0)',      'steps:            ', step
   print '(a, f18.12)',  'mean temperature: ', total / real(n, real64)**2
   print '(a, f8.3, a)', 'setup+post time:  ', t_setup, ' s'
   print '(a, f8.3, a)', 'compute time:     ', t_compute, ' s'
   print '(a, f8.3, a)', 'total time:       ', t_setup+t_compute, ' s'

contains

   ! One time step: unew from u, and the largest change
   subroutine update(u, unew, diff)
      real(real64), intent(in)  :: u(0:n+1, 0:n+1)
      real(real64), intent(inout) :: unew(0:n+1, 0:n+1)   ! inout: keeps the boundary
      real(real64), intent(out) :: diff
      integer :: i, j

      diff = 0.0_real64
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
   end subroutine update

   function sum_interior(u) result(total)
      real(real64), intent(in) :: u(0:n+1, 0:n+1)
      real(real64) :: total
      integer :: i, j

      total = 0.0_real64
      !$omp parallel do default(none) shared(u) private(i, j) reduction(+:total)
      do j = 1, n
         do i = 1, n
            total = total + u(i,j)
         end do
      end do
      !$omp end parallel do
   end function sum_interior

end program heat_swap
