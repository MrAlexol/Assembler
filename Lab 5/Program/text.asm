%define STRING_SIZE 256

    global _Z8cmpwordsPcPS_
    extern _Z6outputiPc

    section .data
Fgg db "rosa rsa ros bark  brosab roza rqqghhrosaqq osa rusa fjksd bjv rosa", 0

    section .bss
result resb 256

    section .text
    global _start
_start:

_Z8cmpwordsPcPS_:
    ; locals:
    ;   wordPtr - [rbp - 48] // qword указатель на место, где остановилось сравнивание слов, в текущем слове
    ;   wordStart - [rbp - 40] // qword начало слова для сравнения
    ;   result - [rbp - 32] // qword результат
    ;   nestWord - [rbp - 24] // qword указатель на исходное слово, формирующее гнездо
    ;   input - [rbp - 16] // qword указатель на введенную строку
    ;   nests - [rbp - 8] // word количество найденных гнезд
    ;   charPos - [rbp - 6] // word определяет номер символа, на который оканчивается слово, формирующее гнездо (обратная нумерация)
    ;   writePos - [rbp - 4] // word определяет номер символа для записи в строке одного гнезда
    ;   inLen - [rbp - 2] // word длина исходного слова

    push rbp
    mov rbp, rsp

    sub rsp, 56
    ;mov [rbp - 16], rdi     ; input (local var)
    ;mov [rbp - 32], rsi     ; result (local var)

    mov qword [rbp - 16], Fgg
    mov qword [rbp - 32], result 

    push rbx                ; сохранение rbx

; основная обработка
    ; подготовка перед внешним циклом
    cld
    mov rdi, [rbp - 16]	    ; rdi = input;

    mov rcx, STRING_SIZE
    mov al, ' '
    repe scasb              ; пропустить все пробелы
    dec rdi                 ; rdi = слово в строке (исходное слово, формирующее гнездо)

        ; temp
        ; mov r12, rdi
        ; mov r13, rcx
        ; mov rsi, rdi
        ; call _Z6outputiPc
        ; mov rdi, r12
        ; mov rcx, r13
        ; mov al, ' '
        ; end

    mov [rbp - 24], rdi     ; nestWord (local var) = rdi
    mov [rbp - 6], cx       ; charPos (local var)

    repne scasb             ; найти пробел
    mov rax, rcx
    mov cx, [rbp - 6]
    sub ecx, eax            ; cx - длина исходного слова
    mov [rbp - 4], cx
    dec cx
    mov [rbp - 2], cx       ; inLen = --cx;

    mov rdi, [rbp - 32]     ; rdi = result[0];
    mov rsi, [rbp - 24]     ; rsi = nestWord;
    rep movsb               ; вписать nestWord 0-м словом в гнездо
    mov byte [rdi], ' '

    cmp byte [rsi], 10
    je .end_of_proc

    ; repnz scasb           ; пропустить все не пробелы - пропустить текущее слово
    mov rdi, rsi
    
.cmp_next_word:
    xor rcx, rcx
    mov cx, [rbp - 6]
    mov al, ' '
    repe scasb              ; пропустить все пробелы - найти следующее слово
    dec rdi                 ; rdi = следующее слово в строке (слово для сравнения)
    mov [rbp - 40], rdi     ; wordStart = rdi;

    ; сравнение исходного слова с текущим

    mov rsi, [rbp - 24]     ; rsi = nestWord;
    movzx rcx, word [rbp - 2]
    repe cmpsb              ; сравнение до 1-го несовпадения

    push rcx                ; кол-во оставшихся букв в исходном слове
    push rdi                ; сравниваемое слово

    xor rbx, rbx
    xor rdx, rdx

    xor al, al              ; может, проверяемое слово короче исходного (конец строки)
    inc rcx
    repne scasb
    mov rdi, [rsp]
    cmp rcx, 1
    sete bl
    mov al, ' '             ; может, проверяемое слово короче исходного (пробел в конце)
    mov rcx, [rsp + 8]
    inc rcx
    repne scasb
    pop rdi
    cmp rcx, 1
    sete dl
    or bl, dl
    jz .skip_move
    dec rdi
