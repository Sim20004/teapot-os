#!/bin/bash

nasm -f elf64 main.asm -o bin/main.o
ld bin/main.o -o bin/main