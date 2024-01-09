![0 hY8HQjJfrnb3a5UL](https://github.com/flydeoo/mya/assets/41344995/ac83edee-422d-466f-aa10-b562d6303adb)

welcome to episode 3 of making tiny OS.

in this episode, I will discuss about implementing stack and function calls. also, we would talk about how to use GDB to debug our bootloader and then we leverage a bios interrupt to clear the screen and some refactoring in our code. finally, we will create make file for our project to make things simpler.

Let's dive into implementing the stack instead of discussing its importance.

as we discussed in previous episodes, CPU has registers for logical segments of program.

in fact, it's the idea of segmentation. in order to tell CPU that we want somewhere in memory known as stack, we should set some register of CPU.

our bootloader should fit in 512 bytes (then we create a second stage bootloader to bypass this limit) and lays on address 0x7c00:

![0 5VYJYRWUxycgz9TE](https://github.com/flydeoo/mya/assets/41344995/f0480152-9440-4883-92e4-f0f499492b34)

now we want to spot somewhere in memory for stack.

we have three registers to do that. stack segment, stack pointer, and base pointer.

stack segment holds the address of a block of memory where stack information is located.

Note: Again, in real mode segment registers are multiplied by 16 to create real address.

stack pointer register holds top of the stack and base pointer register holds bottom of the stack.

assume that we want to have stack area on address 0x8400.

in order to have stack area on address 0x8400 which is byte number 33792, we should set stack segment register to 0x840. since:

```
0x8400 = 0840 * 16
```

we can implement it using the following code:

``` assembly
mov ax, 0x840
mov ss, ax
```

here is the updated view of memory:

![0 s3IZj3GBLJ04OAQ2](https://github.com/flydeoo/mya/assets/41344995/a46cb559-8ba9-45f4-baa0-aa86db8d46a7)

on x86 architecture, stack grows downwards in memory. (stack grows in the opposite direction of the memory address growth direction.)

It's time to determine the size of the stack. To do that, we set both the stack pointer and base pointer to the same address.

this address is offset from stack segment and determines the stack size.

for example, if we set "SP" and "BP" to address 0x2000 (yes, these are not segment registers, and no need to set 0x200 if we mean 0x2000)

the result will be:

![0 z91_JO5ITaUksJJT](https://github.com/flydeoo/mya/assets/41344995/943216ef-07b0-41a1-9f08-2a7dac919d79)

as you see in the picture, whatever we put on the BP and SP, is offset from SS.in order to make 8KB stack, we set 0x2000 to SP and BP using the following code:

``` assembly
mov ax, 0x2000
mov sp, ax
mov bp, ax
```

For testing, we push and pop some values to a stack to ensure everything is done correctly:

``` assembly
push ax
push ax
pop bx
```

Now we need to test our bootloader and check its runtime. We also need to inspect stack values to ensure that our code works properly.

debugger is the key. we use GDB to debug our program. GDB is very handy in our project because it can connect to qemu and debug our bootloader.

so to debug our program, first we need to tell the qemu to load our program but not start it and also listen on the default port (which is 1234) for a debugger to connect to it.

to do that we change the qemu command to:

``` bash
qemu-system-i386 -fda boot.bin -s -S
```

the result of the above command would be qemu waiting for connection of the debugger:

![0 eTrpqteRvxsfvfVl](https://github.com/flydeoo/mya/assets/41344995/805eb7a1-b13b-45a4-9f1c-82fbfdef026f)

and then we need to run gdb using the following command:

``` bash
gdb boot.asm
```

then we shall see gdb program open up like the following picture:

![0 a4_XfTEwnU6OBsI1](https://github.com/flydeoo/mya/assets/41344995/b1ef9490-e6e5-4b22-b0f2-ca2dd04d444e)

now it's time to connect gdb to qemu. in order to do that we use the following command in gdb prompt:

```
target remote :1234
```
now it's time to set a breakpoint to start off the program and then run it.

to do that we use the following command in gdb:

```
b *0x7c00
```

this command creates a break point at address 0x7c00 which is the start of our bootloader code.

now it's time to see our code. to do that we tell gdb to show the assembly equivalent of opcodes in memory. to do that we use:

```
layout asm
```

This will result in the following output:

![0 OX2BM5wy19fbpAMa](https://github.com/flydeoo/mya/assets/41344995/0c80dc2b-0f83-4e30-91b1-2ce9db31713c)


If you're ready to advance to a breakpoint, let's do it now. To do that we type in gdb command prompt the following command:

```
continue
```

here is the result:

![0 PlS-wjw5uFuoWeRw](https://github.com/flydeoo/mya/assets/41344995/b253e7f1-01bc-434d-a8d6-71c64309f25e)

as you can see gdb disassembles our code as 32-bit assembly opcodes and thus uses eax, ebp, and …

to fix this issue, we should tell the gdb to disassemble opcodes as 16-bit, not 32-bit.

the standard way is this command:

```
set architecture i8086
```

but it won't work. it's not our fault but as I understand, gdb gets architecture from the target which in our case qemu i386, and because it's a 32-bit machine, gdb prefers to keep going with target architecture and doesn't obey our set architecture command.

so to fix this we need external help. I found a solution from [this](https://gist.github.com/MatanShahar/1441433e19637cf1bb46b1aa38a90815) GitHub gist.

we need two files called "target.xml" and "i386–32bit.xml". (I put these files in a folder called "gdb_asset", and you can access them in the project repository)

to fix issue we run this command in the gdb command prompt:

```
set tdesc filename gdb_asset/target.xml
```

and then we need to refresh assembly layout by firing disassembly command:

```
disassemble $eip-10, 5
```

the result would be:

![0 btpJ0DC9svxt36x-](https://github.com/flydeoo/mya/assets/41344995/5a52deb0-1170-4433-8395-12366a15d0a3)

as you can see gdb now disassembles opcodes as 16-bit assembly opcodes.

now we can use step command to step one instruction in our program. to do that:

```
stepi
```

or simply

```
si
```
![0 neTrEZQ-H-hWv-CD](https://github.com/flydeoo/mya/assets/41344995/9e5063bd-0a4b-4857-902d-82f8d3cfcc45)

as you see at bottom of the picture, program counter or IP register now is at 0x7c03. it means that CPU has executed opcode at address 0x7c00 which is mov ax, 0x7c0 and now waiting for our command to execute 0x7c03.

if we type "si" command again, it will proceed the highlighted instruction and wait for our command.

but for now, I prefer to see if "ax" register really has 0x7c0 value in it or not. to check register value we use the following command:

```
info registers register_name
```

in our case it would be:

```
i r ax
```
(yes we can use i r instead of info register)

the result would be:

```
ax    0x7c0     1984
```
result description: register name, value in hex, value in decimal

now we can use multiple steps until we reach 0x7c12 or push instruction.

![0 MrC6iAU2Kguh5NAp](https://github.com/flydeoo/mya/assets/41344995/ed73d169-8d7d-4635-897f-980fcf357ae9)

at this address, CPU just executed push ax, which pushed the value in register ax to stack.

we want to check stack to see whether it works or not.

to do that, first, we know from previous instructions that "ax" had 0x2000 value in it.

now to check if it really pushed to stack, there are some calculations:

as we discussed earlier, "sp" shows top of the stack. and it had value of 0x2000.

now by pushing something to the stack, "sp" has a new value which is 0x2000–2 (2 is size of the "ax" that is pushed to the stack)

```
0x2000 - 0x02 = 0x1ffe
```

and we know that "sp" is inside the stack segment area so we should add the stack pointer address to stack segment to reveal the "sp" address in memory:

```
0x8400 + 0x1ffe = 0xa3fe
```

now if we look at this address using the following command:

```
x/4x 0xa3fe
```

we shall see following result:
![0 nsTHeZf7rLBm5ZSk](https://github.com/flydeoo/mya/assets/41344995/8009461e-4d3d-484c-be6b-baab13fc690b)

as you see 0x2000 is on the stack. mission passed!

![0 xa_fXFi8w0zgU_vu](https://github.com/flydeoo/mya/assets/41344995/f2ac9bcc-d152-4878-b2db-90dfdb4b0740)

Now that we have successfully implemented a stack, we can use it to define functions and call them, all mounting on the stack.

for example here is a bios function that clears the screen. I just copied it from Joe Bergeron's [blog](https://www.joe-bergeron.com/posts/Writing%20a%20Tiny%20x86%20Bootloader/):

``` assembly
clear_screen:
mov ah, 0x07   ; tells BIOS to scroll down window
mov al, 0x00   ; clear entire window
mov bh, 0x07   ; white on black 
mov cx, 0x00   ; specifies top left of screen as (0,0) 
mov dh, 0x18   ; 18h = 24 rows of chars 
mov dl, 0x4f   ; 4fh = 79 cols of chars 
int 0x10       ; calls video interrupt ret 

ret
```

and then instead of jumping, we call this function. by calling function, the return address pushed to the stack automatically, and when executing the "ret" instruction, popped off from the stack and jumps to that address.

we can define a routine for our program like: first clear screen, then print Hello, world! on the screen and then finish.

now that we have functions we can do that like:

``` assembly
call clear_screen
call print_text
call finish
```

so far our program would be like this:

``` assembly
bits 16
 
mov ax, 0x7c0 
mov ds, ax 

mov ax, 0x840 
mov ss, ax 

mov ax, 0x2000
mov sp, ax 
mov bp, ax 

push ax 
push ax 
pop bx 

call clear_screen 
call print_text 
call finish

print_text:

mov ah, 0x0E 
mov bh, 0x00 
mov bl, 0x00 
mov si, 0 
mov cx, 0 

print_loop: 
cmp cx, 14 
je exit 
lea si, msg 
add si, cx 
mov al, [si] 
int 0x10 
inc cx 
jmp print_loop
ret

clear_screen:

mov ah, 0x07   ; tells BIOS to scroll down window 
mov al, 0x00   ; clear entire window 
mov bh, 0x07   ; white on black 
mov cx, 0x00   ; specifies top left of screen as (0,0) 
mov dh, 0x18   ; 18h = 24 rows of chars 
mov dl, 0x4f   ; 4fh = 79 cols of chars 
int 0x10       ; calls video interrupt 
ret

exit:
mov ax, 0 

finish:
hlt

msg: db "Hello, world!"
times 510-($-$$) db 0
dw 0xAA55
```

and result would be:

![0 GRMHu7B8fRRn9RM1](https://github.com/flydeoo/mya/assets/41344995/c4733de0-43df-4c5e-8ed6-771db00aea74)

it seems like there are many steps to assemble and run qemu and then start gdb and config it.

so I made a makefile to make our life much easier:

``` makefile
boot.bin: boot.asm
       nasm -f bin -o boot.bin boot.asm

.PHONY: run debug

run:
     $(MAKE) && qemu-system-i386 -fda boot.bin -s -S

debug:
     #qemu-system-i386 -s -S -fda boot.bin
     gdb -ex "target remote :1234" -ex "b *0x7c00" -ex "set tdesc filename gdb_asset/target.xml" -ex "layout asm"
```

By using this makefile, we can simply run "make run" followed by "make debug" in a separate terminal. This will open gdb connected to qemu, disassembling via 16-bit architecture, and should look like the following:

![0 KfCTQhkzq-Y8akqL](https://github.com/flydeoo/mya/assets/41344995/0d186e52-5c0e-46fa-a024-3f81697e6401)

After entering "continue" in the gdb command prompt, gdb will jump to the address 0x7c00, which marks the start of our program.

That's all for now. If you're interested in accessing the codes for this project and more, please check out the following GitHub repository:
https://github.com/flydeoo/mya

Also, check out the episode 3 release at:
https://github.com/flydeoo/mya/releases/tag/v0.031

Thank you for reading, and see you in the next episode.










