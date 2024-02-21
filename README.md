# what is mya
<p align="center">
<img src="https://repository-images.githubusercontent.com/717717871/cb51134d-cf2a-4552-b633-7acae2573303" alt="mya" style="width: 700px;">
</p>

**`mya`** is a fun project to create a tiny OS from scratch using **x86 assembly** and **C programming language**.
<br><br><br>

# how to use
You can either read each episode from the [doc section](#docs) or [Medium](#other-media).

For each episode that includes code, there is a corresponding [release](https://github.com/flydeoo/mya/releases) with the same name as the episode.
<br><br><br>
# docs

- [episode 0: introduction to the journey of making tiny OS](https://github.com/flydeoo/mya/blob/main/docs/episode%200%3A%20introduction%20to%20the%20journey%20of%20making%20tiny%20OS.md)
<br><br>![Static Badge](https://img.shields.io/badge/concepts-%20-blue) <br><dl><dd><dl><dd><dl><dd>[`introduction`]</dd></dl></dd></dl></dd></dl>
<br>
<br>
<br>

- [episode 1: my understanding of CPU and Memory interaction](https://github.com/flydeoo/mya/blob/main/docs/episode%201%3A%20my%20understanding%20of%20CPU%20and%20Memory%20interaction.md)
<br><br>![Static Badge](https://img.shields.io/badge/concepts-%20-blue) <br><dl><dd><dl><dd><dl><dd>[`the need for labels`, `era of uni programming and multiprogramming`, `linker and Hardware/software based relocation`, `segmentationm`, `OS loader`]</dd></dl></dd></dl></dd></dl>
<br>
<br>
<br>

- [episode 2: write our very first tiny bootloader](https://github.com/flydeoo/mya/blob/main/docs/episode%202%3A%20write%20our%20very%20first%20tiny%20bootloader.md)
<br><br>![Static Badge](https://img.shields.io/badge/concepts-%20-blue) <br><dl><dd><dl><dd><dl><dd>[ `flat binary`, `assembler base address`, `org directive`, `far jump` ]</dd></dl></dd></dl></dd></dl><hr>
![Static Badge](https://img.shields.io/badge/accomplishments-%20-green) <br><dl><dd><dl><dd><dl><dd>[ `writing a simple bootloader`, `using bios interrupt 0x10`, `qemu kickstart` ]</dd></dl></dd></dl></dd></dl>
<br>
<br>
<br>

- [episode 3: Tracing Stack and Function Calls with GDB](https://github.com/flydeoo/mya/blob/main/docs/episode3%3A%20Tracing%20Stack%20and%20Function%20Calls%20with%20GDB.md)
<br><br>![Static Badge](https://img.shields.io/badge/concepts-%20-blue) <br><dl><dd><dl><dd><dl><dd>[ `stack registers: SS, SP, BP` ]</dd></dl></dd></dl></dd></dl><hr>
![Static Badge](https://img.shields.io/badge/accomplishments-%20-green) <br><dl><dd><dl><dd><dl><dd>[ `start using GDB`, `define stack`, `add some functionality to bootloader`, `start using makefile`, `trace stack` ]</dd></dl></dd></dl></dd></dl>
<br>
<br>
<br>

- [episode 4: CPU interaction with memory and IO](https://github.com/flydeoo/mya/blob/main/docs/episode%204%3A%20CPU%20interaction%20with%20memory%20and%20IO.md)
<br><br>![Static Badge](https://img.shields.io/badge/concepts-%20-blue) <br><dl><dd><dl><dd><dl><dd>[ `cpu interaction with RAM and ROM via address and control bus`, `CPU address space`, `binary black magic`, `Memory mapped I/O`, `Isolated mapped I/O` ]</dd></dl></dd></dl></dd></dl>
<br>
<br>
<br>

- [episode 5: switch to protected mode](https://github.com/flydeoo/mya/blob/main/docs/episode%205%3A%20switch%20to%20protected%20mode.md)
<br><br>![Static Badge](https://img.shields.io/badge/concepts-%20-blue) <br><dl><dd><dl><dd><dl><dd>[ `Global Descriptor Table (GDT)`, `CHS addressing`, `absolute vs relative addressing`, `protectd mode` ]</dd></dl></dd></dl></dd></dl><hr>
![Static Badge](https://img.shields.io/badge/accomplishments-%20-green) <br><dl><dd><dl><dd><dl><dd>[ `writing second stage bootloader`, `implementing GDT`, `switch to protected mode`, `using bios interrupt 0x13 and CHS` ]</dd></dl></dd></dl></dd></dl>
<br>
<br>
<br>

- [episode 6: migrate preparation](https://github.com/flydeoo/mya/blob/main/docs/episode%206%3A%20migrate%20preparation.md)
<br><br>![Static Badge](https://img.shields.io/badge/concepts-%20-blue) <br><dl><dd><dl><dd><dl><dd>[ `why migrate to c` ]</dd></dl></dd></dl></dd></dl><hr>
![Static Badge](https://img.shields.io/badge/accomplishments-%20-green) <br><dl><dd><dl><dd><dl><dd>[ `build toolchain (GCC, linker, assembler)` ]</dd></dl></dd></dl></dd></dl>
<br>
<br>
<br>

- [episode 7: migrate to C](https://github.com/flydeoo/mya/blob/main/docs/episode%207%3A%20migrate%20to%20C.md)
<br><br>![Static Badge](https://img.shields.io/badge/concepts-%20-blue) <br><dl><dd><dl><dd><dl><dd>[ `linker script`, `compiler and linker options: -nostdlib -lgcc -ffreestanding` , `C compilation environment: Freestanding and Hosted`, `C call conventions` ]</dd></dl></dd></dl></dd></dl><hr>
![Static Badge](https://img.shields.io/badge/accomplishments-%20-green) <br><dl><dd><dl><dd><dl><dd>[ `writing linker script`, `migrate from assembly to C`, `start writing kernel with C` ]</dd></dl></dd></dl></dd></dl>

<br>
<br>
<br>

# Upcoming episodes



>  More episodes will be determined soon.



# other media

You can also access these episodes on Medium via this link: [flydeoo](https://medium.com/@thisisflydeoo)
