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
    mov eax, 1      ; represent the starting sector we wanna load from which is 1
    mov ecx, 100    ; ecx will contain the number of sectors we want to load 100
    mov edi, 0x0100000 ; contain the address where we want to load the kernel into 
    call ata_lba_read

    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax ; backup the lba for later
    ; send the highest 8 bits to the lba to the hard disk controller
    shr eax, 24
    or eax, 0xE0 ; select the master drive
    mov dx, 0x1F6
    out dx, al
    ; finished sendin the highest 8 bits of the lba

    ;sending the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ; finished sending the total sectors to read


    ; send more bits of the lba
    mov eax, ebx ; restore the backup lba
    mov dx, 0x1F3
    out dx, al      ; with out we're talking to the bus on the mother board and then the controllers listening to us
    ; finished sending more bits of the lba

    ;send more bits of the lba
    mov dx, 0x1F4
    mov eax, ebx ; restore the backup lba
    shr eax, 8
    out dx, al
    ;finished sending more bits of the lba

    ;send upper 16 bits of the lba
    mov dx, 0x1F5
    mov eax, ebx ; restore the backup lba
    shr eax, 16
    out dx, al
    ;finished sending upper 16 bits of the lba


    mov dx, 0x1F7
    mov al, 0x20
    out dx, al


    ; read all sectors into memory
.next_sector:
    push ecx


;checking if we need to read
.try_again:

    mov dx, 0x1F7
    in al, dx
    test al, 8
    jz .try_again

; we need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector

    ;end of reading sectors into memory
    ret




times 510- ($ - $$) db 0
dw 0xAA55


