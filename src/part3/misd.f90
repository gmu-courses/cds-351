! A MISD "simulation" using OpenMP

program misd_simulation
   use omp_lib
   implicit none

   ! The "Single Data" - a critical value fed to all instruction streams
   real :: input_data = 42.0

   ! Independent verification outputs from different instruction streams
   real :: result_stream_1, result_stream_2, result_stream_3
   logical :: system_safe

   print *, "MISD Simulation Starting..."
   print *, "Single Input Data Stream feeding into the core: ", input_data
   print *, "--------------------------------------------------------"

   ! OMP SECTIONS allows us to execute completely unique instructions 
   ! simultaneously on different threads using the exact same data variable.
   !$omp parallel sections private(system_safe)
      
      ! === INSTRUCTION STREAM 1: Standard computation ===
      !$omp section
         print *, "[Thread", omp_get_thread_num(), "] Instruction Stream 1 running Primary Algorithm..."
         result_stream_1 = (input_data * 2.5) + 10.0
      
      ! === INSTRUCTION STREAM 2: Redundant mathematical equivalent ===
      !$omp section
         print *, "[Thread", omp_get_thread_num(), "] Instruction Stream 2 running Backup Formula..."
         result_stream_2 = (input_data + input_data) + (input_data * 0.5) + 10.0
      
      ! === INSTRUCTION STREAM 3: Bitwise/Inverse safety check transformation ===
      !$omp section
         print *, "[Thread", omp_get_thread_num(), "] Instruction Stream 3 running Safety Boundary Check..."
         result_stream_3 = ((input_data + 5.0) * 5.0 / 2.0) - 2.5
         
   !$omp end parallel sections

   print *, "--------------------------------------------------------"
   print *, "Stream 1 Result: ", result_stream_1
   print *, "Stream 2 Result: ", result_stream_2
   print *, "Stream 3 Result: ", result_stream_3

   ! Voter / Comparator Logic (Classic MISD application)
   if ((result_stream_1 == result_stream_2) .and. (result_stream_2 == result_stream_3)) then
      print *, "MISD Verdict: All instruction streams agree. Data is valid and uncorrupted."
   else
      print *, "MISD Verdict: WARNING! Divergence detected. A hardware core or memory fault occurred."
   end if

end program misd_simulation
