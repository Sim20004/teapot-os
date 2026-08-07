global _start
section .text

_start:
    cli         ; disables interrupts

    mov ax, 0
    mov ds, ax

    mov ax, 0x8888
    mov ss, ax
    mov sp, 0x8888

    hlt