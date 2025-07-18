#!/bin/bash

if which wl-copy wl-paste > /dev/null; then
    COPY_CMD="wl-copy"
elif which xclip > /dev/null; then
    COPY_CMD="xclip -selection clipboard"
else
    echo "Warning: xclip or wl-copy not found. Unable to share clipboard." >&2
    exit 0
fi

function main() {
    local CB="$1"

    while [ -p "$CB" ]; do
        cat "$CB" | $COPY_CMD
    done
}

main "$@"
