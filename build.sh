#!/bin/sh

set -eu

# --------------------------------------------------
# Configuration
# --------------------------------------------------

BOOT_SRC="boot/src/boot.asm"
KERNEL_SRC="kernel/src/kernel.asm"

BUILD_DIR="bin"
BOOT_BIN="$BUILD_DIR/boot.bin"
KERNEL_BIN="$BUILD_DIR/kernel.bin"
OS_IMAGE="$BUILD_DIR/os.img"

PROGRAM_NAME=$(basename "$0")

# --------------------------------------------------
# Colours
# --------------------------------------------------

if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    RESET=''
fi

# --------------------------------------------------
# Helpers
# --------------------------------------------------

info() {
    printf "${BLUE}==>${RESET} %s\n" "$1"
}

success() {
    printf "${GREEN}✓${RESET} %s\n" "$1"
}

warning() {
    printf "${YELLOW}!${RESET} %s\n" "$1"
}

error() {
    printf "${RED}error:${RESET} %s\n" "$1" >&2
}

die() {
    error "$1"
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --------------------------------------------------
# Help
# --------------------------------------------------

usage() {
    cat <<EOF
TeapotOS build system

Usage:
    $PROGRAM_NAME <command> [options]

Commands:
    build       Assemble the bootloader, kernel and disk image
    run         Build and run the OS in QEMU
    clean       Remove generated build files
    rebuild     Clean and build from scratch
    help        Show this help message

Options:
    -h, --help      Show this help message
    --no-build      Run the existing image without rebuilding
    --debug         Start QEMU with debugging enabled

Examples:
    $PROGRAM_NAME build
    $PROGRAM_NAME run
    $PROGRAM_NAME run --debug
    $PROGRAM_NAME run --no-build
    $PROGRAM_NAME rebuild
    $PROGRAM_NAME clean

Build output:
    $BOOT_BIN
    $KERNEL_BIN
    $OS_IMAGE
EOF
}

# --------------------------------------------------
# Dependency checking
# --------------------------------------------------

check_dependencies() {
    command_exists nasm || die "NASM is not installed."
}

check_qemu() {
    command_exists qemu-system-i386 || die "qemu-system-i386 is not installed."
}

# --------------------------------------------------
# Build
# --------------------------------------------------

build() {
    check_dependencies

    mkdir -p "$BUILD_DIR"

    info "Assembling bootloader..."
    nasm -f bin "$BOOT_SRC" -o "$BOOT_BIN"
    success "Bootloader assembled"

    info "Assembling kernel..."
    nasm -f bin "$KERNEL_SRC" -o "$KERNEL_BIN"
    success "Kernel assembled"

    info "Creating disk image..."
    cat "$BOOT_BIN" "$KERNEL_BIN" > "$OS_IMAGE"
    success "Disk image created: $OS_IMAGE"

    printf '\n'
}

# --------------------------------------------------
# Clean
# --------------------------------------------------

clean() {
    if [ ! -d "$BUILD_DIR" ]; then
        warning "Nothing to clean."
        return
    fi

    info "Removing build directory..."
    rm -rf "$BUILD_DIR"

    success "Build directory removed"
}

# --------------------------------------------------
# Run
# --------------------------------------------------

run() {
    debug=0
    no_build=0

    for arg in "$@"; do
        case "$arg" in
            --debug)
                debug=1
                ;;
            --no-build)
                no_build=1
                ;;
            -h|--help)
                usage
                return
                ;;
            *)
                die "Unknown run option: $arg"
                ;;
        esac
    done

    check_qemu

    if [ "$no_build" -eq 0 ]; then
        build
    elif [ ! -f "$OS_IMAGE" ]; then
        die "$OS_IMAGE does not exist. Build the OS first."
    fi

    info "Starting TeapotOS..."

    if [ "$debug" -eq 1 ]; then
        qemu-system-i386 \
            -drive "file=$OS_IMAGE,format=raw" \
            -d int \
            -no-reboot \
            -no-shutdown
    else
        qemu-system-i386 \
            -drive "file=$OS_IMAGE,format=raw"
    fi
}

# --------------------------------------------------
# Command parsing
# --------------------------------------------------

if [ "$#" -eq 0 ]; then
    usage
    exit 0
fi

command="$1"
shift

case "$command" in
    build)
        [ "$#" -eq 0 ] || die "build does not accept arguments."
        build
        ;;

    run)
        run "$@"
        ;;

    clean)
        [ "$#" -eq 0 ] || die "clean does not accept arguments."
        clean
        ;;

    rebuild)
        [ "$#" -eq 0 ] || die "rebuild does not accept arguments."
        clean
        build
        ;;

    help|-h|--help)
        usage
        ;;

    *)
        error "Unknown command: $command"
        printf '\n'
        usage
        exit 1
        ;;
esac