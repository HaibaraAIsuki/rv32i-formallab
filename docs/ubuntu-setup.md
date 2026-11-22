# Ubuntu 24.04: getting started

This guide assumes your PC uses Ubuntu 24.04 on x86_64; verify with `uname -m`.
The GitHub repo is **not** a fork. Clone your own repository.

## 1. Clone the repo

```bash
mkdir -p ~/projects && cd ~/projects
git clone https://github.com/HaibaraAIsuki/rv32i-formallab.git
cd rv32i-formallab
```

Already cloned? From its directory, run `git pull --ff-only origin main` on a clean `main` branch.

## 2. Install the Ubuntu packages

Read the script first if you prefer, then run:

```bash
bash scripts/setup-ubuntu.sh
```

This installs Git, make, a C++ toolchain, Python, Verilator and GTKWave. It will request your sudo password and use Ubuntu's package manager. It **does not** install OSS CAD Suite automatically.

## 3. Install OSS CAD Suite

Download a recent **linux-x64** archive from the official
[OSS CAD Suite releases](https://github.com/YosysHQ/oss-cad-suite-build/releases).
Check that the archive is from `YosysHQ/oss-cad-suite-build` and matches your machine architecture.

For example, after downloading the archive into `~/Downloads`, extract it:

```bash
mkdir -p ~/opt
tar -xzf ~/Downloads/oss-cad-suite-linux-x64-*.tgz -C ~/opt
```

The glob is an example: check the actual archive extension and name first.
The resulting default directory is usually `~/opt/oss-cad-suite`. Confirm by running `ls ~/opt/oss-cad-suite/bin`. If the archive's top-level directory differs, adjust accordingly.

For the current terminal:

```bash
export PATH="$HOME/opt/oss-cad-suite/bin:$PATH"
```

For future Bash sessions, add the PATH line to `~/.bashrc` (only once).
You can also use `source ~/opt/oss-cad-suite/environment` if the downloaded release provides that environment file.

## 4. Verify your local environment

From the repository directory:

```bash
make doctor
make lint
make sim-alu
make formal-alu
```

`make test` performs the last three checks in sequence. If any command fails, capture its output; don't mark a proof complete without looking at the property configuration and limitations.

Formal output is written beneath `build/alu_formal/`. Git ignores generated files. When a property fails, inspect the logs and counterexample trace in that directory. The initial proof is combinational ALU checking only, not RV32I architectural conformance.

## 5. VS Code

Open the repository using `code .` if VS Code is installed. Use **Terminal → Run Task** to find ALU lint, simulation, formal and environment checks.

## 6. Work without overwriting the main branch

```bash
git switch main
git pull --ff-only origin main
git switch -c learn/alu
# make and test your own edits
git add rtl/alu.sv tb/tb_alu.sv
git commit -m "learn: experiment with ALU"
git push -u origin learn/alu
```

Open a Pull Request on GitHub and review the generated CI result. On a new machine, set your Git author identity using `git config --global user.name` and `git config --global user.email` if needed. Pushing requires GitHub authentication (SSH or an approved HTTPS credential).

## Troubleshooting

- `sby: command not found`: OSS CAD Suite's `bin/` is not in your PATH.
- `boolector: command not found`: use the OSS CAD Suite build that includes it.
- `verilator: command not found`: rerun `bash scripts/setup-ubuntu.sh`.
- `make formal-alu` fails: inspect `build/alu_formal/logfile.txt`; save the actual error.
- CI red: visit the repository's **Actions** tab and review the failing step; locally installed versions can differ.

## Security / reproducibility note

Do not use `curl | bash` from unknown websites. The setup script uses Ubuntu's package manager, while OSS CAD Suite must come from the official releases. Record `yosys -V`, `verilator --version`, and `sby --version` alongside results.
