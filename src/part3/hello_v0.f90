program omp_hello_v0

  use omp_lib   ! OpenMP library routines

  !$omp parallel      ! start parallel region
    write(*, '(a)', advance='no') " hello "
    write(*, '(a)') " world "
  !$omp end parallel  ! end parallel region

end program omp_hello_v0
