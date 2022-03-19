    section .text
readLn:
    ; // Пример вызова по C: readLn(char* strIn, uint16_t count);
    push rbp
    mov rbp, rsp

    mov     rax, 0          ; системная функция READ
    mov     rdi, 0          ; дескриптор файла STDIN
    mov     rsi, [rbp + 16] ; адрес выводимой строки
    mov     dx, [rbp + 24]  ; длина строки
    syscall                 ; вызов системной функции

    pop rbp
    ret 10

print:
    ; // Пример вызова по C: print(char* strOut, uint16_t count);
    push rbp
    mov rbp, rsp

    mov     rax, 1          ; системная функция WRITE
    mov     rdi, 1          ; дескриптор файла STDOUT
    mov     rsi, [rbp + 16] ; адрес выводимой строки
    mov     dx, [rbp + 24]  ; длина строки
    syscall                 ; вызов системной функции

    pop rbp
    ret 10