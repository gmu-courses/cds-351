! Measure main-memory latency by "pointer chasing"
!
! The array next(:) stores, at each position, the index of the next position
! to visit:   j = next(j).
! Each load needs the result of the previous one, so the processor cannot
! fetch ahead or overlap loads. The time per step is the time to fetch
! one value: the latency.
!
! The same 256 MiB array is walked in two orders:
!   1. sequential: next(i) = i + 1      (neighbors in memory)
!   2. random:     a random single cycle through all elements
! Sequential order uses every value in each cache line, and the hardware
! prefetcher sees the pattern and fetches ahead. Random order defeats both,
! so each step waits for main memory.
!
! Build:  gfortran -O3 mem_latency.f90 -o mem_latency.x
!
program mem_latency
   use iso_fortran_env, only: real64, int64  ! for portability
   implicit none

   integer, parameter :: n = 2**25                  ! 32 Mi x 8 bytes = 256 MiB
   integer(int64), parameter :: nsteps = 2_int64**24
   integer(int64), allocatable :: next(:)
   real(real64) :: ns_seq, ns_rand

   allocate(next(n))

   call make_sequential(next)
   ns_seq = chase(next, nsteps)

   call make_random_cycle(next)
   ns_rand = chase(next, nsteps)

   print '(a)',          'Pointer chase through a 256 MiB array'
   print '(a, f8.2, a)', '  sequential order: ', ns_seq,  ' ns per load'
   print '(a, f8.2, a)', '  random order:     ', ns_rand, ' ns per load'
   print '(a, f8.1)',    '  ratio random / sequential: ', ns_rand / ns_seq

contains

   subroutine make_sequential(next)
      integer(int64), intent(out) :: next(:)
      integer :: i

      do i = 1, size(next) - 1
         next(i) = i + 1
      end do
      next(size(next)) = 1
   end subroutine make_sequential

   ! Sattolo's algorithm: a random permutation that is one single cycle,
   ! so the chase visits every element before returning to the start.
   subroutine make_random_cycle(next)
      integer(int64), intent(out) :: next(:)
      integer :: i, j
      integer(int64) :: tmp
      real :: r

      do i = 1, size(next)
         next(i) = i
      end do
      do i = size(next), 2, -1
         call random_number(r)
         j = 1 + int(r * (i - 1))          ! j in 1 .. i-1
         tmp = next(i)
         next(i) = next(j)
         next(j) = tmp
      end do
   end subroutine make_random_cycle

   function chase(next, nsteps) result(ns_per_load)
      integer(int64), intent(in) :: next(:)
      integer(int64), intent(in) :: nsteps
      real(real64) :: ns_per_load
      integer(int64) :: j, k, t1, t2, rate

      j = 1
      call system_clock(t1, rate)
      do k = 1, nsteps
         j = next(j)
      end do
      call system_clock(t2)

      ns_per_load = real(t2 - t1, real64) / real(rate, real64) &
                    / real(nsteps, real64) * 1.0e9_real64
      if (j < 1) print *, 'impossible'     ! keep the chase live
   end function chase

end program mem_latency
