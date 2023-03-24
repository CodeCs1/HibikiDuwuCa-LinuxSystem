#!/bin/bash

export LFS=$1

pushd "$1"
if [ -f ./sources/linux-6.2.8.tar.xz ]; then
	echo "skip in download linux kernel"
else
	echo "Downloading Linux kernel..."
	cd ./sources
	wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.2.8.tar.xz
	cd ..
fi

echo "Extracting Linux Kernel..."
tar xf ./sources/linux-6.2.8.tar.xz
if [ $? -eq 1 ]; then
	echo "Extract fail!"
fi
echo "Configuring Linux Kernel [HEADER]"
cd ./linux-6.2.8
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr/include
echo "PART 4 COMPLETED!"
echo "Removing source folder."
cd ..
rm -rf ./linux-6.2.8
