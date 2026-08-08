#!/bin/sh

nasm -f bin boot/src/boot.asm -o bin/boot.bin
nasm -f bin kernel/src/kernel.asm -o bin/kernel.bin

cat bin/boot.bin bin/kernel.bin > bin/os.img

if [ "$1" = "qemu" ]; then
    qemu-system-i386 -drive file=bin/os.img,format=raw
fi