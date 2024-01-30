Hello everyone, it's nice to meet you all.

Today, we will be discussing how to migrate from assembly to C programming language. for me, It's amazing that our C code would run on a system without OS (runtime environment) just like running code on bare metal.


why migrate to C?

- well, I'm not Chris Sawyer. (He programmed an entire simulation game using assembly language.)

- by using C, we can see what is going on under the hood. Linus Torvalds once said, "Nothing is better than C":

[Linus Torvalds "Nothing better than C"](https://www.youtube.com/watch?v=CYvJPra7Ebk)

![0 DPRUiUAoppWh8KvN](https://github.com/flydeoo/mya/assets/41344995/66326477-8289-4f53-8ab5-ca0681810dd4)


What are the steps?

- build toolchain

- config (linker script) (next episode)

- create workflow (makefile) (next episode)


> Note: the main resource of this episode is this nano byte video: [Setting up an OS dev environment, building GCC toolchain](https://www.youtube.com/watch?v=TgIdFVOV_0U)


# build toolchain

As you see in the following picture, some components are involved in compiling C code to binary:

![0 5EjBm2ngiY-8gK1k](https://github.com/flydeoo/mya/assets/41344995/e6a9db24-e60a-4757-8b6a-488b3ae248b9)

[picture from researchgate: https://www.researchgate.net/figure/The-roles-of-GCC-and-Binutils_fig6_221610429]

They can be categorized into binutils and GCC. you may already have binutils and GCC installed on your system, but the issue is they are configured, built, and compiled to create executables for your modern system architecture. they won't compile a C program for old 32-bit i386 CPU.

so we are going to build and compile a version of GCC and binutils for our old CPU which met i386 architecture specifications.

> Note: you can read more about cross compiler on wikipedia:
> https://en.wikipedia.org/wiki/Cross_compilerhttps://en.wikipedia.org/wiki/Cross_compiler


# build and compile

[this part of the article copied from wikipedia: https://en.wikipedia.org/wiki/Cross_compiler]

GCC, a free software collection of compilers, can be set up to cross compile. It supports many platforms and languages.

GCC requires that a compiled copy of binutils is available for each targeted platform. Especially important is the GNU Assembler. Therefore, binutils first has to be compiled correctly with the switch - target=some-target sent to the configure script. GCC also has to be configured with the same - target option. GCC can then be run normally provided that the tools, which binutils creates.

Follow the steps to build and compile the toolchain.

## step 0:

install toolchain on your system to build and compile a new GCC: (this time a cross compiler one)

``` bash
sudo apt install build-essential nasm qemu-system-x86 build-essential
```

## step 1:

install build-dependency of a version of the GCC you want (just install dependency to build and then you need to download that version source code and compile it)

``` bash
sudo apt build-dep gcc-13
```

this is build dependency for gcc version 13, so we should download source code of gcc version 13 and then build and compile it.



## step 2:

create a folder called "toolchain" in the "code" directory and navigate to it:

``` bash
mkdir toolchain && cd toolchain
```

download source code of gcc 13:

``` bash
wget https://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-13.2.0/gcc-13.2.0.tar.gz
```

download binutils:

``` bash
wget https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz
```

extract them in toolchain folder:

``` bash
tar -xvf  gcc-13.2.0.tar.gz && tar -xvf binutils-2.41.tar.xz
```


## step 3:

create a folder named "binutils-build" and navigate there:

``` bash
mkdir binutils-build && cd binutils-build
```


[from wikipedia: https://en.wikipedia.org/wiki/Configure_script]

Obtaining software directly from the source code is a common procedure on Unix computers, and generally involves the following three steps: configuring the makefile, compiling the code, and finally installing the executable to standard locations. A configure script accomplishes the first of these steps. Using configure scripts is an automated method of generating makefiles before compilation to tailor the software to the system on which the executable is to be compiled and run.

run binutils configure script with the following arguments to create desired makefile:

``` bash
../binutils-2.41/configure --target=i686-elf --prefix="path_to_project/mya/code/toolchain/i686-elf" --with-sysroot --disable-nls --disable-werror
```

this command creates a makefile in the binutils-build folder with the following setting:

- prefix
  
This option specifies the directory where the Binutils will be installed. It's usually set to "/usr/local" by default. You can change it to a different directory if you want the Binutils to be installed in a specific location.

> Note: we have to use absolute address of the mya project for prefix, so replace "path_to_project" with the actual path of the mya project in your system.
>

- target

This option specifies the target system for which the Binutils are being built. It can be set to a specific system (e.g., "x86_64-pc-linux-gnu" for a 64-bit Linux system) or left blank if you want the Binutils to be built for the system you're currently using.



navigate to the binutils-build directory:

``` bash
cd binutils-build
```

now you can build and compile binutils with the following command:

``` bash
sudo make -j 8 && make install
```

j 8 makes this process faster by dedicating 8 cores of CPU to run the process parallelly.

it takes time. so chill out and relax until the compilation process is finished.

If all processes are successful, you will find "i686-elf" folder within the toolchain folder, containing the linker and assembler.



## step 4:

time to build and compile gcc.

go to the "toolchain" folder and create "gcc-build" folder and cd there:

``` bash
mkdir gcc-build && cd gcc-build
```

then run gcc configure script:

``` bash
../gcc-13.2.0/configure --target=i686-elf --prefix="path_to_project/mya/code/toolchain/i686-elf" --disable-nls --enable-languages=c,c++ --without-headers
```

> Note: again, you should replace "path_to_project" with absolute path of the mya project in your system.


now, everything is ready to build and compile gcc. To do that use the following commands:

``` bash
sudo make -j 8 all-gcc  
sudo make -j 8 all-target-libgcc  
sudo make install-gcc  
sudo make install-target-libgcc
```

it takes time, be patient.

if everything goes well, then we have handcraft gcc and binutils in i686-elf folder inside the toolchain directory.

you can verify that by going to the "…../code/toolchain/i686-elf/bin" directory and check the gcc and ld version:

``` bash
i686-elf-gcc -v
```

result:

```
Using built-in specs.
COLLECT_GCC=i686-elf-gcc
Target: i686-elf
Configured with: ../gcc-13.2.0/configure --target=i686-elf --prefix= --disable-nls --enable-languages=c,c++ --without-headers
Thread model: single
Supported LTO compression algorithms: zlib zstd
gcc version 13.2.0 (GCC)
```

and for binutils:

``` bash
i686-elf-ld -v
```

result:

```
GNU ld (GNU Binutils) 2.41
```


congrats. We've completed the first step of migrating from assembly to C. I've written a bash script that automates all the workarounds, so you don't need to manually build and compile the toolchain anymore:


"build_toolchain.sh":


``` bash
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
```

you can use the following commands to run this script:

``` bash
sudo chmod u+x build_toolchain.sh
```

and then:

``` bash
sudo ./build_toolchain.sh
```


![1 xLD5g_sU72yEpHvGopN6Lw](https://github.com/flydeoo/mya/assets/41344995/18126893-629a-47b4-8a75-447243d130cb)


time to wrap up this episode and prepare for the next one.


If you want to access the codes for this project, please visit mya GitHub repository at: https://github.com/flydeoo/mya

Also, you check out the episode 6 release at: https://github.com/flydeoo/mya/releases/tag/v0.06


thanks for reading and stay tuned for the next episode.
