program parallel_do_example
    use omp_lib
    implicit none

    integer, parameter :: n = 1000000
    integer :: i
    real(8), dimension(n) :: a, b
    real(8) :: total_sum

    total_sum = 0.0d0

    ! Distribute loop iterations across threads
    !$omp parallel do default(none) shared(a, b) private(i) reduction(+:total_sum)
    do i = 1, n
        a(i) = real(i, kind=8) * 0.5d0
        b(i) = 2.0d0
        total_sum = total_sum + (a(i) * b(i))
    end do
    !$omp end parallel do

    print *, "Total sum:", total_sum
end program parallel_do_example
