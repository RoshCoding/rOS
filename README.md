# rOS: A self-built OS and Bootloader
This project was built without the use of AI-written code. Every line was hand typed.


## Project Overview:
The project is designed for x86 systems with backwards compatibility intended. 

### Bootloader:
A functioning 2 stage custom bootloader that loads the kernel. The bootloader is written entirely in assembly and contains the following parts:
- BIOS output functionality
- Multi-Sector stage loading with CHS convention
- A20 handling with int 0x15 and Fast A20 gate 
- Memory mapping with int 0x15 and E820
- GDT setup and Protected mode

### Kernel:
A functioning kernel is to be implemented with the following features, written with C:
- VGA and serial port drivers
- Port I/O
- CPU interrupt and fault handling
- Memory management with the E820 map, paging, and a kernel heap
- A functioning file system
- A shell

## Testing and Development
Development is done with Neovim. All testing is currently done with QEMU to emulate a working x86 system.
