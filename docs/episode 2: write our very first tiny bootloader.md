![0 K2ku9vlzaU87Ey8h](https://github.com/flydeoo/mya/assets/41344995/1c36cba6-0451-4978-9ccb-69e00567cc26)
Alright, let's write our very first bootloader. In order to do that, we might need to know how addressing works inside our program.

Interestingly, assemblers don't have any idea where the program will be located in memory.

However, we can use labels in our program code and reference them via jump instructions. In such cases, assemblers replace the label with an address that points to the location of the labeled instruction.

To calculate addresses, assemblers use a default base address and calculate the offset to the label from that base address. Usually, the base address is set to 0 at the start of the program code.

Here is an example source code named main.asm:

``` assembly
mov eax, 5
mov ebx, 7

jmp sum

add eax, 8

sum:

add eax, ebx
test eax, 12

```

We can assemble it using nasm to produce a flat binary:

``` bash
nasm -f bin -o main.bin main.asm
```

> We use flat binary to omit linker relocation in program addresses.

Therefore we have a flat binary which we can inspect using the following command:

```
   0:   66 b8 05 00 00 00    mov  eax,0x5
   6:   66 bb 07 00 00 00    mov  ebx,0x7
   c:   eb 04                jmp  0x12
   e:   66 83 c0 08          add  eax,0x8
  12:   66 01 d8             add  eax,ebx
  15:   66 a9 0c 00 00 00    test eax,0xc
```

As you can see assembler assigns each opcode of instructions, an address.

The base address starts from zero and increases with opcode size steps.

So when there is a jump to a label called "sum", the assembler replaces "sum" with the address where the first instruction after the "sum" label is located (which is add eax, ebx).

It is also possible to change this base address through org directive.
I can easily change base address via org directive.
For example, if we want our base address to start from 0x100 instead of 0x0, we need just to add "org 0x100" to our source code:

``` assembly
org 0x100
mov eax, 5
mov ebx, 7

jmp sum

add eax, 8

sum:

add eax, ebx
test eax, 12
```

Once you assemble your code and use object dump to inspect it, you will see the updated base address:

```
   0:   66 b8 05 00 00 00    mov  eax,0x5
   6:   66 bb 07 00 00 00    mov  ebx,0x7
   c:   eb 04                jmp  0x12
   e:   66 83 c0 08          add  eax,0x8
  12:   66 01 d8             add  eax,ebx
  15:   66 a9 0c 00 00 00    test eax,0xc
```

Does it make sense? We changed the program origin address, but opcodes remain the same. It's like we do nothing and nasm doesn't respect the org directive.

![0 gGlndQsdeZskVXEK](https://github.com/flydeoo/mya/assets/41344995/ffd55545-8df8-4539-9106-4686c91b0a7f)

It may seem confusing, but there's actually an explanation for this.

If you look at the objdump result, on line 0x0c, you probably see that "eb" is opcode for jump, and therefore "04" is related to where it should jump.

If you look carefully you will notice that "04" is distance between the jump instruction and label address (0x12–0x0e = 0x04).

This means jumping to a label does not involve jumping to the absolute address of the label, but rather to the relative address of the label via offset from the jump instruction to the label.

As a result, it doesn't make difference between when we use the org directive and when we don't.

But there are other situations that it does matter to use the org directive and we can see the difference:

Far jump.

``` assembly
org 0x800

mov eax, 9

jmp 0x00:sum

mov ebx, 2
mov eax, 8

sum:

add eax, 1
mov ebx, eax
```

objdump result:

```
   0:   66 b8 09 00 00 00    mov eax,0x9
   6:   ea 17 08 00 00       jmp 0x0:0x817
   b:   66 bb 02 00 00 00    mov ebx,0x2
  11:   66 b8 08 00 00 00    mov eax,0x8
  17:   66 83 c0 01          add eax,0x1
  1b:   66 89 c3             mov ebx,eax

```

As you can see org directive affects the jump addressing.

another example would be:

``` assembly
org 0x100
mov eax, 5
mov ebx, 7

mov al, 0

txt: db "Hello"

mov al, 0

msg: db "world"

mov al, 0

jmp sum

add eax, 8
mov ecx, txt
mov ecx, [txt]
mov ebx, msg
mov ebx, [msg]

sum:
add eax, ebx
test eax, 12
```

Then assemble and inspect it:

```
   0:   66 b8 05 00 00 00    mov eax,0x5
   6:   66 bb 07 00 00 00    mov ebx,0x7
   c:   b0 00                mov al,0x0
   e:   48                   dec ax
   f:    65 6c               gs ins BYTE PTR es:[di],dx
  11:   6c                   ins BYTE PTR es:[di],dx
  12:   6f                   outs   dx,WORD PTR ds:[si]
  13:   b0 00                mov al,0x0
  15:   77 6f                ja  0x86
  17:   72 6c                jb  0x85
  19:   64 b0 00             fs mov al,0x0
  1c:   eb 1a                jmp 0x38
  1e:   66 83 c0 08          add eax,0x8
  22:   66 b9 0e 01 00 00    mov ecx,0x10e
  28:   66 8b 0e 0e 01       mov ecx,DWORD PTR ds:0x10e
  2d:   66 bb 15 01 00 00    mov ebx,0x115
  33:   66 8b 1e 15 01       mov ebx,DWORD PTR ds:0x115
  38:   66 01 d8             add eax,ebx
  3b:   66 a9 0c 00 00 00    test eax,0xc
```

There is an issue here: object dump assumes our data as instruction so it disassembles it as instruction which is incorrect. We can ignore:

```
   e:   48                    dec ax
   f:    65 6c                gs ins BYTE PTR es:[di],dx
  11:   6c                    ins BYTE PTR es:[di],dx
  12:   6f                    outs   dx,WORD PTR ds:[si]
```

And

```
  15:   77 6f                 ja  0x86
  17:   72 6c                 jb  0x85
```

They are just data, not instructions.



As you can see in the instructions:

```
  22:   66 b9 0e 01 00 00    mov ecx,0x10e                | mov ecx, txt
  28:   66 8b 0e 0e 01       mov ecx,DWORD PTR ds:0x10e   | mov ecx, [txt]
  2d:   66 bb 15 01 00 00    mov ebx,0x115                | mov ebx, msg
  33:   66 8b 1e 15 01       mov ebx,DWORD PTR ds:0x115   | mov ebx, [msg]
```

txt placed on address "0x0e" and msg placed on address "0x15".

Because of org 0x100, the origin of the program changed, and instead of having mov ecx, 0x0e we have mov ecx, 0x10e which is 0x100+e.

> Note: There is a NASM directive called "rel" in 64-bit mode that can make relative addresses (relative to rip) instead of absolute addresses.


Now let's start our adventure to code:


At this stage, we are going to design a simple bootloader. It's also important to say that we are creating a tiny OS based on x86 architecture.


x86 CPUs, for the sake of backward compatibility, start in 16-bit mode which is called real mode. Yes, even nowadays modern 64-bit CPUs start in legacy 16-bit real mode and then switch to protected mode which we talk about it later.


> Note:
> I was reading about the history of x86 processors and I realized that even though a 64-bit CPU like Intel i7 uses a 36-bit address bus, it is still categorized as a 64-bit processor. This made me wonder why it has a 64-bit category if its address size is not 64-bit. Could you clarify this? The answer is that the bitness of a CPU is determined by the size of its registers and not by the size of its address bus. A 64-bit CPU means that it can store and manipulate 64 bits of data at a time.

So first step is to tell the assembler to assemble code with 16-bit opcodes.


To do that, open a new file:

``` bash
vim boot.asm
```

and then in the source file we simply write:

``` assembly
bits 16
```

save and exit (only legends know how to exit vim)


> Reminder:
> bit 16 is not part of assembly language but it's assembler directive. directives are just kind of preprocessing commands that modify assembler behavior.



ok. Let's demonstrate our situation:

- we have an assembly program named boot.asm.
  
- another pre-written program called bios, scans disks, floppies, and … to find the bootloader and put it on somewhere in memory.
  
this is a good picture that describes how bios works from this resource (https://www.apriorit.com/dev-blog/66-develop-boot-loader).

![0 GbvC_ci9D0X-RsMs](https://github.com/flydeoo/mya/assets/41344995/213fb7b1-9889-4437-8428-2f29ab700e48)

- CPU is in real mode which means it has segment registers for each segment of running program. and due to some design limits, its hardware relocation is not as simple as:

```
  physical address = base + logical address
```

it's like:
```
physical address = (base * 16) + logical address
```

the CPU is at your disposal and it has a pair of registers for each logical section (segment) of your program, so you can have a program with different segments like text, data and … and load it to different parts of RAM and then set those registers in cpu to point to those program sections in RAM.


but here we miss two main things:

First, we don't have a linker and linker script that manages the program address references to different sections and relocations.


and the second one is that the bios copy the program as a whole to address 0x7c00.

bios don't copy each section of the program to a different address. to do that a program called "loader" is needed. (which is an important part of the operating system)

so our bootloader copied by bios to ram and it doesn't have any logical segment (or section)


(while the CPU supports it, bios software doesn't use this capability and honestly, why do we need to load the bootloader in different parts of the memory? it is just a simple program and doesn't need such complexity.)

for this session, I just want to have a simple bootloader that doesn't do anything related to bootloading an OS. I want to have just a bootloader that leverages bios interrupts to print text to the screen.


to do that we need to define data that we want to print in our source file.

let's write it down:

``` assembly
bits 16

msg: db "Hello, world!"
```

because we define data in our program that we want to reference to it later, we have to set a CPU register named DS (data segment) to address in memory that our program loaded by bios. why?

let's see this program:

``` assembly
bits 16
msg: db "Hello, world!"
mov ax, msg
mov ax, [msg]
```

and inspect it with objdump:

```
   0:   48                    data
   1:   65 6c                 data
   3:   6c                    data
   4:   6f                    data
   5:   2c 20                 data
   7:   77 6f                 data
   9:   72 6c                 data
   b:   64 21 b8 00 00        and WORD PTR fs:[bx+si+0x0],di
  10:   a1 00 00              mov ax,ds:0x0
```
so as you see mov instruction references to data that we define with addressing that starts from 0 and since our data is defined at the start of the file, it has address 0.

When CPU executes mov instruction with reference to data, it uses hardware relocation with DS register.

so the CPU deals with data addresses like this:

```
physical address of data = (Data segment *16) + logical address (which is 0x0 here)
```

and we know that our program loaded by bios to address 0x7c00.

so the data actually saved to address 0x7c00 + 0x0

```
0x7c00 = (data segment*16) + 0x0
```

thus the data segment should be set to 0x7c0 (0x7c0*16 = 0x7c00)


> Note:
> yes, we can use the org directive instead of setting data segment and it makes the same result:
> physical address = (segment address * 16) + logical address
> 0x7c00 = (0x0*16) + 0x7c00

so far our program looks like this:

``` assembly
bits 16

mov ax, 0x7C0
mov ds, ax

msg: db "Hello, world!"
```

now it's time to use bios interrupt functions to write something to the screen.

to do that we leverage bios interrupt 0x10. (http://www.ctyme.com/intr/rb-0106.htm)

```
int 0x10/AH=0x0e:

AH = 0Eh
AL = character to write
BH = page number
BL = foreground color (graphics modes only)

mov ah, 0x0E        ; print character to TTY
mov al, [char]
mov bh, 0x00        ; page number 0 
mov bl, 0x00        ; foreground color, irrelevant - in text mode

```

this code prints a character to the screen. so we need to loop over it:

``` assembly
bits 16

mov ax, 0x7c0
mov ds, ax

msg: db "Hello, world!"

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

exit: 
mov ax, 0
```

and the whole file would be like this:

``` assembly
bits 16

mov ax, 0x7c0
mov ds, ax

msg: db "Hello, world!"

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

exit: 
mov ax, 0

times 510-($-$$) db 0 
dw 0xAA55
```

following code:

``` assembly
times 510-($-$$) db 0
dw 0xAA55
```

adds a two-byte signature (which is 0xAA 0x55) at byte numbers 511 and 512, so bios can recognize our bootloader.

to compile it using nasm, run the following command:

``` bash
nasm -f bin -o boot.bin boot.asm
```

which produces flat binary of our bootloader.

then we need to test our boot loader. I prefer to use qemu.

qemu is quick emulator that can provide a host to run our low-level program.

To run our program on a 16-bit machine using qemu, we can use the following command:

``` bash
qemu-system-i386 -fda boot.bin
```

and when you do that you should see the following picture:

![0 r5iIYRjdPbJkvFJN](https://github.com/flydeoo/mya/assets/41344995/37c8ccc5-ec3f-440f-91a9-17dc3b681b4b)

you see "Hello, world!" in your qemu?

I don't see that in mine either.

Why is it not working even though we are doing everything right?

![0 OwCvRQ2etQFm28F7](https://github.com/flydeoo/mya/assets/41344995/3d763a48-f774-4897-92f1-14f09910a1b9)


there is no myth behind it. actually, there is a good explanation for that.

if we check the binary code produced by assembler:

``` bash
objdump -b binary -m i8086 -M intel -D boot.bin
```

we see:
```
   0:   b8 c0 07              mov ax,0x7c0
   3:   8e d8                 mov ds,ax
   5:   48                    dec ax
   6:   65 6c                 gs ins BYTE PTR es:[di],dx
   8:   6c                    ins BYTE PTR es:[di],dx
   9:   6f                    outs   dx,WORD PTR ds:[si]
   a:   2c 20                 sub al,0x20
   c:   77 6f                 ja  0x7d
   e:   72 6c                 jb  0x7c
  10:   64 21 b4 0e b7        and WORD PTR fs:[si-0x48f2],si
  15:   00 b3 00 be           add BYTE PTR [bp+di-0x4200],dh
  19:   00 00                 add BYTE PTR [bx+si],al
  1b:   b9 00 00              mov cx,0x0
  1e:   83 f9 0e              cmp cx,0xe
  21:   74 0d                 je  0x30
  23:   8d 36 05 00           lea si,ds:0x5
  27:   01 ce                 add si,cx
  29:   8a 04                 mov al,BYTE PTR [si]
  2b:   cd 10                 int 0x10
  2d:   41                    inc cx
  2e:   eb ee                 jmp 0x1e
  30:   b8 00 00              mov ax,0x0
     ...
 1fb:   00 00                 add BYTE PTR [bx+si],al
 1fd:   00 55 aa              add BYTE PTR [di-0x56],dl
```

we see that our data lay between addresses 0x05 to 0x10.

the hex equivalent for "Hello, world!" is "48 65 6C 6C 6F 2C 20 77 6F 72 6C 64 21"

but these hex values can also represent opcodes of instructions.

and if CPU executes them, unpredicted behavior happens.

for example, in our case, this chain of hex represents these assembly instructions:

```
   5:   48                    dec ax
   6:   65 6c                 gs ins BYTE PTR es:[di],dx
   8:   6c                    ins BYTE PTR es:[di],dx
   9:   6f                    outs   dx,WORD PTR ds:[si]
   a:   2c 20                 sub al,0x20
   c:   77 6f                 ja  0x7d
   e:   72 6c                 jb  0x7c
  10:   64 21 b4 0e b7        and WORD PTR fs:[si-0x48f2],si
```

that's exactly why our program won't work. As you see on addresses 0x0c and 0x0e we have two conditional jumps (and one of them fires).

so the CPU jumps to an address that we don't know what is there and never executes our code. that's why our program doesn't work.

there is no way to say to the CPU that "Hey CPU this is data, don't act like instruction for this."

so to fix this issue, we just need to put data out of the CPU execution path.

to do that, just move data to the end of our code:

``` assembly
bits 16

mov ax, 0x7c0
mov ds, ax

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

exit: 
mov ax, 0

msg: db "Hello, world!"

times 510-($-$$) db 0
dw 0xAA55
```

It's time to determine whether it's working or not:

![0 hhegT46Jx2tM_NS4](https://github.com/flydeoo/mya/assets/41344995/410284f0-3732-4afb-bfe6-46053346ba6a)

congrats! it's working. we just wrote our first program that runs on a 16-bit machine without any OS, together.

I think it's time to wrap up this article.

For access to the codes of this project and more, please check out the following GitHub repository: https://github.com/flydeoo/mya

Thank you for reading and see you in the next episode.

