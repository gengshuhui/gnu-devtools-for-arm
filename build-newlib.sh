#!/bin/bash
# Helper script to automate the building and synchronization of Newlib with an existing toolchain.

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <target> <builddir> <srcdir> <scriptdir>"
    exit 1
fi

target=$1
builddir=$2
srcdir=$3
scriptdir=$4

if [ ! -d "$builddir" ]; then
    echo "Error: Toolchain Build directory '$builddir' does not exist or is not a directory."
    exit 1
fi

dirname=$(dirname "$builddir")

newlibbuilddir="${dirname}/build-newlib-${target}"

$scriptdir/build-baremetal-toolchain.sh --target=$target --check-gdb --with-language=fortran --srcdir=$srcdir --builddir=$newlibbuilddir --enable-binutils --enable-gcc --enable-gdb --no-check-gdb --enable-newlib --disable-qemu start-bootstrap-newlib
$scriptdir/build-baremetal-toolchain.sh --target=$target --check-gdb --with-language=fortran --srcdir=$srcdir --builddir=$newlibbuilddir --enable-binutils --enable-gcc --enable-gdb --no-check-gdb --enable-newlib --disable-qemu install-newlib --newlib-installdir=${builddir}/install

rsync -a $newlibbuilddir/install/$target/include/ $builddir/install/$target/include/
rsync -a $newlibbuilddir/install/$target/lib/ $builddir/install/lib/gcc/$target/*/
rsync -a $newlibbuilddir/install/lib/gcc/$target/*/ $builddir/install/lib/gcc/$target/*/
