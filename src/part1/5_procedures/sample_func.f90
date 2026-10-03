program sample_func
   implicit none
   
   print *, Calc_avg_v1(1.,2.,3.)
   print *, Calc_avg_v2(1.,2.,3.)

contains
    ! Note the different implementations of the SAME function:

    ! function itself is typed
    real function Calc_avg_v1 (a, b, c)
        real, intent(in) :: a, b, c
        
        Calc_avg_v1 = (a + b + c)/3.0
        
    end function Calc_avg_v1
    
    ! or result is specified (and typed)
    function Calc_avg_v2 (a, b, c) result(avg)
        real, intent(in) :: a, b, c
        real             :: avg  ! local var
        
        avg = (a + b + c)/3.0 
        
    end function Calc_avg_v2

end program sample_func
