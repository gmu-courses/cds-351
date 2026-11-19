program collapse_demo
    use iso_fortran_env, only: real64
    use omp_lib, only: omp_get_wtime, omp_get_max_threads
    implicit none

    ! Notice NJ is small while NI is large!
    integer, parameter :: NI = 2000000
    integer, parameter :: NJ = 4
    real(real64), allocatable :: A(:,:)
    real(real64) :: t0, t_no_collapse, t_collapse
    integer :: i, j

    allocate(A(NI, NJ))
    A = 0.0_real64

    ! WITHOUT collapse(2): Only parallelizes the outer loop (j = 1..4)
    ! If you run with 8 or 16 threads, only 4 threads work and the rest sit idle!
    t0 = omp_get_wtime()
    !$omp parallel do default(none) shared(A) private(i, j)
    do j = 1, NJ
        do i = 1, NI
            A(i, j) = compute(i, j)
        end do
    end do
    !$omp end parallel do
    t_no_collapse = omp_get_wtime() - t0

    ! WITH collapse(2): Flattens (j, i) into a single 1D iteration space
    ! Total iterations = NJ * NI = 8,000,000 -> evenly distributed across ALL threads!
    t0 = omp_get_wtime()
    !$omp parallel do collapse(2) default(none) shared(A) private(i, j)
    do j = 1, NJ
        do i = 1, NI
            A(i, j) = compute(i, j)
        end do
    end do
    !$omp end parallel do
    t_collapse = omp_get_wtime() - t0

    print '(a, i2, a, i0, a, i0)', "Threads: ", omp_get_max_threads(), &
                                  " | Grid: ", NI, " x ", NJ
    print '(a, f8.4, a)', "Without collapse(2): ", t_no_collapse, " s"
    print '(a, f8.4, a)', "With    collapse(2): ", t_collapse,    " s"
    print '(a, es12.4)',  "Checksum:            ", sum(A)

    deallocate(A)

contains

    pure real(real64) function compute(i, j)
        integer, intent(in) :: i, j
        real(real64) :: x
        x = real(i + j, real64) * 1.0e-6_real64
        compute = sin(x) * cos(x) + sqrt(x * x + 1.0_real64)
    end function compute

end program collapse_demo
