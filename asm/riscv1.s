.text
.globl __start
__start:
    lui  x5, 0x80000      # x5 = 0x80000000
    addi x5, x5, -4       # x5 = 0x7FFFFFFC (memory-mapped IO address)
    lw   x10, 0(x5)       # x10 = a = CPUIn
    addi x11, x0, 0       # sum = 0
    addi x12, x0, 8       # i = 8 (loop counter)

count_loop:
    andi x13, x10, 1      # x13 = a & 1 (isolate LSB)
    add  x11, x11, x13    # sum += x13
    srli x10, x10, 1      # a = a >> 1
    addi x12, x12, -1     # i -= 1
    bne  x12, x0, count_loop

    sw   x11, 0(x5)       # CPUOut = sum
    jal  x0, 0            # halt