%include '/home/hxw/czxt/program/functions.asm'

section .bss
inp:   resb  255
;倒序按位存储两个整数
num1:  resb  128
num2:  resb  128
;bigAdd的结果
addRes:  resb  128

section .text
    global main
main:
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
    call   bigAdd
    mov    eax, addRes
    call   sprintR

    call   exit

;@name bigAdd 大数加法
;@params num1, num2
;@return addRes
bigAdd:
    push   eax
    push   ebx
    push   ecx     ;cl储存num1当前位
    push   edx     ;dl储存num2当前位
    mov    eax, 0  ;eax储存当前位指针
    mov    bl, 0   ;bl储存进位
addLoop:
    cmp    byte[num1+eax], 0
    jz     firEnd
    cmp    byte[num2+eax], 0
    jz     secEnd
    ;将整数暂存入cl和dl
    mov    cl, byte[num1+eax]
    sub    ecx, 48
    mov    dl, byte[num2+eax]
    sub    edx, 48
    add    cl, dl
addInc:
    add    cl, bl  ;加上进位
    cmp    cl, 10  ;判断是否有进位
    jae    hasInc
    jmp    noInc
hasInc:  ;有进位
    mov    bl, 1
    sub    cl, 10
    jmp    finishInc
noInc:
    mov    bl, 0
finishInc:  ;将当前位数字的字符存入结果串中
    add    cl, 48
    mov    byte[addRes+eax], cl
    inc    eax
firEnd:  ;实际上此时num1未必读完
    cmp    byte[num2+eax], 0
    jz     secEnd
    jmp    secNotEnd
secNotEnd:  ;若两者都未读完，继续add
    cmp    byte[num1+eax], 0
    jnz    addLoop
secLoop:  ;此时一定是num1完num2未完
    mov    cl, byte[num2+eax]
    sub    cl, 48
    jmp    addInc
secEnd:  ;此时num2一定读完
    cmp    byte[num1+eax], 0
    jz     bothEnd
    jmp    firNotEnd
firNotEnd:  ;此时一定是num2完num1未完
    mov    cl, byte[num1+eax]
    sub    cl, 48
    jmp    addInc
bothEnd:
    cmp    bl, 49  ;若仍有进位要加上
    je     incBit
    jmp    addEnd
incBit:  ;在末位添加'1'
    mov    eax, addRes
    call   slen
    mov    byte[addRes+eax], bl
addEnd:
    pop    edx
    pop    ecx
    pop    ebx
    pop    eax
    ret