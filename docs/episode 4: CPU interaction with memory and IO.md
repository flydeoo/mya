It’s nice to have you here on episode 4 of Making Tiny OS.

today we are talking about CPU interaction with RAM and ROM via address and control bus.

In fact, we are going to investigate x86 memory map and learn how CPU addressing works.

osdev has an excellent article on the [x86 memory map](https://wiki.osdev.org/Memory_Map_(x86)). If you go to the article, there’s a picture that describes the real-mode address space:

![image](https://github.com/flydeoo/mya/assets/41344995/51e57b31-8a41-4038-b5da-3914a8d4313f)

The first time I saw this picture, many questions popped into my mind:


* what is address space meaning?
* what is ROM doing here? aren’t these addresses from RAM?
* what is the meaning of “hardware mapped”?
* Are they connecting some memory addresses to hardware so that if we write to these RAM addresses, the hardware will notice it through those connections?


I strongly recommend watching [this](https://youtu.be/4knBXkN1GEU?si=zfrZKdaG-3zoNlRp) youtube video before you continue reading this episode:

![image](https://github.com/flydeoo/mya/assets/41344995/11fdfd5d-36b8-4a92-9ba4-e3b39296cf5a)


and for curious ones who want to know the answer:

those addresses in the memory map table are “address space” (I rather say “CPU address space”), and they mean what ranges from the CPU address bus dedicated to which peripheral.

and hardware mapped doesn’t mean that. it means those ranges of address in the CPU address bus, are designed to go to hardware. so actually when you send data to those addresses, your data won’t written in memory, it goes to hardware (usually there are circuits to do that).


in order to have a better view, I prepare some examples:

assume that we have a special CPU with 4 4-bit address bus (for the sake of simplicity) and there is just a RAM and a ROM that CPU wants to interact with:

![image](https://github.com/flydeoo/mya/assets/41344995/da3f8bfd-efd3-4204-a1d7-460b6dde0361)

a 4-bit address bus can serve up to 16 addresses. so the CPU can just address from 0 to 15.

With this in mind, one approach for interacting with RAM and ROM is like:

let’s use different instructions for RAM and ROM, thus we have “mov_ram [0 to 15]” and “mov_rom [0 to 15]”.

this means CPU can use a 16-byte RAM and a 16-byte ROM at the cost of having two instructions.

![image](https://github.com/flydeoo/mya/assets/41344995/6681b01c-7969-45a5-b0f3-df8623b76fa4)


since we have two different instructions for data transfer between CPU and ROM and RAM, there is no need the chop the CPU address space. we can use all address space of the CPU for each peripheral, but just a circuit is needed to determine if the instruction is mov_rom, then select ROM via chip select and if it’s mov_ram, select RAM via chip select. that’s all.



**another approach is like**:

let’s have just 1 instruction for interacting with both RAM and ROM. but how is this possible?

if RAM and ROM share CPU address space, we need something called “circuit address decoding”.

In this case, total addresses of the CPU address bus (which ranges from 0 to 15) are allocated to RAM and ROM. this can be done in different ways.

for example from addresses 0 to 11 dedicated to RAM and from 12 to 15 dedicated to ROM.

via this scheme, we can address a 12-byte RAM and 4-byte ROM via just one instruction like “mov [0 to 15]”.

since we have 1 instruction for both RAM and ROM, chip selection should be done in another way.

inside RAM, cells have addresses from 0 to 11, and inside ROM, cells have addresses from 0 to 3.

so when CPU wants to access address 2, it means it wants to access bytes 2 of RAM, and if CPU wants to access address 14, it means it wants to access byte 3 of ROM.

but how is this done? If CPU issues address 14, how does it know that it should get byte 3 of ROM instead of byte 14 of ROM? (which in this case is not possible since our ROM is a 4-byte ROM.)


this is done by address decoder. address decoder has some inputs and according to those inputs, decides to enable and disable which part of memory. for example, in our case, if CPU wants to interact with address 5, the address decoder enables RAM and disables ROM.

Let me use the binary system to illustrate what’s happening:

![image](https://github.com/flydeoo/mya/assets/41344995/08b25e61-647c-40e8-95c7-9e8d7b6596e0)


first, let’s demonstrate the layout of address space in binary. A0 to A3 are address lines.


```
A3 A2 A1 A0   |(cell addresses of RAM/ROM)| decimal representation of cell address
---------------------- RAM -------------------------
0  0  0  0    | 0000     |    0
0  0  0  1    | 0001     |    1
0  0  1  0    | 0010     |    2
0  0  1  1    | 0100     |    3
0  1  0  0    | 0100     |    4
0  1  0  1    | 0101     |    5
0  1  1  0    | 0110     |    6
0  1  1  1    | 0111     |    7
1  0  0  0    | 1000     |    8
1  0  0  1    | 1001     |    9
1  0  1  0    | 1010     |    10
1  0  1  1    | 1011     |    11
---------------------- ROM -------------------------
1  1  0  0    | 00       |    12
1  1  0  1    | 01       |    13
1  1  1  0    | 10       |    14
1  1  1  1    | 11       |    15
```

as you can see when CPU wants to interact with RAM, it is all good. but when it wants to interact with ROM addresses, there is a problem.

for example, CPU issues address 1110 (in binary) but it means cell 10 (3 in decimal) of ROM. how does this kind of mapping happen?

if you look at the binary representation of ROM addresses you probably see that the “A1 A0” sequence matches the cell address of ROM (yes, this is black magic of binary). so let’s just connect the A0 and A1 to ROM. thus with this approach, we achieve our goal.

![image](https://github.com/flydeoo/mya/assets/41344995/0112b7e0-519c-44d2-8f8c-7bbfd6527063)




**want another example? ok let’s dive into**:

assume we have a 4-bit CPU address bus (again!). we have 8-byte ROM which acquires the CPU address space from 0 to 7 and 8-byte RAM which acquires the CPU address space from 8 to 15.

![image](https://github.com/flydeoo/mya/assets/41344995/b7548ce6-8235-4e77-b379-37e34bacc686)



```
A3 A2 A1 A0   |(cell addresses of RAM/ROM)| decimal representation of cell address
---------------------- ROM -------------------------
0  0  0  0    | 000     |    0
0  0  0  1    | 001     |    1
0  0  1  0    | 010     |    2
0  0  1  1    | 011     |    3
0  1  0  0    | 100     |    4
0  1  0  1    | 101     |    5
0  1  1  0    | 110     |    6
0  1  1  1    | 111     |    7
---------------------- RAM -------------------------
1  0  0  0    | 000     |    8
1  0  0  1    | 001     |    9
1  0  1  0    | 010     |    10
1  0  1  1    | 011     |    11
1  1  0  0    | 100     |    12
1  1  0  1    | 101     |    13
1  1  1  0    | 110     |    14
1  1  1  1    | 111     |    15
```

This time we can just connect A0, A1, and A2 to RAM and ROM.

![image](https://github.com/flydeoo/mya/assets/41344995/60932716-49e3-4f09-aed6-5965e03892ac)



about binary black magic:


in binary, a number after a sequence of ones is the number that we can place our RAM or ROM address space. why?

because the next number of that is like:

```
1{sequence of zeros}
```

and it’s good because if we ignore 1 and all left-hand side numbers, we can map this sequence of zeros to the zero address of our device (ROM or RAM or whatever) and …


Here is another example from Chegg:

![image](https://github.com/flydeoo/mya/assets/41344995/5c07cc4c-4971-4735-841b-b56d216a6cb9)

> Note: Chip Select (CS) is usually active low but it seems in this example, it is active high.

for example, when A6 and A7 lines are low, just the first RAM slot is selected.

![image](https://github.com/flydeoo/mya/assets/41344995/bbc1ded1-d6c4-4023-9ff5-3736f6cd7e1f)

![image](https://github.com/flydeoo/mya/assets/41344995/f24d8b7f-b4ff-4dc9-bed1-dc881b960133)



**Bonus part: Let’s discuss I/O**:
> The information for this part of the article was collected from various blogs, including pictures and text, so all credit goes to them.

![image](https://github.com/flydeoo/mya/assets/41344995/c778b0c7-6843-4348-9146-4fac66083868)

**Memory-mapped IO vs Port-mapped IO**

Microprocessors normally use two methods to connect external devices: memory mapped or port mapped I/O. However, as far as the peripheral is concerned, both methods are really identical.

Memory mapped I/O is mapped into the same address space as program memory and/or user memory, and is accessed in the same way.

Port mapped I/O uses a separate, dedicated address space and is accessed via a dedicated set of microprocessor instructions.

The difference between the two schemes occurs within the microprocessor. Intel has, for the most part, used the port mapped scheme for their microprocessors and Motorola has used the memory mapped scheme.

As 16-bit processors have become obsolete and replaced with 32-bit and 64-bit in general use, reserving ranges of memory address space for I/O is less of a problem, as the memory address space of the processor is usually much larger than the required space for all memory and I/O devices in a system.

Therefore, it has become more frequently practical to take advantage of the benefits of memory-mapped I/O. However, even with address space being no longer a major concern, neither I/O mapping method is universally superior to the other, and there will be cases where using port-mapped I/O is still preferable.




**Memory-mapped IO (MMIO)**

![image](https://github.com/flydeoo/mya/assets/41344995/9d28397c-3133-45d1-affe-3c1b89a8d911)

Picture source : [IO Devices](http://www.grimware.org/doku.php/documentations/devices/io.devices)

I/O devices are mapped into the system memory map along with RAM and ROM. To access a hardware device, simply read or write to those ‘special’ addresses using the normal memory access instructions.

The advantage to this method is that every instruction which can access memory can be used to manipulate an I/O device.

The disadvantage to this method is that the entire address bus must be fully decoded for every device. For example, a machine with a 32-bit address bus would require logic gates to resolve the state of all 32 address lines to properly decode the specific address of any device. This increases the cost of adding hardware to the machine.


**Port-mapped IO (PMIO or Isolated IO)**

![image](https://github.com/flydeoo/mya/assets/41344995/bbd10dc7-3a86-4c24-a544-907ff565a27a)

Picture source : [IO Devices](http://www.grimware.org/doku.php/documentations/devices/io.devices)

I/O devices are mapped into a separate address space. This is usually accomplished by having a different set of signal lines to indicate a memory access versus a port access. The address lines are usually shared between the two address spaces, but less of them are used for accessing ports. An example of this is the standard PC which uses 16 bits of port address space, but 32 bits of memory address space.

The advantage to this system is that less logic is needed to decode a discrete address and therefore less cost to add hardware devices to a machine. On the older PC compatible machines, only 10 bits of address space were decoded for I/O ports and so there were only 1024 unique port locations; modern PC’s decode all 16 address lines. To read or write from a hardware device, special port I/O instructions are used.

From a software perspective, this is a slight disadvantage because more instructions are required to accomplish the same task. For instance, if we wanted to test one bit on a memory mapped port, there is a single instruction to test a bit in memory, but for ports we must read the data into a register, then test the bit.



**Comparison — Memory-mapped vs port-mapped**

![image](https://github.com/flydeoo/mya/assets/41344995/b7ddc5cf-cebc-4931-b894-19fc42bb5d3c)


> Note: An I/O address, also called a “port address”

I hope this article helps you get a better understanding of how things work.


Thank you for reading and see you in the next episode.

