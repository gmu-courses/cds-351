! See the cache levels by timing loads from working sets of increasing size
!
! For each size, an array next(:) holds a random single cycle and we follow
! it:   j = next(j).   Each load depends on the previous one, so the time per
! step is the latency of wherever the array currently lives:
!
!   array fits in L1  -> about 1 ns
!   fits in L2        -> a few ns
!   fits in L3        -> roughly 10 ns (not every processor has an L3)
!   main memory only  -> roughly 100 ns
!
! Plot ns per load against size: the jumps mark the cache sizes.
! Compare them with your machine's cache sizes:
!
!   Linux:  lscpu            macOS:  sysctl hw | grep cachesize
!
! Build:  gfortran -O3 cache_latency.f90 -o cache_latency.x
!
program cache_latency
   use iso_fortran_env, only: real64, int64
   implicit none

   integer(int64), parameter :: nsteps = 2_int64**24
   integer(int64), allocatable :: next(:)
   integer :: p, n

   print '(a)', '   size (KiB)    ns per load'
   do p = 9, 25                          ! 2**9 .. 2**25 elements of 8 bytes
      n = 2**p                           ! 4 KiB .. 256 MiB
      allocate(next(n))
      call make_random_cycle(next)
      print '(i13, f15.2)', 8 * n / 1024, chase(next, nsteps)
      deallocate(next)
   end do

contains

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
      do k = 1, min(nsteps, int(size(next), int64))   ! warm up: load the array
         j = next(j)
      end do

      call system_clock(t1, rate)
      do k = 1, nsteps
         j = next(j)
      end do
      call system_clock(t2)

      ns_per_load = real(t2 - t1, real64) / real(rate, real64) &
                    / real(nsteps, real64) * 1.0e9_real64
      if (j < 1) print *, 'impossible'     ! keep the chase live
   end function chase

end program cache_latency
