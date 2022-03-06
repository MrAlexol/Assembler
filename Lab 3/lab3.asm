%define STDIN   0
%define STDOUT  1
%define READ    0
%define WRITE   1

%include "../lib64.asm"

%macro write_string 2
    ; вывод
    mov     rax, WRITE      ; системная функция
    mov     rdi, STDOUT     ; дескриптор файла
    mov     rsi, %1         ; адрес выводимой строки
    mov     rdx, %2         ; длина строки
    syscall                 ; вызов системной функции
%endmacro

%macro read_string 2
    ; ввод
    mov     rax, READ       ; системная функция read
    mov     rdi, STDIN      ; дескриптор файла stdin
    mov     rsi, %1         ; адрес вводимой строки
    mov     rdx, %2         ; длина строки
    syscall                 ; вызов системной функции
%endmacro

    section .data
ExitMsg     db      "Press Enter to Exit", 10
lenExit     equ     $-ExitMsg
StartMsg    db      "Type expression parameters", 10
lenStart    equ     $-StartMsg
QInv        db      "q = "
lenAInv     equ     $-QInv
DInv        db      "d = "
lenDInv     equ     $-DInv
CheckMsg    db      "Incoming parameters:", 10
lenCheck    equ     $-CheckMsg
Semicol     db      "; "
lenSemicol  equ     $-Semicol
EnterMsg    db      10
lenEnter    equ     $-EnterMsg
ResultMsg   db      "The result is f = "
lenResult   equ     $-ResultMsg
Comma       db      ','
lenComma    equ     $-Comma

    section .bss
InBuf   resb    10  ; буфер ввода
lenIn   equ     $-InBuf
OutBuf  resb    7   ; буфер вывода

q       resw    1
d       resw    1

result  resw    1

    section .text
global _start

_start:
    write_string StartMsg, lenStart ; puts("Type expression parameters");

    ; mov word [q], 10
    ; mov word [d], 3

    ; завершение программы
    write_string ExitMsg, lenExit ; puts("Press Enter to Exit");
    read_string InBuf, lenIn ; gets();
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции
