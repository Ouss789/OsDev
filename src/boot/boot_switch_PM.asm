ORG 0x7c00
BITS 16


CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop


times 33 db 0


start:
    jmp 0:step2


step2:
    cli   ; clear interrrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti   ; enable interrupts

.load_protected:
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    jmp CODE_SEG:load32




;GDT
gdt_start:
gdt_null:
    dd 0x0  ; dd means define double word 00000000
    dd 0x0
    ;offset 0x8

gdt_code:
        ; cs should point to this gdt_code
    dw 0xffff ; segment limit 0-15 bits
    dw 0       ; base first 0-15 bits
    db 0        ; base 16-23 bits
    db 0x9a     ; access byte
    db 11001111b ; high 4 bit flags and the low 4 bit flags
    db 0        ; base 24-31 bits

    ; offset 0x10

gdt_data:
        ; should be linked to DS, SS, ES, FS, GS
    dw 0xffff ; segment limit 0-15 bits
    dw 0       ; base first 0-15 bits
    db 0        ; base 16-23 bits
    db 0x92     ; access byte
    db 11001111b ; high 4 bit flags and the low 4 bit flags
    db 0        ; base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; give us the size of the descriptor
    dd gdt_start ; give us the address (offset) of the descriptor

[BITS 32]
load32:
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
    jmp $

times 510- ($ - $$) db 0
dw 0xAA55


