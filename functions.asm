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