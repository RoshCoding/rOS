## Memory Map for E820 setup
We'll need to find these locations later for the kernel, so it's best to set it up in a place we're comfortable with: like below 0x7C00 or 0x1000 (clear of the BIOS data at 0x500 and our stack at 0x7C00)

Let's set it up at 0x1000.
