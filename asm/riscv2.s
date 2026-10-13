.text
.globl __start
__start:
    lui  x7, 0x80000      # x7 = 0x80000000
    addi x7, x7, -4       # x7 = 0x7FFFFFFC
    addi s0, x0, 3        # A = 3
    addi s1, x0, 4        # B = 4
    addi s2, x0, 0        # P = 0
    addi s3, x0, 8        # i = 8

mult_loop:
    andi t0, s1, 1        # t0 = B & 1
    beq  t0, x0, skip_add
    add  s2, s2, s0       # P = P + A

skip_add:
    slli s0, s0, 1        # A = A << 1
    srli s1, s1, 1        # B = B >> 1
    addi s3, s3, -1       # i -= 1
    bne  s3, x0, mult_loop

    sw   s2, 0(x7)        # CPUOut = P
    jal  x0, 0            # halt