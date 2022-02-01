    section .data           ; ������� ������������������ ����������
ExitMsg db      "Press Enter to Exit", 10 ; ��������� ���������
lenExit equ     $-ExitMsg
A       dd   -30
B       dd   21

    section .bss            ; ������� �������������������� ����������
InBuf   resb    10          ; ����� ��� �������� ������
lenIn   equ     $-InBuf     ; ����� ������ ��� �������� ������
X       resd    1

    section .text           ; ������� ����
    global _start

_start:
    ; ����������
    mov     EAX, [A]        ; ��������� ����� A � ������� EAX
    add     EAX, 5          ; ������� EAX � 5, ��������� � EAX
    sub     EAX, [B]        ; ������� ����� B, ��������� � EAX
    mov     [X], EAX        ; ��������� ��������� � ������

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
