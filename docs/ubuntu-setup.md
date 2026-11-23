# Ubuntu 24.04 + VS Code: complete native setup

This is the recommended **native** development path for RV32I-FormalLab (no Docker or FPGA required). All SystemVerilog code is edited in VS Code. Verification tools run locally in the VS Code integrated terminal and via **Terminal → Run Task**.

## Prerequisites

- Ubuntu 24.04 with a desktop environment (x86_64 recommended; arm64 supported when upstream binaries are available).
- Internet connectivity, sudo access, free disk space (OSS CAD Suite is a large download).
- A GitHub account for pushing your own changes.

You own [HaibaraAIsuki/rv32i-formallab](https://github.com/HaibaraAIsuki/rv32i-formallab). **Clone**, do not Fork.

## 1. Clone

If Git is missing, install it first:

```bash
sudo apt update && sudo apt install -y git
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/HaibaraAIsuki/rv32i-formallab.git
cd rv32i-formallab
```

If you already cloned, don't clone twice! Instead open your working directory and, if `git status` is clean:

```bash
git switch main
git pull --ff-only origin main
```

## 2. Install everything with one script

Review [scripts/setup-ubuntu.sh](../scripts/setup-ubuntu.sh) before running (it uses sudo / apt and downloads official binaries). Then execute:

```bash
bash scripts/setup-ubuntu.sh
```

The script:

1. Installs common Ubuntu packages (compiler, Git, Make, Python, Verilator, GTKWave, RISC-V GNU assembler/compiler, ctags).
2. Reuses your existing VS Code or installs Microsoft's official `.deb` if `code` is missing.
3. Downloads and extracts the official YosysHQ OSS CAD Suite (Yosys, SBY and solver) into `~/opt/oss-cad-suite`. The script checks GitHub release metadata, downloads from the official repo, and does not use `curl | bash`.
4. Creates `.venv` and installs the Python development dependencies (Cocotb, pytest).
5. Installs recommended VS Code extensions.
6. Runs `make doctor`, `make test` and `make toolchain-check`.

**The script runs on your computer, not on GitHub or in ChatGPT.** It may request your sudo password and needs a large download. If a step fails, capture the output and troubleshoot that step; do not assume the environment is complete.

The installer is repeatable: it reuses a complete OSS CAD Suite directory and the existing Python venv. To update the suite, explicitly back up/remove the old installation before rerunning `scripts/install-oss-cad-suite.sh`.

## 3. Open your project in VS Code

After setup:

```bash
cd ~/projects/rv32i-formallab
code .
```

The workspace config provides:
- Verilog-HDL/SystemVerilog syntax support and Verilator linting
- Python interpreter pointing to `.venv`
- An integrated terminal with OSS CAD Suite on `PATH`
- Build/test/formal/waveform tasks (see `.vscode/tasks.json`)

Press **Ctrl+Shift+P → Tasks: Run Task** and select a task. Or open the VS Code terminal with **Ctrl+`** and use `make` commands below.

### First run

```bash
make doctor
make test
make toolchain-check
```

`make test` runs `lint`, `sim-alu`, then `formal-alu`. This is the initial ALU demonstration, **not a complete CPU proof**.

To generate and inspect a real waveform:

```bash
make wave-alu
```

The Verilator testbench writes `build/alu.vcd`, then GTKWave opens the VCD. In GTKWave, add `a`, `b`, `op` and `result` to the waveform pane. GTKWave needs a graphical session.

The RISC-V cross-compiler assembles `sw/asm/alu_smoke.S` using **`-march=rv32i -mabi=ilp32`**, confirming the toolchain can generate RV32I object code. There is no full CPU to run it yet.

## 4. Installed components

| Component | Purpose | Where |
|---|---|---|
| VS Code + Verilog-HDL extension | Write SystemVerilog with lint feedback | Desktop app |
| Verilator | Lint and simulate SV | Ubuntu / OSS CAD |
| Yosys + SymbiYosys + Boolector | Formal property checks | OSS CAD Suite |
| GTKWave | Visualize VCD waves | Ubuntu / OSS CAD |
| RISC-V GNU toolchain | Assemble/compile bare-metal RV32I snippets | Ubuntu |
| Python `.venv` + Cocotb/pytest | Python-driven verification (later stages) | Project-local virtual environment |
| Git | Branch/commit/push | Ubuntu |

## 5. Development workflow

```bash
git switch main
git pull --ff-only origin main
git switch -c learn/alu
# Edit RTL in VS Code and run checks
make test
git add rtl/alu.sv tb/tb_alu.sv
git commit -m "learn: explore ALU signed comparisons"
git push -u origin learn/alu
```

Open a Pull Request on GitHub to let Actions run the same ALU checks remotely. For the first push, GitHub may require that you authenticate (SSH key or a credential helper). Configure Git author identity if needed.

## 6. Troubleshooting

- `code: command not found`: rerun `bash scripts/install-vscode.sh` or use the official [VS Code Linux setup](https://code.visualstudio.com/docs/setup/linux).
- `sby: command not found`: check `~/opt/oss-cad-suite/bin/sby`, then run `source ~/opt/oss-cad-suite/environment` or use `make` targets (they add the bin directory to `PATH`).
- `boolector: command not found`: inspect the actual OSS CAD Suite release contents; a compatible solver is needed.
- `make formal-alu` fails: inspect `build/alu_formal/logfile.txt` and the job logs before changing assertions.
- VS Code linter cannot see the tool: open the project via `code .` from a Bash terminal or reload the VS Code window; the workspace uses Verilator installed system-wide.
- GTKWave won't open: make sure you have a graphical Linux desktop/session. `build/alu.vcd` can still be inspected elsewhere.
- Missing `riscv64-unknown-elf-gcc`: retry Ubuntu package setup; `riscv64-unknown-elf-gcc` is also capable of targeting RV32I.
- Missing `.venv`: create it with `python3 -m venv .venv` then `.venv/bin/python -m pip install -r requirements-dev.txt`.
- Git auth fails: configure SSH or follow GitHub's sign-in prompts. Do not commit tokens/passwords.

## 7. Proof limitations

The initial `formal/alu.sby` checks combinational ALU properties with unconstrained symbolic inputs. Its result depends on the asserted properties and tool execution. A PASS here does not prove correctness of future register file, memory, PC, or whole RV32I ISA.

See also [the learning roadmap](learning-roadmap.md).
