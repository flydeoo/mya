Hi there, it’s great to have you here for episode 1. Let’s dive in!

I’m not going to dive into all the details, I just show you some points.

When you press the power button on your computer, several steps occur before your operating system starts working. These steps can be found on this helpful resource: https://wiki.osdev.org/Boot_Sequence.

The computer has firmware called bios which is written by the motherboard manufacturer and it does many things.

one of them which is important for us is: finding a special volume from the disk and loading it somewhere on the memory (and then jumping to it (running it)).

And what is it on that special volume? Bootloader.

And how does bios find that volume? With a special two-byte sign at the end of the sector.

As I said I’m not going to delve into these things because good resources explain them perfectly. So I would rather talk about other things.

> OH, I remember something: the term “memory” belongs to both RAM and ROM.

> Also, when we talk about memory addresses, our measure is Byte, not bit.

So if you read the boot sequence from wiki OS, you know that the first step for us is to write a program which is called bootloader, put a special sign at the end of it, and then put it on the disk. Then bios scans the disk, finds that program, and loads it to an address of RAM. Which is 0x7c00.

Shortly, we will start writing the bootloader. However, there is something we should know. If you write assembly code for an operating system, you probably remember the structure that your programs take on:

```
Segment .data
//
//
//

Segment .bss
//
//
//

Segment .text
//
//
//

```

But now, we don’t have OS, linker, and … here. We write assembly code that runs on bare metal (we can say that I guess).

So forget about writing our assembly bootloader with logical segments.

