%define STRING_SIZE 256

    global _Z8cmpwordsPcPS_
    extern _Z6outputiPc

    section .data
str: db "ruka ruska rua ruka rusk ruk ua ra ", 0 ; ruka ruska rua ruka rusk ruk ua ra 

    section .bss
result resb 256*16

    section .text
    global _start
_start:

_Z8cmpwordsPcPS_:
    ; locals:
    ; [rbp - 8] - str       qword   char[]
    ; [rbp - 16] - result   qword   char[]
    ; [rbp - 20] - len1     dword   int
    ; [rbp - 24] - len2     dword   int
    ; [rbp - 32] - ptr1     qword   char*
    ; [rbp - 40] - ptr2     qword   char*
    ; [rbp - 44] - len      dword   int
    ; [rbp - 48] - num      dword   int

    push rbp
    mov rbp, rsp

    push str
    push result
    sub rsp, 32

    push rbx                ; сохранение rbx

; основная обработка
    ; подготовка перед внешним циклом
    cld
    mov rdi, [rbp - 8]	    ; rdi = str;
    mov dword [rbp - 48], 0 ; num = 0; // счетчик гнезд

.ext_loop:
    ; получить исходное слово
    mov rcx, STRING_SIZE
    mov al, ' '
    repe scasb              ; пропустить все пробелы
    dec rdi                 ; rdi = слово в строке (исходное слово, формирующее гнездо)
    cmp byte [rdi], 0
    jz .end_of_proc

    mov [rbp - 32], rdi     ; ptr1 = rdi;

    ; выбор гнезда для записи результата
    mov dword [rbp - 44], 0 ; заполняемость гнезда
    mov eax, [rbp - 48]
    sal eax, 8
    add [rbp - 16], eax     ; переключение на нужное гнездо

    ; len1 = длина исходного слова
    ;push rcx
    push ' '
    push rdi
    call _strlen@16         ; strlen(rdi, ' ');
    ;pop rcx
    mov [rbp - 20], eax

    ; запись исходного слова в гнездо
    mov rcx, rax
    mov rsi, rdi
    mov rdi, [rbp - 16]
    rep movsb
    inc eax
    add [rbp - 44], eax     ; len += ++eax;
    mov byte [rdi], ' '

    mov rdi, [rbp - 32]     ; rdi = ptr1;
    add edi, [rbp - 20]     ; rdi += len1;

.int_loop:
    
    ; получить слово для сравнения
    mov rcx, STRING_SIZE
    mov al, ' '
    repe scasb              ; пропустить все пробелы
    dec rdi                 ; rdi = слово в строке (слово для сравнения)
    cmp byte [rdi], 0
    jne .handle_word
    ; переход к следующей итерации
    mov ebx, [rbp - 44]
    add rbx, [rbp - 16]
    mov byte [rbx - 1], 0       ; result[len] = '\0'; // "закупорим" гнездо
    mov rdi, [rbp - 32]
    add edi, [rbp - 20]
    inc dword [rbp - 48]
    jmp .ext_loop

.handle_word:
    mov [rbp - 40], rdi     ; ptr2 = rdi;

    ; len2 = длина сравниваемого слова
    ;push rcx
    push ' '
    push rdi
    call _strlen@16         ; strlen(rdi, ' ');
    ;pop rcx
    mov [rbp - 24], eax

    sub eax, [rbp - 20]     ; len2 V len1
    je .len1_eq_len2        ; len2 равно len1
    cmp eax, -1
    je .len1_lt_len2        ; len2 + 1 = len1
    
    add edi, [rbp - 24]     ; разница в длине больше 1
    jmp .int_loop

.len1_eq_len2:
    ; сравнение не более len2 раз или до несовпадения
    xor rcx, rcx
    mov ecx, [rbp - 24]
    mov rsi, [rbp - 32]
    repe cmpsb
    jecxz .add_word
    
    ; пропустить по 1 букве в словах

    ; сравнение до конца слова или до несовпадения
    repe cmpsb
    ; предыдущие буквы одинаковые?
    je .add_word
    mov rdi, [rbp - 40]
    add edi, [rbp - 24]         ; пропуск неподошедшего слова
    jmp .int_loop

.add_word:
    ; добавить сравниваемое слово
    mov rdi, [rbp - 16]
    add edi, [rbp - 44]
    mov rsi, [rbp - 40]
    xor rcx, rcx
    mov ecx, [rbp - 24]
    rep movsb
    mov byte [rdi], ' '
    mov eax, [rbp - 24]
    inc eax
    add [rbp - 44], eax
    mov rdi, rsi
    jmp .int_loop

.len1_lt_len2:

    ; сравнение не более len2 раз или до несовпадения
    xor rcx, rcx
    mov ecx, [rbp - 24]
    mov rsi, [rbp - 32]
    repe cmpsb

    je .add_word

    ; вернуться на 1 букву в сравниваемом слове
    dec rdi
    inc rcx

    ; сравнение до конца слова или до несовпадения
    repe cmpsb
    ; предыдущие буквы одинаковые?
    je .add_word

    mov rdi, [rbp - 40]
    add edi, [rbp - 24]         ; пропуск неподошедшего слова
    jmp .int_loop

.end_of_proc:

    pop rbx                 ; восстановление rbx
    mov rsp, rbp
    pop rbp
    mov rax, 0              ; возвращаемое значение
    ret

%define MAX_STRING_LENGTH 256

; int __stdcall strlen(char* str, char sym);
_strlen@16:
    ; // Пример вызова по C: strlen(char* str, char sym); // str - строка, sym - символ конца строки
    push    rbp
    mov     rbp, rsp

    push    rdi             ; сохранить rdi

    mov     rax, [rbp + 24] ; [rbp + 24] - символ конца строки (arg1)
    mov     rdi, [rbp + 16] ; [rbp + 16] - адрес строки (arg0)

    cld
    mov     rcx, MAX_STRING_LENGTH
    repnz   scasb           ; поиск символа конца строки

    mov     rax, MAX_STRING_LENGTH
    sub     rax, rcx
    dec     rax             ; вычисление длины строки по значению rcx

    pop     rdi             ; восстановить rdi
    pop     rbp
    ret     16