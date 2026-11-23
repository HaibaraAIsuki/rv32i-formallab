#!/usr/bin/env bash
# Download an official YosysHQ OSS CAD Suite release into ~/opt/oss-cad-suite.
# Running twice is safe: an existing complete installation is reused.
set -euo pipefail

dest="$HOME/opt/oss-cad-suite"
if [[ -x "$dest/bin/sby" && -x "$dest/bin/yosys" ]]; then
    echo "[SKIP] OSS CAD Suite already present at $dest"
    exit 0
fi
if [[ -e "$dest" ]]; then
    echo "[ERROR] $dest exists but is incomplete. Move it aside and retry." >&2
    exit 1
fi

case "$(uname -m)" in
    x86_64|amd64) arch=x64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) echo "[ERROR] Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
echo "[INFO] Resolving current YosysHQ OSS CAD Suite release..."
curl -fSL --retry 3 \
    -H 'Accept: application/vnd.github+json' \
    -H 'User-Agent: RV32I-FormalLab-setup' \
    'https://api.github.com/repos/YosysHQ/oss-cad-suite-build/releases/latest' \
    -o "$temp_dir/release.json"

asset_url="$(python3 - "$temp_dir/release.json" "$arch" <<'PY'
import json
import sys
from pathlib import Path
release = json.loads(Path(sys.argv[1]).read_text())
prefix = f"oss-cad-suite-linux-{sys.argv[2]}-"
assets = [
    a for a in release.get("assets", [])
    if a.get("name", "").startswith(prefix) and a["name"].endswith(".tgz")
]
if not assets:
    raise SystemExit(f"No matching official archive found for {prefix}*.tgz")
print(assets[0]["browser_download_url"])
PY
)"

echo "[INFO] Downloading official archive (large download; free disk space required)..."
curl -fL --retry 3 "$asset_url" -o "$temp_dir/suite.tgz"
mkdir -p "$temp_dir/extract"
tar -xzf "$temp_dir/suite.tgz" -C "$temp_dir/extract"

if [[ ! -x "$temp_dir/extract/oss-cad-suite/bin/yosys" ||
      ! -x "$temp_dir/extract/oss-cad-suite/bin/sby" ]]; then
    echo "[ERROR] Unexpected archive layout; see official YosysHQ releases." >&2
    exit 1
fi

mkdir -p "$HOME/opt"
mv "$temp_dir/extract/oss-cad-suite" "$dest"

# Make tools visible to interactive Bash. The Makefile also sets PATH for VS Code Tasks.
path_line='export PATH="$HOME/opt/oss-cad-suite/bin:$PATH"'
touch "$HOME/.bashrc"
if ! grep -Fqx "$path_line" "$HOME/.bashrc"; then
    printf '\n# RV32I-FormalLab / OSS CAD Suite\n%s\n' "$path_line" >> "$HOME/.bashrc"
fi
echo "[OK] Installed in $dest"
echo "[INFO] For this shell: export PATH=\"\$HOME/opt/oss-cad-suite/bin:\$PATH\""
