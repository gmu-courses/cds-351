module matrix_mod
   implicit none
   private
   public multiply_manual
   public relative_error

contains

   subroutine multiply_manual(a, b, c)
      real, intent(in) :: a(:,:), b(:,:)
      real, allocatable, intent(out) :: c(:,:)
      ! local variables
      integer :: i, j, k
      integer :: alloc_stat
      character(len=200) :: message

      ! Here we use size() because matrices are not square
      allocate(c(size(a,1), size(b,2)), stat=alloc_stat, errmsg=message)
      if (alloc_stat /= 0) then
         error stop "multiply_manual: allocation failed: " // trim(message)
      end if

      c = 0.0

      ! Using naive j-i-k ordering 
      do j = 1, size(b,2)
          do i = 1, size(a,1)
              do k = 1, size(a,2)
                  c(i,j) = c(i,j) + a(i,k) * b(k,j)
            end do
         end do
      end do
   end subroutine multiply_manual


   pure function relative_error(computed, reference) result(error)
      real, intent(in) :: computed(:,:), reference(:,:)
      real :: error
      ! local variables
      real :: absolute_error, reference_scale

      absolute_error = maxval(abs(computed - reference))
      reference_scale = maxval(abs(reference))

      if (reference_scale > 0.0) then
         error = absolute_error / reference_scale
      else
         error = absolute_error
      end if
   end function relative_error

end module matrix_mod

