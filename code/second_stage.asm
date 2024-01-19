bits 16

org 0xa411


cli
call enable_a20
call load_gdt


mov eax, cr0 
or al, 1       ; set PE (Protection Enable) bit in CR0 (Control Register 0)
mov cr0, eax

jmp 0x08:pmode_main



pmode_main:
[bits 32]

mov eax, 0x10

mov ax, 0x10	; offset of data segment in GDT
mov ds, ax
mov ss, ax

; use same stack that real mode used:
mov eax, 0xA410
mov esp, eax
mov ebp, eax







enable_a20:
[bits 16]

push    ax         	;Saves AX
mov al, 0xdd		; Look at the command list 
out 0x64, al   		;Command Register 
pop ax          	;Restore's AX
ret 



start_of_GDT:
[bits 16]

	dq 0		; NULL descriptor
	

			; code segment
	dw 0xffff	; segment limit 0-15
	dw 0x0000	; segment base  0-15
	db 0x00		; segment base  16-23
	db 10011010b	; access
	db 11001111b	; flags + limit 16-19
	db 0x00		; base base 24-31



			; data segment
	dw 0xffff	; segment limit 0-15
	dw 0x0000	; segment base  0-15
	db 0x00		; segment base  16-23
	db 10010010b	; access
	db 11001111b	; flags + limit 16-19
	db 0x00		; base base 24-31

end_of_GDT:
[bits 16]
		dw end_of_GDT -  start_of_GDT - 1	; gdt size
		dd start_of_GDT				; address of gdt


load_gdt:
[bits 16]

lgdt [end_of_GDT]

ret


