#!/usr/bin/env bash
# Full native Ubuntu 24.04 setup for RV32I-FormalLab + VS Code.
# Run: bash scripts/setup-ubuntu.sh
# Needs sudo, network access and several GB of free space for the EDA suite.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ ! -r /etc/os-release ]]; then
    echo "[ERROR] Cannot identify operating system." >&2
    exit 1
fi
. /etc/os-release
if [[ "${ID:-}" != "ubuntu" ]]; then
    echo "[ERROR] This installer targets Ubuntu 24.04 (found ${PRETTY_NAME:-unknown})." >&2
    exit 1
fi
if [[ "${VERSION_ID:-}" != "24.04" ]]; then
    echo "[WARN] Instructions are maintained for Ubuntu 24.04; found ${VERSION_ID:-unknown}."
fi

echo "[1/6] Installing Ubuntu packages (sudo required)..."
sudo apt-get update
sudo apt-get install -y \
    git make build-essential python3 python3-venv python3-pip \
    curl ca-certificates tar xz-utils universal-ctags \
    verilator gtkwave gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf

echo "[2/6] Setting up Microsoft Visual Studio Code..."
bash scripts/install-vscode.sh

echo "[3/6] Installing YosysHQ OSS CAD Suite..."
bash scripts/install-oss-cad-suite.sh
export PATH="$HOME/opt/oss-cad-suite/bin:$PATH"

echo "[4/6] Installing Python test dependencies into project .venv..."
if [[ ! -f .venv/pyvenv.cfg ]]; then
    /usr/bin/python3 -m venv .venv
fi
.venv/bin/python -m pip install --disable-pip-version-check -r requirements-dev.txt

echo "[5/6] Installing recommended VS Code extensions..."
bash scripts/install-vscode-extensions.sh

echo "[6/6] Checking tools and starter code..."
make doctor
make test
make toolchain-check

echo
echo "[DONE] Native development environment installed and starter checks executed."
echo "Open VS Code: code ."
echo "In VS Code: Terminal -> Run Task (Ctrl+Shift+P, 'Tasks: Run Task')."
echo "To update your shell PATH now: source ~/opt/oss-cad-suite/environment"
