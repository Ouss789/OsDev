ORG 0
BITS 16
_start:
    jmp short start
    nop


times 33 db 0


start:
    jmp 0x7c0:step2


handle_zero:
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret

handle_one:
    mov ah, 0eh
    mov al, 'W'
    mov bx, 0x00
    int 0x10
    iret


step2:
    cli   ; clear interrrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti   ; enable interrupts

    mov word[ss:0x00], handle_zero ; we do ss here to specify we wanna use the stack segment, otherwise it will use the data segment pointing to 0x7c00
    mov word[ss:0x02], 0x7c0

    mov word[ss:0x04], handle_one
    mov word[ss:0x06], 0x7c0

   ; mov ax, 0x00
   ; div ax ; caused an exception we devided by 0
   int 1

    mov si, message  ; move the address of the label message to si register
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

message: db 'hello world!' , 0

times 510- ($ - $$) db 0
dw 0xAA55