program mimd_example
   use omp_lib
   implicit none

   integer, parameter :: ARRAY_SIZE = 1000
   integer, dimension(ARRAY_SIZE) :: data
   integer :: total_sum
   integer :: i, thread_id, num_threads

   ! Initialize data with some sample values
   do i = 1, ARRAY_SIZE
      data(i) = i
   end do

   total_sum = 0

   ! $OMP PARALLEL DO splits the loop across multiple autonomous CPU cores (MIMD).
   ! The reduction(+:total_sum) clause prevents race conditions by giving each 
   ! thread its own independent local tracker, combining them at the end.
   !$omp parallel do reduction(+:total_sum) private(thread_id)
   do i = 1, ARRAY_SIZE
      ! (Optional) Print thread mapping to visually prove it is MIMD
      if (mod(i, 250) == 1) then
         thread_id = omp_get_thread_num()
         num_threads = omp_get_num_threads()
         print *, "Core/Thread ", thread_id, " of ", num_threads, &
                  " is independently processing index ", i
      end if

      total_sum = total_sum + data(i)
   end do
   !$omp end parallel do

   print *, "MIMD Total Sum: ", total_sum

end program mimd_example
