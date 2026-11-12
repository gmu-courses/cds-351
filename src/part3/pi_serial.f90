program pi_serial
    use iso_fortran_env, only: real64
    use omp_lib, only: omp_get_wtime
    implicit none

    integer, parameter :: num_steps = 1000000000

    integer :: i
    real(real64) :: x, sum, pi, step
    real(real64) :: start_time, run_time

    step = 1.0_real64 / real(num_steps, real64)
    sum = 0.0_real64

    start_time = omp_get_wtime()

    ! Numerical integration using the midpoint rule
    do i = 0, num_steps - 1
        x = (real(i, real64) + 0.5_real64) * step
        sum = sum + 4.0_real64 / (1.0_real64 + x*x)
    end do

    pi = step * sum

    run_time = omp_get_wtime() - start_time

    print '(a,f18.15)', "  Total Pi: ", pi
    print '(a,f10.6,a)', "  Time: ", run_time, " seconds"

end program pi_serial


