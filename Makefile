ASM := nasm
QEMU := qemu-system-i386

BUILD := build
SRC := src
BOOT_PATH := $(SRC)/boot

OS_IMG := $(BUILD)/os.img

QEMUFLAGS := -no-reboot -drive format=raw,file=
ASMFLAGS := -f bin

.PHONY: all bootloader run debug clean

all:
	$(ASM) $(ASMFLAGS) $(SRC)/main.asm -o $(BUILD)/main.bin
	$(QEMU) $(QEMUFLAGS)$(build)/main.bin

bootloader:
	$(ASM) $(ASMFLAGS) $(BOOT_PATH)/stage1.asm -o $(BUILD)/stage1.bin
	$(ASM) $(ASMFLAGS) $(BOOT_PATH)/stage2.asm -o $(BUILD)/stage2.bin
	cat $(BUILD)/stage1.bin $(BUILD)/stage2.bin > $(OS_IMG)
	$(QEMU) $(QEMUFLAGS)$(OS_IMG)

run:
	$(QEMU) $(QEMUFLAGS)/main.bin

debug:
	$(QEMU) $(QEMUFLAGS)/main.bin -s -S -d int -D qemu.log

clean:
	rm -rf $(BUILD)/*

