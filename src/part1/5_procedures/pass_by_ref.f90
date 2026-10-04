! Optional example
program foo
   use iso_c_binding ! to use modern, standard-compliant C_LOC
   implicit none
   
   real, target :: a     ! To use C_LOC(), variables must have 
   integer, target :: n  ! the TARGET attribute

   a = 1.0
   n = 3

   ! transfer(..., 1_c_intptr_t) is used here purely to convert 
   ! the standard C pointer type into a printable integer address
   print *, 'loc(a): ', transfer(c_loc(a), 1_c_intptr_t)
   print *, 'loc(n): ', transfer(c_loc(n), 1_c_intptr_t)
   call sub1(a, n)

contains

   subroutine sub1(x, i)
     real, target, intent(inout) :: x 
     integer, target, intent(in) :: i

     print *, 'loc(x): ', transfer(c_loc(x), 1_c_intptr_t)
     print *, 'loc(i): ', transfer(c_loc(i), 1_c_intptr_t)
   end subroutine sub1
end program foo

