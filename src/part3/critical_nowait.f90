program critical_nowait_demo
    use omp_lib
    implicit none

    integer, parameter :: n = 1000000
    real, allocatable :: data(:)
    real :: global_sum, local_sum
    integer :: i

    allocate(data(n))
    data = 1.0          ! Expected sum is 1,000,000.0
    global_sum = 0.0

    !$omp parallel default(none) shared(global_sum, data) private(i, local_sum)
        local_sum = 0.0

        !$omp do
        do i = 1, n
            local_sum = local_sum + data(i)
        end do
        !$omp end do nowait

        global_sum = global_sum + local_sum

    !$omp end parallel

    print *, "Global sum:", global_sum
    deallocate(data)
end program critical_nowait_demo

