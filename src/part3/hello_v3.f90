subroutine greet()
    use omp_lib
    implicit none
    integer ::id
    id = omp_get_thread_num()
    print *, "Hello from thread", id 
end subroutine greet

program omp_hello_v3
    implicit none
    print *, "Start:"
    !$omp parallel
    
    call greet()
    
    !$omp end parallel
    print *, "Done"
end program omp_hello_v3

