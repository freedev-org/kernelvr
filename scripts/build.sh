#!/bin/bash

BASEDIR="$PWD"
RELEASEDIR="$BASEDIR/releases"

COLOR_GREEN="\x1b[32;1m"
COLOR_RED="\x1b[31;1m"
COLOR_NORMAL="\x1b[0m"

function main() {
    local src="$1"
    local version="$2"

    cd "$src"

    step config || exit
    step build || exit
    step release "$version" || exit
}

# Usage: step <step_name>
function step() {
    local name="$1"
    shift 1

    echo "$name: Running..."
    if "step_$name" "$@"; then
        echo -e "$name: ${COLOR_GREEN}DONE${COLOR_NORMAL}"
        return 0
    else
        echo -e "$name: ${COLOR_RED}ERROR $?${COLOR_NORMAL}"
        return 1
    fi
}

function step_config() {
    make defconfig || return

    for config in $BASEDIR/configs/*.config; do
        add_config "$(basename $config)" || return
    done

    make olddefconfig
    sed -i "s/=m/=y/g" .config
}

function step_build() {
    env -i \
        PATH="$PATH" \
        HOME="$HOME" \
        PWD="$PWD" \
        USER="$USER" \
        SHELL="$SHELL" \
        make -j$(nproc)
        # make V=1 -j1
}

# Usage: step_release <version>
function step_release() {
    local version="$1"
    local dir="$RELEASEDIR/$version"
    mkdir -p "$dir"

    cp -f "arch/x86/boot/bzImage" "$dir/"
    cp -f "vmlinux" "$dir/"
}

# Usage: add_config <filename>
function add_config() {
    local config="$1"

    cp -f "$BASEDIR/configs/$config" "kernel/configs/_$config"
    make "_$config"
}


if [ -z "$2" ]; then
    echo "Usage: $0 <src_path> <version>"
    exit 0
fi

if [ ! -d "$1/kernel" ]; then
    echo "Error: You should have the Linux source code on '$1' path before run this script." >&2
    exit 1
fi

main "$@"
