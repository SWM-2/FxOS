bits 32

extern entry

section .magic
    align 4
    dd 0x1BADB002
    dd 0x00
    dd - (0x1BADB002 + 0x00)

section .text

%ifdef PAGED
    PAGE_OFF equ 0xFFC00000
%else
    PAGE_OFF equ 0
%endif 

PAGE_TAB equ 0
PAGE_DIR equ 1023

global start

start:
  
    mov esp, stack_space
    cmp eax, 0x2badb002
    jne 
    jmp $
    hlt

saveeax: dd 0
saveebx: dd 0

global cpuid_vstr
cpuid_vstr:
    mov edi, [esp + 4]
    pusha
    mov eax, 0x0
    cpuid
    mov [edi], ebx
    mov [edi+4], edx
    mov [edi+8], ecx
    popa
    ret

color: db 0x0E

;AL = Character
putc:
    mov edi, 0xB8000
    or 
    inc word [cursorX]

section .data
cursorX: dw 0
cursorY: dw 0

section .bss
resb 8192
stack_space: