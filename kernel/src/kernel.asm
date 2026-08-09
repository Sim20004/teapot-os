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
    mov eax, prompt
    mov ebx, prompt_len
    call print

keyboard_loop:
    in al, 0x64
    test al, 1
    jz keyboard_loop

    in al, 0x60

    ; -------------------------
    ; Enter
    ; -------------------------
    cmp al, 0x1C
    je .enter_pressed
    ; -------------------------
    ; Left Shift
    ; -------------------------

    cmp al, 0x2A
    je shift_down

    cmp al, 0xAA
    je shift_up

    ; -------------------------
    ; Right Shift
    ; -------------------------

    cmp al, 0x36
    je shift_down

    cmp al, 0xB6
    je shift_up

    ; -------------------------
    ; Ignore other key releases
    ; -------------------------

    test al, 0x80
    jnz keyboard_loop

    ; -------------------------
    ; Convert scancode
    ; -------------------------

    movzx eax, al

    cmp byte [shifted], 1
    je .shifted

    mov al, [scancode_to_ascii + eax]
    jmp .got_character

.shifted:
    mov al, [scancode_to_ascii_shifted + eax]

.got_character:
    ; Ignore keys that don't produce characters
    cmp al, 0
    je keyboard_loop

    mov [key_buffer], al

    mov eax, key_buffer
    mov ebx, 1
    call print

    jmp keyboard_loop
.enter_pressed:
    mov eax, prompt
    mov ebx, prompt_len
    call print 
    jmp keyboard_loop

scancode_to_ascii:

; 0x00 - 0x0F
db 0
db 0
db '1'
db '2'
db '3'
db '4'
db '5'
db '6'
db '7'
db '8'
db '9'
db '0'
db '-'
db '='
db 0
db 0

; 0x10 - 0x1F
db 'q'
db 'w'
db 'e'
db 'r'
db 't'
db 'y'
db 'u'
db 'i'
db 'o'
db 'p'
db '['
db ']'
db 0
db 0
db 'a'
db 's'

; 0x20 - 0x2F
db 'd'
db 'f'
db 'g'
db 'h'
db 'j'
db 'k'
db 'l'
db ';'
db "'"
db '`'
db 0
db '\'
db 'z'
db 'x'
db 'c'
db 'v'

; 0x30 - 0x3F
db 'b'
db 'n'
db 'm'
db ','
db '.'
db '/'
db 0
db '*'
db 0
db ' '
db 0
db 0
db 0
db 0
db 0
db 0

; 0x40 - 0x4F
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

; 0x50 - 0x5F
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

; 0x60 - 0x6F
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

; 0x70 - 0x7F
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

; 0x80 - 0x8F
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

; 0x90 - 0x9F
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

; 0xA0 - 0xAF
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

; 0xB0 - 0xBF
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

; 0xC0 - 0xCF
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

; 0xD0 - 0xDF
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

; 0xE0 - 0xEF
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

; 0xF0 - 0xFF
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0
db 0

scancode_to_ascii_shifted:

; 0x00 - 0x0F
db 0
db 0
db '!'
db '@'
db '#'
db '$'
db '%'
db '^'
db '&'
db '*'
db '('
db ')'
db '_'
db '+'
db 0
db 0

; 0x10 - 0x1F
db 'Q'
db 'W'
db 'E'
db 'R'
db 'T'
db 'Y'
db 'U'
db 'I'
db 'O'
db 'P'
db '{'
db '}'
db 0
db 0
db 'A'
db 'S'

; 0x20 - 0x2F
db 'D'
db 'F'
db 'G'
db 'H'
db 'J'
db 'K'
db 'L'
db ':'
db '"'
db '~'
db 0
db '|'
db 'Z'
db 'X'
db 'C'
db 'V'

; 0x30 - 0x3F
db 'B'
db 'N'
db 'M'
db '<'
db '>'
db '?'
db 0
db '*'
db 0
db ' '
db 0
db 0
db 0
db 0
db 0
db 0

; 0x40 - 0x4F
times 16 db 0

; 0x50 - 0x5F
times 16 db 0

; 0x60 - 0x6F
times 16 db 0

; 0x70 - 0x7F
times 16 db 0

; 0x80 - 0x8F
times 16 db 0

; 0x90 - 0x9F
times 16 db 0

; 0xA0 - 0xAF
times 16 db 0

; 0xB0 - 0xBF
times 16 db 0

; 0xC0 - 0xCF
times 16 db 0

; 0xD0 - 0xDF
times 16 db 0

; 0xE0 - 0xEF
times 16 db 0

; 0xF0 - 0xFF
times 16 db 0

shifted db 0
shift_down:
    mov byte [shifted], 1
    jmp keyboard_loop

shift_up:
    mov byte [shifted], 0
    jmp keyboard_loop
kernel_start_msg db "Kernel started successfully!", 10, "Welcome to TeapotOS!", 10
kernel_start_msg_len equ $ - kernel_start_msg
prompt db 10, "TeapotOS> "
prompt_len equ $ - prompt
key_buffer db 0
cursor_x dd 0
cursor_y dd 0