#!/usr/bin/env bash
set -euo pipefail

missing=0
for tool in git make g++ python3 verilator yosys sby boolector; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf '[OK]      %-12s %s\n' "$tool" "$(command -v "$tool")"
    else
        printf '[MISSING] %s\n' "$tool"
        missing=1
    fi
done
if command -v gtkwave >/dev/null 2>&1; then
    printf '[OK]      gtkwave      %s\n' "$(command -v gtkwave)"
else
    echo '[OPTIONAL] gtkwave (waveform viewer)'
fi

if [[ "$missing" -ne 0 ]]; then
    echo
    echo 'Missing required tools. See docs/ubuntu-setup.md.'
    exit 1
fi

echo
echo 'Required commands found. This does NOT imply that tests or proofs have passed.'
