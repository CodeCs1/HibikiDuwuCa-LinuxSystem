#!/bin/bash

source ./part/enviroment.sh

if [ -f .process ]; then
	echo "Process stopped because interrupt"
	echo "Continue building g++ package..."
	pushd "$1"
	cd gcc-14.2.0/build
	make -j$(nproc)
	if [ $@ -eq 1 ]; then
			echo "Build step fail to continue."
			exit
	else
		echo "Installing package..."
		make install
		cd ..
		cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
			`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
		echo "PART 3 COMPLETED !"
		echo "Removing source folder..."
		cd ../..
		rm -rf gcc-14.2.0
		rm -rf ../.process
	fi
else
	touch .process
	echo "Extracting g++..."
	pushd "$1"
	if [ -d gcc-14.2.0 ]; then
		echo "Extracted, skip"
	else
		tar xf ./sources/gcc-14.2.0.tar.xz
		tar xf ./sources/mpfr-4.2.1.tar.xz
		tar xf ./sources/gmp-6.3.0.tar.xz
		tar xf ./sources/mpc-1.3.1.tar.gz
		
		mv -v ./mpfr-4.2.1 ./gcc-14.2.0/mpfr
		mv -v ./gmp-6.3.0 ./gcc-14.2.0/gmp
		mv -v ./mpc-1.3.1 ./gcc-14.2.0/mpc
	fi
	if [ $? -eq 1 ];then
		echo "Extracting fail."
		exit
	else
		echo "Configuring package..."
		cd gcc-14.2.0
		case $(uname -m) in
		  x86_64)
		    sed -e '/m64=/s/lib64/lib/' \
			-i.orig gcc/config/i386/t-linux64
		 ;;
		esac
		mkdir build
		cd build
		../configure                  \
		    --target=$LFS_TGT         \
		    --prefix=$LFS/tools       \
		    --with-glibc-version=2.40 \
		    --with-sysroot=$LFS       \
		    --with-newlib             \
		    --without-headers         \
		    --enable-default-pie      \
		    --enable-default-ssp      \
		    --disable-nls             \
		    --disable-shared          \
		    --disable-multilib        \
		    --disable-threads         \
		    --disable-libatomic       \
		    --disable-libgomp         \
		    --disable-libquadmath     \
		    --disable-libssp          \
		    --disable-libvtv          \
		    --disable-libstdcxx       \
		    --enable-languages=c,c++
		echo "Building package"
		echo "Using default core to build."
		make -j$(nproc)
		if [ $@ -eq 1 ]; then
			echo "Build step fail to continue."
			exit
		else
			echo "Installing package..."
			make install
			cd ..
			cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
			  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
			echo "PART 3 COMPLETED !"
			echo "Removing source folder..."
			cd ../..
			rm -rf gcc-14.2.0
		fi
	fi
fi
