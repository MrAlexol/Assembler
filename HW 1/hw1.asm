    section .data           ; сегмент инициализированных переменных

    section .bss            ; сегмент неинициализированных переменных

    section .text           ; сегмент кода
    global _start
    extern main

_start:
    sub rsp, 16             ; int result;
    call main               ; result = main();

    ; завершение программы
    mov rax, 60             ; системная функция 60 (exit)
    mov rdi, [rsp]          ; return result;
    syscall                 ; вызов системной функции
