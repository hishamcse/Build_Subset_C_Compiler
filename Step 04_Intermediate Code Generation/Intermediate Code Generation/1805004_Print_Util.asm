PRINTLN PROC 
    PUSH AX
    PUSH BX 
    PUSH CX 
    PUSH DX
    PUSH BP
    
    MOV BP, SP
    MOV AX, WORD PTR[BP + 12] 
    TEST AX,8000H
    JZ PRINTLN_DRIVER

    MOV CX, AX
    MOV AH, 2
    MOV DL, 45
    INT 21H
    MOV AX, CX
        
    PRINTLN_DRIVER:
    MOV CX, 0
    WHILE:
       MOV BX, 10
       CALL DIVIDE_UTIL  
       CALL ABS_UTIL
       PUSH DX 
       INC CX
       CMP AX, 0
       JNE WHILE 

    MOV AH, 2 
    
    GO:
       POP BX
       MOV DL, BL
       ADD DL, 48
       INT 21H 
       DEC CX
       CMP CX, 0
       JG GO

    LAST:
      MOV AH, 2
      MOV DL, 0DH
      INT 21H
      MOV AH, 2
      MOV DL, 0AH
      INT 21H 
      POP BP
      POP DX
      POP CX
      POP BX
      POP AX
    RET    
PRINTLN ENDP

DIVIDE_UTIL PROC  
    PUSH BX
    CWD
    IDIV BX
    POP BX
    RET
DIVIDE_UTIL ENDP

ABS_UTIL PROC  
   PUSH AX
   CMP DX, 0
   JGE ABS_LAST
   MOV AX, 0
   SUB AX, DX
   MOV DX, AX  
   ABS_LAST:
   POP AX
   RET
ABS_UTIL ENDP