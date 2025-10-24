// src/byteSub.s
// Aplica S-Box por byte a la matriz (16 bytes).
// x0 = &state[0]
// Requiere: Sbox en constants.s

    .text
    .global byteSub
    .type   byteSub, %function
    .extern Sbox

byteSub:
    // prólogo estándar
    STP     x29, x30, [sp, #-16]!
    MOV     x29, sp

    // x10 = &Sbox (ADRP/ADD = seguro en AArch64)
    ADRP    x10, Sbox
    ADD     x10, x10, :lo12:Sbox

    // i = 0..15
    MOV     w2, #0
1:
    LDRB    w3, [x0, w2, UXTW]     // b = state[i]
    LDRB    w4, [x10, w3, UXTW]    // b' = Sbox[b]
    STRB    w4, [x0, w2, UXTW]     // state[i] = b'
    ADD     w2, w2, #1
    CMP     w2, #16
    B.NE    1b

    // epílogo
    LDP     x29, x30, [sp], #16
    RET
    .size byteSub, (. - byteSub)
