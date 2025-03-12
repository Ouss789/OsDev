[BITS 32]

global _start
;global problem

extern kernel_main

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov ebp, 0x00200000
    mov esp, ebp

    ; Enable A20 liness
    in al, 0x92
    or al, 2
    out 0x92, al


    ;remap the master PIC

    mov al, 00010001b ; put the pic in intialization mode
    out 0x20, al ; send the command to the master pic

    mov al, 0x20 ; interrupt 0x20 is where isr should start
    out 0x21, al

    mov al, 00000001b
    out 0x21, al

    ;End of the master PIC


    call kernel_main

    jmp $


;problem:
   ; mov eax, 0
    ; div eax

    ;int 0




times 512- ($ - $$) db 0
