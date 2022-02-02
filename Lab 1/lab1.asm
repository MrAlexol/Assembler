    section .data           ; ������� ������������������ ����������
ExitMsg db      "Press Enter to Exit", 10 ; ��������� ���������
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
name_ru db      "�������", 10

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

    section .bss            ; ������� �������������������� ����������
InBuf   resb    10          ; ����� ��� �������� ������
lenIn   equ     $-InBuf     ; ����� ������ ��� �������� ������
X       resd    1
alu     resw    10
f1      resb    5

    section .text           ; ������� ����
    global _start

_start:
    ; ����������
    mov     eax, [A]        ; ��������� ����� A � ������� EAX
    add     eax, 5          ; ������� EAX � 5, ��������� � EAX
    sub     eax, [B]        ; ������� ����� B, ��������� � EAX
    mov     [X], eax        ; ��������� ��������� � ������

    ; ������������
    add     WORD    [F1], 1
    add     DWORD   [F2], 1

    ; �����
    mov     rax, 1          ; ��������� ������� 1 (write)
    mov     rdi, 1          ; ���������� ����� stdout=1
    mov     rsi, ExitMsg    ; ����� ��������� ������
    mov     rdx, lenExit    ; ����� ������
    syscall                 ; ����� ��������� �������

    ; ����
    mov     rax, 0          ; ��������� ������� 0 (read)
    mov     rdi, 0          ; ���������� ����� stdin=0
    mov     rsi, InBuf      ; ����� �������� ������
    mov     rdx, lenIn      ; ����� ������
    syscall                 ; ����� ��������� �������

    ; ���������� ���������
    mov     rax, 60         ; ��������� ������� 60 (exit)
    xor     rdi, rdi        ; return code 0    
    syscall                 ; ����� ��������� �������
