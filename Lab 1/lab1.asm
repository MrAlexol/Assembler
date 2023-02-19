    section .data           ; сегмент инициализированных переменных
ExitMsg db      "Press Enter to Exit", 10 ; выводимое сообщение
lenExit equ     $-ExitMsg
A       dd   -30
B       dd   21

val1    db      255
chart   dw      256
lue3    dw      -128
v5      db      10h
        db      100101B
beta    db      23,23h,0ch
sdk     db      "Hello",10
min     dw      -32767
ar      dd      12345678h
valar   times   5   db      8

value1  dw      25
value2  dd      -35
name    db      "Alex", 10
name_ru db      "Алексей", 10

v1      db      25h, 0
v2      dw      25h
v3      dw      '%'
v4      db      '%', 0

u1      db      0, 25h
u2      dw      2500h
u3      db      0, '%'
u4      dw      10010100000000b

F1      dw      65535
F2      dd      65535

    section .bss            ; сегмент неинициализированных переменных
InBuf   resb    10          ; буфер для вводимой строки
lenIn   equ     $-InBuf     ; длина буфера для вводимой строки
X       resd    1
alu     resw    10
f1      resb    5

    section .text           ; сегмент кода
    global _start

_start:
    ; вычисления
    mov     eax, [A]        ; загрузить число A в регистр EAX
    add     eax, 5          ; сложить EAX и 5, результат в EAX
    sub     eax, [B]        ; вычесть число B, результат в EAX
    mov     [X], eax        ; сохранить результат в памяти

    ; переполнение
    add     WORD    [F1], 1
    add     DWORD   [F2], 1

    ; вывод
    mov     rax, 1          ; системная функция 1 (write)
    mov     rdi, 1          ; дескриптор файла stdout=1
    mov     rsi, ExitMsg    ; адрес выводимой строки
    mov     rdx, lenExit    ; длина строки
    syscall                 ; вызов системной функции

    ; ввод
    mov     rax, 0          ; системная функция 0 (read)
    mov     rdi, 0          ; дескриптор файла stdin=0
    mov     rsi, InBuf      ; адрес вводимой строки
    mov     rdx, lenIn      ; длина строки
    syscall                 ; вызов системной функции

    ; завершение программы
    mov     rax, 60         ; системная функция 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; вызов системной функции
