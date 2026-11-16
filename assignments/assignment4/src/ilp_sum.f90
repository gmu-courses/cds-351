! Summing with 1, 2, 4, and 8 accumulators (Assignment 4, Exercise 4.5)
!
! Each sum is computed twice: once on a small array that stays in L1 cache,
! and once on a large array that must stream from main memory. Every case
! performs the same number of additions, about 2**28.
! Output is CSV: case, accumulators, seconds, ns per addition, sum.
!
program ilp_sum
   use iso_fortran_env, only: real64, int64, compiler_options
   implicit none

   integer(int64), parameter :: total_adds = 2_int64**28

   print '(2a)', '# compiler options: ', compiler_options()
   print '(a)', 'case,accumulators,seconds,ns_per_add,sum'
   call time_sums('cache', 2**11)               ! 16 KiB
   call time_sums('memory', 2**25)              ! 256 MiB

contains

   subroutine time_sums(label, n)
      character(len=*), intent(in) :: label
      integer, intent(in) :: n
      real(real64), allocatable :: x(:)
      real(real64) :: nadds, s, s1, s2, s3, s4, s5, s6, s7, s8
      integer(int64) :: t1, t2, rate
      integer :: i, r, reps

      allocate(x(n))
      call random_number(x)
      reps = int(total_adds / n)
      nadds = real(n, real64) * reps

      ! One accumulator: one dependency chain
      call system_clock(t1, rate)
      s = 0.0_real64
      do r = 1, reps
         do i = 1, n
            s = s + x(i)
         end do
      end do
      call system_clock(t2)
      call report(label, 1, elapsed(t1, t2, rate), nadds, s)

      ! Two accumulators
      call system_clock(t1)
      s1 = 0.0_real64
      s2 = 0.0_real64
      do r = 1, reps
         do i = 1, n, 2
            s1 = s1 + x(i)
            s2 = s2 + x(i+1)
         end do
      end do
      call system_clock(t2)
      call report(label, 2, elapsed(t1, t2, rate), nadds, s1 + s2)

      ! Four accumulators
      call system_clock(t1)
      s1 = 0.0_real64
      s2 = 0.0_real64
      s3 = 0.0_real64
      s4 = 0.0_real64
      do r = 1, reps
         do i = 1, n, 4
            s1 = s1 + x(i)
            s2 = s2 + x(i+1)
            s3 = s3 + x(i+2)
            s4 = s4 + x(i+3)
         end do
      end do
      call system_clock(t2)
      call report(label, 4, elapsed(t1, t2, rate), nadds, (s1 + s2) + (s3 + s4))

      ! Eight accumulators
      call system_clock(t1)
      s1 = 0.0_real64
      s2 = 0.0_real64
      s3 = 0.0_real64
      s4 = 0.0_real64
      s5 = 0.0_real64
      s6 = 0.0_real64
      s7 = 0.0_real64
      s8 = 0.0_real64
      do r = 1, reps
         do i = 1, n, 8
            s1 = s1 + x(i)
            s2 = s2 + x(i+1)
            s3 = s3 + x(i+2)
            s4 = s4 + x(i+3)
            s5 = s5 + x(i+4)
            s6 = s6 + x(i+5)
            s7 = s7 + x(i+6)
            s8 = s8 + x(i+7)
         end do
      end do
      call system_clock(t2)
      call report(label, 8, elapsed(t1, t2, rate), nadds, ((s1 + s2) + (s3 + s4)) + ((s5 + s6) + (s7 + s8)))

      deallocate(x)

   end subroutine time_sums

   ! Print one line of CSV output
   subroutine report(label, k, seconds, nadds, total)
      character(len=*), intent(in) :: label
      integer, intent(in) :: k
      real(real64), intent(in) :: seconds, nadds, total

      print '(a, ",", i0, ",", f0.4, ",", f0.3, ",", es23.15)', &
            label, k, seconds, 1.0e9_real64 * seconds / nadds, total
   end subroutine report

   function elapsed(t1, t2, rate) result(seconds)
      integer(int64), intent(in) :: t1, t2, rate
      real(real64) :: seconds

      seconds = real(t2 - t1, real64) / real(rate, real64)
   end function elapsed

end program ilp_sum
