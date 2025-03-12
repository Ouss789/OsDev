ORG 0
BITS 16
_start:
    jmp short start
    nop


times 33 db 0


start:
    jmp 0x7c0:step2


step2:
    cli   ; clear interrrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti   ; enable interrupts

    mov ah, 2  ; read sector command
    mov al, 1  ; one sector to read
    mov ch, 0  ; cylinder low eight bits
    mov cl, 2  ; read sector 2
    mov dh, 0  ; head number
    mov bx, buffer
    int 0x13
    jc error



    mov si,  
    call print

    jmp $

error:

    mov si, error_message
    call print
    jmp $



print:

    mov bx, 0

.loop:  ;sub label
    lodsb   ; load the char that si register pointing to , and load it in the "al" register then increment
    cmp al, 0 ; compare al with 0
    je .done ; if it's equal to 0 then jump to done
    call print_char ; if it's not equal to 0 then call print_char
    jmp .loop

.done:
    ret  ; return from the sub routine

print_char:
    mov ah, 0eh ; this is the function to output to the screen when talking with bios
    int 0x10  ; call interrupt 0x10 which will invoke the BIOS
    ret

error_message : db'failed to load sector'


times 510- ($ - $$) db 0
dw 0xAA55


buffer: