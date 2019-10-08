section .bss
;参数(倒序按位存储)
addPar1:  resb  255
addPar2:  resb  255
;结果(倒序按位存储)
addRes:  resb  255

section .text
;@name bigAdd 大数加法
;@params addPar1, addPar2
;@return addRes
bigAdd:
    push   eax
    push   ebx
    push   ecx     ;cl储存addPar1当前位
    push   edx     ;dl储存addPar2当前位
    ;先将上次计算的结果清除
    mov    eax, addRes
    call   clearChar
    mov    eax, 0  ;eax储存当前位指针
    mov    bl, 0   ;bl储存进位
addLoop:
    cmp    byte[addPar1+eax], 0
    jz     firEnd
    cmp    byte[addPar2+eax], 0
    jz     secEnd
    ;将整数暂存入cl和dl
    mov    cl, byte[addPar1+eax]
    sub    ecx, 48
    mov    dl, byte[addPar2+eax]
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
firEnd:  ;实际上此时addPar1未必读完
    cmp    byte[addPar2+eax], 0
    jz     secEnd
    jmp    secNotEnd
secNotEnd:  ;若两者都未读完，继续add
    cmp    byte[addPar1+eax], 0
    jnz    addLoop
secLoop:  ;此时一定是addPar1完addPar2未完
    mov    cl, byte[addPar2+eax]
    sub    cl, 48
    jmp    addInc
secEnd:  ;此时addPar2一定读完
    cmp    byte[addPar1+eax], 0
    jz     bothEnd
    jmp    firNotEnd
firNotEnd:  ;此时一定是addPar2完addPar1未完
    mov    cl, byte[addPar1+eax]
    sub    cl, 48
    jmp    addInc
bothEnd:
    cmp    bl, 1  ;若仍有进位要加上
    je     incBit
    jmp    addEnd
incBit:  ;在末位添加'1'
    mov    eax, addRes
    call   slen
    add    bl, 48
    mov    byte[addRes+eax], bl
addEnd:
    pop    edx
    pop    ecx
    pop    ebx
    pop    eax
    ret
