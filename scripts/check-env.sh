#!/usr/bin/env bash
set -euo pipefail

# Executed by Makefile, which prepends OSS CAD Suite bin to PATH.
missing=0
for tool in git make g++ python3 verilator yosys sby boolector riscv64-unknown-elf-gcc riscv64-unknown-elf-objdump; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf '[OK]       %-26s %s\n' "$tool" "$(command -v "$tool")"
    else
        printf '[MISSING]  %s\n' "$tool"
        missing=1
    fi
done
for tool in code gtkwave ctags; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf '[OK]       %-26s %s\n' "$tool" "$(command -v "$tool")"
    else
        printf '[MISSING]  %s\n' "$tool"
        missing=1
    fi
done

if [[ -x .venv/bin/python ]]; then
    if .venv/bin/python -c 'import cocotb, pytest' >/dev/null 2>&1; then
        echo '[OK]       project Python venv with cocotb and pytest'
    else
        echo '[MISSING]  cocotb and/or pytest inside project .venv'
        missing=1
    fi
else
    echo '[MISSING]  .venv Python environment'
    missing=1
fi

echo
if [[ "$missing" -ne 0 ]]; then
    echo '[FAIL] Some required dependencies are missing.'
    echo '       Run: bash scripts/setup-ubuntu.sh'
    exit 1
fi
echo '[OK] Required tools found. Run make test to check RTL and formal.'
