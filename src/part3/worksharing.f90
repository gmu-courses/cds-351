! The computation has two phases:
!
!   phase 1:  a(i) = f(i)            every iteration is independent
!   phase 2:  b(i) = a(n+1-i)        reads a value written by ANOTHER thread
!
! Phase 2 may start only when all of phase 1 is finished.
!
program worksharing
    use iso_fortran_env, only: real64
    use omp_lib, only: omp_get_max_threads
    implicit none

    integer, parameter :: n = 20000
    real(real64) :: a(n), b(n)
    integer :: i

    print '(a, i0)', 'threads: ', omp_get_max_threads()

    a = 0.0_real64
    !$omp parallel
    !$omp do
    do i = 1, n
        a(i) = f(i)
    end do
    !$omp end do     ! implicit barrier: all threads wait here
    !$omp do
    do i = 1, n
        b(i) = a(n + 1 - i)
    end do
    !$omp end do
    !$omp end parallel
    print '(a, i0, a, i0)', 'with barrier:    wrong values of b: ', count_wrong(b), ' of ', n

contains

    ! Note: f(i) takes longer as i increases, therefore threads handling 
    ! higher iterations of the first loop finish much later than threads
    ! handling lower iterations.
    pure function f(i) result(y)
        integer, intent(in) :: i
        real(real64) :: y
        integer :: k

        y = 1.0_real64
        do k = 1, i
            y = y + 1.0_real64 / real(k, real64)**2
        end do
    end function f

    integer function count_wrong(b)
        real(real64), intent(in) :: b(:)
        integer :: i

        count_wrong = 0
        do i = 1, size(b)
            if (b(i) /= f(size(b) + 1 - i)) count_wrong = count_wrong + 1
        end do
    end function count_wrong

end program worksharing
