#!/bin/bash
# Build script for OpenBLAS on Windows
# Designed to statically link in GCC
# runtime DLLs

OPENBLAS_COMMIT="701ea88"
BUILD_BITS=64
OPENBLAS_ROOT="C:/msys64/home/treddy/OpenBLAS"

# initial setup / clean-up
cd $OPENBLAS_ROOT
git checkout $OPENBLAS_COMMIT
git clean -xfd
rm -rf $OPENBLAS_ROOT/$BUILD_BITS

# set flags
march="x86-64"
extra="-fno-asynchronous-unwind-tables"
vc_arch="X64"
plat_tag="win_amd64"
# for static gcc inclusion see:
# https://github.com/xianyi/OpenBLAS/issues/1172
cflags="-O2 -march=$march -mtune=generic $extra"
fflags="$cflags -frecursive -ffpe-summary=invalid,zero"

# Build OpenBLAS
make BINARY=$BUILD_BITS DYNAMIC_ARCH=1 USE_THREAD=1 USE_OPENMP=0 \
     NUM_THREADS=24 NO_WARMUP=1 NO_AFFINITY=1 CONSISTENT_FPCSR=1 \
     BUILD_LAPACK_DEPRECATED=1 \
     COMMON_OPT="$cflags" \
     FCOMMON_OPT="$fflags" \
     MAX_STACK_ALLOC=2048
make PREFIX=$OPENBLAS_ROOT/$BUILD_BITS install
