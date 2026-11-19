! Compute-bound benchmark
program worksharing_compute
    use iso_fortran_env, only: real64
    use omp_lib, only: omp_get_wtime, omp_get_max_threads
    implicit none

    integer, parameter :: n = 10000000  ! 80 MB array (avoids swap/compression)
    integer, parameter :: work_iters = 50   ! Increases FLOPs per byte loaded
    real(real64), allocatable :: a(:)
    real(real64) :: val
    integer :: i, k
    real(real64) :: start_time, run_time

    allocate(a(n))
    a = 1.0_real64

    start_time = omp_get_wtime()

    !$omp parallel do default(none) shared(a) private(i, k, val)
    do i = 1, n
        val = a(i)
        do k = 1, work_iters
            val = sqrt(val * val + 1.0_real64) + sin(val) * cos(val)
        end do
        a(i) = val
    end do
    !$omp end parallel do

    run_time = omp_get_wtime() - start_time
    print '(a, i2, a, f10.6, a)', "Threads: ", omp_get_max_threads(), &
                                  " | Time: ", run_time, " seconds"

    deallocate(a)
end program worksharing_compute

