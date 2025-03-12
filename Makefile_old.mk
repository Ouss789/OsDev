all:
	nasm -f bin ./boot_switch_PM.asm -o ./boot_switch_PM.bin
	dd if=./message.txt >> ./boot_switch.bin
	dd if=/dev/zero bs=512 count=1 >> ./boot_switch_PM.bin