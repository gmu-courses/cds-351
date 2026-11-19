program expose_race_demo
    use omp_lib
    implicit none

    integer, parameter :: n = 1000000
    real, allocatable :: data(:)
    real :: global_sum, local_sum
    integer :: i, trial, failures

    allocate(data(n))
    data = 1.0
    failures = 0

    do trial = 1, 100
        global_sum = 0.0

        !$omp parallel default(none) shared(global_sum, data) &
        !$omp& private(i, local_sum)
        local_sum = 0.0
        !$omp do
        do i = 1, n
            local_sum = local_sum + data(i)
        end do
        !$omp end do nowait  ! no implicit barrier before the unprotected write
        
        ! Unprotected race condition
        global_sum = global_sum + local_sum
        
        !$omp end parallel

        if (abs(global_sum - real(n)) > 1.0) then
            failures = failures + 1
            if (failures <= 5) print '(a, i3, a, f12.1)', &
                "Trial ", trial, " FAILED! Global sum = ", global_sum
        end if
    end do

    print '(a, i3, a)', "Total corrupted runs out of 100: ", failures, " / 100"
    deallocate(data)
end program expose_race_demo


