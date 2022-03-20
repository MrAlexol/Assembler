    section .text
readLn:
    ; // Пример вызова по C: readLn(char* strIn, uint16_t count);
    push    rbp
    mov     rbp, rsp

    mov     rax, 0          ; системная функция READ
    mov     rdi, 0          ; дескриптор файла STDIN
    mov     rsi, [rbp + 16] ; адрес выводимой строки
    mov     dx, [rbp + 24]  ; длина строки
    syscall                 ; вызов системной функции

    pop     rbp
    ret     10

print:
    ; // Пример вызова по C: print(char* strOut, uint16_t count);
    push    rbp
    mov     rbp, rsp

    mov     rax, 1          ; системная функция WRITE
    mov     rdi, 1          ; дескриптор файла STDOUT
    mov     rsi, [rbp + 16] ; адрес выводимой строки
    mov     dx, [rbp + 24]  ; длина строки
    syscall                 ; вызов системной функции

    pop     rbp
    ret     10

%define MAX_STRING_LENGTH 256

strlen:
    ; // Пример вызова по C: strlen(char* str); // str - строка, оканчивающаяся на 0
    push    rbp
    mov     rbp, rsp

    mov     al, 0           ; al = 0 - символ для поиска
    mov     rdi, [rbp + 16] ; [rbp + 16] - адрес строки (arg0)

    cld
    mov     rcx, MAX_STRING_LENGTH
    repnz   scasb           ; поиск \0 - символа конца строки

    mov     ax, MAX_STRING_LENGTH
    sub     ax, cx
    dec     ax              ; вычисление длины строки по значению rcx

    pop rbp
    ret 8

CPrint:
    ; // Пример вызова по C: CPrint(char* strOut); // strOut - строка, оканчивающаяся на 0
    push    rbp
    mov     rbp, rsp

    mov     rsi, [rbp + 16] ; адрес выводимой строки
    push    rsi
    call    strlen
    mov     dx, ax
    mov     rax, 1          ; системная функция WRITE
    mov     rdi, 1          ; дескриптор файла STDOUT
    syscall                 ; вызов системной функции

    pop rbp
    ret 8

CStylizeString:
    ; Процедура заменяет самый правый пробел или enter в строке на \0
    ; // Пример вызова по C: CStylizeString(char* str, uint16_t count); // str - строка, оканчивающаяся на enter или пробел
    push    rbp
    mov     rbp, rsp

    xor     rcx, rcx
    mov     rdi, [rbp + 16] ; [rbp + 16] - адрес строки (arg0)
    add     di, [rbp + 24]  ; перемещение в конец строки
    std                     ; справа налево

    mov     al, 10          ; al = 10 - поиск enter
    mov     cx, [rbp + 24]  ; [rbp + 24] - длина всей строки (arg1)
    repnz   scasb           ; поиск \n - символа перевода строки

    jecxz   .enter_not_found
    jmp     short .give_result

.enter_not_found:
    mov     rdi, [rbp + 16] ; [rbp + 16] - адрес строки (arg0)
    add     di, [rbp + 24]  ; перемещение в конец строки

    mov     al, 32          ; al = 32 - поиск пробела
    mov     cx, [rbp + 24]  ; [rbp + 24] - длина всей строки (arg1)
    repnz   scasb           ; поиск ' ' - возможного символа конца строки

    jecxz   .space_not_found
    
    jmp     short .give_result

.give_result:
    inc     rdi
.space_not_found:
    mov     al, 0
    mov     [rdi], al

    mov     rax, 0
    pop     rbp
    ret     10