bits 32

extern entry

section .magic
    align 4
    dd 0x1BADB002
    dd 0x00
    dd - (0x1BADB002 + 0x00)

section .text

mmee: db "Memory Map Entry", 0x0D, 0

grubd: db "GRUB Bootloader detected", 0x0D, 0

nlne:
    mov al, 0x0D
    call putc
    ret

global start
start:
    mov esp, stack_space
    pusha
    mov ecx, 80*25
    mov esi, 0xB8000
    .loop:
        mov [esi], word 0x1000
        add esi, 2
        dec ecx
        jnz .loop

    mov esi, msg
    call puts
    popa

    cmp eax, 0x2badb002
    jne .nogrub

        mov esi, grubd
        call puts

        mov ecx, [ebx + 44]
        mov esi, [ebx + 48]

        .rdloop:
            mov eax, [esi]

            pusha
            cmp [esi+(4+(4*1))], dword 0
            jne .noaval
            
            mov eax, [esi+(4+(4*2))]
            mov ebx, [esi+(4+(4*4))] 
            mov esi, [esi+(4+(4*0))]
            call add_memmap_entry

            .noaval:
            popa

            add esi, eax
            add esi, 4
            sub ecx, eax
            sub ecx, 4
            jnz .rdloop

        call print_memmap

    .nogrub:

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

puts:
    .loop:
        mov al, [esi]
        call putc
        inc esi
        cmp byte [esi], 0x00
        jne .loop
    ret

HEX_CHR: db "0123456789ABCDEF"

puth:
    push eax
    shr eax, 4
    jz .nopt
    call puth
    .nopt:
    pop eax
    and eax, 0xF
    mov esi, HEX_CHR
    add esi, eax
    mov al, [esi]
    call putc
    ret

;ESI = Base
;EAX = Length
;EBX = Type

add_memmap_entry:
    pusha
    mov ecx, 256
    mov edi, memory_map
    .loop:

        cmp [edi+8], dword 0
        je .exc

        add edi, 4*3
        dec ecx
        jnz .loop
    popa
    ret
    .exc:
    mov [edi], esi
    mov [edi+4], eax
    mov [edi+8], ebx
    popa 
    ret

print_memmap:
    pusha
    mov ecx, 256
    mov edi, memory_map

    .loop:

        or [edi+8], dword 0
        jz .nox

        pusha
        mov eax, [edi]
        call puth
        popa

        pusha
        mov al, ','
        call putc
        popa

        pusha
        mov eax, [edi+4]
        call puth
        popa

        pusha
        mov al, ','
        call putc
        popa

        pusha
        mov eax, [edi+8]
        call puth
        popa

        pusha
        mov al, 0x0D
        call putc
        popa

        .nox:

        add edi, 12

        dec ecx
        jnz .loop

    popa
    ret

section .data

printf_mod: db 0

cursorX: dd 0
cursorY: dd 0
color: db 0x1F

msg: db "Hello, World", 0x0D, 0x00

memory_map: times 256*3 dd 0

section .bss
resb 8192
stack_space: