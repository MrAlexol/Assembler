%include "iostream.asm"

global main

    section .data           ; сегмент инициализированных переменных
ExitMsg db      "Press Enter to Exit", 10 ; выводимое сообщение
lenExit equ     $-ExitMsg

    section .bss            ; сегмент неинициализированных переменных
InBuf   resb    10          ; буфер для вводимой строки
lenIn   equ     $-InBuf     ; длина буфера для вводимой строки

    section .text
main:
    push rbp
    mov rbp, rsp            ; пролог

    push WORD lenExit
    push ExitMsg
    call print              ; print(ExitMsg, lenExit);

    push WORD lenIn
    push InBuf
    call readLn             ; readLn(InBuf, lenIn);

    mov ax, 0
    mov [rbp + 16], ax      ; поместим в стек код возврата
    mov rsp, rbp            ; эпилог
    pop rbp
    ret