%include "iostream.asm"

%define INBUF_SIZE 256

global main

    section .data           ; сегмент инициализированных переменных
ExitMsg         db  "Press Enter to Exit", 10, 0 ; выводимое сообщение
InviteMsg       db  "Type the text", 10, 0 ; приглашение ко вводу
Consonants      db  "bcdfghjklmnpqrstvwxzBCDFGHJKLMNPQRSTVWXZ" ; согласные
Cons_count      equ $-Consonants
Vowels          db  "aeoiuyAEOIUY" ; гласные
Vows_count      equ $-Vowels

    section .bss            ; сегмент неинициализированных переменных

    section .text           ; сегмент кода
main:                       ; int main() { ... };
    push rbp
    mov rbp, rsp            ; пролог

    sub rsp, INBUF_SIZE     ; char InBuf[INBUF_SIZE];

    ; test
    sub rsp, 2              ; short totalVowels;
    sub rsp, 64             ; short consonants[32];

    lea rax, [rbp - 258]
    push rax
    lea rax, [rbp - 322]
    push rax

    push InviteMsg
    call scanWord

    ; =====

    mov rcx, INBUF_SIZE
    mov al, 0
    cld
    lea rdi, [rbp - INBUF_SIZE]
    rep stosb               ; InBuf = { 0 };

    push InviteMsg
    call CPrint              ; puts(InviteMsg);

    push WORD INBUF_SIZE
    lea rax, [rbp - INBUF_SIZE]
    push rax
    call readLn             ; readLn(InBuf, INBUF_SIZE);

    push WORD INBUF_SIZE
    lea rax, [rbp - INBUF_SIZE]
    push rax
    call CStylizeString     ; поместим в конце InBuf \0

    ; lea rax, [rbp - INBUF_SIZE]
    ; push rax
    ; call inspectString      ; вызов основной процедуры обработки



    push ExitMsg
    call CPrint             ; puts(ExitMsg);

    push WORD INBUF_SIZE
    lea rax, [rbp - INBUF_SIZE]
    push rax
    call readLn             ; readLn(InBuf, INBUF_SIZE);

    mov rax, 0              ; поместим код возврата в rax   
    mov rsp, rbp            ; эпилог
    pop rbp
    ret

inspectString:              ; arg0 - адрес строки с \0 на конце
    push rbp
    mov rbp, rsp            ; пролог

    sub rsp, 2              ; short totalVowels;
    sub rsp, 64             ; short consonants[32];

    push WORD 0             ; vector words << 0; // words - вектор индексов начал слов в строке
    mov rcx, 0              ; index
    mov rax, 1              ; cnt

.next_char:
    mov rbx, [rbp + 16]
    cmp byte [rbx + rcx], 32
    jne .not_space
    push cx
    inc WORD [rsp]          ; words << (index + 1);
    inc rax
.not_space:
    inc rcx

    mov rbx, [rbp + 16]
    cmp byte [rbx + rcx], 0
    jne .next_char          ; наполнение words окончено

    
    mov rcx, rax

    mov rbx, [rsp + rcx*2 - 2]  ; int wordInt << words; // берем начиная с нижнего индекса


    mov rax, 0              ; поместим код возврата в rax   
    mov rsp, rbp            ; эпилог
    pop rbp
    ret 8

scanWord:
    ; // Пример вызова по C: scanWord(char* str, short& cons, short& vows); // str - строка, оканчивающаяся на 0
    push rbp
    mov rbp, rsp            ; пролог

    mov ax, 0
    mov rbx, [rbp + 24]
    mov [rbx], ax           ; cons = 0;
    mov rbx, [rbp + 32]
    mov [rbx], ax           ; vows = 0;

    push QWORD [rbp + 16]
    call strlen             ; ax = strlen(str);

    mov cx, 0
.word_cycle:                ; ищем rcx-ю букву среди гласных
    push ax
    mov rbx, [rbp + 16]
    add rbx, rcx
    mov al, [rbx]           ; загрузка буквы из строки в al

    mov rdi, Vowels         ; загрузка адреса строки с гласными в rdi
    push cx
    mov rcx, Vows_count
    cld
    repne scasb
    jecxz .vowels_not_found
    mov rbx, [rbp + 32]
    inc WORD [rbx]          ; vows++;
.vowels_not_found:

    mov rdi, Consonants     ; загрузка адреса строки с гласными в rdi
    mov rcx, Cons_count
    cld
    repne scasb
    jecxz .consonants_not_found
    mov rbx, [rbp + 24]
    inc WORD [rbx]          ; cons++;
.consonants_not_found:

    pop cx
    pop ax

    inc cx
    cmp cx, ax
    jl .word_cycle

    mov rax, 0              ; поместим код возврата в rax   
    mov rsp, rbp            ; эпилог
    pop rbp
    ret 24