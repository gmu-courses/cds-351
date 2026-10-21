program main
    use io_mod, only : read_config, read_matrix, write_report
    use matrix_mod, only : multiply_manual, relative_error
    implicit none
    
    character(len=200) :: matrix_a_file, matrix_b_file, output_file
    real, allocatable :: a(:,:), b(:,:)
    real, allocatable :: c_manual(:,:), c_intrinsic(:,:)
    real :: error

    ! First we we read the namelist
    call read_config("config.nml", matrix_a_file, matrix_b_file, output_file)
    ! Now, we read the text files
    call read_matrix(matrix_a_file, a)
    call read_matrix(matrix_b_file, b)

    ! This check prevents issues later
    if (size(a,2) /= size(b,1)) then
        error stop "Input matrices must conformable."
    end if

    ! Matrix multiplication tests
    ! Naive triple-nested loop
    call multiply_manual(a, b, c_manual)
    ! Fortran's built-in
    c_intrinsic = matmul(a, b)
    
    error = relative_error(c_manual, c_intrinsic)
    
    call write_report(output_file, matrix_a_file, matrix_b_file, &
        a, b, c_manual, error)
    
    if (error <= 1.0e-5) then
        print *, "Validation OK"
    else
        print *, "Validationn failed. Relative error:", error
    end if
    
end program main

