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
    cli
    mov [saveeax - PAGE_OFF], eax
    mov [saveebx - PAGE_OFF], ebx
    %ifdef PAGED
        mov al, 'P'
    %else
        mov al, 'U'
    %endif
    mov esi, 0xB8000
    mov [esi], al

    %ifdef PAGED
    mov eax, 0
    mov ebx, 0
    .fpt:
        mov ecx, ebx
        or ecx, 3
        mov [kernel_page_table-PAGE_OFF+eax*4], ecx
        add ebx, 4096
        inc eax
        cmp eax, 1024
        jne .fpt
    
    mov ebx, kernel_page_table-PAGE_OFF
    or ebx, 3
    mov [global_page_directory-PAGE_OFF], ebx
    mov [global_page_directory-PAGE_OFF+PAGE_DIR*4], ebx

    mov eax, global_page_directory-PAGE_OFF
    mov cr3, eax
    mov eax, cr0
    or eax, 0x80000001
    mov cr0, eax
    mov eax, paged
    jmp paged

paged:
    %endif

    mov esp, stack_space

    mov eax, [saveeax]
    mov ebx, [saveebx]

    push ebx
    push eax
    mov eax, entry
    call eax

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

global update_paging
update_paging:
    mov eax, global_page_directory-PAGE_OFF
    mov cr3, eax
    ret

section .data
%ifdef PAGED
align 0x1000
global kernel_page_table
global global_page_directory

global_page_directory: times 0x1000 db 0
kernel_page_table: times 0x1000 db 0
%endif

section .bss
resb 8192
stack_space: