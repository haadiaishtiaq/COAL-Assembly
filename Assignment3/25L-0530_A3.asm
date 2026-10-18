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


viewport:
	push es
	push ax
	push bx
	push cx
	push di
	cld
	
	mov ax, 0xb800
	mov es, ax
	
	; Upper border line
	mov bx, 0
	mov ax, 3
	mov bl, 80
	mul bl
	add ax, 8
	shl ax, 1
	mov di, ax
	mov ax, 0x07CD
	mov cx, 64
	rep stosw
	
	; Lower border line
	mov bx, 0
	mov ax, 21
	mov bl, 80
	mul bl
	add ax, 8
	shl ax, 1
	mov di, ax
	mov ax, 0x07CD
	mov cx, 64
	rep stosw
	
	; Left boundary vertical line
	mov bx, 0
	mov ax, 4
    mov bl, 80
    mul bl
    add ax, 8
    shl ax, 1
    mov di, ax
    mov ax, 0x07BA
    mov cx, 17
	l_loop:
		mov [es:di], ax
		add di, 160
		loop l_loop
	
	; Right boundary vertical line
	mov bx, 0
	mov ax, 4
	mov bl, 80
	mul bl
	add ax, 71
	shl ax, 1
	mov di, ax
	mov ax, 0x07BA
	mov cx, 17
	r_loop:
		mov [es:di], ax
		add di, 160
		loop r_loop
	
	pop di
	pop cx
	pop bx
	pop ax
	pop es
	ret


printTitle:
	push bx
	push ds
	push si
	push ax
	push cx
	push es
	push di
	
	mov si, title
	mov ax, 0xb800
	mov es, ax
	
	mov bx, 0
	mov ax, 4
    mov bl, 80
    mul bl
    add ax, 36
    shl ax, 1
    mov di, ax
	
    mov ah, 0x1E
	mov cx, 8
	cld
	
	t_loop:
		lodsb
		stosw
		loop t_loop
	
	pop di
	pop es
	pop cx
	pop ax
	pop si
	pop ds
	pop bx
	ret


printPara:
	push bp
    mov bp, sp
    push si
    push ax
    push bx
    push cx
    push dx
    push es
    push di
	
	mov ax, 0xb800
    mov es, ax
	mov si, [bp+6] ; Message offset
	mov dh, 6      ; Starting row
	mov dl, 10     ; Starting col
	
	calc_row:
		mov al, dh
		mov bl, 80
		mul bl
		mov bl, dl
		xor bh, bh
		add ax, bx
		shl ax, 1
		mov di, ax
		
		mov cx, 0
		
	process_char:
		mov ax, [bp+4]
		lodsb
		cmp al, 0
		je end_para
		cmp al, 10
		je break_line
		
		stosw
		inc cx
		cmp cx, 60
		je break_line
		jmp process_char
		
	break_line:
		mov dl, 10
		inc dh
		cmp dh, 21
		jge end_para
		jmp calc_row
		
	end_para:
		pop di
		pop es
		pop dx
		pop cx
		pop bx
		pop ax
		pop si
		pop bp
		ret 4


; Parameters: top, left, bottom, right, n
scroll:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push ds
	push es

	mov ax, 0xb800
	mov ds, ax
	mov es, ax
	cld

	; Rows to move calculation
	mov bx, [bp+8]
	sub bx, [bp+12]
	inc bx
	sub bx, [bp+4]

	mov ax, [bp+12]
	mov di, 80
	mul di
	add ax, [bp+10]
	shl ax, 1
	mov di, ax

	mov ax, [bp+4]
	mov si, 160
	mul si
	add ax, di
	mov si, ax

	; Width calculation
	mov dx, [bp+6]
	sub dx, [bp+10]
	inc dx

	; Skip value calculation
	mov ax, 160
	sub ax, dx
	sub ax, dx

	scroll_move:
		mov cx, dx
		rep movsw
		add si, ax
		add di, ax
		dec bx
		jnz scroll_move

	mov bx, [bp+4]
	mov si, ax
	mov ax, 0x0720
	
	scroll_blank:
		mov cx, dx
		rep stosw
		add di, si
		dec bx
		jnz scroll_blank

	pop es
	pop ds
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 10


; Parameters: string, attr
highlight:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es
	cld

	mov ax, 0xb800
	mov es, ax
	mov dh, 4

hl_row:
	mov al, dh
	mov ah, 0
	mov bl, 80
	mul bl
	add ax, 9
	shl ax, 1
	mov di, ax
	mov cx, 62

hl_cell:
	mov bx, di
	mov si, [bp+6]

hl_comp:
	lodsb
	cmp al, 0
	je hl_matched
	scasb
	jne hl_next
	inc di
	jmp hl_comp

hl_matched:
	inc word [count]
	mov ax, [bp+4]
	
hl_apply:
	mov [es:di-1], al
	sub di, 2
	cmp di, bx
	ja hl_apply

hl_next:
	mov di, bx
	add di, 2
	dec cx
	jnz hl_cell

	inc dh
	cmp dh, 21
	jb hl_row

	pop es
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4


; Parameters: num, offset
printNum:
	push bp
	mov bp, sp
	push bx
	push cx
	push dx
	push di
	push es

	mov ax, 0xb800
	mov es, ax
	mov ax, [bp+6]
	mov di, [bp+4]
	mov bx, 10
	xor cx, cx

	num_div_loop:
		xor dx, dx
		div bx                  ; ax = quotient, dx = remainder
		push dx
		inc cx
		cmp ax, 0
		jne num_div_loop

	num_print_loop:
		pop dx
		add dl, '0'
		mov dh, 0x07
		mov [es:di], dx
		add di, 2
		loop num_print_loop

	mov ax, di

	pop es
	pop di
	pop dx
	pop cx
	pop bx
	pop bp
	ret 4


status:
	push ax
	push si
	push di
	push es

	mov ax, 0xb800
	mov es, ax
	cld
	mov di, 3680
	mov ah, 0x07

	mov si, msg1
	stat_p1:
		lodsb
		cmp al, 0
		je stat_p1done
		stosw
		jmp stat_p1
		
	stat_p1done:
		push word [count]
		push di
		call printNum           ; Returns updated DI offset in AX
		mov di, ax
		mov ah, 0x07

	mov si, msg2
	stat_p2:
		lodsb
		cmp al, 0
		je stat_p2done
		stosw
		jmp stat_p2
		
	stat_p2done:
		pop es
		pop di
		pop si
		pop ax
		ret


start:
	call clrscr
	call viewport
	call printTitle
	
	push paragraph
	push word 0x0700
	call printPara
	
	push word 6     ; Top
	push word 9     ; Left
	push word 20    ; Bottom
	push word 70    ; Right
	push word 1     ; n
	call scroll
	
	push search
	push word 0xCE
	call highlight
	call status
	
	mov ax, 0x4C00
    int 0x21
