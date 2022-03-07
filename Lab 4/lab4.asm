%define STDIN   0
%define STDOUT  1
%define READ    0
%define WRITE   1

%define ROWNUM  4
%define COLNUM  6

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

%macro atoi 0
    ; Макрос, предназначенный для перевода строки в число
    ; Входные данные:
    ;   RSI - Адрес строки, завершающейся символом 10
    ;   RDI - Адрес числовой переменной для вывода
    call    StrToInt64          ; вызов процедуры
    cmp     rbx, 0              ; сравнение кода возврата
    jne     StrToInt64.Error    ; обработка ошибки
    mov     [rdi], ax           ; [rdi] = ax
%endmacro

%macro read_integer 3
    ; Макрос, предназначенный только для чтения 2-байтовых целых
    ; Аргументы:
    ;   1 - Буфер ввода
    ;   2 - Длина буфера ввода
    ;   3 - Переменная для записи результата преобразований - числа.
    read_string %1, %2 ; scanf("%s", %1);
    mov rdi, %3
    atoi
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
StartMsg    db      "Type matrix 4x6", 10
lenStart    equ     $-StartMsg
CheckMsg    db      "Incoming parameters:", 10
lenCheck    equ     $-CheckMsg
ResultMsg   db      "The result is"
lenResult   equ     $-ResultMsg
SpaceMsg    db      9
lenSpace    equ     $-SpaceMsg
EnterMsg    db      10
lenEnter    equ     $-EnterMsg

    section .bss
InBuf   resb    32  ; буфер ввода
lenIn   equ     $-InBuf
OutBuf  resb    7   ; буфер вывода
array   resw    24  ; массив
row     resq    1   ; счетчик строк массива

    section .text
global _start

_start:
    write_string StartMsg, lenStart ; puts("Type matrix 4x6");

    mov rcx, 0
    ; Цикл ввода строк матрицы
        cycleReadRows:
    mov [row], rcx

    read_string InBuf, lenIn        ; InBuf = gets(); // получим строку, где числа разделены пробелами

    ; Преобразование строки в одномерный массив чисел
    mov rcx, lenIn                  ; rcx = lenIn
        cycleTransformStr:          ; for (int rcx = lenIn; rcx > 0; rcx--) {
    cmp byte [InBuf + rcx - 1], 32  ;   if (InBuf + rcx - 1 == ' ') { // заменим все пробелы на Enter
    jne skipCycleTransformStr
    mov byte [InBuf + rcx - 1], 10  ;   *(InBuf + rcx - 1) = '\n';
    mov rsi, InBuf
    add rsi, rcx                    ;   Сохраним все адреса замененных пробелов (т.е. адреса строк с числами)
    push rsi                        ;   в стек, чтобы затем по очереди их извлечь и найти числа для преобразования.
        skipCycleTransformStr:      ;   }
    loop cycleTransformStr          ; }

    mov rsi, InBuf                  ; Адрес первого числа в большой строке известен, но его нет в стеке,
    mov rax, [row]                  ; поэтому обработаем его отдельно.
    imul rax, COLNUM                ; В регистр RAX поместим количество элементов для пропуска с начала массива.
    lea rdi, [rax * 2 + array]      ; Поместим эффективный адрес в регистр RDI.
    atoi                            ; Преобразование строки по адресу [RDI] в число типа WORD.

    mov rcx, COLNUM - 1             ; for (int rcx = COLNUM - 1; rcx > 0; rcx--) {
        cycleStrToArr:
    pop rsi                         ;   Берем адреса строк с числами из стека.
    mov rax, [row]
    imul rax, COLNUM
    add rax, COLNUM                 ;   Подсчитаем эффективный адрес для сохранения числа во внутреннем представлении.
    sub rax, rcx                    ;   В регистр RAX поместим количество элементов для пропуска с начала массива.
    lea rdi, [rax * 2 + array]      ;   Загрузим в RDI эффективный адрес для результата преобразования.
    atoi                            ;   Преобразуем.
    loop cycleStrToArr              ; }

    mov rcx, [row]
    inc rcx
    cmp rcx, ROWNUM
    jl cycleReadRows
    ; Конец ввода матрицы

    write_string CheckMsg, lenCheck ; puts("Incoming parameters:");
    mov rcx, 0
    ; Цикл вывода строк матрицы
        cyclePrintRows:
    mov [row], rcx

    ; Вывод элементов массива через пробел
    mov rcx, COLNUM                 ; rcx = COLNUM;
        cyclePrintArr:
    mov rax, [row]                  ; В регистр RAX поместим количество элементов для пропуска с начала массива.
    imul rax, COLNUM
    add rax, COLNUM
    sub rax, rcx
    push rcx                        ; Сохранение счетчика в стек.
    mov rsi, OutBuf                 ; Подготовка
    mov rcx, 2                      ; к вызову
    lea rdi, [rax * 2 + array]      ; процедуры
    call numToString                ; numToString.
    dec rcx
    write_string OutBuf, rcx        ; printf("%d ", d);
    write_string SpaceMsg, lenSpace
    pop rcx                         ; Извлечение счетчика из стека.
    loop cyclePrintArr
    write_string EnterMsg, lenEnter

    mov rcx, [row]
    inc rcx
    cmp rcx, ROWNUM
    jl cyclePrintRows
    ; Конец вывода матрицы

    ; Завершение программы
    write_string ExitMsg, lenExit   ; puts("Press Enter to Exit");
    read_string InBuf, lenIn        ; gets();
    mov     rax, 60                 ; системная функция 60 (exit)
    xor     rdi, rdi                ; return code 0    
    syscall                         ; вызов системной функции
