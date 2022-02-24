%define STDIN   0
%define READ    0

%include "../lib64.asm"

    section .data
ExitMsg db      "Press Enter to Exit", 10 ; выводимое сообщение
lenExit equ     $-ExitMsg


    section .bss
InBuf   resb    10  ; буфер ввода
lenIn   equ     $-InBuf
a       resd    1
s       resd    1

    section .text
global _start

_start:
    ; ввод
    mov     eax, READ       ; системная функция read
    mov     edi, STDIN      ; дескриптор файла stdin
    mov     esi, InBuf      ; адрес вводимой строки
    mov     edx, lenIn      ; длина строки
    syscall                 ; вызов системной функции

    ; обработка ввода
    call    StrToInt64      ; вызов процедуры
    cmp     ebx, 0          ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
    mov     [a], eax        ; a = eax

    ; завершение программы
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции