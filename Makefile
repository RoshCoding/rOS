NASM := nasm
QEMU := qemu-system-i386
BUILD := build

OS_IMG := $(BUILD)/os.img

.PHONY: all run debug clean
