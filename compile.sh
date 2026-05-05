#!/bin/bash

nasm -f bin boot.asm -o boot.bin
nasm -f bin stage2.asm -o stage2.bin
dd if=boot.bin of=os.img bs=512 count=1 conv=notrunc
dd if=stage2.bin of=os.img bs=512 seek=1 conv=notrunc