%define STDIN   0
%define STDOUT  1
%define READ    0
%define WRITE   1

%define ROWNUM  4
%define COLNUM  6

%include "../lib64.asm"

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

readLn:
    ; // Пример вызова по C: readLn(char* array, int count);
    push rbp
    mov rbp, rsp

    mov     rax, 0          ; системная функция READ
    mov     rdi, 0          ; дескриптор файла STDIN
    mov     rsi, [rbp + 16] ; адрес выводимой строки
    mov     rdx, [rbp + 24] ; длина строки
    syscall                 ; вызов системной функции

    pop rbp
    ret 16

numToString:
    ; Входные данные:
    ;   RSI - адрес строки
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

print:
    ; // Пример вызова по C: print(char* array, int count);
    push rbp
    mov rbp, rsp

    mov     rax, 1          ; системная функция WRITE
    mov     rdi, 1          ; дескриптор файла STDOUT
    mov     rsi, [rbp + 16] ; адрес выводимой строки
    mov     rdx, [rbp + 24] ; длина строки
    syscall                 ; вызов системной функции

    pop rbp
    ret 16

printMatrix:
    ; // Пример вызова по C: printMatrix(int* array, int rows, int cols);
    push rbp
    mov rbp, rsp

    mov rcx, 0
    ; Цикл вывода строк матрицы
        cyclePrintRows:
    push rcx                        ; Положим в стек номер текущей строки

    ; Вывод элементов массива через пробел
    mov rcx, [rbp + 32]             ; rcx = arg2; // (COLNUM)
        cyclePrintArr:
    mov rax, [rsp]                  ; rax = *rsp; // номер текущей строки
    imul rax, [rbp + 32]            ; rax *= arg2; // кол-во элементов в предыдущих строках
    add rax, [rbp + 32]             ; rax += arg2; // кол-во элементов в матрице с кол-вом строк, равным текущему номеру строки
    sub rax, rcx                    ; rax -= rcx; // индекс текущего элемента при нумерации матрицы построчно
    shl rax, 1                      ; rax *= 2; // смещение в байтах относительно начала массива
    push rcx                        ; Сохранение счетчика в стек.
    push 0                          ; char str[8] = {0}; // Объявление локальной переменной
    mov rsi, rsp                    ; Подготовка к вызову процедуры numToString.
    mov rcx, 2                      ; rcx = 2; // тип данных - word
    mov rdi, [rbp + 16]             ; rdi = arg0 + rax;
    add rdi, rax                    ; rsi = str;
    call numToString
    ; print(str, strlen(str));
    dec rcx                         ; rcx--; // rcx содержит длину строки с Enter на конце
    mov rax, rsp                    ; rax = rsp;
    push rcx                        ; arg1 = rcx;
    push rax                        ; arg0 = rax;
    call print                      ; print(arg0, arg1);
    ; print('\t', 1);
    push lenSpace                   ; arg1 = 1;
    push SpaceMsg                   ; arg0 = '\t';
    call print                      ; print(arg0, arg1);

    add rsp, 8                      ; Забудем переменную str
    pop rcx                         ; Извлечение счетчика из стека.
    loop cyclePrintArr

    ; puts();
    push lenEnter                   ; arg1 = 1;
    push EnterMsg                   ; arg0 = '\n';
    call print                      ; print(arg0, arg1);

    pop rcx                         ; Извлечем из стека номер текущей строки
    inc rcx                         ; Переходим на следующую строку
    cmp rcx, [rbp + 24]
    jl cyclePrintRows
    pop rbp
    ret 24

