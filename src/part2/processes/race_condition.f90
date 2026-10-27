program race_condition
    implicit none
    integer, parameter :: N = 1000000
    integer :: i
    integer :: total_sum

    total_sum = 0

    ! Imagine we slice this loop across 4 threads. 
    ! Thread 1 does 1 to 250,000; Thread 2 does 250,001 to 500,000, etc.
    do i = 1, N
        ! RACE CONDITION: All threads try to read 'total_sum', add 1, 
        ! and write it back at the exact same physical memory address.
        total_sum = total_sum + 1
    end do

    print *, "Expected Sum:", N
    print *, "Calculated Sum:", total_sum
end program race_condition
