#!/usr/bin/env bash
# Usage: bash scripts/setup-ubuntu.sh
# Installs Ubuntu packages only. OSS CAD Suite is installed separately.
set -euo pipefail
if [[ ! -r /etc/os-release ]]; then
    echo "Cannot identify the operating system." >&2; exit 1
fi
. /etc/os-release
if [[ "${ID:-}" != ubuntu ]]; then
    echo "This setup script targets Ubuntu (tested instructions: 24.04)." >&2
    exit 1
fi

sudo apt-get update
sudo apt-get install -y \
    git make build-essential python3 python3-venv \
    curl ca-certificates verilator gtkwave

echo
echo "Ubuntu packages installed."
echo "Next: install the OSS CAD Suite for yosys/sby/boolector."
echo "See docs/ubuntu-setup.md for the download and PATH instructions."
echo "Then run: make doctor && make test"
