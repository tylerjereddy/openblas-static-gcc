#!/bin/bash
# Build script for OpenBLAS on MacOS

OPENBLAS_COMMIT="701ea88"
BUILD_BITS=64
OPENBLAS_ROOT="/Users/treddy/github_projects/OpenBLAS"

# initial setup / clean-up
cd $OPENBLAS_ROOT
git checkout $OPENBLAS_COMMIT
git clean -xfd
rm -rf $OPENBLAS_ROOT/$BUILD_BITS

# set flags
march="x86-64"
extra="-fno-asynchronous-unwind-tables"
# for static gcc inclusion see:
# https://github.com/xianyi/OpenBLAS/issues/1172
# also: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=46539
cflags="-O2 -march=$march -mtune=generic $extra -static-libgcc -static-libgfortran"
fflags="$cflags -frecursive -ffpe-summary=invalid,zero"

# Build OpenBLAS
# NOTE: physically removing file at
# /usr/local/Cellar/gcc/8.2.0/lib/gcc/8/ that
# correspond to libquadmath*dylib helps force
# the static link to libquadmath.a
LIBRARY_PATH=/usr/local/Cellar/gcc/8.2.0/lib/gcc/8/ \
CC=/usr/local/Cellar/gcc/8.2.0/bin/gcc-8 FC=/usr/local/Cellar/gcc/8.2.0/bin/gfortran-8 \
make BINARY=$BUILD_BITS DYNAMIC_ARCH=1 USE_THREAD=1 USE_OPENMP=0 \
     NUM_THREADS=64 NO_WARMUP=1 NO_AFFINITY=1 CONSISTENT_FPCSR=1 \
     BUILD_LAPACK_DEPRECATED=1 \
     COMMON_OPT="$cflags" \
     FCOMMON_OPT="$fflags" \
     MAX_STACK_ALLOC=2048
make PREFIX=$OPENBLAS_ROOT/$BUILD_BITS install