.skip_move:

    pop rcx

    xor rdx, rdx
    xor rbx, rbx
    cmp byte [rsi], ' '     ; исходное слово закончилось?
    sete bl
    cmp byte [rsi - 1], ' '
    sete dl
    or bl, dl               ; bl = ([rsi] == ' ') | ([rsi - 1] == ' ')
    jz .cmps_go_on          ; bl - исходное слово закончилось

    cmp byte [rdi], ' '     ; сравниваемое слово закончилось?
    sete bl
    cmp byte [rdi - 1], ' '
    sete dl
    or bl, dl               ; bl = ([rdi] == ' ') | ([rdi - 1] == ' ') // bl - найден пробел
    mov dl, byte [rdi]
    and dl, byte [rdi - 1]  ; dl = [rdi] & [rdi - 1]
    cmp dl, 0
    sete dl                 ; // dl - найден /0
    mov [rbp - 48], rdi     ; wordPtr = rdi;
    or bl, dl               ; bl - найден пробел или /0, т.е. сравниваемое слово закончилось
    ;T jz .check_end_of_string
    jz .come_back

    ; добавить сравниваемое слово
.add_word:
    sub rdi, [rbp - 40]
    mov rcx, rdi            ; rcx = длина сравниваемого слова
    mov bx, [rbp - 4]       ; bx = writePos;
    mov rdi, [rbp - 32]     ; rdi = result;
    add di, bx
    mov rsi, [rbp - 40]     ; rsi = слово, которое только что сравнивалось
    add [rbp - 4], cx       ; writePos += cx;
    rep movsb
    cmp byte [rdi - 1], ' '
    je .space_is_already_there
    mov byte [rdi], ' '     ; в конце переписанного слова запишем пробел
    inc word [rbp - 4]
.space_is_already_there:
    jmp .check_end_of_string

.come_back:
    dec rsi
    inc word [rbp - 48]
    cmpsb
    jz .add_word
    jnz .check_end_of_string

.cmps_go_on:
.comparison:                ; сравнение до пробела у исходного слова или до 1-го несовпадения
    mov al, [rsi]           ; rsi - исходное слово
    cmp al, ' '
    je .end_of_comparison
    cmp al, [rdi]           ; rdi - сравниваемое слово
    jne .end_of_comparison
    inc rsi
    inc rdi
    jmp .comparison

.end_of_comparison:

    xor rbx, rbx
    xor rdx, rdx

    cmp byte [rdi], ' '     ; сравниваемое слово закончилось?
    sete bl
    cmp byte [rdi], 0       ; сравниваемое слово закончилось?
    sete dl
    or bl, dl               ; bl = ([rdi] == ' ') | ([rdi] == '\0')
    jz .failed_comparison

    ; добавить сравниваемое слово
    mov [rbp - 48], rdi     ; wordPtr = rdi;
    sub rdi, [rbp - 40]          
    mov rcx, rdi            ; rcx = длина сравниваемого слова
    mov bx, [rbp - 4]       ; bx = writePos;
    mov rdi, [rbp - 32]     ; rdi = result;
    add di, bx
    mov rsi, [rbp - 40]     ; rsi = слово, которое только что сравнивалось
    add [rbp - 4], cx       ; writePos += cx;
    rep movsb
    mov byte [rdi], ' '     ; в конце переписанного слова запишем пробел
    inc word [rbp - 4]

    jmp .check_end_of_string
.failed_comparison:

    mov rcx, STRING_SIZE
    mov al, ' '
    repne scasb
    dec rdi
    mov [rbp - 48], rdi

        ; temp
        ; mov r12, rdi
        ; mov r13, rcx
        ; mov rsi, rdi
        ; call _Z6outputiPc
        ; mov rdi, r12
        ; mov rcx, r13
        ; mov al, ' '
        ; end

    ;repnz scasb            ; пропустить все не \0 (temp)
    ;dec rdi
.check_end_of_string:
    mov rdi, [rbp - 48]     ; rdi = wordPtr;
    ; переход к следующей итерации
    xor rbx, rbx
    mov bl, byte [rdi]
    and bl, byte [rdi - 1]  ; bl = [rdi] & [rdi - 1]
    jnz .cmp_next_word      ; если слова для сравнения еще есть, возвращаемся наверх

    mov rdi, [rbp - 32]     ; rdi = result;
    add di, [rbp - 4]       ; di += writePos;
    dec rdi
    mov byte [rdi], 0

    ; mov rax, rdi

    push rdi
    push rsi
    sub rsp, 64             ; char buf[32];
    movzx cx, [rbp - 2]     ; rcx = inLen;
    mov rsi, [rbp - 24]     ; rsi = nestWord;
    mov rdi, rsp
    rep movsb               ; strcpy(buf, nestWord);
    mov byte [rdi], 0

    mov rdi, 5
    mov rsi, rsp
    ;call _Z6outputiPc       ; output();

    add rsp, 64
    pop rsi
    pop rdi
.end_of_proc:

    pop rbx                 ; восстановление rbx
    mov rsp, rbp
    pop rbp
    mov rax, 0              ; возвращаемое значение
    ret
