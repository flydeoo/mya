boot.bin: boot.asm
	  nasm -f bin -o boot.bin boot.asm


.PHONY: run debug

run:
	$(MAKE) && qemu-system-i386 -fda boot.bin -s -S

debug:
	#qemu-system-i386 -s -S -fda boot.bin
	gdb -ex "target remote :1234" -ex "b *0x7c00" -ex "set tdesc filename gdb_asset/target.xml" -ex "layout asm"
