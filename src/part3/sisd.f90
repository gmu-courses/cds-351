program sisd_example
   implicit none
   integer, dimension(5) :: data = [1, 2, 3, 4, 5]
   integer :: sum_val
   integer :: i

   sum_val = 0

   ! Sequential loop demonstrating SISD
   do i = 1, size(data)
      sum_val = sum_val + data(i)
   end do

   print *, "SISD Sum: ", sum_val

end program sisd_example
