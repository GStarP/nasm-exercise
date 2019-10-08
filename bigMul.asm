section .bss
;参数(倒序按位存储)
mulPar1:  resb  255
mulPar2:  resb  255
;结果(倒序按位存储)
mulRes:  resb  255
;乘10辅助函数的参数&结果
mulTenTmp:  resb  255

section .text
;@name bigMul 大数乘法
;@params addPar1, addPar2
;@return addRes
bigMul:
    push   eax  ;指针
    push   ebx
    push   ecx  ;暂存当前位
    mov    byte[mulRes], 48  ;初始化结果为'0'
    mov    eax, mulPar2
    call   slen
    mov    ebx, mulPar2
    add    eax, ebx  ;eax现指向mulPar2末位后一位
mulPar2Loop:
    sub    eax, 1
    cmp    byte[eax], 0
    jz     finishMul
    mov    cl, byte[eax]
    push   eax  ;这里一定要记得保存eax！因为上面还要用！
mulPar2BitLoop:
    cmp    cl, 48
    je     nextBit
    ;将mulPar1加到mulRes上直至mulPar2此位减到'0'
    mov    eax, mulPar1
    mov    ebx, addPar1
    call   copyStr
    mov    eax, mulRes
    mov    ebx, addPar2
    call   copyStr
    call   bigAdd
    ;
    ;mov    eax, addRes
    ;call   sprintR
    mov    eax, addRes
    mov    ebx, mulRes
    call   copyStr
    sub    cl, 1
    jmp    mulPar2BitLoop
nextBit:
    ;将目前的res乘10
    mov    eax, mulRes
    mov    ebx, mulTenTmp
    call   copyStr
    call   mulTen
    mov    eax, mulTenTmp
    mov    ebx, mulRes
    call   copyStr
    pop    eax  ;取出上面保存过的eax
    jmp    mulPar2Loop
finishMul:
    ;多乘了一个10，要删去首位
    mov    eax, mulRes
    call   leftShiftOne
    pop    ecx
    pop    ebx
    pop    eax
    ret

;@name mulTen 倒序按位存储整数字符串乘10
;@params mulTenTmp(首地址)
;@return mulTenTmp
mulTen:
    push   eax
    push   ebx
    mov    eax, mulTenTmp
    mov    ebx, eax
    call   slen
    add    eax, ebx
mulTenLoop:
    cmp    byte[eax-1], 0
    jz     finishMulTen
    mov    bl, byte[eax-1]
    mov    byte[eax], bl
    sub    eax, 1
    jmp    mulTenLoop
finishMulTen:
    mov    byte[eax], 48  ;个位填上'0'
    pop    ebx
    pop    eax
    ret
