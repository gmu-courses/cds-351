program parallel_ll_tasks
    use omp_lib
    implicit none

    type :: node
        integer :: val
        type(node), pointer :: next => null()
    end type node

    type(node), pointer :: head => null(), curr => null()
    integer :: i

    ! Build a sample linked list (1 to 10)
    do i = 10, 1, -1
        allocate(curr)
        curr%val = i
        curr%next => head
        head => curr
    end do

    ! Parallel traversal using OpenMP tasks
    !$omp parallel
    !$omp single
        curr => head
        do while (associated(curr))
            ! firstprivate(curr) captures the current pointer address for the task
            !$omp task firstprivate(curr)
                call process_node(curr)
            !$omp end task
            curr => curr%next
        end do
        !$omp taskwait
    !$omp end single
    !$omp end parallel

contains

    subroutine process_node(n)
        type(node), pointer, intent(in) :: n
        print '(A, I0, A, I0)', 'Node ', n%val, ' processed by thread ', omp_get_thread_num()
    end subroutine process_node

end program parallel_ll_tasks

