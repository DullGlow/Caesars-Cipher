%include        'functions.asm'

SECTION .data    
    shiftMsg db "Enter amount to shift by: "
    lenshiftMsg equ $ - shiftMsg
    
    sentenceMsg db "Enter sentence to cypher: "
    lensentenceMsg equ $ - sentenceMsg

    resultMsg db `Result: \u001b[32m`   ; Result will be printed in green
    lenResultMsg equ $ - resultMsg
    

SECTION .bss            ; Section containing uninitialized data
    numStr resb 11      ; 11 byte for shiftNum string
    num resb 4          ; 4 byte for shiftNum integer
    sentence resb 4096  ; 4096 byte for sentence
    
SECTION .text           ; Section containing code

global _start
    
    
_start:
    nop
    
    ; Print: 'Enter amount to shift by: '
    mov eax, shiftMsg       ; Message to print
    mov ebx, lenshiftMsg    ; Buffer size
    call print
    
    ; Read number
    mov eax, 3              ; sys_read
    mov ebx, 0              ; stdin
    mov ecx, numStr         ; Store input here
    mov edx, 11             ; Read 11 byte
    int 0x80                ; syscall
    
    ; Print: 'Enter sentence to cypher: '
    mov eax, sentenceMsg    ; Message to print
    mov ebx, lensentenceMsg ; Buffer size
    call print
    
    ; Read sentence
    mov eax, 3              ; sys_read
    mov ebx, 0              ; stdin
    mov ecx, sentence       ; Store input here
    mov edx, 4096           ; Buffer size
    int 0x80                ; syscall
    
    ; Get sentence length
    mov ebx, sentence       ; Prepare EBX for slen function
    call slen               ; Call slen, which counts string length

    push eax                ; Save length
    mov ecx, eax            ; Put lenght in ecx
    dec ecx                 ; Decrement by 1 (so we don't shift \n)
    
    ; Convert input number (which is string) to integer
    mov ebx, numStr
    call to_int
    
    ; shiftNum = shiftNum % 26
    mov ebx, 26
    call remainder          ; eax = eax%26
    
    mov ebx, eax            ; EBX = number to shift by
    mov eax, sentence       ; EAX = sentence to shift
do_more:
    call shift_letter
    inc eax                 ; Move onto next character
    dec ecx                 ; Update counter
    jnz do_more             ; Jump while counter != 0
    
    ; Now sentence is shifted, so we print it out

    ; Print: 'Result: '
    mov eax, resultMsg
    mov ebx, lenResultMsg
    call print

    ; Print cyphered sentence
    mov eax, sentence       ; Message to print
    pop ebx                 ; Message length
    call print              ; Print message
    
    ; Exit
    mov eax, 1
    int 0x80
    
    
    

;---------------------------------------------------------------
; void shift_letter  --  Shifts a character by given amount
;
; IN:
;   EAX: Character to shift
;   EBX: Number to shift by
; OUT:
;   None
;---------------------------------------------------------------

shift_letter:
    ; Check if current char is a letter
    ; If its letter, check upper or lower case 
    ; and call corresponding function
    cmp byte[eax], 'A'      ; Is char lower than 'A'
    jb .return              ; If yes, return
    
    cmp byte[eax], 'Z'      ; Is lower or equal to 'Z'
    jbe .shift_upper        ; If yes, we have upper case letter
    
    cmp byte[eax], 'z'      ; Is above 'z'
    ja .return              ; If yes, return
    
    cmp byte[eax], 'a'      ; Is above 'a'
    jae .shift_lower        ; If yes, we have lower case letter

    jmp .return 

.shift_upper:
    add byte [eax], bl      ; Shift the letter
    cmp byte [eax], 'Z'     ; Is it below or equal to 'Z'?
    jbe .return             ; If yes, finish functin

    sub byte [eax], 26      ; If not, substract 26

    jmp .return

.shift_lower:
    add byte [eax], bl      ; Shift the letter
    cmp byte [eax], 'z'     ; Is it below or equal to 'z'?
    jbe .return             ; If yes, finish functin

    sub byte [eax], 26      ; If not, substract 26

.return:
    ret
