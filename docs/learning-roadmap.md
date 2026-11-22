# Learning roadmap

## Stage 1: 32-bit ALU
- Read RV32I arithmetic and shift semantics.
- Inspect `rtl/alu.sv` and compare signed versus unsigned cases.
- Run `make lint`, `make sim-alu`, and `make formal-alu`.
- Intentionally change signed SLT to an unsigned comparison and inspect the generated counterexample.
- Keep a note of your exact commands, tool versions, and proof limitations.

## Stage 2: Single-cycle core
Add register file, decoder, immediate generator, PC logic, and instruction/data memory interfaces. Simulate small hand-written assembly tests.

## Stage 3: ISA behavior
Implement all intended RV32I arithmetic, control-flow, load/store semantics; separately specify handling of FENCE, ECALL, EBREAK, misaligned accesses, and illegal instructions.

## Stage 4: Module-level formal
Prove x0 is immutable, register writes occur only when enabled, JALR clears bit zero, load sign-extension and store masks are correct, and conditional PC updates match the decoded instruction.

## Stage 5: RVFI and riscv-formal
Emit instruction retirement information through RVFI. Integrate the upstream checker and document every assumption, covered instruction, proof engine, and bounded versus unbounded result.

## Stage 6: Formal-guided bug lab
Inject targeted bugs into signed comparison, arithmetic shifts, branch offset construction, register x0, and store-byte enables. Preserve reproducible counterexamples and fixes.

This is an incremental learning plan, not a statement of completed verification.
