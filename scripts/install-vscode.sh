#!/usr/bin/env bash
# Install Microsoft VS Code for Ubuntu if 'code' is missing.
set -euo pipefail
if command -v code >/dev/null 2>&1; then
    echo "[SKIP] Visual Studio Code already installed: $(command -v code)"
    exit 0
fi

case "$(dpkg --print-architecture)" in
    amd64) vscode_arch=x64 ;;
    arm64) vscode_arch=arm64 ;;
    *) echo "[ERROR] No supported official VS Code .deb for this architecture." >&2; exit 1 ;;
esac

echo "[INFO] Downloading official VS Code package from Microsoft..."
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
curl -fL --retry 3 \
    "https://update.code.visualstudio.com/latest/linux-deb-${vscode_arch}/stable" \
    -o "$tmpdir/code.deb"

if [[ "$(dpkg-deb -f "$tmpdir/code.deb" Package)" != code ]]; then
    echo "[ERROR] Download is not a VS Code 'code' Debian package." >&2
    exit 1
fi
sudo apt-get install -y "$tmpdir/code.deb"
command -v code >/dev/null || { echo "[ERROR] VS Code install did not provide the code CLI." >&2; exit 1; }
echo "[OK] VS Code installed."
