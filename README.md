# TeapotOS

TeapotOS is a hobby operating system written entirely in x86 Assembly. It is developed from scratch as a learning project to explore how operating systems work at a low level, from the boot process to kernel development.

## Features

* Custom x86 bootloader
* Global Descriptor Table (GDT) setup
* Protected Mode (32-bit) kernel
* VGA text-mode terminal
* Hardware cursor support
* PS/2 keyboard driver
* Interactive command shell
* Automatic screen scrolling
* Shift and Backspace support

## Commands

| Command  | Description                 |
| -------- | --------------------------- |
| `help`   | Display available commands  |
| `clear`  | Clear the terminal          |
| `whoami` | Display the current user    |
| `ver`    | Display version information |


## Requirements

### Running

* x86-compatible CPU
* BIOS-based boot environment
* Emulator such as QEMU, Bochs, or VirtualBox

### Building

* NASM
* A Unix-like environment (Linux recommended)

## Building

Assemble the bootloader and kernel:

```bash
nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin
```

Create a bootable image:

```bash
cat boot.bin kernel.bin > os.img
```

## Running with QEMU

```bash
qemu-system-i386 -drive format=raw,file=os.img
```

## Project Structure

```text
.
├── boot.asm
├── kernel.asm
├── os.img
├── LICENSE
└── README.md
```

### boot.asm

Responsible for:

* Initial system setup
* Loading the kernel
* Creating and loading the GDT
* Switching to Protected Mode
* Jumping to the kernel

### kernel.asm

Responsible for:

* Terminal output
* Keyboard input
* Command processing
* Screen scrolling
* Shell functionality

## Current Status

TeapotOS is currently in early alpha development.

Implemented:

* Boot process
* Protected Mode transition
* Terminal output
* Keyboard input
* Basic shell commands

Planned:

* Memory management
* Filesystem support
* Executable loading
* Drivers
* User applications
* Multitasking
* Networking

## Version

Current Release: **v0.1.0-alpha1**

## License

TeapotOS is licensed under the GNU General Public License v3.0.

See the `LICENSE` file for details.

## Disclaimer

TeapotOS is an educational and experimental operating system. It is not intended for production use and may contain bugs, incomplete features, and breaking changes between releases.
