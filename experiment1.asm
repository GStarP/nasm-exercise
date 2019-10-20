section .data
msg:  db  'Please input x and y :'

section .bss
inp:   resb  255
;倒序按位存储两个整数
num1:  resb  255
num2:  resb  255
;加法参数(倒序按位存储)
addPar1:  resb  255
addPar2:  resb  255
;加法结果(倒序按位存储)
addRes:  resb  255
;乘法参数(倒序按位存储)
mulPar1:  resb  255
mulPar2:  resb  255
;乘法结果(倒序按位存储)
mulRes:  resb  255
;乘10辅助函数的参数&结果
mulTenTmp:  resb  255

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

;常用的functions.asm

;@name exit 退出程序
exit:
    mov    ebx, 0
    mov    eax, 1
    int    80h
    ret

;@name slen 计算字符串长度
;@params eax(字符串起始地址)
;@return eax(字符串长度)
slen:
    push   ebx
    mov    ebx, eax
nextchar:
    cmp    byte[eax], 0    ;以这个字符作为字符串的结尾
    jz     finish
    inc    eax
    jmp    nextchar
finish:
    sub    eax, ebx
    pop    ebx
    ret

;@name sprint 打印字符串
;@params eax(字符串起始地址)
sprint:
    push   edx
    push   ecx
    push   ebx
    push   eax
    call   slen
    mov    edx, eax    ;edx存储字符串长度
    pop    eax
    mov    ecx, eax
    mov    ebx, 1
    mov    eax, 4
    int    80h
    pop    ebx
    pop    ecx
    pop    edx
    ret

;@name sprintLF 打印字符串，末尾有换行符
;@params eax(字符串起始地址)
sprintLF:
    call   sprint
    push   eax
    mov    eax, 0Ah
    push   eax
    mov    eax, esp    ;esp是栈指针，此时就相当于0Ah的起始地址
    call   sprint
    pop    eax
    pop    eax
    ret

;@name iprint 按位打印整数
;@params eax(计算后的整数)
iprint:
    push   eax
    push   ecx
    push   edx
    push   esi
    mov    ecx, 0
divideLoop:
    inc    ecx       ;存有位数
    mov    edx, 0
    mov    esi, 10
    idiv   esi       ;eax=eax/10
    add    edx, 48   ;edx存有余数
    push   edx       ;edx存入栈
    cmp    eax, 0
    jnz    divideLoop
printLoop:
    dec    ecx
    mov    eax, esp
    call   sprint
    pop    eax
    cmp    ecx, 0
    jnz    printLoop
    pop    esi
    pop    edx
    pop    ecx
    pop    eax
    ret

;@name iprintLF 按位打印整数，末尾有换行符
;@params eax(计算后的整数)
iprintLF:
    call   iprint
    push   eax
    mov    eax, 0Ah
    push   eax
    mov    eax, esp
    call   sprint
    pop    eax
    pop    eax
    ret

;@name atoi 将数字字符串转换为整数
;@params eax(字符串首地址)
;@return eax(计算所得整数)
atoi:
    push   ebx
    push   ecx
    push   edx
    push   esi
    mov    esi, eax
    mov    eax, 0
    mov    ecx, 0
mulLoop:
    xor    ebx, ebx
    mov    bl, [esi+ecx]
    cmp    bl, 48
    jl     finished
    cmp    bl, 57
    jg     finished
    sub    bl, 48
    add    eax, ebx
    mov    ebx, 10
    mul    ebx
    inc    ecx
    jmp    mulLoop
finished:
    mov    ebx, 10
    div    ebx
    pop    esi
    pop    edx
    pop    ecx
    pop    ebx
    ret

;@name sprintR 倒序输出
;@params eax(字符串首地址)
sprintR:
    push   ebx
    push   ecx
    push   edx
    mov    ecx, eax  ;ecx保存字符串首地址
    call   slen      ;eax现在存有字符串长度
    add    eax, ecx
sprintRLoop:
    sub    eax, 1
    cmp    byte[eax], 0
    jz     finishSprintR
    mov    ecx, eax
    mov    edx, 1
    mov    eax, 4
    mov    ebx, 1
    int    80h
    mov    eax, ecx
    jmp    sprintRLoop
finishSprintR:
    ;换行
    push   eax
    mov    eax, 0Ah
    push   eax
    mov    eax, esp    ;esp是栈指针，此时就相当于0Ah的起始地址
    call   sprint
    pop    eax
    pop    eax
    pop    edx
    pop    ecx
    pop    ebx
    ret

;@name clearChar 清除残留字符
;@params eax(起始地址)
clearChar:
    push   ebx
    mov    ebx, 0
clearCharLoop:
    cmp    byte[eax+ebx], 0
    jz     finishClearChar
    mov    byte[eax+ebx], 0
    inc    ebx
    jmp    clearCharLoop
finishClearChar:
    pop    ebx
    ret

;@name copyStr 拷贝字符串
;@params eax(源字符串首地址) ebx(目标地址)
copyStr:
    push   ecx
    push   edx     ;dl临时储存字符
    mov    ecx, 0  ;ecx储存偏移量
copyLoop:
    cmp    byte[eax+ecx], 0
    jz     clearAim
    mov    dl, byte[eax+ecx]
    mov    byte[ebx+ecx], dl
    inc    ecx
    jmp    copyLoop
clearAim:
    cmp    byte[ebx+ecx], 0
    jz     finishCopy
    mov    byte[ebx+ecx], 0
    inc    ecx
    jmp    clearAim
finishCopy:
    pop    edx
    pop    ecx
    ret

;@name leftShiftOne 左移一位
;@param eax(首地址)
leftShiftOne:
    push   ebx  ;偏移量
    push   ecx
    mov    ebx, 0
leftShiftOneLoop:
    cmp    byte[eax+ebx+1], 0
    jz     finishLeftShiftOne
    mov    cl, byte[eax+ebx+1]
    mov    byte[eax+ebx], cl
    inc    ebx
    jmp    leftShiftOneLoop
finishLeftShiftOne:
    mov    byte[eax+ebx], 0
    pop    ecx
    pop    ebx
    ret
	
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