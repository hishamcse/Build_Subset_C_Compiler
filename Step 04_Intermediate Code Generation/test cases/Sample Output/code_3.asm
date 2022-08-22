.MODEL SMALL

.STACK 100H

.DATA
	a_1_1 DW ?
	b_1_1 DW ?
	c_1_1 DW 3 DUP (0)
	t1 DW ?
	t2 DW ?
	t3 DW ?
	t4 DW ?
	t5 DW ?
	t6 DW ?
	t7 DW ?


.CODE

	main PROC

		;initialize DS
		MOV AX, @DATA
		MOV DX, AX

		; int a,b,c[3];

		; a=1*(2+3)%3;
		MOV t1, 1
		MOV t2, 2
		MOV t3, 3
		MOV AX, t2
		ADD AX, t3
		MOV t2, AX
		MOV AX, t1
		MOV BX, t2
		IMUL BX
		MOV t1, AX
		MOV t2, 3
		XOR DX, DX
		MOV AX, t1
		MOV BX, t2
		IDIV BX
		MOV t1, DX
		MOV AX, t1
		MOV a_1_1, AX

		; b=1<5;
		MOV t1, 1
		MOV t2, 5
		MOV AX, t1
		CMP AX, t2
		JL L0
		MOV t1, 0
		JMP L1
		L0:
		MOV t1, 1
		L1:
		MOV AX, t1
		MOV b_1_1, AX

		; c[0]=2;
		MOV t1, 0
		MOV t2, 2
		MOV BX, t1
		ADD BX, BX
		MOV AX, t2
		MOV c_1_1[BX], AX

		; if(a&&b) c[0]++;else c[1]=c[0];
		CMP a_1_1, 0
		JE L2
		CMP b_1_1, 0
		JE L2
		MOV t2, 1
		JMP L3
		L2:
		MOV t2, 0
		L3:
		CMP t2, 0
		JE L4
		MOV t4, 0
		MOV BX, t4
		ADD BX, BX
		MOV AX, c_1_1[BX]
		MOV t5, AX
		INC c_1_1[BX]
		JMP L5
		L4:
		MOV t6, 1
		MOV t7, 0
		MOV BX, t6
		ADD BX, BX
		MOV DI, t7
		ADD DI, DI
		MOV AX, c_1_1[DI]
		MOV c_1_1[BX], AX

		L5:

		; println(a);
		PUSH a_1_1
		CALL integerOutput

		; println(b);
		PUSH b_1_1
		CALL integerOutput

		;DOS EXIT
		MOV AH, 4CH
		INT 21H

	main ENDP

	integerOutput PROC
		;save registers to stack
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH BP

		;extract number
		MOV BP, SP
		MOV AX, [BP+12]

		;check if negative
		CMP AX, 0
		JGE POSITIVE2
		PUSH AX
		MOV DL, '-'
		MOV AH, 2
		INT 21H
		POP AX
		NEG AX

		;extract digits
		POSITIVE2:
		MOV CX, 0
		MOV BX, 10D

		WHILE_2:
			MOV DX, 0
			DIV BX
			PUSH DX
			INC CX
			CMP AX, 0
			JNE WHILE_2

		;print digits
		MOV AH, 2

		WHILE_3:
			POP DX
			ADD DL, '0'
			INT 21H
			LOOP WHILE_3
		MOV DL, 20H
		INT 21H

		;restore saved registers from stack
		POP BP
		POP DX
		POP CX
		POP BX
		POP AX

		RET 2

	integerOutput ENDP

END MAIN

