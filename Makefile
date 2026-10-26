ASM := nasm
QEMU := qemu-system-i386
BUILD := build

SRC := src

OS_IMG := $(BUILD)/os.img

.PHONY: all run debug clean

all:
	

run:
	make

debug:


clean:
	rm -rf $(BUILD)/

