%macro print 2
mov rax,1
mov rdi,0
mov rsi,%1
mov rdx,%2
syscall
%endmacro
%macro read 2
mov rax,0
mov rdi,1
mov rsi,%1
mov rdx,%2
syscall
%endmacro
section .data
menu:  db "=====================================",10
 db "                 MENU                ",10
 db "=====================================",10
 db "Enter your choice",10
 db "1. Hex to BCD",10
 db "2.BCD to hex",10
 db "3.Exit",10
menulen: equ $-menu
msg1:  db "Enter the number",10
len1:  equ $-msg1
blank:  db "",10
blen: equ $-blank

section .bss
choice resb 2
hexcode resb 5
bcdcode resb 5
count resb 1
ascdigit resb 1
asciicode resb 4

section .text
global _start:
_start:
print menu,menulen
read choice,2
cmp byte[choice],31h
je hod
cmp byte[choice],32h
je doh
cmp byte[choice],33h
je exit
jmp _start   ;jump to start if invalid choice is entered




hod:    ;hex to bcd
print msg1,len1
read hexcode,5
mov byte[count],4
call hextoascii   ;value at dx is hexadecimal ie binary
mov byte[count],0
mov rax,0h
mov ax,dx
mov rdx,0h
mov rbx,0Ah
back:
div rbx
push dx
mov rdx,0
inc byte[count]
cmp ax,0h
jnz back

repeat:
pop dx
add dl,30h
mov byte[ascdigit],dl
print ascdigit,1
dec byte[count]
jnz repeat
print blank,blen
jmp _start

doh:   ;bcd to hex

print msg1,len1
read bcdcode,6

mov rbx,10
mov rdx,0
mov rax,0
mov byte[count],5
mov rsi,bcdcode

;converting to decimal
unpack:
mul rbx
sub byte[rsi],30h
movsx cx,byte[rsi] ;move with sign extended
add ax,cx
inc rsi
dec byte[count]
jnz unpack
;now we have the decimal value. Convert we have hex val 
mov byte[count],4
mov rsi,asciicode
again:
rol ax,4
mov bl,al
and bl,0Fh
cmp bl,9
jbe nocorrection2
add bl,7
nocorrection2:
add bl,30h
mov byte[rsi],bl
inc rsi
dec byte[count]
jnz again
print asciicode,4
print blank,blen

jmp _start

exit:   ;exit system call
mov rax,60
mov rdx,0h
syscall

hextoascii:
mov ax,0h
mov dx,0h
mov rsi,hexcode
back2:
rol dx,4
mov al,byte[rsi]
sub al,30h
cmp al,9
jbe nocorrection
sub al,7h
nocorrection:
add dx,ax
add rsi,1
dec byte[count]
jnz back2
ret