program pi_spmd
    use iso_fortran_env, only: real64
    use omp_lib
    implicit none

    integer, parameter :: max_threads = 4
    integer, parameter :: num_steps = 1000000000

    integer :: i, j, id, numthreads
    real(real64) :: pi, full_sum, step, x
    real(real64) :: partial_sum
    real(real64) :: thread_sum(0:max_threads-1)
    real(real64) :: start_time, run_time

    step = 1.0_real64 / real(num_steps, real64)

    call omp_set_dynamic(.false.)

    do j = 1, max_threads

        call omp_set_num_threads(j)
        thread_sum = 0.0_real64

        start_time = omp_get_wtime()

        !$omp parallel private(i, id, numthreads, x, partial_sum)

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

        print '(a,i0,a,f18.15,a,f10.6,a)', &
            "Threads: ", j, &
            "  Pi: ", pi, &
            "  Time: ", run_time, " seconds"

    end do

end program pi_spmd

! Notes:
! ------
!
! Every thread executes the same code, but its thread ID determines which
! iterations it performs.
! For four threads, the iteration distribution is:
! 
! Thread 0:  0, 4,  8, 12, 16, ...
! Thread 1:  1, 5,  9, 13, 17, ...
! Thread 2:  2, 6, 10, 14, 18, ...
! Thread 3:  3, 7, 11, 15, 19, ...
!
! This is equivalent to a cyclic distribution of iterations
!
! There are two distinct mechanisms at work:
! - Parallel execution: !$omp parallel creates a team of threads that execute the same code.
! - Work distribution: The programmer explicitly distributes iterations using id and numthreads.
!
! The thread_sum array allows each thread to store its result independently, avoiding
! a race condition. Because partial sums are accumulated locally and written to the
! array only once per thread, repeated false sharing is also avoided.
!
! Change the number of threads and note that there will be the small differences in the
! resulting values of π between runs with different thread counts. Why? Because
! floating-point addition is not associative, and changing the number of threads
! changes the order of accumulation.
