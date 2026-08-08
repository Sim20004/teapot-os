org 0x8000
bits 32

jmp kernel_start

times 16 db 0xCC

kernel_start:
    mov esi, message
    mov edi, 0xB8000
    add edi, 160
    mov ecx, message_len

.loop:
    mov al, [esi]
    mov ah, 0x07
    mov [edi], ax
    inc esi
    add edi, 2
    loop .loop

hang:
    jmp hang

message db "Kernel booted successfully!"
message_len equ $ - message