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


