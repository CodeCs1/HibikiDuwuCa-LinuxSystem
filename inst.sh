#!/bin/bash

printf "Checking for config file... "

if [ ! -f ".config_compile" ]; then
    echo "Configuration file not found!"
    echo "Try creating '.config_compile' config file"
    exit -2
fi

echo "OK"

. .config_compile

printf "Checking configuration option file..."
if [[ ! -b ${drive_path} ]]; then
    echo "Drive path ${drive_path} not found!"
    exit -2
fi
if [[ ! -b ${boot_path} ]]; then
    echo "Boot path ${boot_path} not found!"
    exit -2
fi


if [[ -z ${cpucore} ]]; then
    echo "cpucore is empty!"
    exit -2
fi

if [[ -z ${system_init} ]]; then
    echo "system_init is empty!"
    exit -2
fi

if [[ -z ${swap_on} ]]; then
    echo "swap_on is empty!"
    exit -2
fi


printf "OK"
printf "\n"


echo "DrivePath: ${drive_path}"
echo "cpucore: ${cpucore}"
echo "system_init: ${system_init}"
echo "Swap on: ${swap_on}"

echo "Is your option is correct ? (enter = yes)"
read
printf "Checking System Requirement"

LC_ALL=C
PATH=/usr/bin:/bin

bail() { echo "FATAL: $1"; exit 1; }
grep --version > /dev/null 2> /dev/null || bail "grep does not work"
sed '' /dev/null || bail "sed does not work"
sort   /dev/null || bail "sort does not work"

ver_check()
{
   if ! type -p $2 &>/dev/null
   then
     echo "ERROR: Cannot find $2 ($1)"; return 1;
   fi
   v=$($2 --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
   if printf '%s\n' $3 $v | sort --version-sort --check &>/dev/null
   then
     printf "OK:    %-9s %-6s >= $3\n" "$1" "$v"; return 0;
   else
     printf "ERROR: %-9s is TOO OLD ($3 or later required)\n" "$1";
     return 1;
   fi
}

ver_kernel()
{
   kver=$(uname -r | grep -E -o '^[0-9\.]+')
   if printf '%s\n' $1 $kver | sort --version-sort --check &>/dev/null
   then
     printf "OK:    Linux Kernel $kver >= $1\n"; return 0;
   else
     printf "ERROR: Linux Kernel ($kver) is TOO OLD ($1 or later required)\n" "$kver";
     return 1;
   fi
}

# Coreutils first because --version-sort needs Coreutils >= 7.0
ver_check Coreutils      sort     8.1 || bail "Coreutils too old, stop"
ver_check Bash           bash     3.2
ver_check Binutils       ld       2.13.1
ver_check Bison          bison    2.7
ver_check Diffutils      diff     2.8.1
ver_check Findutils      find     4.2.31
ver_check Gawk           gawk     4.0.1
ver_check GCC            gcc      5.2
ver_check "GCC (C++)"    g++      5.2
ver_check Grep           grep     2.5.1a
ver_check Gzip           gzip     1.3.12
ver_check M4             m4       1.4.10
ver_check Make           make     4.0
ver_check Patch          patch    2.5.4
ver_check Perl           perl     5.8.8
ver_check Python         python3  3.4
ver_check Sed            sed      4.1.5
ver_check Tar            tar      1.22
ver_check Texinfo        texi2any 5.0
ver_check Xz             xz       5.0.0
ver_kernel 4.19

if mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]
then echo "OK:    Linux Kernel supports UNIX 98 PTY";
else echo "ERROR: Linux Kernel does NOT support UNIX 98 PTY"; fi

alias_check() {
   if $1 --version 2>&1 | grep -qi $2
   then printf "OK:    %-4s is $2\n" "$1";
   else printf "ERROR: %-4s is NOT $2\n" "$1"; fi
}
echo "Aliases:"
alias_check awk GNU
alias_check yacc Bison
alias_check sh Bash

echo "Compiler check:"
if printf "int main(){}" | g++ -x c++ -
then echo "OK:    g++ works";
else echo "ERROR: g++ does NOT work"; fi
rm -f a.out

if [ "$(nproc)" = "" ]; then
   echo "ERROR: nproc is not available or it produces empty output"
else
   echo "OK: nproc reports $(nproc) logical cores are available"
fi

echo "LAST WARNING: The next step will format ALL data in ${drive_path}"
echo "Only support GPT (MBR not support!)"
echo "Press ctrl+C to quit."
printf "Starting in "
for (( i=10; i>0; i-- )); do
    printf "%i" $i
    sleep 1.
    printf "..."
done



mkfs.ext4 ${drive_path}
mkfs.fat -F 32 ${boot_path}

if [ ! -d "/mnt/lfs" ]; then
    echo "Creating /mnt/lfs..."
    mkdir -p /mnt/lfs
fi

export LFS=/mnt/lfs
export LFS_TGT=x86_64-duca-gnu

mount ${drive_path} $LFS
mount ${boot_path} $LFS/boot --mkdir

mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources

if [[ ${system_init} == "systemv" ]]; then
    wget https://www.linuxfromscratch.org/lfs/view/development/wget-list-sysv
    wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources
    pushd $LFS/sources
        wget https://www.linuxfromscratch.org/lfs/view/development/md5sums
        md5sum -c md5sums
    popd

elif [[ ${system_init} == "systemd" ]]
    wget https://www.linuxfromscratch.org/lfs/view/systemd/wget-list-systemd
    wget --input-file=wget-list-systemd --continue --directory-prefix=$LFS/sources
    pushd $LFS/sources
        wget https://www.linuxfromscratch.org/lfs/view/systemd/md5sums
        md5sum -c md5sums
    popd
fi

chown root:root $LFS/sources/*

echo "Preparing System Folder"

mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac

mkdir -pv $LFS/tools


echo "Log into cuka user..."
su - cuka


#This will use in entire building process
pushd $LFS/sources
    tar xvf binutils-2.42.tar.xz
    cd binutils-2.42
    mkdir -v build
    cd       build
    time {
        ../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-default-hash-style=gnu
            &&
        make ${cpucore} &&
        make install
    ;}
    if [ $? -eq 1 ]; then
        echo "Installation of binutils failed!"
        exit -1
    fi
    cd ../..
    rm -rf binutils-2.42
popd

echo "Done in installing core system !"