![image](https://github.com/flydeoo/mya/assets/41344995/a7520a9e-fd3c-4430-8b12-51cd8ce3ed6f)


You may wonder why we can’t do that.

It’s about how CPU and memory interact with each other. So I invite you to read the following article.

I have read some articles on how memory works and written down my understanding on paper. now I want to share them with you:

Programs need to know their instruction’s addresses in memory. What do I mean by saying that?

Imagine our program residing in the computer’s memory, and think of this memory as a sequence of instructions, each assigned a unique address. Now, let’s say a particular instruction indicates that the program should jump to another address.

In order to have such a program, the source code of that program needs to be compiled or assembled with knowing that jump address. For this purpose, assemblers and compilers consider a base address for your program codes, and as your code grows, this address increases too.

So by this strategy, when we have jump to a label in our code, they can replace label with address that they calculate. thus, they produce code with a jump to a memory address.

And if you put that program code somewhere in memory that assembler or compiler considers as its base address, the program works as intended.


![image](https://github.com/flydeoo/mya/assets/41344995/0c46f668-671f-48ad-9173-6f7e495a2e7e)

Another example: we have a goto in c, or jump in assembly. How do they work?

When you are writing a program, compiler or assembler assumes a start address offset for program and as you add codes to your program, the address grows.

For example:

```c

Int a = 0;
Int b = a + 5;
goto flag;
//
// Some other code
//
flag:
Int c = b + 15;
printf("%d", c);

```

How does this work? This works if compiler or assembler marks each instruction of your code with an address and when you say goto flag, it replaces the flag with that address.

## era of uni programming

In the early days of computers, programmers wrote out symbolic programs on sheets of paper and then hand assembled them into “machine code”, thus the symbols were bound to addresses by hand translation by programmer.

In this situation, if programmer wants to add or delete instructions, any address affected by added or deleted instructions should be adjusted.

![image](https://github.com/flydeoo/mya/assets/41344995/9d5639b9-63ae-4bb6-bed9-0a74ef8fea19)

(When assemblers arrive, this process is passed from the programmer to computers. Through assemblers, when a program is changed, all that is required is to reassemble it..)

- in this era, programs have entire memory, thus programs are assembled and linked for fixed memory locations.

- in this era, running executable is like:

you write a program that starts at address 0x200 and then load it to address 0x200. Since the program is placed at the exact same address it is written for, it will work perfectly.

![image](https://github.com/flydeoo/mya/assets/41344995/0ccfc7c4-a152-4689-be10-6b9cd346d5fb)


## subprograms, libraries, and linker

useful programs are composed of sub-programs. at that time computer installations keep a library of pre-written subprograms & programmers could use them in their new programs, instead of requiring programmers to write all subprograms themselves.

but how?

they need to load programs along subprograms and because subprograms are pre-written, they need to relocate the subprogram’s code to reflect the address at which they were loaded.

![image](https://github.com/flydeoo/mya/assets/41344995/75611de9-0ad4-43c9-bc36-2f1722a9364f)

[linkers by changing subprogram’s code, change the load address of them!]
[so a thing named “linker” acts like glue to main program and subprograms that were written before]

## era of multiprogramming, time sharing, and OS

with advent of OS, multiprogramming and its extension, time sharing, people want to run multiple programs at same time (interactively). but how is this possible?

to run multiple programs at same time in that era, CPU must switch between programs quickly.

one approach to do that is like :

we load the first program to memory, then CPU does some work and then moves state of the program (CPU registers + program memory) to disk and then moves the second program into memory, and so on… obviously, this process is slow.

the second approach is like:

just let programs stay in memory and switch between them. this approach needs “isolation” and a new concept called “virtual address” but we talk about it later.

now we focus on the first part of the sentence and ask: “How do multiple programs load and stay in memory?”

when we want to have multiple programs in memory, it’s not working like “load the program at the address that is written for”.

- let me first talk about evolution of address binding and OS’s effect on it and then we come back to loading multiple programs to memory:

with advent of OS, address binding changes. at this time, relocating loader separate from linker.

so we have linker and loader separated from each other. before OS, each program has entire memory, thus program assembled and linked for fixed memory location.

but in the OS case, since there are other programs & “OS” in memory, therefore programs have to share memory with each other. this means that the actual address at which the program would be loaded and running won’t known until the OS loads the program into memory. so it’s actually deferring final address binding from link time to load time.

(we also call it software-based relocation or static relocation)

let me simplify the view for you: a programmer writes a simple program. assembler generates machine code of program (assembler generates a form of primitive address for labels of the program with this idea in mind that program address starts from zero).

linker links different parts of the program together(e.g. libraries). When Linker puts different parts of the program and libraries together, addresses are messed up. so in first step linker relocates addresses in program to fix this issue. (and then one more time relocate addresses in program according to linker script.)

now program works as if it’s loaded into the memory location that it’s written for.

static-relocation approach follows this principle:

loader knows that if it loads the program in another address, it won’t work. On the other side, that part of the memory the program wants may be occupied by other programs or even OS.

how do they solve it? with relocation!

- we have a program that works if it is loaded at address X, but unfortunately, loader can just load it to address Y. loader knows the program will be in location Y, therefore loader relocates program addresses to reflect this change from X to Y. e.g. (numbers are in decimal) if our program has this instruction:

```

mov eax, [50]

```

and it’s working if the program codes load to address 0, but loader loads them to address 110. loader change the instruction like

```
mov eax, [50+110]

```

after this relocation happens, loader loads the program into memory.

because of the loader’s relocation, the program works.

this method is called static or software-based relocation.

![image](https://github.com/flydeoo/mya/assets/41344995/1b1131c5-a56d-423c-9e08-1c87a75510c9)


## hardware-based relocation, VM

now we know the problem. we also have one approach to solve the issue (via software relocation).

Do you agree that it’s faster if we implement an algorithm via hardware? so we did.

let’s review:

we know that we can’t load programs to memory like before.

the solution is: ok. let’s load it in another location and then relocate its addresses.

but this time, with hardware relocation approach, we don’t change addresses of program via loader. with hardware support, on the fly, when cpu references memory location, the address changes.

![image](https://github.com/flydeoo/mya/assets/41344995/c9df1129-3a9a-4847-9132-d8355a385168)

let me explain:

We let the program have its view of address, but load the program into another location in memory. (other than what program expected)

ok, now we have a program that works if it is loaded at address X, but we load it to address Y.

and loader also doesn’t update the addresses according to where program loaded.

how does hardware-based relocation solve this?

in this approach, the CPU has a unit named MMU and MMU has base and bound registers. it works like:

the OS says to MMU that I load this program at address x. so MMU save that to base register & when executing instructions, on the fly, translates program addresses by adding their value to the base register. so it’s like

```
physical address = base + program address.

```

in this case, program address space differs from the actual physical memory location that program resides. so we call the program’s view of memory “virtual address space” and the actual address that program resides in “physical address space” of program.

so hardware-based relocation is simply an address translation of virtual to physical. this is done by relocation.

![image](https://github.com/flydeoo/mya/assets/41344995/f209fa19-032b-4b91-98ba-4520e00e347c)

we have a primitive approach which is “software-based relocation or static relocation” in which the loader of OS changes the addresses of the program to where it actually loaded in memory. for example, if the program has

```
mov eax, [10]

```

instruction & the address of the program starts from 0, but the loader loads it to address 30. in this case loader also changes the instruction to:

```
mov eax, [40]

```

after a while, this approach depreciated as “hardware-based relocations or dynamic relocation” came in.

so when CPU executes

```
mov eax, [15]

```

the MMU changes it to:

```
mov eax, [15+base register]

```

dynamic relocation does it things on the fly and CPU sees virtual addresses of the program but static relocation does it at load time, so CPU sees actual addresses in instructions.

with advent of hardware-relocation and virtual memory, each program could again have entire address space.

programs could be linked to be loaded at fixed address, with hardware rather than software relocation taking care of any load-time relocation.

![image](https://github.com/flydeoo/mya/assets/41344995/ab6c31ea-4627-43fa-8828-93dd4ab561a2)

## program’s sections or logical segments

computers with hardware relocation always run more than one program, frequently multiple copies of the same program. when a computer runs multiple instances of one program, some parts of the program are the same among all running instances (the executable code, in particular), while other parts are unique to each instance.

if the parts that don’t change can be separated from the parts that do change, the operating system can use a single copy of the unchanging part, saving considerable storage. compilers and assemblers were modified to create object code in multiple sections, with one section for read-only code and another section for writable data, the linker had to be able to combine all of sections of each type so that linked program would have all the code in one place and all of the data in another. [from the book]

![image](https://github.com/flydeoo/mya/assets/41344995/e944cdee-5f19-44d7-a3d3-714cb3b187e2)

## segmentation

while base and bound with hardware support is a good idea but in this scenario we copy entire address space of the program to memory, so the free space within the program address space wastes the memory.

![image](https://github.com/flydeoo/mya/assets/41344995/207c126d-3dd2-4328-b77a-7945f51cf4e4)

The idea is simple: instead of having just one base and bounds pair in our MMU, why not have a base and bounds pair per logical segment (e.g. code, heap, stack, …) of the address space?

explanation: if we have one base and bound register in MMU, then program address space sections should copied to memory entirely.

but if we have a pair of base and bound registers for logical segments of program, then the OS’s loader can load them separately in different locations of memory & thus there is no waste of memory like we have if we copy entire address space of the program to memory.

so it’s like:

loader puts sections (logical segments) of the program in different locations of memory & then sets each MMU segment register to point to those addresses if OS wants to run that program.

![image](https://github.com/flydeoo/mya/assets/41344995/8703aa4d-2531-485b-926f-9b980ee3caea)


> when we use logical segments, the reference to values in those segments is made by offset from start of those segments:

![image](https://github.com/flydeoo/mya/assets/41344995/ea091bde-2e49-4357-a900-c94cf0f82dd5)

## Room for investigation: Expansion to x86 real mode and protected mode

in x86 we have a term named segmentation which means for each logical section of program we have base and limit register in cpu.

so for data section, we have DS register as base register, for code or text segment CS as base register, and …

and it’s MMU duty to add segment register of the running program to offset from instruction to convert logical address to physical address.

for example: if DS is set to 15 and we have instruction like: mov ax, [label_address] the MMU add DS to label_address to convert logical to physical.

and if the instruction explicitly uses segment register in it, like:

```
mov ax, [0x35:label_address]

```

it means that MMU sets DS to 0x35 and then translates logical address to physical address.

and in x86 real mode, the MMU converts logical address to physical address with this formula:

```
Segment base register *16 + offset = physical address

```

but in x86 protected mode it differs and segment registers like CS, SS, DS are segment selectors in the GDT table. so in protected mode, they are just selectors in the GDT table and thus MMU works differently from the real mode.

if you want to load and run a program with real mode segmentation, the loader must load each logical section of the program to an address in memory (better to use what is written in the linker script), and then when the program is loaded in memory, to run it, set SS, CS and DS to program sections in memory.

but in protected mode, those base registers (SS, CS, DS) are segment selectors in GDT, and we shouldn’t change them.

So a question remains:

assume that in protected mode, we have segmentation with flat memory model.

all things discussed are based on that we have a linker script that generates program code that works if it’s loaded in for example location x and loader also loads the program to location x in memory.

but what if the loader loads the program sections in other location? obviously, a relocation is needed.

in real mode, we know that we can change the segment registers to adjust program address to fit in the new location.

but in protected mode with flat memory model, we can’t change segment registers. so what should we do then?

so the loader loads program sections in memory but can’t set segment registers to point to them, so what is the solution?

GPT answer:

> In protected mode with a flat memory model, when the loader loads a program section to a location other than the one specified in the linker script, and if the program contains absolute addresses, a process known as relocation is needed.

> Typically, an executable file contains a relocation table that specifies the locations in the code and data sections that need adjustment. During the loading process, the loader examines this table and applies the necessary offsets to update the absolute addresses based on the actual location where the program is loaded in memory.

> This process allows programs to be loaded at different base addresses without requiring changes to the segment registers in protected mode.

as I get it’s software relocation and thus we can conclude that in real mode segmentation, we use hardware base relocation via help of MMU and in protected mode segmentation with flat memory model we use software base relocation with help of MMU, GDT and loader.

Correct?

GPT answer:

> Yes, that’s a correct understanding. In real mode with segmentation, hardware-based relocation is achieved through the MMU, where changing the base register directly adjusts the effective memory address. In protected mode with a flat memory model, software-based relocation is used, and the loader adjusts absolute addresses in the program through the GDT and MMU, without directly modifying the segment registers.

resources :
- Operating Systems: Three Easy Pieces article on: https://pages.cs.wisc.edu/~remzi/OSTEP/
- Linkers and Loaders book by John R. Levine
- pictures from google images


Thanks for reading. Stay tuned for next episode.









