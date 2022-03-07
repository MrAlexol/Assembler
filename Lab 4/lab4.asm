%define STDIN   0
%define STDOUT  1
%define READ    0
%define WRITE   1

%include "../lib64.asm"

%macro write_string 2
    ; Макрос, предназначенный для вывода сообщений
    ; Аргументы:
    ;   1 - Адрес строки
    ;   2 - Длина строки
    mov     rax, WRITE      ; системная функция
    mov     rdi, STDOUT     ; дескриптор файла
    mov     rsi, %1         ; адрес выводимой строки
    mov     rdx, %2         ; длина строки
    syscall                 ; вызов системной функции
%endmacro

%macro read_string 2
    ; Макрос, предназначенный для чтения строковых сообщений
    ; Аргументы:
    ;   1 - Буфер ввода
    ;   2 - Длина буфера ввода
    mov     rax, READ       ; системная функция read
    mov     rdi, STDIN      ; дескриптор файла stdin
    mov     rsi, %1         ; адрес вводимой строки
    mov     rdx, %2         ; длина строки
    syscall                 ; вызов системной функции
%endmacro

%macro atoi 1
    ; Макрос, предназначенный для перевода строки в число
    ; Аргументы:
    ;   1 - Адрес числовой переменной
    ; Входные данные:
    ;   RSI - адрес строки, завершающейся символом 10
    call    StrToInt64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
    mov     [%1], ax            ; variable = ax
%endmacro

%macro read_integer 3
    ; Макрос, предназначенный только для чтения 2-байтовых целых
    ; Аргументы:
    ;   1 - Буфер ввода
    ;   2 - Длина буфера ввода
    ;   3 - Переменная для записи результата преобразований - числа.
    read_string %1, %2 ; scanf("%s", %1);
    atoi %3
%endmacro

numToString:
    ; Входные данные:
    ;   RSI - адрес строки, завершающейся символом 10
    ;   RCX - размер числа в байтах
    ;   RDI - адрес числа для перевода
    ; Вывод:
    ;   RCX - длина строки
    ;   [RSI] - строка
    cmp     rcx, 1              ; switch (rcx) {
    je      type_byte           ; case 1: goto type_byte;
    cmp     rcx, 2
    je      type_word           ; case 2: goto type_word;
    cmp     rcx, 4
    je      type_dword          ; case 4: goto type_dword;
    jmp     StrToInt64.Error    ; default: return;

        type_byte:
    movsx   eax, BYTE [rdi]
    jmp numToStringContinue
        type_word:
    movsx   eax, WORD [rdi]
    jmp numToStringContinue
        type_dword:
    mov     eax, [rdi]
    jmp numToStringContinue

        numToStringContinue:
    call    IntToStr64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
    mov     rcx, rax
    ret

    section .data
ExitMsg     db      "Press Enter to Exit", 10
lenExit     equ     $-ExitMsg
StartMsg    db      "Type matrix", 10
lenStart    equ     $-StartMsg

CheckMsg    db      "Incoming parameters:", 10
lenCheck    equ     $-CheckMsg

ResultMsg   db      "The result is"
lenResult   equ     $-ResultMsg

    section .bss
InBuf   resb    64  ; буфер ввода
lenIn   equ     $-InBuf
OutBuf  resb    7   ; буфер вывода

    section .text
global _start

_start:
    write_string StartMsg, lenStart ; puts("Type matrix");

    write_string CheckMsg, lenCheck ; puts("Incoming parameters:");

    ; Завершение программы
    write_string ExitMsg, lenExit ; puts("Press Enter to Exit");
    read_string InBuf, lenIn ; gets();
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции
