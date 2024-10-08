#!/bin/bash

# The Installation script based on OS

# OS: Hibiki Duwuca OS (The Hibiki Duca Vtuber Linux System)

export LFS=''

if [ $1 == "-HELP" ] || [ $1 == "-help" ]; then
	echo "The Installation script (version 8.8.2024-duca)"
	echo "Usage: installation.sh <ARGS>"
	echo ""
	echo "ARGS:"
	echo " -FOLDER <folder location>: Specify folder input"
	echo " -DRIVE <device location>: Specify drive input"
	echo "    -ENABLE_SWAP=<y/n>: Enable Swap drive"
	echo "           -SWAP <swap location or swap file>: Specify swap input"
	echo " -PART <part_number>: Specify any part without doing all"
	echo " -HELP: Show this help"
	echo " -PREPARE: Start prepare script"
	echo " -CLEAN: Clear anything, return back to normal state"
	echo ""
	echo "                    WAITER ONLY        "
	echo " -ALL: start all process (may take long time)"
	echo "UPDATE:"
	echo "There is also have BLFS based for xorg!"
	echo "This Installation use: Hibiki Duwuca as default OS"
elif [ $1 == "-FOLDER" ] || [ $1 == "-folder" ]; then
	if [ -x ".tmpdrv" ]; then
		echo "Target drive found, removing..."
		rm -rf .tmpdrv
		rm -rf .tmpfol
	fi
	echo "Will use $2 as default folder..."
	echo $2 > .tmpfol
elif [ $1 == "-DRIVE" ] || [ $1 == "-drive" ]; then
	if [ -x ".tmpfol" ]; then
		echo "Target folder found, removing..."
		rm -rf .tmpfol
		rm -rf .rmpdrv
	fi
	echo "Will use {$2} as default drive..."
	echo $2 > .tmpdrv
elif [ $1 == "-PART" ] || [ $1 == "-part" ]; then
	if [ -f ".tmpfol" ]; then
		filename='.tmpfol'
		while read line; do
			echo "Using $line as default initramfs folder"
			echo "Running script..."
			time sh ./part/part$2.sh $line
		done < $filename
	elif [ -f ".tmpdrv" ]; then
		filename='.tmpdrv'
		while read line; do
			echo "Using $line as default installation drive"
			echo "Running script..."
			time sh ./part/part$2.sh $line
		done < $filename
	fi	
elif [ $1 == "-ALL" ] || [ $1 == "-all" ]; then
	if [ -x ".tmpfol" ]; then
		filename='.tmpfol'
		while read line; do
			echo "Using $line as default initramfs folder"
			time sh ./installation -prepare
			time sh ./part/part1.sh $line
			time sh ./part/part2.sh $line
			time sh ./part/part3.sh $line
			time sh ./part/part4.sh $line
			time sh ./part/part5.sh $line
			time sh ./part/part6.sh $line
		done < $filename
	fi
elif [ $1 == "-PREPARE" ] || [ $1 == "-prepare" ]; then
	if [ -f ".tmpfol" ]; then
		filename='.tmpfol'
		while read line; do
			echo "Using $line as default preparation folder"
			if [ -d "$line/sources" ]; then
				echo "Prepararion folder existed."
				exit
			else
				echo "Downloading basic-linux sources..."
				wget https://www.linuxfromscratch.org/lfs/view/development/wget-list-sysv
				mkdir -v $line/sources
				chmod -v a+wt $line/sources
				wget --input-file=./wget-list-sysv --continue --directory-prefix=$line/sources
			fi
		done < $filename
	fi
elif [ $1 == "-CLEAN" ] || [ $1 == "-clean" ]; then
	if [ -x ".tmpfol" ]; then
		echo "Cleaning Initrd..."
		if [ -x ".tmpfol" ]; then
			filename='.tmpfol'
			while read line; do
				rm -rf $line
			done < $filename
		elif [ -x ".tmpdrv" ]; then
			filename='.tmpdrv'
			while read line; do
				rm -rf $line
			done < $filename
		fi

		echo "Cleaning System Configuration..."
		rm -rf .tmpfol .tmpdrv
	fi
fi
