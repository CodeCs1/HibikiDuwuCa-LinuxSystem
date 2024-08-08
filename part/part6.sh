#!/bin/bash

source ./part/enviroment.sh

pushd "$1"
if [ -d "gcc-14.2.0" ]; then
	echo "Skip in reextract package"
else

	tar xf ./sources/gcc-14.2.0.tar.xz
	tar xf ./sources/mpfr-4.2.1.tar.xz
	tar xf ./sources/gmp-6.3.0.tar.xz
	tar xf ./sources/mpc-1.3.1.tar.gz
	
	mv -v ./mpfr-4.2.1 ./gcc-14.2.0/mpfr
	mv -v ./gmp-6.3.0 ./gcc-14.2.0/gmp
	mv -v ./mpc-1.3.1 ./gcc-14.2.0/mpc
fi
cd gcc-14.2.0
mkdir buildlib
cd buildlib
echo "Configuring Libstdc++..."
../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0
echo "Building package..."
echo "Using default core to build"
make
echo "Installing the package.."
make DESTDIR=$LFS install
echo "PART 6 COMPLETED!"
echo "Removing libtool archive..."
rm -v $LFS/usr/lib/lib{stdc++,stdc++fs,supc++}.la
echo "Removing buildlib folder..."
cd ..
rm -rf buildlibes
