! Estimating pi with schedule(runtime): one executable, every schedule
!
! The same loop as pi_reduction.f90, with two changes:
!   - default(none), so every variable must be listed (num_steps is a
!     parameter, so it is exempt);
!   - schedule(runtime), so the schedule is read from OMP_SCHEDULE when the
!     program starts. No recompiling is needed to try a new schedule.
!
! Every iteration costs the same, so static should win. dynamic,1 hands out
! one iteration at a time and pays the scheduling overhead a billion times.
!
! Always set OMP_SCHEDULE. If it is unset, gfortran uses dynamic,1 for
! schedule(runtime), the slowest choice here.
!
! Build:  gfortran -O3 -fopenmp pi_schedule.f90 -o pi_schedule.x
! Run:    OMP_NUM_THREADS=4 OMP_SCHEDULE=dynamic,1000 ./pi_schedule.x
!
! Sweep:
!   for s in static dynamic,1 dynamic,1000 guided; do
!     for p in 1 2 4 8; do
!       OMP_NUM_THREADS=$p OMP_SCHEDULE=$s ./pi_schedule.x
!     done
!   done
!
program pi_schedule
    use iso_fortran_env, only: real64
    use omp_lib
    implicit none

    integer, parameter :: num_steps = 1000000000

    integer :: i, chunk
    integer(omp_sched_kind) :: kind
    real(real64) :: x, sum, pi, step
    real(real64) :: start_time, run_time
    character(len=8) :: kind_name

    step = 1.0_real64 / real(num_steps, real64)
    sum = 0.0_real64

    start_time = omp_get_wtime()

    !$omp parallel do default(none) private(i, x) shared(step) &
    !$omp&   schedule(runtime) reduction(+:sum)
    do i = 0, num_steps - 1
        x = (real(i, real64) + 0.5_real64) * step
        sum = sum + 4.0_real64 / (1.0_real64 + x*x)
    end do
    !$omp end parallel do

    pi = step * sum

    run_time = omp_get_wtime() - start_time

    ! Report the schedule actually used (from OMP_SCHEDULE, or the default)
    call omp_get_schedule(kind, chunk)
    select case (kind)
    case (omp_sched_static)
        kind_name = 'static'
    case (omp_sched_dynamic)
        kind_name = 'dynamic'
    case (omp_sched_guided)
        kind_name = 'guided'
    case default
        kind_name = 'auto'
    end select

    ! One line per run, so a sweep prints a table
    print '(a8, a, i6, a, i3, a, f18.15, a, f9.4, a)', kind_name, ' chunk', chunk, &
        '   threads', omp_get_max_threads(), '   pi', pi, '   time', run_time, ' s'

end program pi_schedule
