program matrix_application
   use io_mod, only : read_config, read_matrix, write_report
   use matrix_mod, only : multiply_manual, summarize_run
   use matrix_types_mod, only : matrix_data, run_summary
   implicit none

   character(len=200) :: matrix_a_file, matrix_b_file, output_file
   type(matrix_data) :: a, b, c_manual, c_intrinsic
   type(run_summary) :: summary

   call read_config("config.nml", matrix_a_file, matrix_b_file, output_file)
   call read_matrix(matrix_a_file, a)
   call read_matrix(matrix_b_file, b)

   if (size(a%values,2) /= size(b%values,1)) then
      error stop "Input matrices are not conformable for multiplication."
   end if

   call multiply_manual(a, b, c_manual)

   c_intrinsic%name = "MATMUL reference"
   c_intrinsic%values = matmul(a%values, b%values)

   call summarize_run(c_manual, c_intrinsic, summary)
   call write_report(output_file, a, b, c_manual, summary)

   if (summary%verified) then
      print *, "Validation succeeded. Relative error:", summary%relative_error
   else
      print *, "Validation failed. Relative error:", summary%relative_error
   end if

end program matrix_application

