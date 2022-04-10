%define STRING_SIZE 256

    global _Z8cmpwordsPcPS_
    extern _Z6outputiPc

    section .text

_Z8cmpwordsPcPS_:
    ; locals:
    ;   nestWord - [rbp - 24] // qword указатель на исходное слово, формирующее гнездо
    ;   input - [rbp - 16] // qword указатель на введенную строку
    ;   nests - [rbp - 8] // word количество найденных гнезд
    ;   charPos - [rbp - 10] // word определяет номер символа, на который оканчивается слово, формирующее гнездо (обратная нумерация)
    push rbp
    mov rbp, rsp

    sub rsp, 24
    mov [rbp - 16], rdi     ; input (local var)
    mov [rbp - 8], si       ; nests (local var)
    push rbx                ; сохранение rbx

    mov rdi, [rbp - 16]
    cld
    mov al, ' '
    mov rcx, STRING_SIZE
; .loop_replace_spaces:
;     cmp byte [rdi], 0
;     jz .end_of_replacing

;     cmp byte [rdi], 32
;     jne .not_space
;     mov byte [rdi], 0	    ; заменить пробелы на '\0'
; .not_space:
;     inc rdi
;     jmp .loop_replace_spaces
; .end_of_replacing:
.loop_replace_spaces:
    repne scasb
    mov byte [rdi - 1], 0
    cmp rcx, 0
    jne .loop_replace_spaces

; основная обработка
    ; подготовка перед внешним циклом
    cld
    mov rdi, [rbp - 16]	    ; rdi = input;

    mov rcx, STRING_SIZE
    xor al, al
    repz scasb              ; пропустить все \0
    dec rdi                 ; rdi = слово в строке (исходное слово, формирующее гнездо)

    ; temp
    mov r12, rdi
    mov r13, rcx
    mov rsi, rdi
    call _Z6outputiPc
    mov rdi, r12
    mov rcx, r13
    xor al, al
    ; end

    mov [rbp - 24], rdi     ; nestWord (local var)
    mov [rbp - 10], cx      ; charPos (local var)

    repnz scasb             ; пропустить все не \0 - пропустить текущее слово
.cmp_next_word:
    
    repz scasb              ; пропустить все \0 - найти следующее слово
    dec rdi                 ; rdi = следующее слово в строке (слово для сравнения)

    ; сравнение исходного слова с текущим

    ; temp
    mov r12, rdi
    mov r13, rcx
    mov rsi, rdi
    call _Z6outputiPc
    mov rdi, r12
    mov rcx, r13
    xor al, al
    ; end

    repnz scasb             ; пропустить все не \0 (temp)
    dec rdi

    ; переход к следующей итерации
    cmp byte [rdi], 10
    sete bl
    cmp byte [rdi - 1], 10
    sete dl
    or bl, dl               ; bl = (rdi == 10) & ([rdi - 1] == 10)
    jz .cmp_next_word        ; если слова для сравнения еще есть, возвращаемся наверх

    ; mov rax, rdi

    ; mov rdi, 5
    ; mov rsi, rax
    ; call _Z6outputiPc

    pop rbx                 ; восстановление rbx
    mov rsp, rbp
    pop rbp
    mov rax, 0              ; возвращаемое значение
    ret
