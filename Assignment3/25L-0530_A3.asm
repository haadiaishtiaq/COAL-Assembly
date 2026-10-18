[org 0x0100]

jmp start

title:      db '25L-0530'
paragraph:  db 'Hello World', 10
			db 'How are you doing!', 10
			db 'Assignment 3', 10
			db 'Hello World Hello World Hello World Hello World Hello World Hello World', 0
search:     db 'World', 0
count:      dw 0
msg1:       db 'Total Matches Found: [', 0
msg2:       db '] | Viewport Status: ACTIVE', 0

clrscr:
	push es
	push ax
	push cx
	push di
	
	mov ax, 0xb800
	mov es, ax
	
	mov di, 0
	mov ax, 0x0720
	mov cx, 2000
	
	cld
	rep stosw
	
	pop di
	pop cx
	pop ax
	pop es
	ret
start:
	call clrscr
	mov ax, 0x4C00
	int 0x21
