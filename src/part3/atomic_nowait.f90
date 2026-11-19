program atomic_nowait_demo
    use omp_lib
    implicit none

    integer, parameter :: n = 1000000
    real, allocatable :: data(:)
    real :: global_sum, local_sum
    integer :: i

    allocate(data(n))
    data = 1.0          ! Expected sum is 1,000,000.0
    global_sum = 0.0

    !$omp parallel default(none) shared(global_sum, data) &
    !$omp& private(i, local_sum)
    local_sum = 0.0
    
    !$omp do
    do i = 1, n
        local_sum = local_sum + data(i)
    end do
    !$omp end do nowait ! no implicit barrier before the unprotected write
    
    ! Unprotected race condition
    global_sum = global_sum + local_sum

    !$omp end parallel

    print *, "Global sum:", global_sum
    deallocate(data)
end program atomic_nowait_demo

! What happens in this case:
!
! !$omp atomic
! global_sum = global_sum + complex_function(shared_array)
! atomic, only the update to the target variable (x) is atomic
! complex_function(shared_array) runs in parallel without any lock
