bits 32

extern entry

section .magic
    align 4
    dd 0x1BADB002
    dd 0x00
    dd - (0x1BADB002 + 0x00)

section .text

global start
start:
    mov esp, stack_space
    cmp eax, 0x2badb002
    mov al, '@'
    call putc 
    jmp $
    hlt

;AL = Character
putc:
    cmp al, 0x0D
    je .nl
    push eax

    mov eax, [cursorY]
    mov dx, 80
    mul dx
    add eax, [cursorX]
    lea edi, [0xB8000 + eax*2]

    pop eax

    mov [edi], al
    mov al, [color]
    mov [edi+1], al

    inc dword [cursorX]
    cmp [cursorX], dword 79
    jg .nl

    ret
    .nl:
        mov [cursorX], dword 0
        inc dword [cursorY]
        ret

section .data
cursorX: dd 0
cursorY: dd 0
color: db 0x0E

section .bss
resb 8192
stack_space: