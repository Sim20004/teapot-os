org 0x7C00
bits 16

_start:
    cli                         ; disable interrupts

    mov ah, 0x0e                ; show R in vga text mode
    mov al, 'R'
    int 0x10

    mov ax, 0
    mov ds, ax

    mov ax, 0x0000              ; initialise stack segment at 0x0000
    mov ss, ax
    mov sp, 0x7C00              ; initialise stack pointer at 0x7C00

    lgdt [gdt_descriptor]       ; load gdt

    mov ah, 0x0e                ; show r in vga text mode
    mov al, 'R'
    int 0x10

    mov eax, cr0                ; enable protected mode
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode_start


gdt:                            ; define gdt

gdt_null:
    times 8 db 0                ; first entry must be null

gdt_code:                       ; entry 1: code
    dw 0xFFFF                   ; limit 0-15
    dw 0x0000                   ; base 0-15
    db 0x00                     ; base 16-23
    db 0x9A                     ; access byte
    db 0xCF                     ; flags + limit 16-19
    db 0x00                     ; base 24-31

gdt_data:                       ; entry 2: data
    dw 0xFFFF                   ; limit 0-15
    dw 0x0000                   ; base 0-15
    db 0x00                     ; base 16-23
    db 0x92                     ; access byte
    db 0xCF                     ; flags + limit 16-19
    db 0x00                     ; base 24-31

gdt_end:                        ; end of gdt

gdt_descriptor:                 ; gdt descriptor
    dw gdt_end - gdt - 1        ; gdt size
    dd gdt                      ; gdt start


bits 32                         ; 32-bit mode

protected_mode_start:

    mov ax, 0x10                ; reinitialises stack in protected mode
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov esp, 0x90000

                                ; now we have fully initialised protected mode

    mov edi, 0xB8000            ; show H in vga text mode
    mov al, 'H'
    mov ah, 0x07

    mov word [edi], ax

    cli                         ; disable interrupts

hang:
    hlt
    jmp hang


times 510 - ($ - $$) db 0       ; boot sector padding
dw 0xAA55