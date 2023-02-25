    section _text

; Подпрограмма преобразования строки в число.
; Ограничение: число должно находиться в интервале -30000 ≤ x ≤ 30000.
; Вход: ESI – адрес строки, содержащей запись числа (положительные числа
; вводятся без знака), в конце введенной строки символ «10».
; Выход: EAX – 32-х разрядное число, EBX – 0, если преобразование прошло
; без ошибок, и 1, если в процессе преобразования обнаружен ввод
; недопустимого символа или введенное число не попадает в заданный интервал.

StrToInt:
         push   edi
         mov    bh, '9'
         mov    bl, '0'
         push   esi     ; сохраняем адрес исходной строки
         cmp    byte[esi], '-'
         jne    .prod
         inc    esi     ; пропускаем знак минус
.prod    cld
         xor    di, di  ; обнуляем будущее число
.cycle:  lodsb          ; загружаем символ (цифру)
         cmp    al, 10  ; если 10, то на конец
         je     .Return
         cmp    al, bl  ; сравниваем с кодом нуля
         jb     .Error  ; "ниже" – Ошибка
         cmp    al, bh  ; сравниваем с кодом девяти
         ja     .Error  ; "выше" – Ошибка
         sub    al, 30h ; получаем цифру из символа
         cbw            ; расширяем до слова
         push   ax      ; сохраняем в стеке
         mov    ax, 10  ; заносим 10 в AX
         mul    di      ; умножаем, результат в DX:AX
         pop    di      ; в DI – очередная цифра
         add    ax, di
         mov    di, ax  ; в DI – накопленное число
         jmp    .cycle
.Return: pop    esi
         mov    ebx, 0
         cmp    byte[esi], '-'
         jne    .J
         neg    di
.J       mov    ax, di
         cwde
         jmp    .R
.Error:  pop    esi
         mov    eax, 0
         mov    ebx, 1
.R       pop    edi
         ret

; Подпрограмма преобразования числа в строку.
; Ограничение: числа в интервале -30000 ≤ x ≤ 30000.
; Вход: EAX – число, ESI – адрес области памяти для размещения строки
; результата (не менее 7 байт).
; Выход: EAX – размер строки результата, запись числа будет прижата к
; левой границе области по адресу ESI, после числа будет вставлен символ с кодом 10.

IntToStr: 
         push   edi
         push   ebx
         push   edx
         push   ecx
		 push   esi
		 mov    byte[esi],0     ; на место знака
         cmp    eax,0
         jge    .l1
         neg    eax
         mov    byte[esi],'-'
.l1      mov    byte[esi+6],10
         mov    edi,5
         mov    bx,10
.again:  cwd                    ; расширили слово до двойного
         div    bx              ; делим результат на 10
         add    dl,30h          ; получаем из остатка код цифры
         mov    [esi+edi],dl    ; пишем символ в строку
         dec    edi             ; переводим указатель на 
                                ; предыдущую позицию
         cmp    ax, 0           ; преобразовали все число?
         jne    .again
         mov    ecx, 6
         sub    ecx, edi        ; длина результата+знак
		 mov    eax,ecx
		 inc    eax             ; длина результата+знак+0А
         inc    esi             ; пропускаем знак
		 push   esi
         lea    esi,[esi+edi]   ; начало символов результата
		 pop    edi

         mov    ebx, [esp]
         cmp    byte [ebx], '-'
         je     .signed         ; если у числа нет знака,
         dec    edi             ; левый символ будет занят цифрой, а не пустовать
         dec    eax             ; длина результата+знак+0А, но знака нет
.signed:
         rep movsb
         pop    esi  
         pop    ecx
         pop    edx
         pop    ebx
         pop    edi
         ret
         