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
extra="-fno-asynchronous-unwind-tables"
# for static gcc inclusion see:
# https://github.com/xianyi/OpenBLAS/issues/1172
# also: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=46539
cflags="-O2 -mcpu=power8 -mtune=power8 $extra -static-libgcc -static-libgfortran"
fflags="$cflags -frecursive -ffpe-summary=invalid,zero"

# Build OpenBLAS
make TARGET=POWER8
make PREFIX=$OPENBLAS_ROOT/$BUILD_BITS install
