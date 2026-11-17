program single_example
   use omp_lib
   implicit none

   integer, parameter :: n = 100
   real(8) :: a(n)
   integer :: i, total_threads

   !$omp parallel default(none) shared(a, total_threads) private(i)

      ! Executed by ONLY ONE thread (whichever arrives first)
      !$omp single
      total_threads = omp_get_num_threads()
      print '(a, i0, a)', "Thread ", omp_get_thread_num(), " is initializing shared setup..."
      print '(a, i0)', "Total active threads in team: ", total_threads
      !$omp end single
      ! Implicit barrier here: all threads wait until the single block finishes

      ! Executed by ALL threads in parallel
      !$omp do
      do i = 1, n
         a(i) = real(i, kind=8) * 2.0d0
      end do
      !$omp end do

      ! Executed by ONLY ONE thread to safely print a summary
      !$omp single
      print '(a, i0, a, f6.1)', "Thread ", omp_get_thread_num(), " verified a(n) = ", a(n)
      !$omp end single

   !$omp end parallel

end program single_example

