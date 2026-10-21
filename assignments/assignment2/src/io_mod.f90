module io_mod
   implicit none
   private

   public :: read_config, read_matrix, write_report

contains

   subroutine read_config(filename, matrix_a_file, matrix_b_file, output_file) !a_path, b_path, report_path)
      character(len=*), intent(in) :: filename
      character(len=*), intent(out) :: matrix_a_file, matrix_b_file, output_file !a_path, b_path, report_path

      integer :: unit, ios
      character(len=200) :: message
      !character(len=200) :: matrix_a_file, matrix_b_file, output_file
      namelist /config/ matrix_a_file, matrix_b_file, output_file

      ! These are defaults
      matrix_a_file = "data/matrix_a.txt"
      matrix_b_file = "data/matrix_b.txt"
      output_file = "output/report.txt"

      open(newunit=unit, file=filename, status="old", action="read", &
           iostat=ios, iomsg=message)
      if (ios /= 0) then
         error stop "Could not open configuration file: " // trim(message)
      end if

      ! Note how we read a namelist, the format part is nml=config
      read(unit, nml=config, iostat=ios, iomsg=message)
      if (ios /= 0) then
         close(unit)
         error stop "Could not read configuration file: " // trim(message)
      end if

      close(unit, iostat=ios, iomsg=message)
      if (ios /= 0) then
         error stop "Could not close configuration file: " // trim(message)
      end if

      ! Not really needed but...
      !a_path = trim(matrix_a_file)
      !b_path = trim(matrix_b_file)
      !report_path = trim(output_file)
   end subroutine read_config


   subroutine read_matrix(filename, matrix)
      character(len=*), intent(in) :: filename
      real, allocatable, intent(out) :: matrix(:,:)

      integer :: unit, ios, nrows, ncols, alloc_stat
      character(len=200) :: message  ! to capture error messages

      open(newunit=unit, file=filename, status="old", action="read", &
           iostat=ios, iomsg=message)
      if (ios /= 0) then
         error stop "Could not open matrix file: " // trim(message)
      end if

      ! Read matrix sizes (first line in the file)
      read(unit, *, iostat=ios, iomsg=message) nrows, ncols
      if (ios /= 0) then
         close(unit)  ! close it because it's already open
         error stop "Could not read matrix dimensions: " // trim(message)
      end if

      ! Let's check for bad inputs
      if (nrows <= 0 .or. ncols <= 0) then
         close(unit)
         error stop "Matrix dimensions must be positive."
      end if

      allocate(matrix(nrows,ncols), stat=alloc_stat, errmsg=message)
      if (alloc_stat /= 0) then
         close(unit)
         error stop "Could not allocate matrix: " // trim(message)
      end if

      ! Once matrix size is known, it can be read in one read()
      read(unit, *, iostat=ios, iomsg=message) matrix
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


   subroutine write_report(filename, a_file, b_file, a, b, c, error)
      character(len=*), intent(in) :: filename, a_file, b_file
      real, intent(in) :: a(:,:), b(:,:), c(:,:)
      real, intent(in) :: error

      integer :: unit, ios
      character(len=200) :: message

      open(newunit=unit, file=filename, status="replace", action="write", &
           iostat=ios, iomsg=message)
      if (ios /= 0) then
         error stop "Could not open report file: " // trim(message)
      end if

      write(unit, '(A,A)') "Matrix A file: ", trim(a_file)
      write(unit, '(A,A)') "Matrix B file: ", trim(b_file)
      write(unit, '(A,2(I0,1X))') "Shape of A: ", shape(a)
      write(unit, '(A,2(I0,1X))') "Shape of B: ", shape(b)
      write(unit, '(A,2(I0,1X))') "Shape of C: ", shape(c)
      write(unit, '(A,ES14.6)') "Sum of C: ", sum(c)
      write(unit, '(A,ES14.6)') "Relative error: ", error

      close(unit, iostat=ios, iomsg=message)
      if (ios /= 0) then
         error stop "Could not close report file: " // trim(message)
      end if
   end subroutine write_report

end module io_mod

