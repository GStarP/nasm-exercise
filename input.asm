section .data
  msg:  db  "Please Input: "
  msgLen:  equ  $-msg

section .bss
  inp  resb  256

section .text
  global _start

_start:
  ; show input tip message
  mov  rax, 4
  mov  rbx, 1
  mov  rcx, msg
  mov  rdx, msgLen
  int  80h
  ; read input from keyboard
  mov  rax, 3
  mov  rbx, 0
  mov  rcx, inp
  mov  rdx, 256
  int  80h
  ; print the input
  push rax
  mov  rax, 4
  mov  rbx, 1
  mov  rcx, inp
  pop  rdx
  int 80h

exit:
  mov  rax, 1
  mov  rbx, 0
  int  80h
