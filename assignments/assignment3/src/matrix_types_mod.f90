module matrix_types_mod
   implicit none
   private

   public :: matrix_data, run_summary

   type :: matrix_data
      character(len=80) :: name = ""
      real, allocatable :: values(:,:)
   end type matrix_data

   type :: run_summary
      real :: checksum = 0.0
      real :: relative_error = 0.0
      logical :: verified = .false.
   end type run_summary

end module matrix_types_mod

