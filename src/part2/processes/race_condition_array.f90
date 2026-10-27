program array_race_condition
    implicit none
    integer, parameter :: N = 1000000
    integer :: i
    integer :: total_sum
    integer :: arr(n)

    total_sum = 0
    arr(:) = 0

    ! Imagine we slice this loop across 4 threads.
    ! Thread 1 does 1 to 250,000; Thread 2 does 250,001 to 500,000, etc.
    do i = 1, N
        ! RACE CONDITION: Multiple threads update arr(idx) at the same time
        arr(mod(i, n) + 1) = arr(mod(i, n) + 1) + 1
    end do

    print *, "Final sum:", sum(arr)
end program array_race_condition

