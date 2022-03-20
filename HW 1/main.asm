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

    lea rax, [rbp - INBUF_SIZE]
    push rax
    call inspectString      ; вызов основной процедуры обработки

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

    push WORD 0             ; short totalVowels = 0;
    sub rsp, 64             ; short consonants[32];
    sub rsp, 2              ; short wordsCount;

    push WORD 0             ; vector words << 0; // words - вектор индексов начал слов в строке
    mov rcx, 0              ; index - индекс буквы в тексте
    mov rax, 1              ; cnt - счетчик слов в тексте

.next_char:
    mov rbx, [rbp + 16]
    cmp byte [rbx + rcx], 32
    jne .not_new_word
    and byte [rbx + rcx], 0
    cmp byte [rbx + rcx + 1], 32
    je .not_new_word
    push cx
    inc WORD [rsp]          ; words << (index + 1);
    inc rax
.not_new_word:
    inc rcx

    mov rbx, [rbp + 16]
    cmp byte [rbx + rcx], 0
    jne .next_char          ; наполнение вектора words окончено
    
    mov [rbp - 68], ax      ; wordsCount = ax;

    xor rcx, rcx
    mov cx, [rbp - 68]     ; cx = wordsCount;
.cycle_words:
    xor rbx, rbx
    mov bx, [rsp + rcx*2 - 2]  ; int wordInd << words; // берем начиная с нижнего индекса

    push WORD 0             ; short vows; // кол-во гласных в слове
    push WORD 0             ; short cons; // кол-во согласных в слове

    push rcx

    lea rax, [rsp + 10]
    push rax                ; arg2 = &vows;
    lea rax, [rsp + 16]
    push rax                ; arg1 = &cons;
    mov rax, [rbp + 16]
    add rax, rbx
    push rax                ; arg0 - i-е слово в строке
    call scanWord           ; scanWord(str, cons, vows);

    pop rcx

    xor rbx, rbx
    mov bx, [rbp - 68]
    sub bx, cx
    pop WORD [rbp + rbx*2 - 66]
    pop ax
    add [rbp - 2], ax

    loop .cycle_words

    ; [rbp - 66] - массив с кол-вом согласных
    ; [rbp - 2] - общее кол-во гласных

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
    repne scasb             ; поиск данной буквы среди гласных
    jecxz .vowels_not_found
    mov rbx, [rbp + 32]     ; Если буква гласная, увеличиваем счетчик
    inc WORD [rbx]          ; vows++;
.vowels_not_found:

    mov rdi, Consonants     ; загрузка адреса строки с гласными в rdi
    mov rcx, Cons_count
    cld
    repne scasb             ; поиск данной буквы среди согласных
    jecxz .consonants_not_found
    mov rbx, [rbp + 24]     ; Если буква согласная, увеличиваем счетчик
    inc WORD [rbx]          ; cons++;
.consonants_not_found:

    pop cx
    pop ax

    inc cx
    cmp cx, ax              ; ax - длина слова, cx - индекс буквы
    jl .word_cycle

    mov rax, 0              ; поместим код возврата в rax   
    mov rsp, rbp            ; эпилог
    pop rbp
    ret 24