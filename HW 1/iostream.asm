%include "../lib64.asm"

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

putc:
    ; // Пример вызова по C: putc();
    ; // В al ожидается код символа для вывода
    push    rbp
    mov     rbp, rsp

    sub     rsp, 2
    mov     [rbp - 2], al

    mov     rax, 1          ; системная функция WRITE
    mov     rdi, 1          ; дескриптор файла STDOUT
    lea     rsi, [rbp - 2]  ; адрес выводимой строки
    mov     dx, 1           ; длина строки
    syscall                 ; вызов системной функции

    mov     rsp, rbp
    pop     rbp
    ret

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

    mov     rax, MAX_STRING_LENGTH
    sub     rax, rcx
    dec     rax             ; вычисление длины строки по значению rcx

    pop     rbp
    ret     8

CPrint:
    ; // Пример вызова по C: CPrint(char* strOut); // strOut - строка, оканчивающаяся на 0
    push    rbp
    mov     rbp, rsp

    mov     rsi, [rbp + 16] ; адрес выводимой строки
    push    rsi
    call    strlen
    mov     rdx, rax
    mov     rax, 1          ; системная функция WRITE
    mov     rdi, 1          ; дескриптор файла STDOUT
    syscall                 ; вызов системной функции

    pop     rbp
    ret     8

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

.space_not_found:
    mov     rax, 1          ; code enter or space not found
    jmp     short .exit

.give_result:
    inc     rdi
    mov     al, 0
    mov     [rdi], al
    mov     rax, 0          ; code ok

.exit:
    pop     rbp
    ret     10

printNum:
    ; // Пример вызова по C: printNum(short valType); // в eax/ax/al ожидается число
    ; // valType - 1, 2 или 4 байта
    push    rbp
    mov     rbp, rsp

    mov     cx, [rbp + 16]

    cmp     cx, 1               ; switch (cx) {
    je      .type_byte          ; case 1: goto type_byte;
    cmp     cx, 2
    je      .type_word          ; case 2: goto type_word;
    cmp     cx, 4
    je      .type_dword         ; case 4: goto type_dword;
    jmp     StrToInt64.Error    ; default: return;

.type_byte:
    cbw
.type_word:
    cwde
.type_dword:

    push    QWORD 0
    lea     rsi, [rbp - 8]

    xor     rbx, rbx
    call    IntToStr64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
    
    
    push    ax
    lea     rax, [rbp - 8]
    push    rax
    call    print

    mov     rsp, rbp
    pop     rbp
    ret     2