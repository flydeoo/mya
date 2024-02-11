Hi there!

Welcome to the seventh episode of the series on making a tiny OS.

In this episode, we will migrate from assembly to C programming language to create some parts(including the kernel) of our handmade OS with C.

To do that, first, we create a linker script and then read about GCC switches that we need for creating a standalone C program.

hopes are high that at the end of this episode, we write some text to screen with C programming language.


## linker
throwback to when we talked about the memory layout of our OS, we saw the need to know where the program resides in memory. in the assembly bootloader, we give that sense with "org" directive. and in our C program (kernel) we have the same story. here we should give the linker a sense of where the program will load in memory, so the linker, links our c program based on that. (basically linker relocates addresses in the program)

## linker script
First step toward informing the linker, is to determine where we want to put our C program. (C kernel)

Let's review the memory map of our OS:

![0 g77xwXuQGeL_ehW_](https://github.com/flydeoo/mya/assets/41344995/4d740a19-252c-46aa-9761-d676ded3a4db)

since we don't have a loader that loads each section of our program to a different place in the memory (we still use bios interrupt to load our program to memory) we should write a "linker script" in a way that linker puts all sections close to each other at desired address, so the bios loader loads the program as a whole to the desired address.

![0 Jq5xwKHGqGD4JXwM](https://github.com/flydeoo/mya/assets/41344995/6c55bfce-c2b1-40ed-b263-d2594f1fe313)

now that we know the need for a linker script, let's review the steps towards that:

- find a place in memory for your program. (in our case, C kernel)

- create a simple linker script that relocated program addresses around the desired address and creates output for our OS. (obviously, our OS doesn't support the famous Linux elf format)

- use proper switches with LD to inform it to use our custom linker script and …

**Proper place for kernel**

let's consider 0xc350 as start address of the kernel. so the updated view of memory would be like this:

![0 aRKrKR92Zv1wpgGW](https://github.com/flydeoo/mya/assets/41344995/30eeefcf-7b63-4d41-a148-679bc5f30084)


## write linker script

writing linker script is not every day job of a programmer, so it's better to check the syntax reference every time you want to write one.

I found a good resource for writing linker script: https://bravegnu.org/gnu-eprog/lds.html

follow the following steps to create a linker script.

first, create a folder for kernel inside "mya/code" directory:

```bash
mkdir kernel && cd kernel
```

inside the kernel directory, create a file named "linker.ld". (this is our linker script)

```bash
vim linker.ld
```

now, we can write our very own linker script.

It all starts with defining entry point. entry point is the first place that is executed when a program starts running. because it is the first place that gets hit by execution, it's a good place for some functions like zeroing out some areas like bss and some initializations.

so we add an entry point to the linker script:

```
ENTRY(entry)
```

as you see we named our entry point function, "entry". you can use any other name you want and we will define this "entry" function, later.

if you try to link some object files together with "ld" command, you probably see this message from ld:

```
ld: warning: cannot find entry symbol _start; defaulting to 0000000000401000
```

this means that the default ld entry point is "_start".

it is good practice to see your ld default linker script. for example, we can confirm above point by checking the ld default linker script by this command:

``` bash
ld –verbose
```

![0 TnMye-lVOka7O90N](https://github.com/flydeoo/mya/assets/41344995/cc5aecab-05e1-4567-8598-2af28ea5c90a)

there after the entry point, we should define the output format. the reason is the same when we changed the output format of nasm. the famous elf output format (and others) comes with many headers that we don't need at this stage and more importantly, we still use bios loader (int 0x13)

and don't have a loader to read that header and decide based on that to where put the program in memory and …

so we should use binary output format to omit that header.

```
OUTPUT_FORMAT("binary")
```

now, it's time to line up the sections in output. Have a look at the following linker script:

```
ENTRY(entry)
OUTPUT_FORMAT("binary")
phys = 0x0000C350;

SECTIONS
{
 . = phys;

 .entry           : { __entry_start = .;   *(.entry)   }
 .text            : { __text_start = .;    *(.text) }
 .data            : { __data_start = .;    *(.data) }
 .rodata          : { __rodata_start = .;  *(.rodata)  }
 .bss             : { __bss_start = .;     *(.bss)  }
    
 __end = .;
}
```
as you see in the linker script, there is the "SECTIONS" part which describes the layout and lineup of different sections of program in output.

In the first line of "SECTIONS", you see:

```
. = phys;
```

this . (dot) is the linker location counter. by assigning the 0xc350 to the location counter, we inform the linker that 0xc350 is the start address of our program. so the linker manages the addressing based on this address.

then we have sections like .entry, .text, .data, .rodata, .bss. here the order you see section names is the order which linker puts them in output. so the order matters.

as you see each section name is followed by : (colon).

the structure is like:

```
.section_name     : {__label_name = .;    *(.section_name)}
```

first, those "__label_name =." are just labels for current position of the location counter and we can ignore them.

and **what is "*(.section_name)" ?**

well, creating object files and merging them is part of the workflow that we usually do when we develop a program.

![0 jg392X18Rt9heegd](https://github.com/flydeoo/mya/assets/41344995/ef5df5cf-af55-4f0e-a0ad-4733209f4785)

(picture from https://www.researchgate.net/figure/The-object-sections-in-three-object-files-shown-on-the-left-are-combined-by-the-linker_fig2_220404613)

As you see in the above picture, we expect from linker that merge all ".text" sections from object files into one ".text" section in output.

that's exactly what " *(.section_name) " do in linker script.

for example by the line:

```
.text         : { __text_start = .;    *(.text)    }
```

in the linker script, we are telling the linker that all ".text" sections from input files should go to the ".text" section in output.

that was all. there are tons of things we can learn about linker script, but I leave it to you.


## compile and link phase

> this section of article was gathered from osdev. you can read the original articles through: <br>
https://wiki.osdev.org/Why_do_I_need_a_Cross_Compiler%3F <br>
https://wiki.osdev.org/Libgcc <br>
https://wiki.osdev.org/C_Library



The compiler must know the correct target platform (CPU, operating system), otherwise you will run into trouble.

It is possible ask your compiler what target platform it is currently using by calling the command:

``` bash
gcc -dumpmachine
```

If you are developing on 64-bit Linux, then you will get a response such as 'x86_64-unknown-linux-gnu'. This means that the compiler thinks it is creating code for Linux. If you use this GCC to build your kernel, it will use your system libraries, headers, the Linux libgcc, and it will make a lot of problematic Linux assumptions. If you use a cross-compiler such as i686-elf-gcc, then you get a response back such as 'i686-elf' that means the compiler knows it is doing something else and you can avoid a lot of problems easily and properly.



**Freestanding and Hosted**

There are two flavors of the C compilation environment: Hosted, where the standard library is available; and freestanding, where only a few headers are usable that contain only defines and types. The hosted environment is meant for user-space programming while freestanding is meant for kernel programming. The hosted environment is default, but you can switch to the freestanding by passing -ffreestanding to your compiler.

The freestanding headers are: <float.h>, <iso646.h>, <limits.h>, <stdalign.h>, <stdarg.h>, <stdbool.h>, <stddef.h>, <stdint.h>, and <stdnoreturn.h>.

![0 hFB00RFvE4p8ETgb](https://github.com/flydeoo/mya/assets/41344995/422e1508-5d83-4190-a246-460ba81c0123)

(picture from https://ppci.readthedocs.io/en/latest/reference/lang/c.html)



**Linking with your compiler rather than ld**

You shouldn't be invoking ld directly. Your cross-compiler is able to work as a linker and using it as the linker allows it control at the linking stage. This control includes expanding the -lgcc to the full path of libgcc that only the compiler knows about.


**what is libgcc?**

All code compiled with gcc must be linked with libgcc. Its exact contents depend on the particular target, configuration and even command line options. GCC unconditionally assumes it can safely emit calls to libgcc symbols as it sees fit, thus all code compiled by GCC must be linked with libgcc. The library is automatically included by default when you link with GCC and you need to do nothing further to use it.

However, kernels usually don't link with the standard user-space libc for obvious reasons and are linked with the -nodefaultlibs (implied by -nostdlib) which disables the automatic linking with libc and libgcc.



## Options you should link with

**-nostdlib (same as both -nostartfiles -nodefaultlibs)**

The -nostdlib option is the same as passing both the -nostartfiles -nodefaultlibs options. You don't want the start files (crt0.o, crti.o, crtn.o) in the kernel as they only used for user-space programs. You don't want the default libraries such as libc, because the user-space versions are not suitable for kernel use. You should only pass -nostdlib, as it is the same as passing the two latter options.

**what is libc?**

The C standard library provides string manipulation (string.h), basic I/O (stdio.h), memory allocation (stdlib.h), and other basic functionality to C programs.

On Unix platforms, the library is named libc and is linked automatically into every executable.

You need a C standard library implementation with the necessary features to run C programs on your operating system.


**-lgcc**

You disable the important libgcc library when you pass -nodefaultlibs (implied by -nostdlib). The compiler needs this library for many operations that it cannot do itself or that is more efficient to put into a shared function. You must pass this library at the end of the link line, after all the other object files and libraries

This is due to the classic static linking model where an object file from a static library is only pulled in if it is used by a previous object file. Linking with libgcc must come after all the object files that might use it.


## Options that you should pass to your Compiler

You need to pass some special options to your compiler to tell it it isn't building user-space programs.

**-ffreestanding**

This is important as it lets the compiler know it is building a kernel rather than user-space program. The documentation for GCC says you are required to implement the functions memset, memcpy, memcmp and memmove yourself in freestanding mode.

<br>
<br>
to summarize the above explanations, this is what the compile and link command pattern looks like:

<br>
<br>

**to compile:**

``` bash
i686-elf-gcc kernel.c -o kernel.o -ffreestanding
```


**-ffreestanding**

makes gcc compiler not use standard library. there are some headers available in freestanding mode that we can use:

<float.h>, <iso646.h>, <limits.h>, <stdalign.h>, <stdarg.h>, <stdbool.h>, <stddef.h>, <stdint.h>, and <stdnoreturn.h>.

and we have to implement

memset, memcpy, memcmp and memmove

ourself.


<br>
<br>

**to link:**

``` bash
i686-elf-gcc -T link.ld boot.o kernel.o -o kernel.bin -nostdlib -ffreestanding -lgcc
```

**i686-elf-gcc**

uses gcc instead of ld since gcc expands "-lgcc" to the full path of libgcc of i686-elf-gcc cross compiler.

**-T link.ld**

uses a linker script named "link.ld" instead of default gcc linker script

**-nostdlib**

disables unnecessary c standard libs such as libc, so we can't use the following libs and if needed, we have to implement them by ourselves:

<string.h>, <stdio.h>, <stdlib.h>

also disables libgcc automatic linking.

**-ffreestanding**

same as the compiler option

**-lgcc**

since libgcc is disabled by -nostdlib and gcc needs it for linking, we pass -lgcc to the linker which then will expand to path of the cross compiler's libgcc. (because we use gcc instead of ld)

<br>
<br>

Now that we know the basics, let's start coding.

In the linker script section, we introduced "entry" and now we want to implement it. for the sake of simplicity, there is no initialization and declaration inside the entry point of our kernel. actually, we do nothing and just jump to the main function of the c program.

here is "entry.asm":

``` assembly
bits 32

section .entry
global entry
extern start

entry:
     
     
     call start
     hlt
```

you see that it simply calls a function named "start".

that's actually a function from our c kernel.

so why not implement the very first simple kernel now?

let's do it. create a file named kernel.c inside the kernel directory and use the following code:

``` c
void __attribute__((cdecl)) start()
{
     int a = 5;
     int b = 10;
     int c = a+b;
     char* x = 0xb8000;
     *x = 'X';
     
     for(;;);

}
```

this will create a simple c program inside function "start", that prints the "X" letter on the screen.

> Note: if everything goes well we can have an episode on graphics. <br>
0xb8000. this is address of the video display memory and it is hardware mapped.<br>
![0 By2wxzbCkyMIkgpz](https://github.com/flydeoo/mya/assets/41344995/e14317e4-1270-4a7a-ac47-ca1240bbc481)
<br> and there (in the graphic episode) we will talk about 0xb8000 address and explain how it works.

<br>

**what is __attribute__((cdecl)) ?**

this is a function attribute. function attributes instruct compiler to do something.

for example, cdecl attribute causes the compiler to assume that the calling function pops off the stack space used to pass arguments.

within the C programming language, there are two major function call conventions which are "cdecl" and "stdcall".

you can see the difference in the following picture:

![0 y77AVKqzietvrOH9](https://github.com/flydeoo/mya/assets/41344995/ebe0170a-97f0-4ec0-a9bb-4a4285678f25)

(picture from https://mfranc.com/blog/net-internals-sorting-part3)

you can read more about other x86 function attributes at https://gcc.gnu.org/onlinedocs/gcc/x86-Function-Attributes.html#index-cdecl-function-attribute_002c-x86-32

ok. now let's put all things together and create the output. for that purpose, create a makefile inside the kernel directory and use the following code:

``` makefile
TARGET_ASMFLAGS += -f elf
TARGET_CFLAGS += -ffreestanding -nostdlib
TARGET_LIBS += -lgcc
TARGET_LINKFLAGS += -T linker.ld -nostdlib
TARGET_CC = ../toolchain/i686-elf/bin/i686-elf-gcc
TARGET_LD = ../toolchain/i686-elf/bin/i686-elf-gcc

kernel.img: kernel.bin
     dd if=kernel.bin of=kernel.img

kernel.bin: entry.obj kernel.obj $(PROGRAMMER_LIBS)
     $(TARGET_LD) $(TARGET_LINKFLAGS) -Wl,-Map=kernel.map -o $@ $^ $(TARGET_LIBS)
     @echo "--> Created  kernel.bin"

kernel.obj: kernel.c
     
     $(TARGET_CC) $(TARGET_CFLAGS) -c -o kernel.obj kernel.c
     @echo "--> Compiled: " kernel.obj

entry.obj: entry.asm
     
     nasm $(TARGET_ASMFLAGS) -o entry.obj entry.asm
     @echo "--> Compiled: " entry.obj

.PHONEY: clean

clean:
     @echo remove main object files
     rm -f kernel.obj entry.obj kernel.map kernel.bin kernel.img
```

and then use the following command to create binary output of the kernel:

``` bash
make
```

the result would be like:

![0 cvmXprfSazDWA8uH](https://github.com/flydeoo/mya/assets/41344995/71bb8e75-2849-4c67-a0a5-46aef05daf95)

congrats. we just made our c kernel that is capable of running on bare metal.

there is just one step left toward testing it. load the kernel in memory and then jump to its address (which is 0xc350).

to load the kernel to the memory, we need bios int 0x13 again.

so open the "boot.asm" file (located in the code directory) and add the following code to the "load_hda" function:

``` assembly
mov ah, 2
mov al, 1 ; count of sectors
mov ch, 0 ; start of cylinder (C)
mov cl, 1 ; start of sector   (S) (starts from 1)
mov dh, 0 ; head              (H)
mov dl, 0x81 ; read from hdb
mov bx, 0xC350 ; buffer
int 0x13
```

to jump to the kernel address, add the following code to the end of "pmode_main" function in "second_stage.asm":

``` assembly
jmp 0xc350
```

and last step is to inform qemu to include "kernel.bin" file as "hdb".

to do that edit the makefile in the code directory from:

``` makefile
run:  
$(MAKE) all && qemu-system-i386 -fda boot.bin -hda second_stage.bin -s -S
```

to:

``` makefile
run:
    $(MAKE) all && qemu-system-i386 -fda boot.bin -hda second_stage.bin -hdb kernel/kernel.bin -s -S
```

I also add a breakpoint to 0xc350 (start of kernel) to the makefile. so far the makefile looks like this:

``` makefile
boot.bin: boot.asm
       nasm -f bin -o boot.bin boot.asm

second_stage.bin: second_stage.asm
               nasm -f bin -o second_stage.bin second_stage.asm

all: boot.bin second_stage.bin

.PHONY: run debug

run:
     $(MAKE) all && qemu-system-i386 -fda boot.bin -hda second_stage.bin -hdb kernel/kernel.bin -s -S

debug:
     #qemu-system-i386 -s -S -fda boot.bin
     gdb -ex "target remote :1234" -ex "b *0x7c00" -ex "b *0xa411" -ex "b *0xc350" -ex "set tdesc filename gdb_asset/target.xml" -ex "layout asm"
```

now to apply the changes, use the following command:

``` bash
make all
```

<br>

**ready to test?**


ok. head to the "code" directory and as always, use the following command to open the qemu:

``` bash
make run
```

and use the following command to open gdb:

``` bash
make debug
```

![0 D8YTaC5cz3qHORZI](https://github.com/flydeoo/mya/assets/41344995/5087dcd4-2ec2-4611-aa86-cb42f796a828)

as you can see in the following picture, the kernel loaded at 0xc350.

![0 HMECdz8rz0ma2Ut8](https://github.com/flydeoo/mya/assets/41344995/1c763863-3a53-4a65-a863-a61109c4b37d)

and when opcodes of the following c code get executed:

``` c
char* x = 0xb8000;
*x = 'X';
```

![0 F5MKG8Us3VR04x-Q](https://github.com/flydeoo/mya/assets/41344995/5a1a90da-535b-4282-8605-879dbccce944)

you can see letter "X", on the screen:

![0 WojV6BZ2b18fPRdA](https://github.com/flydeoo/mya/assets/41344995/ee949fa6-6882-44f8-a184-c347bb2a13d5)

At this point, there is just one thing left. every time you change kernel files, you should apply the changes using make inside the kernel directory and then come back to the code directory and run the project using make run and debug. let's automate this process by running the second makefile (the one inside the kernel directory) from the main makefile.

in order to do that, change the makefile inside the "code" directory like this:

``` makefile
boot.bin: boot.asm
       nasm -f bin -o boot.bin boot.asm

second_stage.bin: second_stage.asm
               nasm -f bin -o second_stage.bin second_stage.asm

all: boot.bin second_stage.bin

.PHONY: run debug

run:
     $(MAKE) all
     cd kernel && $(MAKE)
     qemu-system-i386 -fda boot.bin -hda second_stage.bin -hdb kernel/kernel.bin -s -S

debug:
     #qemu-system-i386 -s -S -fda boot.bin
     gdb -ex "target remote :1234" -ex "b *0x7c00" -ex "b *0xa411" -ex "b *0xc350" -ex "set tdesc filename gdb_asset/target.xml" -ex "layout asm"
```

ok. I think it's time to wrap up this article.

this is the 7th article on "Making tiny OS" and I'm looking forward to hearing your feedback, so if there is any suggestion, please let me know.

you can access the codes for this project at "mya" GitHub repository: https://github.com/flydeoo/mya

Also, you can check the episode 7 release at: https://github.com/flydeoo/mya/releases/tag/v0.07

thanks for reading and stay tuned for the next episode.
