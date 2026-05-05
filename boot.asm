BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti

    mov [BOOT_DRIVE], dl

    mov si, msg
    call print

    ; reset disk
    mov ah, 0x00
    mov dl, [BOOT_DRIVE]
    int 0x13

    ; load stage2
    mov ah, 0x02
    mov al, 1 ; 1 sector
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [BOOT_DRIVE]

    mov bx, 0x8000
    int 0x13

    jc disk_error

    push 0x0000
    push 0x8000
    retf

disk_error:
    mov si, err
    call print
    jmp $

print:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print
.done:
    ret

msg db "Loading Lunar...", 0x0D, 0x0A, 0 ; 0x0D: \r, 0x0A: \n
err db "Disk error!", 0

BOOT_DRIVE db 0

times 510-($-$$) db 0
dw 0xAA55