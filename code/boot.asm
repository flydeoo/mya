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
