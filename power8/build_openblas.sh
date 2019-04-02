#!/bin/bash
# Build script for OpenBLAS on POWER8 Linux (ppc64le)

OPENBLAS_COMMIT="v0.3.5"
BUILD_BITS=64
OPENBLAS_ROOT="/home/treddy/github_projects/OpenBLAS"

# initial setup / clean-up
cd $OPENBLAS_ROOT
git checkout $OPENBLAS_COMMIT
git clean -xfd
rm -rf $OPENBLAS_ROOT/$BUILD_BITS

# set flags
march="powerpc"
extra="-fno-asynchronous-unwind-tables"
# for static gcc inclusion see:
# https://github.com/xianyi/OpenBLAS/issues/1172
# also: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=46539
cflags="-O2 -march=$march -mtune=generic $extra -static-libgcc -static-libgfortran"
fflags="$cflags -frecursive -ffpe-summary=invalid,zero"

# Build OpenBLAS
make BINARY=$BUILD_BITS DYNAMIC_ARCH=1 USE_THREAD=1 USE_OPENMP=0 \
     NUM_THREADS=64 NO_WARMUP=1 NO_AFFINITY=1 CONSISTENT_FPCSR=1 \
     BUILD_LAPACK_DEPRECATED=1 \
     COMMON_OPT="$cflags" \
     FCOMMON_OPT="$fflags" \
     MAX_STACK_ALLOC=2048
make PREFIX=$OPENBLAS_ROOT/$BUILD_BITS install
