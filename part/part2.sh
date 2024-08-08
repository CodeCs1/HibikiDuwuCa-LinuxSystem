#!/bin/sh

source ./part/enviroment.sh

echo "Extracting Binutils..."
pushd "$1"
if [ -d binutils-2.43 ]; then
	echo "Extracted, skip"
else
	tar xvf ./sources/binutils-2.43.tar.xz
fi
if [ $? < 0 ];then
	echo "Extracting fail."
	exit
else
	echo "Configuring package..."
	cd binutils-2.43
	mkdir build
	cd build
	../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror
        echo "Building package"
        echo "Using default core to build."
        make
        if [ $@ -eq 1 ]; then
        	echo "Build step fail to continue."
        	exit
        else
        	echo "Installing package..."
        	make install
        	echo "PART 2 COMPLETED !"
        	echo "Removing source folder..."
        	cd ../..
        	rm -rf binutils-2.43
        fi
fi

