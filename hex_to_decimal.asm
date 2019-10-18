%macro scall 4
mov rax,%1
mov rdi,%2
mov rsi,%3
mov rdx,%4
syscall
%endmacro

accept_proc:
scall 0,0,buf,5
xor rbx,rbx
mov rcx,4
mov rax,0
mov rsi,buf
next_digit:
rol bx,04H
mov al,[rsi]
cmp al,39H
jbe L1
sub al,07H
L1: sub al,30H
add bx,ax
inc rsi
dec rcx
JNZ next_digit
ret

section .data
m1 DB "Enter 4 digit hex no.",10d,13d
l1 equ $-m1
m2 DB " The equivalent 5-digit BCD is",10d,13d
l2 equ $-m2

section .bss
buf resb 6
digitcount resb 1
char_ans resb 4

section .text
global _start
_start:
scall 1,1,m1,l1
call accept_proc
mov ax,bx
back:
xor rdx,rdx
mov rbx,0AH
div rbx
push dx
inc byte[digitcount]
cmp rax,0h
jne back
scall 1,1,m2,l2
print_bcd:
pop dx
add dl,30H
mov [char_ans],dl
scall 1,1,char_ans,1
dec byte[digitcount]
jnz print_bcd

mov rax,60
mov rdi,0
syscall