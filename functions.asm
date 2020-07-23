;---------------------------------------------------------------
; void print  --  Prints message to stdout
;
; IN:
;   EAX: Message to print
;   EBX: Buffer size
; OUT:
;   None
;---------------------------------------------------------------

print:
    ;save registers
    push eax
    push ebx
    push ecx
    push edx
    
    mov ecx, eax        ; Move message in ECX
    mov edx, ebx        ; Specify size
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    int 0x80            ; syscall
    
    ;recover registers
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret




;---------------------------------------------------------------
; void print_error  --  Prints error and exits
;
; IN:
;   EBX: String
; OUT:
;   EAX: String length
;---------------------------------------------------------------

print_error:
    ; Print error
    mov eax, 4          ; sys_write
    mov ebx, 2          ; stderr
    mov ecx, errorMsg
    mov edx, lenErrorMsg
    int 0x80            ; syscall

    ; Exit
    mov eax, 1
    int 0x80




;---------------------------------------------------------------
; int slen  --  Finds length of a string
;
; IN:
;   EBX: String
; OUT:
;   EAX: String length
;---------------------------------------------------------------

slen:
    ; Save registers
    push ebx
    push ecx                

    xor ecx, ecx            ; Clear ECX
    
do_slen:
    cmp byte [ebx], 0       ; Is current char empty?
    jz end_slen             ; If yes, jump to end
    
    inc ecx                 ; Increase counter
    inc ebx                 ; Move onto next character
    jmp do_slen             ; Continue loop
    
end_slen:
    mov eax, ecx            ; Place return value in EAX

    ; Recover registers
    pop ecx
    pop ebx
    ret




;---------------------------------------------------------------
; int to_int  --  Converts string into integer
;
; IN:
;   EBX: String
; OUT:
;   EAX: Converted integer
;
; Notes: 
;   It is presumed, that string ends with \n
;   TODO: change where result is stored (?)
;---------------------------------------------------------------

to_int:
    ; Save registers
    push ebx
    push ecx
    push edx

    call slen          ; Get string length
    mov ecx, eax       ; Put length in ecx
    dec ecx            ; For \n
    
    xor eax, eax       ; EAX = 0
    
do_digit:
    ; Check if char is between 0 and 9
    cmp byte [ebx], '0'
    jb print_error
    cmp byte [ebx], '9'
    ja print_error
    
    push eax            ; Save EAX
    push ebx            ; Save EBX
    
    ; Put 10^ECX in eax
    dec ecx             ; Temporarily decrease for next function
    mov ebx, 10
    call power          ; Call function
    inc ecx             ; Increase it back
    
    pop ebx             ; Recover
    
    ; EDX = int(ebx[n])
    xor edx, edx
    mov dl, [ebx]       ; EDX = EBX[0]
    sub edx, '0'        ; EDX = EDX - '0'
    
    ; EAX *= EDX   ->     EAX = EBX[n] * 10^ECX
    mul edx             ; EAX = EDX * i32
    mov edx, eax
    
    pop eax
    
    add eax, edx        ; Result += EBX[0] * 10^ECX
    inc ebx             ; Move on next char
    dec ecx             ; Update counter
    jnz do_digit
    
    ; Recover registers
    pop edx
    pop ecx
    pop ebx
    
    ret




;---------------------------------------------------------------
; int power  --  Calculates power of a number
;
; IN:
;   EBX: Base number
;   ECX: Exponent
; OUT:
;   EAX: Returns EBX^ECX
;
; Notes:
;   Only works for exponent >= 0
;---------------------------------------------------------------

power:
    ; Save registers
    push ecx            ; Save ECX
    push ebx            ; Save EBX

    xor eax, eax        ; Empty result | EAX = 0
    inc eax             ; EAX = 1
    
    cmp ecx, 0          ; Is ECX == 0?
    je end_power        ; If so, end function
    
do_power:
    mul ebx             ; EAX *= EBX
    dec ecx             ; Update counter
    jnz do_power        ; While counter != 0
    
end_power:
    ; Recover registers
    pop ebx             ; Recover EBX
    pop ecx             ; Recover ECX
    
    ret




;---------------------------------------------------------------
; int remainder  --  Returns remainder of divison
;
; IN:
;   EAX: Dividend
;   EBX: Divisor
; OUT:
;   EAX: Remainder
;---------------------------------------------------------------

remainder:
    push edx            ; Save EDX
    xor edx, edx        ; Empty EDX
    div ebx             ; EDX:EAX / EBX | quotient -> EAX; remainder -> EDX

    mov eax, edx        ; Store result in eax
    pop edx             ; Restore EDX
    ret                 ; Return




SECTION .data    
    errorMsg db "Undefined error occured. Exiting..."
    lenErrorMsg equ $ - errorMsg
