%define STRING_SIZE 256

    global _Z8cmpwordsPcPA256_c
    extern _Z6outputiPc

    section .data

    section .bss

    section .text

_Z8cmpwordsPcPA256_c:
    ; locals:
    ; [rbp - 8] - str       qword   char[]  входная строка (данные по указателю не меняются)
    ; [rbp - 16] - result   qword   char[]  выходной массив (изменяемый указатель)
    ; [rbp - 20] - len1     dword   int     длина исходного слова (формирующего гнездо)
    ; [rbp - 24] - len2     dword   int     длина сравниваемого слова (записываемого или нет в гнездо)
    ; [rbp - 32] - ptr1     qword   char*   указатель на исходное слово
    ; [rbp - 40] - ptr2     qword   char*   указатель на сравниваемое слово
    ; [rbp - 44] - len      dword   int     длина строки в выходном массиве (индекс для записи в ней)
    ; [rbp - 46] - num      word    short   счетчик гнезд
    ; [rbp - 48] - cnt      word    short   счетчик слов в гнезде

    push rbp
    mov rbp, rsp

    push rdi
    push rsi
    sub rsp, 40

    push rbx                ; сохранение rbx

; основная обработка
    ; подготовка перед внешним циклом
    cld
    mov rdi, [rbp - 8]	    ; rdi = str;
    mov word [rbp - 46], 0  ; num = 0; // счетчик гнезд
    mov word [rbp - 48], 0  ; cnt = 0; // счетчик слов в гнезде

.ext_loop:
    ; получить исходное слово
    mov rcx, STRING_SIZE
    mov al, ' '
    repe scasb              ; пропустить все пробелы
    dec rdi                 ; rdi = слово в строке (исходное слово, формирующее гнездо)
    cmp byte [rdi], 0
    jz .end_of_proc

    mov [rbp - 32], rdi     ; ptr1 = rdi;

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

    mov edi, [rbp - 20]
    add rdi, [rbp - 32]     ; rdi = ptr1 + len1;

.int_loop:
    
    ; получить слово для сравнения
    mov rcx, STRING_SIZE
    mov al, ' '
    repe scasb              ; пропустить все пробелы
    dec rdi                 ; rdi = слово в строке (слово для сравнения)
    cmp byte [rdi], 0
    jne .handle_word

    ; отладочный вывод (вызов процедуры на C++)
    sub rsp, 32             ; char* currentWord = new char[32];
    mov rdi, rsp            ; rdi = currentWord;
    mov rsi, [rbp - 32]     ; rsi = ptr1;
    mov ecx, [rbp - 20]     ; ecx = len1;
    rep movsb
    mov byte [rdi], 0

    movzx rdi, word [rbp - 48]
    mov rsi, rsp
    call _Z6outputiPc       ; output(cnt, currentWord);

    add rsp, 32             ; delete[] currentWord;

    ; переход к следующей итерации
    xor rbx, rbx
    mov ebx, [rbp - 44]
    add rbx, [rbp - 16]
    mov byte [rbx - 1], 0   ; result[len] = '\0'; // "закупорим" гнездо
    xor rdi, rdi
    mov edi, [rbp - 20]
    add rdi, [rbp - 32]     ; rdi = ptr1 + len1;
    inc word [rbp - 46]     ; num++; // номер гнезда
    mov word [rbp - 48], 0  ; cnt = 0; // сброс счетчика слов в гнезде

    ; выбор гнезда для записи результата
    mov dword [rbp - 44], 0 ; заполняемость гнезда
    mov eax, 1
    sal eax, 8
    add [rbp - 16], eax     ; переключение на нужное гнездо

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
    cmp eax, 1
    je .len1_gt_len2        ; len2 - 1 = len1
    
    mov eax, [rbp - 24]
    add rdi, rax            ; разница в длине больше 1
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
    mov edi, [rbp - 24]
    add rdi, [rbp - 40]     ; пропуск неподошедшего слова
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

    mov edi, [rbp - 24]
    add rdi, [rbp - 40]     ; пропуск неподошедшего слова
    jmp .int_loop

.len1_gt_len2:
    ; сравнение не более len2 раз или до несовпадения
    xor rcx, rcx
    mov ecx, [rbp - 20]
    mov rsi, [rbp - 32]
    repe cmpsb

    je .add_word

    ; вернуться на 1 букву в исходном слове
    dec rsi
    inc rcx

    ; сравнение до конца слова или до несовпадения
    repe cmpsb
    ; предыдущие буквы одинаковые?
    je .add_word

    mov edi, [rbp - 24]
    add rdi, [rbp - 40]     ; пропуск неподошедшего слова
    jmp .int_loop

.add_word:
    ; добавить сравниваемое слово
    mov edi, [rbp - 44]
    add rdi, [rbp - 16]
    mov rsi, [rbp - 40]
    xor rcx, rcx
    mov ecx, [rbp - 24]
    rep movsb
    mov byte [rdi], ' '
    mov eax, [rbp - 24]
    inc eax
    add [rbp - 44], eax
    mov rdi, rsi
    inc word [rbp - 48]     ; cnt++;
    jmp .int_loop

.end_of_proc:

    ; return num; // возвращаемое значение
    movzx rax, word [rbp - 46]

    pop rbx                 ; восстановление rbx
    mov rsp, rbp
    pop rbp
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