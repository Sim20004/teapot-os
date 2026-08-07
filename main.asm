
section .data
txt db "Hello"

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

global _start
section .text

_start:
    cli                     ; disable interrupts

    mov ax, 0             
    mov ds, ax

    mov ax, 0x8888
    mov ss, ax              ; initialise stack segment at 0x8888
    mov sp, 0x8888          ; initialise stack pointer at 0x8888
    
    lgdt [gdt_descriptor]

    hlt