# RV32I-FormalLab

> Learn RISC-V microarchitecture and formal verification by building a small RV32I processor from scratch.

**Status:** Learning project / work in progress. The only RTL implemented initially is a combinational ALU; **this is not yet an RV32I CPU**. No formal or simulation run is claimed until it has been executed and documented.

## Goals

1. Understand RV32I instruction encoding, registers, control flow, and load/store semantics.
2. Implement an educational single-cycle RV32I CPU in SystemVerilog.
3. Test RTL with simulation and progressively prove properties using Yosys + SymbiYosys.
4. Expose the RISC-V Formal Interface (RVFI) and integrate [riscv-formal](https://github.com/YosysHQ/riscv-formal).
5. Preserve meaningful bugs, counterexamples, fixes, and reproducible evidence in a **Formal-Guided Bug Lab**.

## Roadmap

- [x] Create the public repository.
- [ ] **Stage 1 — ALU:** implement arithmetic/logic, test edge cases, and prove combinational properties.
- [ ] **Stage 2 — Datapath:** register file, instruction decoder, immediate generator, PC, and memory interface.
- [ ] **Stage 3 — RV32I:** gradually implement arithmetic, branches/jumps, and loads/stores.
- [ ] **Stage 4 — Module formal:** properties for x0, PC, branches, alignment, and byte enables.
- [ ] **Stage 5 — ISA formal:** RVFI signals, riscv-formal checks, and carefully documented assumptions.
- [ ] **Stage 6 — Bug lab + CI:** intentional mutations, generated counterexamples, and regression tests.

The initial target is a simple **single-cycle** educational design (no pipeline, caches, or OS). Full RV32I support is a future milestone, not a current claim.

## Tooling

- SystemVerilog (RTL)
- [Verilator](https://www.veripool.org/verilator/) (simulation and lint)
- [Yosys](https://github.com/YosysHQ/yosys) and [SymbiYosys](https://github.com/YosysHQ/sby) (formal)
- An SMT solver such as Boolector
- Later: Cocotb, RVFI, riscv-formal, and RISC-V ISA tests

On Ubuntu, the [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build) is a convenient option for Yosys/SymbiYosys/solvers. Ensure `verilator` and `sby` are on your `PATH`.

## Quick start (Ubuntu 24.04 + VS Code)

This project uses **native Ubuntu tools** with **VS Code as the editor**; Docker and FPGA boards are not needed.

See the [complete Ubuntu + VS Code installation guide](docs/ubuntu-setup.md). On a machine without Git, install it with `sudo apt install git`. Then:

```bash
mkdir -p ~/projects && cd ~/projects
git clone https://github.com/HaibaraAIsuki/rv32i-formallab.git
cd rv32i-formallab
bash scripts/setup-ubuntu.sh
code .
```

This installer prepares VS Code, Verilator, GTKWave, RISC-V GNU tools, OSS CAD Suite (Yosys / SBY / solver), Python Cocotb and project extensions; it also runs initial checks locally. It needs sudo, an internet connection and disk space. Review the script before running it.

In the VS Code terminal or via **Terminal → Run Task**:

```bash
make doctor            # check installed dependencies
make test              # lint + RTL simulation + ALU formal
make wave-alu          # generate wave and open GTKWave
make toolchain-check   # assemble a small RV32I example
```

[GitHub Actions](.github/workflows/rtl-formal.yml) runs starter checks on PRs and pushes. **Check the real Actions results**; a committed workflow is not proof of passing tests.

## Start with the ALU

Clone:

```bash
git clone https://github.com/HaibaraAIsuki/rv32i-formallab.git
cd rv32i-formallab
```

When the initial ALU files are present, run:

```bash
make lint
make sim-alu
make formal-alu
```

The formal entry point is `formal/alu.sby`; it checks combinational properties over symbolic ALU inputs. **A bounded pass or an overly restrictive assumption is not a blanket proof of CPU correctness.**

## Repository layout

```text
rtl/           SystemVerilog RTL (ALU first, CPU modules later)
tb/            Simulation testbenches (Cocotb planned)
formal/        Properties and SymbiYosys configurations
docs/          Learning roadmap and verification notes
bugs/          Counterexample write-ups and mutations (planned)
sw/            RV32I assembly tests (planned)
```

## References

- [RISC-V Unprivileged ISA specification](https://github.com/riscv/riscv-isa-manual)
- [YosysHQ / sby](https://github.com/YosysHQ/sby)
- [YosysHQ / riscv-formal](https://github.com/YosysHQ/riscv-formal)
- [YosysHQ / NERV](https://github.com/YosysHQ/nerv)

## Scope and evidence

Keep three concepts separate: **simulation passed**, **specific formal properties proved**, and **full ISA conformance**. Each completed stage should record tool versions, exact commands, constraints, outputs, and known limitations.

Licensed under the MIT License.
