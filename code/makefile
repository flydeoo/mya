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