readMatrix:
    ; // Пример вызова по C: readMatrix(int* array, int rows, int cols);
    push rbp
    mov rbp, rsp

    mov rcx, 0
    push rcx                        ; int row = rcx;
    ; Цикл ввода строк матрицы
        cycleReadRows:
    mov [rbp - 8], rcx              ; row = rcx;

    mov rcx, 4
        cycleNewStr:
    push 0                          ; char* newStr = new char[32];
    loop cycleNewStr

    push 32
    mov rax, rbp
    sub rax, 40
    push rax
    call readLn                     ; newStr = gets(); // получим строку, где числа разделены пробелами      

    ; Преобразование строки в одномерный массив чисел
    mov rcx, 32                     ; rcx = 32;
        cycleTransformStr:          ; for (int rcx = lenIn; rcx > 0; rcx--) {
    mov rax, rbp
    sub rax, 40                     ; rax = newStr;
    add rax, rcx                    ; rax += rcx;
    dec rax                         ; rax--;
    cmp byte [rax], 32              ; if (*rax == ' ') { // заменим все пробелы на Enter
    jne skipCycleTransformStr
    mov byte [rax], 10              ; *rax = '\n';
    mov rsi, rax
    inc rsi                         ;   Сохраним все адреса замененных пробелов (т.е. адреса строк с числами)
    push rsi                        ;   в стек, чтобы затем по очереди их извлечь и найти числа для преобразования.
        skipCycleTransformStr:      ;   }
    loop cycleTransformStr          ; }

    mov rsi, rbp
    sub rsi, 40                     ; Адрес первого числа в большой строке известен, но его нет в стеке, поэтому обработаем его отдельно.
    mov rax, [rbp - 8]              ; rax = row;
    imul rax, [rbp + 32]            ; rax *= arg2;
    shl rax, 1                      ; rax *= 2;
    mov rdi, [rbp + 16]             ; rdi = arg0;
    add rdi, rax                    ; rdi += rax; // Поместим эффективный адрес в регистр RDI.
    atoi                            ; Преобразование строки по адресу [RDI] в число типа WORD.

    mov rcx, [rbp + 32]             ; for (int rcx = arg2 - 1; rcx > 0; rcx--) {
    dec rcx
        cycleStrToArr:
    pop rsi                         ;   Берем адреса строк с числами из стека.
    mov rax, [rbp - 8]              ;   rax = row;
    imul rax, [rbp + 32]            ;   rax *= arg2;
    add rax, [rbp + 32]             ;   rax += arg2;
    sub rax, rcx                    ;   rax -= rcx; // В регистр RAX поместим количество элементов для пропуска с начала массива.
    shl rax, 1                      ;   rax *= 2;
    mov rdi, [rbp + 16]             ;   rdi = arg0;
    add rdi, rax                    ;   rdi += rax; // Загрузим в RDI эффективный адрес для результата преобразования.
    atoi                            ;   Преобразуем.
    loop cycleStrToArr              ; }

    mov rcx, [rbp - 8]              ; rcx = row;
    inc rcx                         ; rcx++;
    add rsp, 32                     ; delete newStr;
    cmp rcx, [rbp + 24]             ; if (rcx < arg1)
    jl cycleReadRows                ;   goto cycleReadRows;
    ; Конец ввода матрицы           ; else
                                    ;   return;
    mov rsp, rbp
    pop rbp
    ret 24

    section .data
ExitMsg     db      "Press Enter to Exit", 10
lenExit     equ     $-ExitMsg
StartMsg    db      "Type matrix 4x6", 10
lenStart    equ     $-StartMsg
CheckMsg    db      "Incoming parameters:", 10
lenCheck    equ     $-CheckMsg
ResultMsg   db      "The result is", 10
lenResult   equ     $-ResultMsg
SpaceMsg    db      9
lenSpace    equ     $-SpaceMsg
EnterMsg    db      10
lenEnter    equ     $-EnterMsg

    section .bss
InBuf   resb    32              ; буфер ввода
lenIn   equ     $-InBuf
OutBuf  resb    7               ; буфер вывода
array   resw    ROWNUM*COLNUM   ; массив

    section .text
global _start

_start:
    push lenStart
    push StartMsg
    call print                      ; puts("Type matrix 4x6");

    push QWORD COLNUM               ; arg2 = COLNUM;
    push QWORD ROWNUM               ; arg1 = ROWNUM;
    push array                      ; arg0 = array;
    call readMatrix                 ; readMatrix(arg0, arg1, arg2);

    push lenCheck
    push CheckMsg
    call print                      ; puts("Incoming parameters:");

    push QWORD COLNUM               ; arg2 = COLNUM;
    push QWORD ROWNUM               ; arg1 = ROWNUM;
    push array                      ; arg0 = array;
    call printMatrix                ; printMatrix(arg0, arg1, arg2);

    mov rcx, 0
        cycleMatrix:                ; for (int row = 0; row < ROWNUM; row++) {
    push rcx

    mov rcx, 0                      ;   rcx = 0;
    mov ax, 0                       ;   ax = 0;
        cycleRow:                   ;   for (int col = 0; col < COLNUM; rcx++) {
    push rcx
    mov rcx, [rsp + 8]              ;       rcx = row;
    imul rcx, COLNUM                ;       rcx *= COLNUM;
    add rcx, [rsp]                  ;       rcx += col; // rcx - кол-во элементов для пропуска в одномерном массиве
    cmp WORD [array + rcx * 2], 0   ;       if (array[row][col] < 0)
    jge skipElement
    add ax, [array + rcx * 2]       ;           ax += array[rcx];
        skipElement:
    pop rcx
    inc rcx
    cmp rcx, COLNUM
    jl cycleRow                     ;   }
    mov rcx, [rsp]                  ;   rcx = row;
    imul rcx, COLNUM                ;   rcx *= COLNUM;
    mov [array + rcx * 2], ax       ;   array[row][0] = ax;

    pop rcx
    inc rcx
    cmp rcx, ROWNUM
    jl cycleMatrix                  ; }

    push lenResult
    push ResultMsg
    call print                      ; puts("The result is");

    push QWORD COLNUM               ; arg2 = COLNUM;
    push QWORD ROWNUM               ; arg1 = ROWNUM;
    push array                      ; arg0 = array;
    call printMatrix                ; printMatrix(arg0, arg1, arg2);

    ; Завершение программы
    push lenExit
    push ExitMsg
    call print                      ; puts("Press Enter to Exit"); 
    push lenIn
    push InBuf
    call readLn                     ; gets();     
    mov     rax, 60                 ; системная функция 60 (exit)
    xor     rdi, rdi                ; return code 0    
    syscall                         ; вызов системной функции
