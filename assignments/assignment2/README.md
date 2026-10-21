# Assignment 2 sample solution
Student Name: C. Cruz
Assignment Number: 2
GNU Fortran (Homebrew GCC 16.2.0) 16.2.0


#### Compile and run comnnads


```bash
gfortran -Wall -Wextra -fcheck=all -g -c src/matrix_mod.f90
gfortran -Wall -Wextra -fcheck=all -g -c src/io_mod.f90
gfortran -Wall -Wextra -fcheck=all -g -c src/main.f90
gfortran matrix_mod.o io_mod.o main.o -o matrix_app.x

mkdir -p output  # need output before running main.x

./main.x

cat output/report.txt
```

The input matrices are

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

For these exactly representable input values, the manual and intrinsic results
do agree exactly or to within ordinary floating-point rounding and so the
test showed that the validation was successful with zero relative error.
This will generally not be the case with larger matrices.

Matrix multiplication is compute intensive because multiplying dense m x k
and k x n matrices requires work proportional to m x k x n. For square matrices,
the work grows as the cube of the dimension. Therefore, large matrices can become
an I/O bottleneck. Imagine m=k=n=10000, that's 1E12*4 bytes = 4GB of per matrix!
Reading and storing such large files can become a computational issue.

### Known limitations.

Same as assignment1. Additionally, an obvious limitation is that we are
testing with very simple matrices. The input files are also text, which are not
representative of realistic data, which is in binary format. Therefore, the 4GB
number quoted above is actually much larger for a file on disk.
