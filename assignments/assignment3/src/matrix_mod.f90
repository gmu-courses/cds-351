module matrix_mod
   use matrix_types_mod, only : matrix_data, run_summary
   implicit none
   private

   public :: multiply_manual, summarize_run

contains

   subroutine multiply_manual(a, b, c)
      type(matrix_data), intent(in) :: a, b
      type(matrix_data), intent(out) :: c

      integer :: i, j, k
      integer :: alloc_stat
      character(len=200) :: message

      if (size(a%values,2) /= size(b%values,1)) then
         error stop "multiply_manual: incompatible matrix shapes"
      end if

      c%name = trim(a%name) // " x " // trim(b%name)
      allocate(c%values(size(a%values,1), size(b%values,2)), &
               stat=alloc_stat, errmsg=message)
      if (alloc_stat /= 0) then
         error stop "multiply_manual: allocation failed: " // trim(message)
      end if

      c%values = 0.0

      do j = 1, size(b%values,2)
         do k = 1, size(a%values,2)
            do i = 1, size(a%values,1)
               c%values(i,j) = c%values(i,j) + &
                               a%values(i,k) * b%values(k,j)
            end do
         end do
      end do
   end subroutine multiply_manual


   subroutine summarize_run(manual, reference, summary)
      type(matrix_data), intent(in) :: manual, reference
      type(run_summary), intent(out) :: summary

      summary%checksum = sum(manual%values)
      summary%relative_error = relative_error(manual%values, reference%values)
      summary%verified = summary%relative_error <= 1.0e-5
   end subroutine summarize_run


   pure function relative_error(computed, reference) result(error)
      real, intent(in) :: computed(:,:), reference(:,:)
      real :: error
      real :: absolute_error, reference_scale

      if (any(shape(computed) /= shape(reference))) then
         error = huge(0.0)
         return
      end if

      absolute_error = maxval(abs(computed - reference))
      reference_scale = maxval(abs(reference))

      if (reference_scale > 0.0) then
         error = absolute_error / reference_scale
      else
         error = absolute_error
      end if
   end function relative_error

end module matrix_mod

