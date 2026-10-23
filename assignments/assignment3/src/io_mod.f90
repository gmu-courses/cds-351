module io_mod
   use matrix_types_mod, only : matrix_data, run_summary
   implicit none
   private

   public :: read_config, read_matrix, write_report

contains

   subroutine read_config(filename, a_path, b_path, report_path)
      character(len=*), intent(in) :: filename
      character(len=*), intent(out) :: a_path, b_path, report_path

      integer :: unit, ios
      character(len=200) :: message
      character(len=200) :: matrix_a_file, matrix_b_file, output_file
      namelist /config/ matrix_a_file, matrix_b_file, output_file

      matrix_a_file = "data/matrix_a.txt"
      matrix_b_file = "data/matrix_b.txt"
      output_file = "output/report.txt"

      open(newunit=unit, file=filename, status="old", action="read", &
           iostat=ios, iomsg=message)
      if (ios /= 0) then
         error stop "Could not open configuration file: " // trim(message)
      end if

      read(unit, nml=config, iostat=ios, iomsg=message)
      if (ios /= 0) then
         close(unit)
         error stop "Could not read configuration file: " // trim(message)
      end if

      close(unit, iostat=ios, iomsg=message)
      if (ios /= 0) then
         error stop "Could not close configuration file: " // trim(message)
      end if

      a_path = trim(matrix_a_file)
      b_path = trim(matrix_b_file)
      report_path = trim(output_file)
   end subroutine read_config


   subroutine read_matrix(filename, matrix)
      character(len=*), intent(in) :: filename
      type(matrix_data), intent(out) :: matrix

      integer :: unit, ios, nrows, ncols, alloc_stat
      character(len=200) :: message

      matrix%name = filename

      open(newunit=unit, file=filename, status="old", action="read", &
           iostat=ios, iomsg=message)
      if (ios /= 0) then
         error stop "Could not open matrix file: " // trim(message)
      end if

      read(unit, *, iostat=ios, iomsg=message) nrows, ncols
      if (ios /= 0) then
         close(unit)
         error stop "Could not read matrix dimensions: " // trim(message)
      end if

      if (nrows <= 0 .or. ncols <= 0) then
         close(unit)
         error stop "Matrix dimensions must be positive."
      end if

      allocate(matrix%values(nrows,ncols), stat=alloc_stat, errmsg=message)
      if (alloc_stat /= 0) then
         close(unit)
         error stop "Could not allocate matrix: " // trim(message)
      end if

      read(unit, *, iostat=ios, iomsg=message) matrix%values
      if (ios < 0) then
         close(unit)
         error stop "Matrix file ended before all values were read."
      else if (ios > 0) then
         close(unit)
         error stop "Invalid matrix value: " // trim(message)
      end if

      close(unit, iostat=ios, iomsg=message)
      if (ios /= 0) then
         error stop "Could not close matrix file: " // trim(message)
      end if
   end subroutine read_matrix


   subroutine write_report(filename, a, b, product, summary)
      character(len=*), intent(in) :: filename
      type(matrix_data), intent(in) :: a, b, product
      type(run_summary), intent(in) :: summary

      integer :: unit, ios
      character(len=200) :: message

      open(newunit=unit, file=filename, status="replace", action="write", &
           iostat=ios, iomsg=message)
      if (ios /= 0) then
         error stop "Could not open report file: " // trim(message)
      end if

      write(unit, '(A,A)') "Matrix A: ", trim(a%name)
      write(unit, '(A,A)') "Matrix B: ", trim(b%name)
      write(unit, '(A,2(I0,1X))') "Shape of A: ", shape(a%values)
      write(unit, '(A,2(I0,1X))') "Shape of B: ", shape(b%values)
      write(unit, '(A,2(I0,1X))') "Shape of product: ", shape(product%values)
      write(unit, '(A,ES14.6)') "Checksum: ", summary%checksum
      write(unit, '(A,ES14.6)') "Relative error: ", summary%relative_error
      write(unit, '(A,L1)') "Verified: ", summary%verified

      close(unit, iostat=ios, iomsg=message)
      if (ios /= 0) then
         error stop "Could not close report file: " // trim(message)
      end if
   end subroutine write_report

end module io_mod

