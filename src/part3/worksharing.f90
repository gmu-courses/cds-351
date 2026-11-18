program worksharing
    use iso_fortran_env, only: real64
    use omp_lib, only: omp_get_wtime
    implicit none

    integer, parameter :: n = 1000000000
    real(real64), allocatable :: a(:)
    integer :: i
    real(real64) :: start_time, run_time

    allocate(a(n))
    a = 0.0_real64

    start_time = omp_get_wtime()
    do i = 1, n
        a(i) = a(i) + 1.0_real64
    end do

    run_time = omp_get_wtime() - start_time
    print '(a,f10.6,a)', "  Time: ", run_time, " seconds"

    deallocate(a)
end program worksharing
