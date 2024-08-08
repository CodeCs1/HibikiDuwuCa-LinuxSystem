#!/bin/bash

source ./part/enviroment.sh

echo "Creating Unix-like folder..."
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
  x86_64) mkdir -pv $LFS/usr/lib64 && ln -sv $LFS/usr/lib64 $LFS/lib64 ;;
esac

mkdir -pv $LFS/tools
