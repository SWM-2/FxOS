[global add_memmap_entry]
[global print_memmap]
[global memory_map]
[extern putc]
[extern puth]
[extern puts]

section .text
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
memory_map: times 256*3 dd 0