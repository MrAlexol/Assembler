    section .data           ; сегмент инициализированных переменных

    section .bss            ; сегмент неинициализированных переменных

    section .text           ; сегмент кода

    global _start
    extern main

_start:
    call main               ; rax = main();

    ; завершение программы
    mov rdi, rax            ; result = rax;
    mov rax, 60             ; системная функция 60 (exit)
    syscall                 ; вызов системной функции
