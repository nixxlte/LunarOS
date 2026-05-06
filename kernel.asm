; ================================
;   KERNEL LUNAR
; ================================

BITS 16
ORG 0x8000

jmp start
nop

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov [BOOT_DRIVE], dl

    call clear_screen
    
    ; mov si, boottext
    ; call print_string
    ; boottext db "LunarOS by NixxLTE and Lesano", 0x0D, 0x0A, "Build: 20260505", 0x0D, 0x0A, 0
    
    call load_fs

main_loop:
    call print_prompt
    call read_input
    call handle_command
    jmp main_loop

; ================================
; PRINT PROMPT
; ================================
print_prompt:
    mov si, prompt
    call print_string
    ret

prompt db "LUNAR@kernel$ ",0

; ================================
; PRINT STRING (SI = string)
; ================================
print_string:
.next:
    lodsb                ; pega próximo char de SI -> AL
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10             ; BIOS print
    jmp .next
.done:
    ret

; ================================
; CLEAR SCREEN
; ================================
clear_screen:
    mov ax, 0x0003
    int 0x10
    ret

; ================================
; READ INPUT (teclado)
; salva em buffer
; ================================
read_input:
    mov ax, 0
    mov es, ax

    mov di, buffer
    mov cx, 64
    mov al, 0
    rep stosb

    mov di, buffer

.read:
    mov ah, 0x00
    int 0x16          ; espera tecla

    cmp al, 13        ; Enter?
    je .done

    cmp al, 8         ; Backspace?
    je .backspace

    ; salva char no buffer
    stosb

    ; ecoa na tela
    mov ah, 0x0E
    int 0x10

    jmp .read

.backspace:
    cmp di, buffer
    je .read

    dec di

    ; apagar visualmente
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10

    jmp .read

.done:
    mov al, 0
    stosb

    ; nova linha
    mov si, newline
    call print_string

    ret

buffer times 64 db 0
newline db 0x0D,0x0A,0

; ================================
; HANDLE COMMAND
; ================================
handle_command:
    mov si, buffer
    ; call print_string

    call strcmp_help ; help
    cmp ax, 1
    je cmd_help

    call strcmp_clear ; clear
    cmp ax, 1
    je cmd_clear

    call strcmp_ping ; ping
    cmp ax, 1
    je cmd_ping
    
    call strcmp_pong ; pong (joke)
    cmp ax, 1
    je cmd_pong
    
    call strcmp_about ; about
    cmp ax, 1
    je cmd_about

    call strcmp_echo ; echo
    cmp ax, 1
    je cmd_echo

    ; comando desconhecido
    mov si, unknown
    call print_string
    ret

; ================================
; COMANDOS
; ================================
cmd_help:
    mov si, help_msg
    call print_string
    ret

cmd_clear:
    call clear_screen
    ret

cmd_ping:
    mov si, ping_msg
    call print_string
    ret

cmd_pong:
    mov si, pong_msg
    call print_string
    ret

cmd_about:
    mov si, ascii
    call print_string
    mov si, about_msg
    call print_string
    ret

cmd_echo:
    mov si, buffer

.skip:
    lodsb
    cmp al, ' '
    je .print
    cmp al, 0
    je .done
    jmp .skip

.print:
    call print_string
.done:
    mov si, newline
    call print_string
    ret

; ================================
; STRCMP (buffer vs string)
; retorna AX = 1 se igual
; ================================
strcmp_help:
    mov si, buffer
    mov di, str_help
    jmp strcmp

strcmp_clear:
    mov si, buffer
    mov di, str_clear
    jmp strcmp

strcmp_ping:
    mov si, buffer
    mov di, str_ping
    jmp strcmp

strcmp_pong:
    mov si, buffer
    mov di, str_pong
    jmp strcmp

strcmp_about:
    mov si, buffer
    mov di, str_about
    jmp strcmp

strcmp_echo:
    mov si, buffer
    mov di, str_echo
    jmp strcmp

strcmp:
.compare:
    mov al, [si]
    mov bl, [di]

    ; se chegou no fim do comando (di)
    cmp bl, 0
    je .check_end

    cmp al, bl
    jne .not_equal

    inc si
    inc di
    jmp .compare

.check_end:
    ; aceita:
    ; "echo"
    ; "echo "
    cmp al, ' '
    je .equal
    cmp al, 0
    je .equal
    jmp .not_equal

.equal:
    mov ax, 1
    ret

.not_equal:
    mov ax, 0
    ret

; ================================
; LOAD FILESYSTEM
; ================================
load_fs:
    mov ax, 0x0000
    mov es, ax
    mov bx, 0x7000

    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 3
    mov dh, 0
    mov dl, [BOOT_DRIVE]
    int 0x13

    ret

; ================================
; STRINGS
; ================================

str_echo db "echo",0
str_help  db "help",0
str_ping db "ping",0
str_pong db "pong",0
str_about db "about",0
str_clear db "clear",0

help_msg db "Commands: help, clear, ping, about, echo", 0x0D, 0x0A,0

ping_msg db "Pong!",0x0D,0x0A,0

pong_msg db "Ping!",0x0D,0x0A,0

about_msg db "LunarOS", 0x0D, 0x0A, "Version 0.1, ", "kernel 0.1-3", 0x0A, "Made by NixxLTE and Lesaninhu", 0x0D, 0x0A,0

unknown db "Unknown command", 0x0D, 0x0A,0

ascii db "/\---/\", 0x0D, 0x0A, "( * * )", 0x0D, 0x0A,0

BOOT_DRIVE db 0