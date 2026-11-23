.section .text
.globl _start
_start:
    addi x1, x0, 5
    addi x2, x0, 7
    add  x3, x1, x2
    sw   x3, 0x100(x0)
    lw   x4, 0x100(x0)
    bne  x3, x4, fail
    addi x5, x0, 1
    jal  x0, done
fail:
    addi x5, x0, -1
done:
    ebreak
