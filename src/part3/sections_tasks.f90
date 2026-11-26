program sections_vs_tasks_demo
    use omp_lib
    implicit none

    integer, parameter :: num_files = 6
    integer :: i

    ! !$omp sections (Fixed, heterogeneous blocks known at compile time)
    ! Best when you have a small, fixed set of different setup/physics routines.
    print '(a)', "=== Part 1: !$omp sections (Fixed Functional Parallelism) ==="

    !$omp parallel default(none)
        !$omp sections

            !$omp section
            print '(a, i2)', "  [Section 1] Initializing atmosphere grid on thread ", &
                             omp_get_thread_num()

            !$omp section
            print '(a, i2)', "  [Section 2] Initializing ocean grid      on thread ", &
                             omp_get_thread_num()

            !$omp section
            print '(a, i2)', "  [Section 3] Loading boundary tables      on thread ", &
                             omp_get_thread_num()

        !$omp end sections
    !$omp end parallel

    ! !$omp task (Dynamic tasks generated at runtime)
    ! Best when the number of jobs is determined at runtime (e.g., processing N
    ! variable-length files, traversing a tree, or irregular work queues).
    print '(a)', ""
    print '(a)', "=== Part 2: !$omp task (Dynamic Task Pool) ==="

    !$omp parallel default(none) private(i)
        ! One thread acts as the "producer" generating tasks, while all threads
        ! in the team immediately pull and execute tasks from the pool.
        !$omp single
        do i = 1, num_files
            !$omp task firstprivate(i)
            print '(a, i2, a, i2)', "  [Task ", i, "] Processed dynamically by thread ", &
                                    omp_get_thread_num()
            !$omp end task
        end do
        !$omp taskwait   ! Wait for all generated tasks to finish before proceeding
        !$omp end single
    !$omp end parallel

end program sections_vs_tasks_demo
