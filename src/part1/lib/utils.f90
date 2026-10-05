subroutine print_mat2(a,n,m)
    implicit none
    integer, intent(in) :: n,m
    real, dimension(n,m), intent(in) :: a(n,m)
    integer :: i,j

    do i = 1,n
        write(*,'("|")', advance='no')
        do j=1,m
            write(*,'(f8.3,t3)', advance='no') a(i,j)
        end do
        write(*,'("|")')
    end do
end subroutine print_mat2

subroutine print_mat1(a,n)
    implicit none

    integer, intent(in) :: n
    real, dimension(n), intent(in) :: a(n)
    integer :: i

    do i = 1,n
        write(*,'("|",f8.3,"|")', advance='yes') a(i)
    end do
end subroutine print_mat1

real function mean1(x,n)
    implicit none
    integer, intent(in) :: n
    real, dimension(n), intent(in) :: x
    mean1 = sum(x)/real(n)
end function mean1

real function vars1(x,n)
    implicit none
    integer, intent(in) :: n
    real, dimension(n), intent(in) :: x
    integer :: i
    real mean1
    external mean1
    vars1 = mean1([(x(i)**2, i=1,n)],n) - mean1(x,n)**2
end function vars1

real function stdev1(x,n)
    implicit none
    integer, intent(in) :: n
    real, dimension(n), intent(in) :: x
    real  vars1
    external vars1
    stdev1 = (vars1(x,n))**0.5
end function stdev1

real function cov_var12(x,y,n)
    implicit none
    integer, intent(in) :: n
    real, dimension(n), intent(in) :: x,y
    integer :: i
    real  mean1
    external mean1
    cov_var12 = mean1([(x(i)*y(i), i=1,n)],n) - mean1(x,n)*mean1(y,n)
end function cov_var12

real function cor_12(x,y,n)
    implicit none
    integer, intent(in) :: n
    real, dimension(n), intent(in) :: x,y
    real  cov_var12, stdev1
    external cov_var12, stdev1
    cor_12 = cov_var12(x,y,n)/stdev1(x,n)*stdev1(y,n)
end function cor_12

subroutine selection_sort(arr, n)
    ! Selection sort O(n^2)
    implicit none
    integer, intent(in) :: n
    real, dimension(n), intent(inout) :: arr
    ! locals
    integer :: i, j, iptr
    real tmp

    outer: do i = 1, n-1
        iptr = i
        inner: do j = i+1, n
            minval: if (arr(j) < arr(iptr)) then
                iptr = j
            end if minval
        end do inner
        swap: if (i /= iptr) then
            tmp = arr(i)
            arr(i)  = arr(iptr)
            arr(iptr) = tmp
        end if swap
    end do outer

end subroutine selection_sort

subroutine quicksort(arr, n)
    ! Quicksort algorithm  O(nlogn)
    implicit none
    integer, intent(in) :: n
    real, dimension(n), intent(inout) :: arr

    ! Call the recursive helper on the full array bounds
    if (n > 1) call qsort_helper(arr, 1, n)

contains

    recursive subroutine qsort_helper(a, first, last)
        real, dimension(:), intent(inout) :: a
        integer, intent(in) :: first, last
        integer :: i, j, pivot_idx
        real :: pivot, tmp

        if (first >= last) return

        ! Choose the middle element as pivot to handle semi-sorted data well
        pivot_idx = first + (last - first) / 2
        pivot = a(pivot_idx)

        i = first
        j = last

        ! Partition loop
        partition: do while (i <= j)
            do while (a(i) < pivot)
                i = i + 1
            end do
            do while (a(j) > pivot)
                j = j - 1
            end do

            if (i <= j) then
                ! Swap elements using a temporary variable
                tmp = a(i)
                a(i) = a(j)
                a(j) = tmp
                i = i + 1
                j = j - 1
            end if
        end do partition

        ! Recursively sort left and right partitions
        if (first < j) call qsort_helper(a, first, j)
        if (i < last)  call qsort_helper(a, i, last)

    end subroutine qsort_helper

end subroutine quicksort

function linspace(from, to, nums) result (array)
    ! Similar to Numpy's linspace  
    implicit none
    real, intent(in) :: from, to
    integer, intent(in) :: nums
    ! locals
    real :: array(nums) ! the result
    real :: range
    integer :: i

    range = to - from    
    if (nums == 0) return
    if (nums == 1) then
        array(1) = from
        return
    end if
    do i=1, nums
        array(i) = from + range * (i - 1) / (nums - 1)
    end do
end function linspace

