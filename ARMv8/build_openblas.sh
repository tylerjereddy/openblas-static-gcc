#!/bin/bash
# Build script for OpenBLAS on ARMv8 Linux

OPENBLAS_COMMIT="6a8b426"
BUILD_BITS=64
OPENBLAS_ROOT="/home/treddy/OpenBLAS"

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
cflags="-O2 -march=armv8-a $extra"
fflags="$cflags -frecursive"

# Build OpenBLAS
# the CentOS7 ppc64le compile farm machine (gcc112) did not
# have static gfortran libs installed, and I don't have root
# access, so manually pull in the libgfortran.a with:
# yumdownloader libgfortran-static.ppc64le
# rpm2cpio libgfortran-static-4.8.5-36.el7_6.1.ppc64le.rpm | cpio -idmv
# this makes libgfortran.a available at path:
# /home/treddy/rpm_work/usr/lib/gcc/ppc64le-redhat-linux/4.8.2
# Unfortunately, it was not built with -fPIC and cannot be used to
# statically link in to OpenBLAS
#LDFLAGS="-L/home/treddy/rpm_work/usr/lib/gcc/ppc64le-redhat-linux/4.8.2 -L/usr/lib/gcc/ppc64le-redhat-linux/4.8.5 -L/lib64" \
make TARGET=ARMV8 USE_OPENMP=0 \
     BINARY=$BUILD_BITS \
     COMMON_OPT="$cflags" \
     FCOMMON_OPT="$fflags"
make PREFIX=$OPENBLAS_ROOT/$BUILD_BITS install
tar -czvf openblas-$OPENBLAS_COMMIT-armv8.tar.gz ./$BUILD_BITS
