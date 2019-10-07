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
    pop    ebx
    ret
    