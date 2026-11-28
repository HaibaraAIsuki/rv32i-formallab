/* Single-cycle core smoke test. The final jump loops at _start + 16. */
    .section .text
    .globl _start
_start:
    addi x1, x0, 5
    addi x2, x0, 7
    add  x3, x1, x2
    sub  x4, x3, x1
1:
    jal  x0, 1b
