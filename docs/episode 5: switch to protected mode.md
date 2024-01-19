Hello, programmers! Welcome back to another episode of creating a tiny OS.

Today, we will be focusing on building a second-stage bootloader. We will be using the BIOS interrupt 0x13 to switch to the second-stage bootloader.

Then, we will define the Global Descriptor Table (GDT), enable the A20 line, and finally, switch to protected mode.

Thank you for joining us, and let's get started!

## second stage bootloader
Although our main bootloader has not reached its 512 bytes capacity, it's good practice to create second stage bootloader and switch to it.

![0 5vgFiT5lApEdcz9t](https://github.com/flydeoo/mya/assets/41344995/93f1419c-c80c-4e1b-9d3a-37738dbfdb63)

We need to determine the location of the second stage bootloader in memory to create it.

to decide where to put the second stage bootloader, here is a view of the RAM:

![0 6Hg03-jBeMExSubx](https://github.com/flydeoo/mya/assets/41344995/78d49122-3657-4f2f-8703-1338f2757a31)

I would like to place our new bootloader on 0xa411 which is 1 byte after the base pointer.

thus, the memory map would change to:

![0 mAlYypXFvE65Z3_p](https://github.com/flydeoo/mya/assets/41344995/6b23ea68-8c94-4eca-94d5-0d3c2a812f58)

Now, we can start coding our second stage bootloader:

``` bash
vim second_stage.asm
```

and write the following code to the file:

``` assembly
bits 16
org 0xa411

cli
```

then assemble and make a binary file out of it:

``` bash
nasm -f bin -o second_stage.bin second_stage.asm
```

For loading the second stage bootloader into the RAM, we need to call a BIOS interrupt in the main.asm file, using the second_stage.bin file.

To do this, we need to add two things to the makefile:

Firstly, we must insert our second_stage.bin file as "hda" to QEMU:

``` bash
qemu-system-i386 -fda boot.bin -hda second_stage.bin -s -S
```

and then make another break point to 0xa411 which is start of our second stage bootloader:

``` bash
gdb -ex "target remote :1234" -ex "b *0x7c00" -ex "b *0xa411" -ex "set tdesc filename gdb_asset/target.xml" -ex "layout asm"
```

so far the makefile looks like this:

``` makefile
boot.bin: boot.asm
       nasm -f bin -o boot.bin boot.asm

.PHONY: run debug

run:
     $(MAKE) && qemu-system-i386 -fda boot.bin -hda second_stage.bin -s -S

debug:
     #qemu-system-i386 -s -S -fda boot.bin
     gdb -ex "target remote :1234" -ex "b *0x7c00" -ex "b *0xa411" -ex "set tdesc filename gdb_asset/target.xml" -ex "layout asm"
```

There is an introduction for using bios INT 0x13:

there is a legacy way of accessing data called "CHS" which is designed to work with hard disks.
each hard disk consists of some disks, which are so-called platters:

![0 zu9Ma8WfyjA7ulcf](https://github.com/flydeoo/mya/assets/41344995/9c416ee7-4880-4acd-ad37-6c0051bfbeed)

(image from [blocksandfiles](https://blocksandfiles.com/2022/04/20/chs/))

and for each disk, there are two surfaces called head:

![0 R6yTzteiZml7o_Nb](https://github.com/flydeoo/mya/assets/41344995/a78bf2db-e59e-4941-87eb-f9aca57c0a39)

(image from [dataclinic](http://www.dataclinic.it/data-recovery/hard-disk-functionality.htm))

each surface consists of some sectors:

![0 RYunz98h0lSGWhtd](https://github.com/flydeoo/mya/assets/41344995/884edaad-b945-456b-9b49-1683176a727f)

(image from [stackoverflow](https://stackoverflow.com/questions/32642016/chs-to-lba-mapping-disk-storage))

and chain of sectors on the surface creates tracks:

![0 ehyR-CexamiiW9S7](https://github.com/flydeoo/mya/assets/41344995/fd5745e0-991e-4117-a721-f9259ca820e2)

Cylinders are vertically formed by tracks. In other words, track 12 on platter 0 plus track 12 on platter 1 … is cylinder 12:

![0 jceDOyZOSDKZbXM4](https://github.com/flydeoo/mya/assets/41344995/302162af-6fc6-4912-b6eb-09d05dad27ed)

> Note: The number of cylinders of a disk drive exactly equals the number of tracks on a single surface in the drive.


Geometry:
- Cylinder Number - 1020 (0–1024)
- Head Number - 16 (0–256)
- Sector Number - 63 (1–64)


Now that you are familiar with CHS addressing, let's move to the code:

``` assembly
load_hda:

mov ah, 2 
mov al, 1       ; count of sectors 
mov ch, 0       ; start of cylinder (C) 
mov cl, 1       ; start of sector   (S) (starts from 1) 
mov dh, 0       ; head              (H) 
mov dl, 0x80    ; read from hda 
mov bx, 0xA411  ; buffer 

int 0x13 

ret
```

> Note: we will have episode on hard disk and work with it. for now just accept this config.

and then just jump to our second stage bootloader:

``` assembly
jmp 0xa411
```

so far the "boot.asm" looks like this:

``` assembly
bits 16

mov ax, 0x7c0
mov ds, ax

mov ax, 0x840
mov ss, ax

mov ax, 0x2000
mov sp, ax
mov bp, ax

call clear_screen
call print_text
call load_hda
jmp 0xa411

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

mov ah, 0x07     ; tells BIOS to scroll down window
mov al, 0x00     ; clear entire window
mov bh, 0x07     ; white on black
mov cx, 0x00     ; specifies top left of screen as (0,0)
mov dh, 0x18     ; 18h = 24 rows of chars
mov dl, 0x4f      ; 4fh = 79 cols of chars
int 0x10          ; calls video interrupt

ret

exit:
mov ax, 0

load_hda:

mov ah, 2
mov al, 1         ; count of sectors
mov ch, 0         ; start of cylinder (C)
mov cl, 1         ; start of sector   (S) (starts from 1)
mov dh, 0         ; head               (H)
mov dl, 0x80     ; read from hda
mov bx, 0xA411   ; buffer
int 0x13

ret

msg: db "Hello, world!"

times 510-($-$$) db 0
dw 0xAA55
```

and now it's time to test.

> Spoiler Alert: It won't work!

to do that use the following commands:

``` bash
make run

make debug
```

![0 jcqjlhODZCi22ayr](https://github.com/flydeoo/mya/assets/41344995/2d7e7e65-9ab5-4454-a428-600c7805498e)

as you see in address "0x7c1a", jump instruction changed from "0xa411" to "0x2011"!

it feels like:

![0 KXfli9A_nvnJl9LC](https://github.com/flydeoo/mya/assets/41344995/a66dd857-e5ae-4861-82f5-78617e45b90c)

don't worry. we suffer and prevail together.

there is an explanation for it, like always.

First, it's not important how you write your jump, it's about how assembler bakes it!

in our case when I use object dump to debug binary:

``` bash
objdump -b binary -m i8086 -M intel -D boot.bin
```
```
  17:   e8 35 00              call   0x4f
  1a:   e9 f4 a3              jmp 0xa411
  1d:   b4 0e                 mov ah,0xe
```

In the above dump, I can see that the assembler changed "jmp 0xa411" to a relative jump with an offset from the instruction pointer.

assembler thinks like "ok, Let's make it relative to IP. IP is 0x1d so, I choose 0xa3f4"

this results in:

```
0xa3f4 + IP (which assembler thinks it is 1d) = 0xa411
```

but IP is not "0x1d" at that point. it is "0x7c1d":

![0 QEs7Ukg2kwamrgcS](https://github.com/flydeoo/mya/assets/41344995/eb6b7eb9-d253-409a-9576-80e9311ab19a)


as you see the next instruction is 0x7c1d, so the real IP is 0x7c1d not 0x1d, and thus

CPU adds 0xa3f4 to real IP which is 0x7c1d:

```
0xa3f4 + 0x7c1d = 0x12011
```

and since CPU is limited to 16-bit right now, it omits the MSB and makes it to 0x2011.

```
(0x12011 – 64KB(0x1000) = 0x2011)
```

that's why it shows "jmp 0x2011".

in order to fix this issue, we have two ways:

use absolute jump with help of far jump:

``` assembly
jmp 0x00:0xa411
```

or use org directive to inform the assembler from real IP value.


> Note: During the assemble time ORG directive resets the MLC (memory location counter) to the address specified in the ORG directive.
from: [stackoverflow](https://stackoverflow.com/questions/3407023/what-does-org-assembly-instruction-do)


you can see the difference between when we use org directive and when we don't:

without org directive:

```
0x0:  instruction
0x1:  instruction
0x2:  instruction
0x3:  instruction
```

with org directive: (org 0x7c00)

```
0x7c00: instruction
0x7c01: instruction
0x7c02: instruction
0x7c03: instruction
```

so when we use org directive, the jump instruction changes like:

```
  17:   e8 35 00              call   0x4f
  1a:   e9 f4 27              jmp 0x2811
  1d:   b4 0e                 mov ah,0xe
```

and if we add 0x27f4 + real IP which is 0x7c1d, results in 0xa411. the exact address that we want.

but now we have another issue! the print function doesn't work.

![0 -bZtTcOTQmtHCsa2](https://github.com/flydeoo/mya/assets/41344995/c48d7bf2-5be1-4b15-8839-65ecd39c5316)

In the previous episode, we discussed the concept of addressing and provided some examples to illustrate it.

a quick review would be:

```
mov -> use absolute address
jmp -> use relative address
```
(by jmp, I don't mean far jump)

When we use "jump to label" command within our source code, it still functions properly.

whether the label is on address 0x5 and IP assumed to be 0x1

and when (with org 0x10) label is on address 0x15 and IP assumed to be 0x11, the distance remains the same.

so the functionality of jumps is preserved.


but for "mov" instruction, it's a different story.

we know the mov instruction works like this:

```
DS : logical_address
```

as you know we set DS to 0x7c0. so whatever is on logical_address adds to 0x7c00:

```
0x7c00 + logical_address
```

as I said earlier, mov instruction uses absolute address. so when we use org 0x7c00, the mov opcodes changes from "0x64" to "0x7c64".

so before org directive, it's like:

```
0x7c00 + 0x64 = 0x7c64
```

but now with org directive:

```
0x7c00 + 0x7c64 = invalid address
```

that's why our print function doesn't work.

so, the option is to set DS zero and let org manage it. especially when we get to GDT and protected mode, we have to get rid of these segment registers. so why don't do that right now?

In order to do that we remove these lines from our code:

``` assembly
mov ax, 0x7c0
mov ds, ax
```

so far our boot.asm is like:

``` assembly
bits 16

org 0x7c00

mov ax, 0x840
mov ss, ax

mov ax, 0x2000
mov sp, ax
mov bp, ax

call clear_screen
call print_text
call load_hda
jmp 0xa411

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

mov ah, 0x07     ; tells BIOS to scroll down window
mov al, 0x00     ; clear entire window
mov bh, 0x07     ; white on black
mov cx, 0x00     ; specifies top left of screen as (0,0)
mov dh, 0x18     ; 18h = 24 rows of chars
mov dl, 0x4f      ; 4fh = 79 cols of chars
int 0x10          ; calls video interrupt

ret

exit:
mov ax, 0

load_hda:

mov ah, 2
mov al, 1         ; count of sectors
mov ch, 0         ; start of cylinder (C)
mov cl, 1         ; start of sector   (S) (starts from 1)
mov dh, 0         ; head              (H)
mov dl, 0x80     ; read from hda
mov bx, 0xA411   ; buffer
int 0x13

ret

msg: db "Hello, world!"

times 510-($-$$) db 0
dw 0xAA55
```

and it works!

![0 tmoBOt_P7T89bBq4](https://github.com/flydeoo/mya/assets/41344995/e04afb3f-c187-49ad-958d-1368a63192a4)

as you see, it prints the Hello world on the screen and also managed to load "hda" to RAM and then jump to it at address "0xa411".


## Protected mode

congrats, we are out of the 512-byte limit of the main bootloader by jumping to the second stage bootloader. now it's time to eliminate real mode limitations, especially 1 MB Memory, and switch to protected mode.

please read about protected mode and its benefits and once you get why we want to switch to protected mode, come back and continue reading this article.

I suggest checking out wikipedia and osdev as they are both good resources for this.

Here are the steps to enter protected mode: (I just copy them from osdev)

Before switching to protected mode, you must:

- Disable interrupts, including NMI (as suggested by Intel Developers Manual).
- Enable the A20 Line.
- Load the Global Descriptor Table with segment descriptors suitable for code, data, and stack.


### Disable interrupts

Simply use the "cli" instruction to disable interrupts. We added it to the second-stage bootloader for testing, but now it's necessary.


### A20 line
You won't believe it, but we need to enable the A20 line of the keyboard for backward compatibility.


You can read more about it on osdev and how it's related to entering protected mode, but personally, I don't think it's necessary to understand all the technical details.
(I think I copied the A20_Enable code from Nano Byte Channel.)

to enable A20 line, we use the following code:

``` assembly
enable_a20:
push ax           ; Saves AX
mov al, 0xdd         ; Look at the command list
out 0x64, al         ; Command Register
pop ax               ; Restore's AX
ret
```

There is one interesting point in this code snippet that we should take note of. It uses the "out" instruction which we previously learned is used for communicating with isolated input/output (I/O) devices. These devices have a separate address space from the computer's memory address space and they have their own set of instructions, such as "out" and "in".

### GDT

now that we have A20 enabled, it's time to define GDT.

GDT stands for Global Descriptor Table. It is Global because we have a local one. but for now, I just want to Talk about GDT.

like any other table, GDT has entries. these entries are also called "segment descriptors".

Each entry in the table provides details of a memory segment such as its address range, permissions, type, and more.

for example, We can define "code segment" in this table by specifying the starting and ending addresses, permissions, and other attributes.

Similarly, we can define a place in memory for data segments using this method.

By using a table, we can define up to 8192 entries for multiple code and data segments.

and then what?

we have a table where we define our segments there.

now remember how CPU hardware relocation works:

```
segment register * 16 + logical address
```
and those segment registers like CS, SS, and DS should fed by us.


When operating in protected mode, this process changes:

CPU uses segment registers such as CS, DS, and SS to locate their corresponding entries in the GDT descriptor table. From these entries, the base address of the segment is determined and added to the logical address to generate the actual address in memory.

the following picture describes it:

![0 QkBx6Ca27giJXfli](https://github.com/flydeoo/mya/assets/41344995/5445f4b0-4b46-4f96-89a4-22f48b1e00fd)

(image from [viralpatel](https://www.viralpatel.net/taj/tutorial/protectedmode.php))

so if we want to compare workflows in real mode and protected mode:

![0 mhCIcXriVnqKGNHY](https://github.com/flydeoo/mya/assets/41344995/523510b3-668a-484e-82da-a840bbb8efb2)

we can just use GDT and define some segments in it and then again set the segment register (but this time set segment registers to offset of entry in GDT). Everything has evolved, yet we still struggle with assigning valid values to segment registers.

The good news is we can get rid of them too!

let's remember how addressing works:

```
segment register:logical_address
```

this is the so-called segmented memory model. but there is a chance to migrate from this memory model to a simpler model that doesn't need to set segment registers by the programmer.

In protected mode unlike real mode, we are in 32-bit mode which means that we don't have real mode limitation, especially the one where the logical address is a 16-bit address, so it can address a 64KB segment.

in protected mode, because of its 32-bit nature, a logical address can address from 0 to 4GB.

as a result, we don't really need segment registers anymore and we can set all of them to zero to create a linear address space.

this is called the flat memory model. you can read about it on:
https://en.wikipedia.org/wiki/Flat_memory_model

![0 UqUt20bJijwLB9fM](https://github.com/flydeoo/mya/assets/41344995/6bad7089-a6d6-441d-b956-508f003b8669)

(image from [c-jump](https://www.c-jump.com/CIS77/ASM/Memory/M77_0330_flat_vs_segmented.htm))

as you see in the above picture all segment registers points to address zero.

it means that in the formula:

```
segment register + logical address
```

the segment register is deleted and just the logical address remains.

> In Room for investigation section of episode 1, I explained how relocation changes in protected mode, if we use flat memory model.

To summarize, we will be utilizing the flat memory model. In this particular model, we set the base address of segment registers in the Global Descriptor Table to 0. As a result, the logical address we use must be the absolute address in memory.

![0 aLN-G7YkBIk6D6-5](https://github.com/flydeoo/mya/assets/41344995/f96819ca-f64a-4c95-883d-c2677c705c23)

As mentioned in the picture, in the flat memory model, the logical address is final address and thus we don't set any segment register, anymore.

I think it's time to move on to fill GDT entries.

osdev has a really good explanation about it on: https://wiki.osdev.org/Global_Descriptor_Table

If you visit the osdev article, you will see that each entry in this table has a complex structure like:

![0 Rl6aXHhpLNnkOBfA](https://github.com/flydeoo/mya/assets/41344995/7903534a-6b8c-4f6e-a0c5-aaddfcdf93af)

I bring a guide on how to read this:

![0 6eCIitLrZkaBUUaL](https://github.com/flydeoo/mya/assets/41344995/c53aa25f-26c7-4f8e-a647-f6468a476729)

and by using the following code, we fill the GDT:

``` assembly
start_of_GDT:

     dq 0         ; NULL descriptor

                     ; code segment
     dw 0xffff    ; segment limit 0-15
     dw 0x0000    ; segment base  0-15
     db 0x00      ; segment base  16-23
     db 10011010b ; access
     db 11001111b ; flags + limit 16-19
     db 0x00      ; base base 24-31

                     ; data segment
     dw 0xffff    ; segment limit 0-15
     dw 0x0000    ; segment base  0-15
     db 0x00      ; segment base  16-23
     db 10010010b ; access
     db 11001111b ; flags + limit 16-19
     db 0x00      ; base base 24-31

end_of_GDT:

             dw end_of_GDT -  start_of_GDT - 1    ; gdt size
             dd start_of_GDT                       ; address of gdt
```

each entry has 8 bytes length.

first, we have a null entry with "dq 0".

then we have code segment with base address 0.

Finally, we have the data segment, which has a base address of 0.

Whether the CPU is in Real Mode or Protected Mode is defined by the lowest bit of the CR0 or MSW register.

we must load the descriptor table into the processor's GDTR register and then set the lowest bit of CR0

to do that we define the following code at the end of the table:

``` assembly
end_of_GDT:

             dw end_of_GDT -  start_of_GDT - 1     ; gdt size
             dd start_of_GDT                       ; address of gdt
```

inform the CPU about the table:

``` assembly
load_gdt:

lgdt [end_of_GDT]

ret
```

then set CR0 using the following code:

``` assembly
mov eax, cr0
or al, 1    ; set PE (Protection Enable) bit in CR0 (Control Register 0)
mov cr0, eax
```

so far the flow of the second stage bootloader looks like this:

``` assembly
cli
call enable_a20
call load_gdt

mov eax, cr0
or al, 1    ; set PE (Protection Enable) bit in CR0 (Control Register 0)
mov cr0, eax
```

we can now switch to protected mode. To do that, we define a label where we would be in protected mode and far jump to it. I'll explain why we should use far jump.

``` assembly
cli
call enable_a20
call load_gdt

mov eax, cr0
or al, 1    ; set PE (Protection Enable) bit in CR0 (Control Register 0)
mov cr0, eax

jmp 0x08:pmode_main

pmode_main:
[bits 32]

mov eax, 0x10
```

as you see, protected mode uses 32-bit architecture and thus if we don't instruct the assembler to assemble this part of the program with 32-bit opcodes, then it will produce 16-bit opcodes which results in invalid code generation.

so here is why we use [bits 32] for pmode_main label.

and because the assembler is not wise enough, it will produce 32-bit opcodes for every function after the pmode_main function, too.

We need to inform the assembler to assemble each function of our code using 16-bit.

to do that. simply add [bits 16] to the start of each label.

so far our second stage bootloader would look like this:

``` assembly
bits 16                                                                                                                                                                                                                                                                                                                                                                               

org 0xa411                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
cli                                                                                                                                                                                                                                                                                                                                                                                     
call enable_a20                                                                                                                                                                                                                                                                                                                                                                         
call load_gdt

mov eax, cr0
or al, 1    ; set PE (Protection Enable) bit in CR0 (Control Register 0)
mov cr0, eax

jmp 0x08:pmode_main

pmode_main:
[bits 32]

mov eax, 0x10

enable_a20:
[bits 16]

push ax           ;Saves AX
mov al, 0xdd         ; Look at the command list
out 0x64, al         ;Command Register
pop ax               ;Restore's AX
ret

start_of_GDT:
[bits 16]

     dq 0         ; NULL descriptor

                     ; code segment
     dw 0xffff    ; segment limit 0-15
     dw 0x0000    ; segment base  0-15
     db 0x00      ; segment base  16-23
     db 10011010b ; access
     db 11001111b ; flags + limit 16-19
     db 0x00      ; base base 24-31

                     ; data segment
     dw 0xffff    ; segment limit 0-15
     dw 0x0000    ; segment base  0-15
     db 0x00      ; segment base  16-23
     db 10010010b ; access
     db 11001111b ; flags + limit 16-19
     db 0x00      ; base base 24-31

end_of_GDT:
[bits 16]
             dw end_of_GDT -  start_of_GDT - 1    ; gdt size
             dd start_of_GDT                      ; address of gdt

load_gdt:
[bits 16]

lgdt [end_of_GDT]

ret
```

and I would like to add second stage bootloader to the makefile, too:

``` makefile
boot.bin: boot.asm
       nasm -f bin -o boot.bin boot.asm

second_stage.bin: second_stage.asm
               nasm -f bin -o second_stage.bin second_stage.asm

all: boot.bin second_stage.bin

.PHONY: run debug

run:
     $(MAKE) all && qemu-system-i386 -fda boot.bin -hda second_stage.bin -s -S

debug:
     #qemu-system-i386 -s -S -fda boot.bin
     gdb -ex "target remote :1234" -ex "b *0x7c00" -ex "b *0xa411" -ex "set tdesc filename gdb_asset/target.xml" -ex "layout asm"
```

To verify, you can execute the following commands:

``` bash
make run
make debug
```

you'll see that we are in protected mode:

![0 f8EUqPhbUxWA1OPG](https://github.com/flydeoo/mya/assets/41344995/851570d8-baab-4c25-9590-4c881d0e1df8)


but how?

we said that in order to enter protected mode, we should define GDT and then make segment registers to point to its entries.

We didn't do it, did we?

Yes, we did. Remember when we made that far jump? That's where we set the segment register.

let me explain. segment register should point to GDT entries? that's true.

we can simply set value to segment registers like:

``` assembly
mov ax, offset_in_GDT

mov DS, ax
mov SS, ax
mov CS, ax
```

Everything in the code is correct except for the last line. It is not possible to change the value of the Code Segment register. Moving a value into this segment register is not allowed. While it is acceptable to modify other segment registers, it cannot be done for CS.

but there is another way to put value into CS. that's "far jump".

with far jump, we set value to CS. syntax of the far jump is like:

``` assembly
jmp x:y
```

which "x" is the part that will loaded into CS. now remember the far jump we use to jump to the protected mode:

``` assembly
jmp 0x08:pmode_main
```

what is "0x08"? the offset of Code Segment in the GDT table!

that's it. we use far jump because we want to set CS to offset in GDT and then jump to protected mode!

but we don't set SS and DS to it's offset in GDT. that's true. let's do it in protected mode:

``` assembly
pmode_main:
[bits 32]

mov eax, 0x10

mov ax, 0x10 ; offset of data segment in GDT
mov ds, ax
mov ss, ax

; use same stack that real mode used:
mov eax, 0xA410
mov esp, eax
mov ebp, eax
```

as you see, since we don't use segmented memory model, I also put the exact location of the stack to SP and BP, too.

Upon testing the bootloader, it seems that everything is working fine. However, some unusual opcodes are appearing in protected mode:

![0 kkL2hSJ5VvZKX9jg](https://github.com/flydeoo/mya/assets/41344995/4af43dc5-50cc-4cd8-aa5a-1f618498d04d)

If you take a look at line "0xa42a", you probably share the same feeling as I do:

![0 uu98OpgbbFv7AkgO](https://github.com/flydeoo/mya/assets/41344995/dd6ed40c-c064-48da-8c23-c6c604f10cba)

joke aside, what happened was that we instructed GDB to disassemble opcodes as 16-bit opcodes. However, when we switched to protected mode which uses 32-bit opcodes, it appeared strange because GDB was attempting to disassemble 32-bit opcodes as 16-bit ones.

to fix this, when you enter protected mode, simply use this command to disassemble in 32-bit manner:

```
set architecture i386
```

and then:

```
disassemble $eip-10, 5
```

you see things look normal again:

![0 c8l1nxyZZJpqs2Hf](https://github.com/flydeoo/mya/assets/41344995/b41bc694-c85d-402f-b1b8-fe3c3d53869b)

that's it.

I think we had one of the longest episodes, but worth it.

We are in a good position to migrate to C. so stay tuned for the next episode as we get things ready for this migration.

If you want to access the codes for this project and more, please visit our GitHub repository at:
https://github.com/flydeoo/mya


Also, check out the episode 5 release at:
https://github.com/flydeoo/mya/releases/tag/v0.05


Thanks for reading. see you in the next episode.
