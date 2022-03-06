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

%macro atoi 1
    ; В регистре RSI должен лежать адрес строки, завершающейся символом 10
    call    StrToInt64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
    mov     [%1], ax            ; variable = ax
%endmacro

%macro read_integer 3
    read_string %1, %2 ; scanf("%s", %1);
    atoi %3
%endmacro

numToString:
    ; Ожидается:
    ; RSI - адрес строки, завершающейся символом 10
    ; RCX - размер числа в байтах
    ; RDI - адрес числа для перевода
    ; Вывод:
    ; RCX - длина строки
    ; [RSI] - строка
    cmp     rcx, 1              ; switch (ecx) {
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
StartMsg    db      "Type expression parameters", 10
lenStart    equ     $-StartMsg
QInv        db      "q = "
lenQInv     equ     $-QInv
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

result  resd    1

    section .text
global _start

_start:
    write_string StartMsg, lenStart ; puts("Type expression parameters");

    ; Часть чтения пользовательского ввода
    write_string QInv, lenQInv ; printf("q = ");
    read_integer InBuf, lenIn, q ; scanf("%d", &q); // чтение 2-байтового числа типа integer

    write_string DInv, lenDInv ; printf("d = ");
    read_integer InBuf, lenIn, d ; scanf("%d", &d); // чтение 2-байтового числа типа integer

    ; Вместо ввода в терминал можно использовать значения, указанные непосредственно в программе
    ; mov word [q], 5
    ; mov word [d], 6

    write_string CheckMsg, lenCheck ; puts("Incoming parameters:");

    write_string QInv, lenQInv ; printf("q = ");
    ; printf("%d", q);
    mov rsi, OutBuf     ; вывод в строку OutBuf
    mov rcx, 2          ; тип числа - word
    mov rdi, q          ; адрес числа для перевода в строку
    call numToString
    write_string OutBuf, rcx ; вывод строки

    write_string DInv, lenDInv ; printf("d = ");
    ; printf("%d", d);
    mov rsi, OutBuf     ; вывод в строку OutBuf
    mov rcx, 2          ; тип числа - word
    mov rdi, d          ; адрес числа для перевода в строку
    call numToString
    write_string OutBuf, rcx ; вывод строки

    mov ax, [q]         ; ax = q;
    cmp ax, 10          ; if (ax < 10) {
    jge greq
    mov ax, [q]         ;   ax = q;
    imul ax             ;   ax *= ax;
    mov bx, [d]         ;   bx = d;
    sub bx, 5           ;   bx -= 5;
    idiv bx             ;   dx:ax /= bx
    add ax, [d]         ;   dx:ax += d
    jmp continue        ; }

        greq:           ; else {
    mov ax, [d]         ;   ax = d;
    sub ax, [q]         ;   ax -= q;
    mov bx, 5           ;   bx = 5;
    imul bx             ;   ax *= bx;
                        ; }
        
        continue:
    mov [result], ax
    mov [result+2], dx  ; result = dx:ax
    xor rbx, rbx        ; rbx = 0;

    write_string ResultMsg, lenResult ; printf("The result is f = ");
    ; printf("%d", result);
    mov rsi, OutBuf     ; вывод в строку OutBuf
    mov rcx, 4          ; тип числа - dword
    mov rdi, result     ; адрес числа для перевода в строку
    call numToString
    write_string OutBuf, rcx ; вывод строки

    ; Завершение программы
    write_string ExitMsg, lenExit ; puts("Press Enter to Exit");
    read_string InBuf, lenIn ; gets();
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции
