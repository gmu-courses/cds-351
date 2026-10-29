! Fibonacci two ways: a dependency chain vs. a better algorithm
!
! Iterative:  F(k+1) = F(k) + F(k-1)
!   Each step needs the two previous results, so the steps cannot overlap:
!   n dependent additions, O(n) time.
!
! Matrix power:  [F(n+1) F(n); F(n) F(n-1)] = A**n,  A = [1 1; 1 0]
!   Computing A**n by repeated squaring needs only about log2(n) matrix
!   products: O(log n) time.
!
! F(93) is too large for a 64-bit integer, so exact values stop at n = 92.
! To compare running times for large n, part 2 computes F(n) modulo a prime,
! as is common in number theory and cryptography. The algorithms are the same.
!
! Build:  gfortran -O2 fibonacci.f90 -o fibonacci.x
!
program fibonacci
   use iso_fortran_env, only: real64, int64
   implicit none

   integer(int64), parameter :: p = 1000000007_int64   ! a prime modulus
   integer(int64), parameter :: no_mod = huge(1_int64) ! "no modulus"
   integer(int64), parameter :: exact_n(3) = [10_int64, 50_int64, 92_int64]
   integer, parameter :: ncalls = 10000                ! matrix method is too fast to time once
   integer(int64) :: n, f_iter, f_mat, check, t1, t2, rate
   real(real64) :: s_iter, s_mat
   integer :: k, j

   ! Part 1: exact values, both methods must agree
   print '(a)', 'Exact values'
   do k = 1, 3
      n = exact_n(k)
      print '(a, i3, a, i20, a, i20)', '  F(', n, ') iterative:', &
            fib_iterative(n, no_mod), '   matrix:', fib_matrix(n, no_mod)
   end do

   ! Part 2: running time for large n (values modulo p)
   print '(a)', 'Time to compute F(n) mod 1000000007'
   print '(a)', '            n    iterative (s)     matrix (s)   (matrix: average of 10000 calls)'
   do k = 6, 9
      n = 10_int64**k
      call system_clock(t1, rate)
      f_iter = fib_iterative(n, p)
      call system_clock(t2)
      s_iter = real(t2 - t1, real64) / real(rate, real64)

      f_mat = fib_matrix(n, p)
      check = 0
      call system_clock(t1)
      do j = 1, ncalls                     ! n + j: a different problem each call
         check = mod(check + fib_matrix(n + j, p), p)
      end do
      call system_clock(t2)
      s_mat = real(t2 - t1, real64) / real(rate, real64) / ncalls

      if (f_iter /= f_mat) print *, 'Error: methods disagree for n =', n
      if (check < 0) print *, 'impossible'  ! use the results
      print '(i13, es17.2, es15.2)', n, s_iter, s_mat
   end do

contains

   ! O(n): a chain of dependent additions
   function fib_iterative(n, m) result(f)
      integer(int64), intent(in) :: n, m
      integer(int64) :: f, prev, next
      integer(int64) :: k

      prev = 0                   ! F(0)
      f = 1                      ! F(1)
      if (n == 0) f = 0
      do k = 2, n
         next = mod(f + prev, m)
         prev = f
         f = next
      end do
   end function fib_iterative

   ! O(log n): F(n) is element (1,2) of A**n
   function fib_matrix(n, m) result(f)
      integer(int64), intent(in) :: n, m
      integer(int64) :: f, a(2,2), r(2,2), k

      a = reshape([1_int64, 1_int64, 1_int64, 0_int64], [2, 2])
      r = reshape([1_int64, 0_int64, 0_int64, 1_int64], [2, 2])   ! identity
      k = n
      do while (k > 0)           ! exponentiation by squaring
         if (mod(k, 2_int64) == 1) r = mat_mult(r, a, m)
         k = k / 2
         if (k > 0) a = mat_mult(a, a, m)
      end do
      f = r(1,2)
   end function fib_matrix

   ! 2x2 integer matrix product, reduced modulo m
   function mat_mult(x, y, m) result(z)
      integer(int64), intent(in) :: x(2,2), y(2,2), m
      integer(int64) :: z(2,2)
      integer :: i, j

      do j = 1, 2
         do i = 1, 2
            z(i,j) = mod(mod(x(i,1) * y(1,j), m) + mod(x(i,2) * y(2,j), m), m)
         end do
      end do
   end function mat_mult

end program fibonacci
