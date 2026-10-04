program arr
   implicit none
   real :: a(5)
   !you can try this instead:
   !real :: a(-2:2)
   a = [1,2,3,4,5]
   call print_element(a)
   call print_element1(a)
   call print_element2(a, 2)

contains

subroutine print_element(x)
   real,intent(in) :: x(:)
   print *, x(1)
end subroutine print_element

! explicit lower bound
subroutine print_element1(x)
   real,intent(in) :: x(1:)
   print *,x(1)
end subroutine print_element1

! pass the lower-bound variable
subroutine print_element2(x, bottom)
   integer,intent(in) :: bottom
   real,intent(in) :: x(bottom:)
   print *,x(1)
 end subroutine print_element2
 
end program arr
