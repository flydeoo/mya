#! /bin/bash


GCC_ADDRESS="http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-13.2.0/"
GCC_NAME="gcc-13.2.0.tar.gz"
GCC_ADDRESS+=$GCC_NAME


BINUTILS_ADDRESS="https://ftp.gnu.org/gnu/binutils/"
BINUTILS_NAME="binutils-2.41.tar.xz"
BINUTILS_ADDRESS+=$BINUTILS_NAME

ROOT_DIR=$(pwd)
i686_elf_dir=$ROOT_DIR
i686_elf_dir+="/toolchain/i686-elf"




echo "=> Installing build-dep"
apt build-dep gcc-13

if [ $? -ne 0 ]; then
    	echo "=> Error installing build-dep, forced to exit"
    	exit
fi


echo "=> Create toolchain directory"
mkdir -p toolchain && cd toolchain

if [ $? -ne 0 ]; then
    	echo "=> Error making toolchain directory, forced to exit"
    	exit
fi


echo "=> Download source code of gcc 13 from ftp"

if [ ! -f $GCC_NAME ]; then

    	wget $GCC_ADDRESS

    	if [ $? -ne 0 ]; then
            	echo "=> Error downloading GCC, forced to exit"
            	exit
    	fi


fi



echo "=> Download binutils"


if [ ! -f $BINUTILS_NAME ]; then


    	wget $BINUTILS_ADDRESS

    	if [ $? -ne 0 ]; then
            	echo "=> Error downloading Binutils, forced to exit"
            	exit
    	fi


fi





echo "=> Extracting GCC & binutils"

tar xvf $GCC_NAME && tar xvf $BINUTILS_NAME


if [ $? -ne 0 ]; then
    	echo "=> Error extracting files, forced to exit"
    	exit
fi



echo "=> Create build directory"
mkdir -p binutils-build && mkdir -p gcc-build

if [ $? -ne 0 ]; then
    	echo "=> Error creating build directories, forced to exit"
    	exit
fi




echo "=> Build binutils & GCC"

cd binutils-build && ../binutils-2.41/configure --target=i686-elf --prefix=$i686_elf_dir --with-sysroot --disable-nls --disable-werror


make -j 8 && make install


cd ../gcc-build && ../gcc-13.2.0/configure --target=i686-elf --prefix=$i686_elf_dir --disable-nls --enable-languages=c,c++ --without-headers
 
make -j 8 all-gcc
make -j 8 all-target-libgcc
make install-gcc
make install-target-libgcc

echo "=> Build completed successfully"
