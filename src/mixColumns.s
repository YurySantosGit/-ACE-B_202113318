// src/mixColumns.s

    .text
    .global mixColumns
    .type   mixColumns, %function

mixColumns:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    str     x19, [sp, #-16]!
    mov     x19, x0

    mov     w12, #0x1B

    mov     w20, #0

.col_loop:
    uxtw    x21, w20
    lsl     x21, x21, #2

    add     x22, x19, x21
    add     x23, x22, #1
    add     x24, x22, #2
    add     x25, x22, #3

    ldrb    w0, [x22]
    ldrb    w1, [x23]
    ldrb    w2, [x24]
    ldrb    w3, [x25]

    lsl     w4, w0, #1
    ands    w13, w0, #0x80
    mov     w14, wzr
    b.eq    1f
    mov     w14, w12
1:  eor     w4, w4, w14
    uxtb    w4, w4

    lsl     w5, w1, #1
    ands    w13, w1, #0x80
    mov     w14, wzr
    b.eq    2f
    mov     w14, w12
2:  eor     w5, w5, w14
    uxtb    w5, w5

    lsl     w6, w2, #1
    ands    w13, w2, #0x80
    mov     w14, wzr
    b.eq    3f
    mov     w14, w12
3:  eor     w6, w6, w14
    uxtb    w6, w6

    lsl     w7, w3, #1
    ands    w13, w3, #0x80
    mov     w14, wzr
    b.eq    4f
    mov     w14, w12
4:  eor     w7, w7, w14
    uxtb    w7, w7

    eor     w8,  w4,  w0
    eor     w9,  w5,  w1
    eor     w10, w6,  w2
    eor     w11, w7,  w3

    eor     w15, w4,  w9
    eor     w15, w15, w2
    eor     w15, w15, w3
    uxtb    w15, w15

    eor     w16, w0,  w5
    eor     w16, w16, w10
    eor     w16, w16, w3
    uxtb    w16, w16

    eor     w17, w0,  w1
    eor     w17, w17, w6
    eor     w17, w17, w11
    uxtb    w17, w17

    eor     w18, w8,  w1
    eor     w18, w18, w2
    eor     w18, w18, w7
    uxtb    w18, w18

    strb    w15, [x22]
    strb    w16, [x23]
    strb    w17, [x24]
    strb    w18, [x25]

    add     w20, w20, #1
    cmp     w20, #4
    b.lo    .col_loop

    ldr     x19, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
    .size mixColumns, (. - mixColumns)
    