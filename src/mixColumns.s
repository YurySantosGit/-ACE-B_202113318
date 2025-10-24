// src/mixColumns.s
// x0 = &state[16] (column-major)
// MixColumns por columna (AES) usando xtime y XOR.
// Seguro: x19 = base del estado, sin pisarlo; índices en 64 bits.

    .text
    .global mixColumns
    .type   mixColumns, %function

mixColumns:
    // Prólogo: FP/LR y x19 (callee-saved) para base del estado
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    str     x19, [sp, #-16]!
    mov     x19, x0                  // x19 = base state

    // Constante 0x1B para reducción de xtime
    mov     w12, #0x1B               // w12 = 0x1B

    // c = 0..3 (contador de columnas)
    mov     w20, #0

.col_loop:
    // base_off = (uint64_t)(c * 4)
    uxtw    x21, w20
    lsl     x21, x21, #2

    // Punteros de la columna: r + 4*c
    add     x22, x19, x21            // &state[0 + 4*c]
    add     x23, x22, #1             // &state[1 + 4*c]
    add     x24, x22, #2             // &state[2 + 4*c]
    add     x25, x22, #3             // &state[3 + 4*c]

    // ---- Cargar S0..S3 en w0..w3 ----
    ldrb    w0, [x22]                // S0
    ldrb    w1, [x23]                // S1
    ldrb    w2, [x24]                // S2
    ldrb    w3, [x25]                // S3

    // ---- xtime(Sx) → T0..T3 en w4..w7 ----
    // T0
    lsl     w4, w0, #1
    ands    w13, w0, #0x80           // msb?
    mov     w14, wzr
    b.eq    1f
    mov     w14, w12                 // 0x1B
1:  eor     w4, w4, w14
    uxtb    w4, w4

    // T1
    lsl     w5, w1, #1
    ands    w13, w1, #0x80
    mov     w14, wzr
    b.eq    2f
    mov     w14, w12
2:  eor     w5, w5, w14
    uxtb    w5, w5

    // T2
    lsl     w6, w2, #1
    ands    w13, w2, #0x80
    mov     w14, wzr
    b.eq    3f
    mov     w14, w12
3:  eor     w6, w6, w14
    uxtb    w6, w6

    // T3
    lsl     w7, w3, #1
    ands    w13, w3, #0x80
    mov     w14, wzr
    b.eq    4f
    mov     w14, w12
4:  eor     w7, w7, w14
    uxtb    w7, w7

    // ---- Ux = 3*Sx = T ^ S → w8..w11 ----
    eor     w8,  w4,  w0             // U0
    eor     w9,  w5,  w1             // U1
    eor     w10, w6,  w2             // U2
    eor     w11, w7,  w3             // U3

    // ---- Cálculo de columna C0..C3 (w15..w18) ----
    // C0 = 02*S0 ^ 03*S1 ^ 01*S2 ^ 01*S3 = T0 ^ U1 ^ S2 ^ S3
    eor     w15, w4,  w9
    eor     w15, w15, w2
    eor     w15, w15, w3
    uxtb    w15, w15

    // C1 = S0 ^ T1 ^ U2 ^ S3
    eor     w16, w0,  w5
    eor     w16, w16, w10
    eor     w16, w16, w3
    uxtb    w16, w16

    // C2 = S0 ^ S1 ^ T2 ^ U3
    eor     w17, w0,  w1
    eor     w17, w17, w6
    eor     w17, w17, w11
    uxtb    w17, w17

    // C3 = U0 ^ S1 ^ S2 ^ T3
    eor     w18, w8,  w1
    eor     w18, w18, w2
    eor     w18, w18, w7
    uxtb    w18, w18

    // ---- Escribir C0..C3 ----
    strb    w15, [x22]               // fila 0
    strb    w16, [x23]               // fila 1
    strb    w17, [x24]               // fila 2
    strb    w18, [x25]               // fila 3

    // ---- Siguiente columna ----
    add     w20, w20, #1
    cmp     w20, #4
    b.lo    .col_loop

    // Epílogo
    ldr     x19, [sp], #16
    ldp     x29, x30, [sp], #16
    ret
    .size mixColumns, (. - mixColumns)
    