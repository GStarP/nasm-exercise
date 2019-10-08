%include '/home/hxw/czxt/program/functions.asm'
%include '/home/hxw/czxt/program/bigAdd.asm'
%include '/home/hxw/czxt/program/bigMul.asm'

section .data
msg:  db  'Please input x and y :'

section .bss
inp:   resb  255
;倒序按位存储两个整数
num1:  resb  255
num2:  resb  255

section .text
    global main
main:
    mov    eax, msg
    call   sprintLF
    mov    eax, 3
    mov    ebx, 0
    mov    ecx, inp
    mov    edx, 255
    int    80h
    mov    edx, inp  ;edx储存遍历inp的指针
    mov    ecx, edx
toEnd: ;将指针移动到inp末尾
    cmp    byte[edx], 0
    jz     finishToEnd
    inc    edx
    jmp    toEnd
finishToEnd:
    sub    edx, 1     ;edx-1指向inp最后一位
    mov    ecx, num1  ;ecx储存num的指针
firNum:  ;将空格后的整数写入
    cmp    byte[edx], 20h
    je     finishFirNum
    mov    al, byte[edx]
    mov    byte[ecx], al
    inc    ecx
    sub    edx, 1
    jmp    firNum
finishFirNum:
    sub    edx, 1
    mov    ecx, num2
secNum:  ;将空格前的整数写入
    cmp    byte[edx], 0
    jz     finishSecNum
    mov    al, byte[edx]
    mov    byte[ecx], al
    inc    ecx
    sub    edx, 1
    jmp    secNum
finishSecNum:
    ;进行加法并输出结果
    mov    eax, num1
    mov    ebx, addPar1
    call   copyStr
    mov    eax, num2
    mov    ebx, addPar2
    call   copyStr
    call   bigAdd
    mov    eax, addRes
    call   sprintR
    ;进行乘法并输出结果
    mov    eax, num1
    mov    ebx, mulPar1
    call   copyStr
    mov    eax, num2
    mov    ebx, mulPar2
    call   copyStr
    call   bigMul
    mov    eax, mulRes
    call   sprintR

    call   exit
