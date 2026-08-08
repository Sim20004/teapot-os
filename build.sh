nasm -f bin src/boot.asm -o bin/boot.bin
nasm -f bin src/kernel.asm -o bin/kernel.bin
cat bin/boot.bin bin/kernel.bin > bin/os.img