ASM := nasm
ASMFLAGS := -f bin
QEMU := qemu-system-i386

BUILD := build
SRC := src

OS_IMG := $(BUILD)/os.img

QEMUFLAGS := -no-reboot -drive format=raw,file=$(BUILD)

.PHONY: all run debug clean

all:
	$(ASM) $(ASMFLAGS) $(SRC)/main.asm -o $(BUILD)/main.bin
	$(QEMU) $(QEMUFLAGS)/main.bin


run:
	$(QEMU) $(QEMUFLAGS)/main.bin

debug:
	$(QEMU) $(QEMUFLAGS)/main.bin -s -S -d int -D qemu.log

clean:
	rm -rf $(BUILD)/*

