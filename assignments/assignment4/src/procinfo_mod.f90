! Report the memory used by the running program (Assignment 4)
!
! show_memory asks the operating system about this process with ps:
!
!     RSS  resident set size: physical memory (RAM) the process is using now
!     VSZ  virtual size: all the virtual memory the process has reserved
!
! Both are printed in KiB. execute_command_line starts a shell, which is a
! child process of this program; inside that shell $PPID is the process ID of
! its parent, that is, of this program.
!
module procinfo_mod
   use iso_fortran_env, only: output_unit
   implicit none
   private
   public :: show_memory

contains

   subroutine show_memory(label)
      character(len=*), intent(in) :: label

      write(output_unit, '(a)') label
      flush(output_unit)                 ! print the label before ps writes
      call execute_command_line('ps -o pid=,rss=,vsz=,comm= -p $PPID')
   end subroutine show_memory

end module procinfo_mod
