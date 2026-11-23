#!/usr/bin/env bash
set -euo pipefail

if ! command -v code >/dev/null 2>&1; then
    echo "[WARN] VS Code CLI not found; extensions not installed."
    echo "       Install VS Code, then rerun this script."
    exit 1
fi

# Keep this list in sync with .vscode/extensions.json.
for extension in mshr-h.veriloghdl ms-python.python ms-vscode.cpptools; do
    echo "[INFO] Installing VS Code extension: $extension"
    code --install-extension "$extension" --force
done
echo "[OK] Recommended VS Code extensions installed."
