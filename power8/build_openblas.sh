#!/bin/bash
# Build script for OpenBLAS on POWER8 Linux (ppc64le)

OPENBLAS_COMMIT="6a8b426"
BUILD_BITS=64
OPENBLAS_ROOT="/home/treddy/github_projects/OpenBLAS"

# initial setup / clean-up
cd $OPENBLAS_ROOT
git checkout $OPENBLAS_COMMIT
git clean -xfd
rm -rf $OPENBLAS_ROOT/$BUILD_BITS

# temporarily adjust PATH to prefer
# gcc 6.4 toolchain series for OpenBLAS build
# so that we don't have a runtime depedency on
# a super-new version of i.e., libgfortran
# (which can cause issues in NumPy / Travis CI)
PATH=/opt/at10.0/bin:$PATH

# set flags
extra="-fno-asynchronous-unwind-tables"
# for static gcc inclusion see:
# https://github.com/xianyi/OpenBLAS/issues/1172
# also: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=46539
cflags="-O2 -mcpu=power8 -mtune=power8 $extra"
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
make TARGET=POWER8 USE_OPENMP=0 \
     COMMON_OPT="$cflags" \
     FCOMMON_OPT="$fflags"
make PREFIX=$OPENBLAS_ROOT/$BUILD_BITS install
tar -czvf openblas-$OPENBLAS_COMMIT-ppc64le-power8.tar.gz ./$BUILD_BITS
