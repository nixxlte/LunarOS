; ================================
;   KERNEL LUNAR
; ================================

BITS 16
ORG 0x8000

jmp start
nop

start:
    call clear_screen

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

    call strcmp_help ; help
    cmp ax, 1
    je cmd_help

    call strcmp_clear ; clear
    cmp ax, 1
    je cmd_clear

    call strcmp_ping ; ping
    cmp ax, 1
    je cmd_ping
    
    call strcmp_about ; about
    cmp ax, 1
    je cmd_about

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

cmd_about:
    mov si, about_msg
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

strcmp_about:
    mov si, buffer
    mov di, str_about
    jmp strcmp

strcmp:
.compare:
    mov al, [si]
    mov bl, [di]

    cmp al, bl
    jne .not_equal

    cmp al, 0
    je .equal

    inc si
    inc di
    jmp .compare

.equal:
    mov ax, 1
    ret

.not_equal:
    mov ax, 0
    ret

; ================================
; STRINGS
; ================================
str_help  db "help",0
str_clear db "clear",0
str_ping db "ping",0
str_about db "about",0

help_msg db "Commands: help, clear, ping, about", 0x0D, 0x0A, 0
ping_msg db "Pong!",0x0D,0x0A,0
about_msg db "LunarOS", 0x0D, 0x0A, "Version 0.1, kernel 0.1-2", 0x0A, "Made by NixxLTE and Lesaninhu", 0x0D, 0x0A, 0
unknown db "Unknown command", 0x0D, 0x0A, 0