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

%macro itoa 2
    ; В регистре AX должно находиться число для обработки, в RSI - адрес строки для вывода
    xor     rax, rax
    movsx   eax, word [%1]      ; eax = variable
    mov     rsi, %2
    call    IntToStr64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
%endmacro

%macro dtoa 2
    ; В регистре EAX должно находиться число для обработки, в RSI - адрес строки для вывода
    xor     rax, rax
    mov     eax, [%1]           ; ax = variable
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

    section .data
ExitMsg     db      "Press Enter to Exit", 10
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
EnterMsg    db      10
lenEnter    equ     $-EnterMsg
ResultMsg   db      "The result is s = "
lenResult   equ     $-ResultMsg
Comma       db      ','
lenComma    equ     $-Comma

    section .bss
InBuf   resb    10  ; буфер ввода
lenIn   equ     $-InBuf
OutBuf  resb    7   ; буфер вывода
a       resw    1
b       resw    1
c       resw    1
y       resw    1
s       resd    1
frac    resw    1
tmp     resw    1
numr    resd    1
denr    resw    1

    section .text
global _start

_start:
    write_string StartMsg, lenStart ; puts("Type expression parameters");

    ; часть чтения пользовательского ввода
    write_string AInv, lenAInv ; printf("a = ");
    read_integer InBuf, lenIn, a ; scanf("%d", a); // чтение 2-байтового числа типа integer

    write_string BInv, lenBInv ; printf("b = ");
    read_integer InBuf, lenIn, b ; scanf("%d", b);

    write_string CInv, lenCInv ; printf("c = ");
    read_integer InBuf, lenIn, c ; scanf("%d", c);

    write_string YInv, lenYInv ; printf("y = ");
    read_integer InBuf, lenIn, y ; scanf("%d", y);

    ; предыдущую часть можно заменить следующим:
    ; mov word [a], 10
    ; mov word [b], 3
    ; mov word [c], 1
    ; mov word [y], 5

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
    write_string EnterMsg, lenEnter ; puts("");

    ; numr = a - b*b;
    mov ax, [b]     ; ax = b;
    imul ax         ; ax *= ax;
    mov [numr], ax
    mov [numr+2], dx
    movsx eax, word [a]
    sub eax, [numr]
    mov [numr], eax
    xor eax, eax

    ; denr = y - a;
    mov ax, [y]     ; ax = y;
    sub ax, [a]     ; ax -= a;
    mov [denr], ax  ; denr = ax;

    ; tmp = numr / denr;
    mov dx, [numr+2]
    mov ax, [numr]  ; dx:ax = numr
    idiv word [denr]
    mov [tmp], word 1000
    imul dx, [tmp]  ; dx *= 1000;
    mov [tmp], ax   ; tmp = ax;
    mov ax, dx      ; ax = dx;
    cwd
    idiv word [denr]
    mov [frac], ax  ; frac = ax;

    ; вычисление цифр после запятой в десятичной дроби
    cmp [frac], word 0
    jge pos_frac            ; if (frac < 0)
    add [frac], word 1000   ; frac += 1000; // если дробная часть отрицательна,
    dec word [tmp]          ; --tmp; // вычтем ее из целого

        pos_frac:

    ; s = a*a - c;
    mov ax, [a]     ; ax = a;
    imul ax         ; ax = ax*ax;
    sub ax, [c]     ; ax -= c;
    mov [s+2], dx
    mov [s], ax     ; s = (dx << 16) + ax;

    ; s += tmp;
    mov ax, [tmp]   ; ax = tmp;
    cwd
    add [s], eax    ; s += eax;    

    write_string ResultMsg, lenResult ; printf("The result is s = ");
    dtoa s, OutBuf
    call strlen ; rcx = strlen(OutBuf);
    write_string OutBuf, rcx ; printf("%d", s);
    write_string Comma, lenComma ; printf(",");
    itoa frac, OutBuf
    call strlen ; rcx = strlen(OutBuf);
    write_string OutBuf, rcx ; printf("%d", frac);
    write_string EnterMsg, lenEnter ; puts("");

    ; завершение программы
    write_string ExitMsg, lenExit ; puts("Press Enter to Exit");
    read_string InBuf, lenIn ; gets();
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции
