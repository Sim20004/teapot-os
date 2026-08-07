org 0x7C00
bits 16 

_start:
    cli

    mov ah, 0x0e
    mov al, 'R'
    int 0x10                 ; disable interrupts

    mov ax, 0
    mov ds, ax              ; initialise stack segment at 0x8888
    
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0x7C00         ; initialise stack pointer at 0x8888
    
    lgdt [gdt_descriptor]

    mov ah, 0x0e
    mov al, 'R'
    int 0x10      

    mov eax, cr0
    or eax, 1
    mov cr0, eax 

    jmp 0x08:protected_mode_start

gdt:
gdt_null:
    times 8 db 0
gdt_code:
    dw 0xFFFF  
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00 
gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00
gdt_end:
gdt_descriptor:
    dw gdt_end - gdt - 1
    dd gdt


bits 32

protected_mode_start:

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov esp, 0x90000 

    ; now we have fully initialised protected mode

    mov edi, 0xB8000
    mov al, 'H'
    mov ah, 0x07

    mov [edi], ax

    cli
    hang:
        hlt
        jmp hang

times 510-($-$$) db 0
dw 0xAA55