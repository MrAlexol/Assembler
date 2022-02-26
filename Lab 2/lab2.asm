%define STDIN   0
%define STDOUT  1
%define READ    0
%define WRITE   1

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

%macro atoi 1
    ; В регистре RSI должен лежать адрес строки, завершающейся символом 10
    call    StrToInt64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
    mov     [%1], rax           ; variable = eax
%endmacro

%macro itoa 2
    ; В регистре RAX должно находиться число для обработки, в RSI - адрес строки для вывода
    mov     rax, [%1]           ; eax = variable
    mov     rsi, %2
    call    IntToStr64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
%endmacro

%macro read_integer 3
    read_string %1, %2 ; scanf("%s", %1);
    atoi %3
%endmacro

strlen:
    ; Вычисление длины строки, оканчивающейся на 10. Enter не считается
    ; Адрес строки должен находиться в RSI
    ; Результат будет в регистре RCX
    mov     rcx, -1
    loop:
        inc rcx
        cmp [rsi + rcx], byte 0x0a
        jne loop
    ret

%include "../lib64.asm"

    section .data
ExitMsg     db      10, "Press Enter to Exit", 10
lenExit     equ     $-ExitMsg
StartMsg    db      "Type expression parameters", 10
lenStart    equ     $-StartMsg
AInv        db      "a = "
lenAInv     equ     $-AInv
BInv        db      "b = "
lenBInv     equ     $-BInv
CInv        db      "c = "
lenCInv     equ     $-CInv
YInv        db      "y = "
lenYInv     equ     $-YInv
CheckMsg    db      "Incoming parameters:", 10
lenCheck    equ     $-CheckMsg
Semicol     db      "; "
lenSemicol  equ     $-Semicol

    section .bss
InBuf   resb    10  ; буфер ввода
lenIn   equ     $-InBuf
OutBuf  resb    7   ; буфер вывода
a       resq    1
b       resq    1
y       resq    1
c       resq    1
s       resq    1

    section .text
global _start

_start:
    write_string StartMsg, lenStart ; puts("Type expression parameters");

    write_string AInv, lenAInv ; printf("a = ");
    read_integer InBuf, lenIn, a ; scanf("%d", a);

    write_string BInv, lenBInv ; printf("b = ");
    read_integer InBuf, lenIn, b ; scanf("%d", b);

    write_string CInv, lenCInv ; printf("c = ");
    read_integer InBuf, lenIn, c ; scanf("%d", c);

    write_string YInv, lenYInv ; printf("y = ");
    read_integer InBuf, lenIn, y ; scanf("%d", y);

    write_string CheckMsg, lenCheck ; printf("Incoming parameters: ");

    write_string AInv, lenAInv ; printf("a = ");
    itoa a, OutBuf
    call strlen ; rcx = strlen(OutBuf);
    write_string OutBuf, rcx ; printf("%d\n", a);
    write_string Semicol, lenSemicol ; printf("; ");

    write_string BInv, lenBInv ; printf("b = ");
    itoa b, OutBuf
    call strlen ; rcx = strlen(OutBuf);
    write_string OutBuf, rcx ; printf("%d\n", b);
    write_string Semicol, lenSemicol ; printf("; ");

    write_string CInv, lenCInv ; printf("c = ");
    itoa c, OutBuf
    call strlen ; rcx = strlen(OutBuf);
    write_string OutBuf, rcx ; printf("%d\n", c);
    write_string Semicol, lenSemicol ; printf("; ");

    write_string YInv, lenYInv ; printf("y = ");
    itoa y, OutBuf
    call strlen ; rcx = strlen(OutBuf);
    write_string OutBuf, rcx ; printf("%d\n", y);
    write_string Semicol, lenSemicol ; printf("; ");

    ; завершение программы
    write_string ExitMsg, lenExit ; puts("Press Enter to Exit");
    read_string InBuf, lenIn ; gets();
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции
