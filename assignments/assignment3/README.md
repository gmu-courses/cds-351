# Assignment 3 sample solution
Student Name: C. Cruz
Assignment Number: 3


#### Method

I copied the source and input files from assignment3 and recompiled manually.
Results are identical - as expected.

Again, the input matrices are

```text
A = [1 1 1; 2 2 2]
B = [1 1; 2 2; 1 1]
```

Their independently calculated product is

```text
C = [4 4; 8 8]

and

sum(C) = 24
```

Note I chose simple matrices so that I can easily verify the result by hand.


#### Discussion

As in assignment#2, the manual and intrinsic results do agree exactly or to
within ordinary floating-point rounding and so the test showed that the
validation was successful with zero relative error.

Why we shouldn't copy entire data structures such as shown here:

```
type(matrix_data) :: original , copy

copy = original
```

Since copy and original both contains an allocatable values array thi is,
for large matrices, a significant memory use and data movement.
Why, the most obvious issue for us is that every element inside the original
array is sequentially copied over to the copy memory block - very costly!
Another more subtle issue - not apparent - is that if the destination array
is not allocated then, what will Fortran do? Well, it may allocate/reallocate
it to match the source.


Why can changing the the types module require more recompilation than
changing an independent source file? Because the compiler enforces strict
consistency between the definition of the type and where it is used, that is,
there is a "cascading" effect.


#### 

Copied the Makefile from cds-351  and modify to add new targets

Then it is easy to build and run

```
make clean (removes files from previous run)
make (compiles all the project files without running)
make run (compiles and runs files)

```


### Known limitations.

Same as assignment2:
- testing with very simple matrices
- the input files are also text, which are not representative of realistic data
