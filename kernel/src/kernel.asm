org 0x8000
bits 32

jmp kernel_start

print:
    mov esi, eax
    mov ecx, ebx

    .loop:
        call print_char
        loop .loop
        ret

print_char: 
    mov al, [esi]
    cmp al, 10
    je .newline

    mov edi, 0xB8000

    mov edx, [cursor_y]
    imul edx, 160
    add edi, edx

    mov edx, [cursor_x]
    shl edx, 1
    add edi, edx

    mov ah, 0x07
    mov [edi], ax
    inc dword [cursor_x]

    cmp dword [cursor_x], 80
    je .newline_wrap

    inc esi
    ret

.newline:
    inc esi
    mov dword [cursor_x], 0
    inc dword [cursor_y]

    cmp dword [cursor_y], 25
    je .screen_full

    ret
.newline_wrap:
    inc esi
    mov dword [cursor_x], 0
    inc dword [cursor_y]

    cmp dword [cursor_y], 25
    je .screen_full


    ret
.screen_full:
    push esi
    push ecx

    mov esi, 0xB80A0
    mov edi, 0xB8000
    mov ecx, 1920

.copy:
    mov ax, [esi]
    mov [edi], ax
    add esi, 2
    add edi, 2
    loop .copy

    mov edi, 0xB8F00
    mov ecx, 80

.clear:
    mov word [edi], 0x0720
    add edi, 2
    loop .clear

    mov dword [cursor_y], 24
    mov dword [cursor_x], 0

    pop ecx
    pop esi
    ret
    
    
clear_screen:
    mov edi, 0xB8000    
    mov ecx, 2000
    
    .loop:
        mov al, ' '
        mov ah, 0x07
        mov [edi], ax
        add edi, 2
        loop .loop
    ret

kernel_start:
    call clear_screen
    mov eax, kernel_start_msg
    mov ebx, kernel_start_msg_len
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print
    call print
    call print 
    call print
    call print 
    call print
    call print 
    call print
    call print  

hang:
    jmp hang

kernel_start_msg db "Kernel started successfully!", 10, "Welcome to TeapotOS!"
kernel_start_msg_len equ $ - kernel_start_msg
cursor_x dd 0
cursor_y dd 0