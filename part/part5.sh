#!/bin/bash

source ./part/enviroment.sh

pushd "$1"

if [ -f .process ];then
	echo "OK!"
else
	echo "Extracting Glibc package..."
	tar xf ./sources/glibc-2.40.tar.xz
	if [ $? -eq 1 ]; then
		echo "Extract fail!"
	fi
	echo "Configuring Glibc..."
	cd glibc-2.40
	case $(uname -m) in
	    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
	    ;;
	    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
		    ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
	    ;;
	esac
	patch -Np1 -i "$1/sources/glibc-2.40-fhs-1.patch"
	mkdir build
	cd build
	echo "rootsbindir=/usr/sbin" > configparms	
	../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=4.19               \
      --with-headers=$LFS/usr/include    \
      libc_cv_slibdir=/usr/lib
        echo "Building package"
        echo "Using default core to build"
        make
        if [ $@ -eq 1 ]; then
			echo "Build step fail to continue."
			exit
		else
			echo "Installing package..."
			make DESTDIR=$LFS install
			sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
			$LFS/tools/libexec/gcc/$LFS_TGT/12.2.0/install-tools/mkheaders
			echo "PART 5 COMPLETED!"
			echo "Removing source folder..."
			cd ../..
			rm -rf "$1/glibc-2.40"
		fi
fi
