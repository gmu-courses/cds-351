! Watch the operating system hand memory to a process (Assignment 4, Exercise 4.2)
!
! allocate reserves virtual memory (VSZ grows), but the operating system
! assigns physical pages only when the program first writes to them, so RSS
! grows only as the array is touched.
!
program memory_footprint
   use iso_fortran_env, only: real64, int64
   use procinfo_mod, only: show_memory
   implicit none

   integer(int64), parameter :: n = 50000000_int64     ! 400 MB of real64
   real(real64), allocatable :: a(:)

   print '(a, f8.1, a)', 'Array size: ', 8.0 * real(n) / 2.0**20, ' MiB'
   print '(a)', '  PID   RSS(KiB)   VSZ(KiB)  COMMAND'

   call show_memory('1. program started')

   allocate(a(n))
   call show_memory('2. after allocate')

   a(1:n/2) = 1.0_real64
   call show_memory('3. after writing the first half')

   a(n/2+1:n) = 1.0_real64
   call show_memory('4. after writing the whole array')

   print '(a, es12.4)', 'Checksum: ', sum(a)

   deallocate(a)
   call show_memory('5. after deallocate')

end program memory_footprint
