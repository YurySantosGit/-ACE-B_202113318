// src/keyExpansion.s

    .text
    .global keyExpansion
    .type   keyExpansion, %function
    .extern Sbox
    .extern Rcon

keyExpansion:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #16

    mov x2, #0
1:
    ldrb w3, [x0, x2]
    strb w3, [sp, x2]
    add  x2, x2, #1
    cmp  x2, #16
    b.ne 1b

    ldrb w2,  [x0, #0]
    ldrb w3,  [x0, #1]
    ldrb w4,  [x0, #2]
    ldrb w5,  [x0, #3]

    ldrb w6,  [x0, #4]
    ldrb w7,  [x0, #5]
    ldrb w8,  [x0, #6]
    ldrb w9,  [x0, #7]

    ldrb w14, [x0, #12]
    ldrb w15, [x0, #13]
    ldrb w16, [x0, #14]
    ldrb w17, [x0, #15]

    mov  w18, w15
    mov  w19, w16
    mov  w20, w17
    mov  w21, w14

    adrp x10, Sbox
    add  x10, x10, :lo12:Sbox
    ldrb w18, [x10, w18, uxtw]
    ldrb w19, [x10, w19, uxtw]
    ldrb w20, [x10, w20, uxtw]
    ldrb w21, [x10, w21, uxtw]

    adrp x11, Rcon
    add  x11, x11, :lo12:Rcon
    uxtw x12, w1
    ldrb w22, [x11, x12]
    eor  w18, w18, w22

    eor  w23, w2,  w18
    eor  w24, w3,  w19
    eor  w25, w4,  w20
    eor  w26, w5,  w21

    eor  w27, w6,  w23
    eor  w28, w7,  w24
    eor  w29, w8,  w25
    eor  w30, w9,  w26

    ldrb w2,  [sp, #8]
    ldrb w3,  [sp, #9]
    ldrb w4,  [sp, #10]
    ldrb w5,  [sp, #11]
    eor  w2,  w2,  w27
    eor  w3,  w3,  w28
    eor  w4,  w4,  w29
    eor  w5,  w5,  w30

    ldrb w6,  [sp, #12]
    ldrb w7,  [sp, #13]
    ldrb w8,  [sp, #14]
    ldrb w9,  [sp, #15]
    eor  w6,  w6,  w2
    eor  w7,  w7,  w3
    eor  w8,  w8,  w4
    eor  w9,  w9,  w5

    strb w23, [x0, #0]
    strb w24, [x0, #1]
    strb w25, [x0, #2]
    strb w26, [x0, #3]

    strb w27, [x0, #4]
    strb w28, [x0, #5]
    strb w29, [x0, #6]
    strb w30, [x0, #7]

    strb w2,  [x0, #8]
    strb w3,  [x0, #9]
    strb w4,  [x0, #10]
    strb w5,  [x0, #11]

    strb w6,  [x0, #12]
    strb w7,  [x0, #13]
    strb w8,  [x0, #14]
    strb w9,  [x0, #15]

    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret
    .size keyExpansion, (. - keyExpansion)
