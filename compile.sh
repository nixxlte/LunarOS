#!/bin/bash

nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin
nasm -f bin fs.asm -o fs.bin

dd if=/dev/zero of=os.img bs=512 count=2880

dd if=boot.bin of=os.img conv=notrunc
dd if=kernel.bin of=os.img seek=1 conv=notrunc
dd if=fs.bin of=os.img seek=2 conv=notrunc
# dd if=fb.bin of=os.img seek=3 conv=notrunc