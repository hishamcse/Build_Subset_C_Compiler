.MODEL small
.STACK 100h
.DATA
	a_1 dw ?
	b_1 dw ?
	c_1 dw 3 dup(?)
	t_0 dw ?
	t_1 dw ?
	t_2 dw ?
	t_3 dw ?
	t_4 dw ?

.CODE
print PROC
	;check neg
	cmp ax, 8000H
	jb positive
negative:
	neg ax
	push ax
	mov ah, 2
	mov dl, '-'
	int 21h
	pop ax
positive:
	mov bx, 10
	mov cx, 0
getVals:
	mov dx, 0
	div bx
	push dx
	inc cx
	cmp ax, 0
	jne getVals
printing:
	mov ah, 2
	pop dx
	add dl, '0'
	int 21h
	dec cx
	cmp cx, 0
	jne printing
	mov dl, 0Ah
	int 21h
	mov dl, 0Dh
	int 21h
	ret 
print ENDP

main proc
	mov ax, @data
	mov ds, ax
	;a=1*(2+3)%3; 
	mov ax, 2
	add ax, 3
	mov t_0, ax
	mov bx, 3
	mov ax, t_0
	;check negative
	cmp ax, 8000h
	;divident positive
	jb L_0
	mov dx, 0fffh
	;div operaiton
	jmp L_1
L_0:
	xor dx, dx
L_1:
	div bx
	mov t_0, dx
	mov ax, t_0
	mov a_1, ax
	;b=1<5; 
	mov ax, 1
	cmp ax, 5
	jge L_2
	mov t_1, 1
	jmp L_3
L_2:
	mov t_1, 0
L_3:
	mov ax, t_1
	mov b_1, ax
	;c[0]=2; 
	mov di, 0
	add di, di
	mov ax, 2
	mov c_1[di], ax
	;if (a&&b)c[0]++; else c[1]=c[0]; 
	cmp a_1, 0
	je L_4
	cmp b_1, 0
	je L_4
	mov t_2, 1
	jmp L_5
L_4:
	mov t_2, 0
L_5:
	mov ax, t_2
	cmp ax, 0
	je L_6
	;c[0]++; 
	mov di, 0
	add di, di
	mov ax, c_1[di]
	mov t_3, ax
	inc c_1[di]
	jmp L_7
L_6:
	;c[1]=c[0]; 
	mov di, 0
	add di, di
	mov ax, c_1[di]
	mov t_4, ax
	mov di, 1
	add di, di
	mov ax, t_4
	mov c_1[di], ax
L_7:
	;println(a); 
	mov ax, a_1
	call print
	;println(b); 
	mov ax, b_1
	call print
	;dos exit
	mov ah, 4ch
	int 21h

main endp

END main
