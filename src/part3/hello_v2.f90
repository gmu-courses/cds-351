program omp_hello_v2
    use omp_lib 
    implicit none 
    integer :: id
    
    print *, "Start"
    !$omp parallel private(id)
    
    id = omp_get_thread_num()
    print *, "Hello from thread", id
    
    !$omp end parallel
    print *, "Done"

end program omp_hello_v2
