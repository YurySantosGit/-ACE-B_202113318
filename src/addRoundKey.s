// src/addRoundKey.s
// x0 = puntero a state[16]  (column-major)
// x1 = puntero a key[16]
// Efecto: state[i] ^= key[i]  para i=0..15

    .text
    .global addRoundKey
    .type   addRoundKey, %function

addRoundKey:
    STP     x29, x30, [sp, #-16]!
    mov     x29, sp

    mov     x2, #0                  // i = 0
1:
    ldrb    w3, [x0, x2]            // state[i]
    ldrb    w4, [x1, x2]            // key[i]
    eor     w3, w3, w4              // state[i] ^= key[i]
    strb    w3, [x0, x2]

    add     x2, x2, #1
    cmp     x2, #16
    b.ne    1b

    LDP     x29, x30, [sp], #16
    ret