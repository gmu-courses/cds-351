program pi_spmd
    use iso_fortran_env, only: real64
    use omp_lib
    implicit none

    integer, parameter :: max_threads = 4
    integer, parameter :: num_steps = 1000000000

    integer :: i, id, numthreads
    real(real64) :: pi, full_sum, step, x
    real(real64) :: partial_sum
    real(real64) :: thread_sum(0:max_threads-1)
    real(real64) :: start_time, run_time

    step = 1.0_real64 / real(num_steps, real64)
    thread_sum = 0.0_real64

    start_time = omp_get_wtime()

    ! Use OMP_NUM_THREADS threads, but never more than max_threads, so that
    ! every thread id fits in thread_sum. The runtime may give us fewer.
    
    !$omp parallel num_threads(min(max_threads, omp_get_max_threads()))  &
    !$omp&   private(i, id, numthreads, x, partial_sum)

    id = omp_get_thread_num()
    numthreads = omp_get_num_threads()

    partial_sum = 0.0_real64

    ! Explicit SPMD iteration distribution
    do i = id, num_steps - 1, numthreads
        x = (real(i, real64) + 0.5_real64) * step
        partial_sum = partial_sum + &
            4.0_real64 / (1.0_real64 + x*x)
    end do

    ! Each thread writes to its own array element
    ! This avoids a data race condition
    thread_sum(id) = partial_sum

    !$omp end parallel

    ! Serial accumulation after the parallel region
    full_sum = sum(thread_sum)
    pi = step * full_sum

    run_time = omp_get_wtime() - start_time

    print '(a,f18.15)', "  Total Pi: ", pi
    print '(a,f10.6,a)', "  Time: ", run_time, " seconds"

end program pi_spmd
