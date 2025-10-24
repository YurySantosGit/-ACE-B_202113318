// src/byteSub.s
// Aplica S-Box por byte a la matriz (16 bytes).

    .text
    .global byteSub
    .type   byteSub, %function
    .extern Sbox

byteSub:
    STP     x29, x30, [sp, #-16]!
    MOV     x29, sp

    ADRP    x10, Sbox
    ADD     x10, x10, :lo12:Sbox

    MOV     w2, #0
1:
    LDRB    w3, [x0, w2, UXTW]
    LDRB    w4, [x10, w3, UXTW]
    STRB    w4, [x0, w2, UXTW]
    ADD     w2, w2, #1
    CMP     w2, #16
    B.NE    1b

    LDP     x29, x30, [sp], #16
    RET
    .size byteSub, (. - byteSub)
