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

mov ah, 0x07        ; tells BIOS to scroll down window
mov al, 0x00        ; clear entire window
mov bh, 0x07        ; white on black
mov cx, 0x00        ; specifies top left of screen as (0,0)
mov dh, 0x18        ; 18h = 24 rows of chars
mov dl, 0x4f        ; 4fh = 79 cols of chars
int 0x10            ; calls video interrupt

ret

exit: 
mov ax, 0

load_hda:


mov ah, 2 
mov al, 1	    ; count of sectors
mov ch, 0 	    ; start of cylinder (C)
mov cl, 1 	    ; start of sector   (S) (starts from 1)
mov dh, 0 	    ; head	        (H)
mov dl, 0x80 	    ; read from hda
mov bx, 0xA411 	    ; buffer
int 0x13

mov ah, 2
mov al, 1	    ; count of sectors
mov ch, 0	    ; start of cylinder (C)
mov cl, 1	    ; start of sector   (S) (starts from 1)
mov dh, 0	    ; head          	(H)
mov dl, 0x81	    ; read from hdb
mov bx, 0xC350	    ; buffer
int 0x13


ret




msg: db "Hello, world!"

times 510-($-$$) db 0
dw 0xAA55
