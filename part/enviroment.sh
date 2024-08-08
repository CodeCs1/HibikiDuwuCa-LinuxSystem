#!/bin/sh
set +h
umask 022
export PATH=$LFS/tools/bin:$PATH
export LFS=$1
export LFS_TGT=x86_64-duca-linux-gnu