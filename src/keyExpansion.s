// keyExpansion.s — AES-128, seguro con copia a stack para W6/W7
// x0 = &key[16] (in/out, column-major). w1 = round (0-based).
// Requiere: Sbox, Rcon

    .text
    .global keyExpansion
    .type   keyExpansion, %function
    .extern Sbox
    .extern Rcon

keyExpansion:
    // Prologo + reservar 16 bytes para copia orig[16]
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #16          // sp -> orig[0]

    // Copiar key[16] → orig[16]
    mov x2, #0
1:
    ldrb w3, [x0, x2]
    strb w3, [sp, x2]
    add  x2, x2, #1
    cmp  x2, #16
    b.ne 1b

    // ===== Cargar W0..W3 de key (para comodidad) =====
    ldrb w2,  [x0, #0]   // W0
    ldrb w3,  [x0, #1]
    ldrb w4,  [x0, #2]
    ldrb w5,  [x0, #3]

    ldrb w6,  [x0, #4]   // W1
    ldrb w7,  [x0, #5]
    ldrb w8,  [x0, #6]
    ldrb w9,  [x0, #7]

    // W3 (para RotWord/SubWord)
    ldrb w14, [x0, #12]
    ldrb w15, [x0, #13]
    ldrb w16, [x0, #14]
    ldrb w17, [x0, #15]

    // temp = SubWord(RotWord(W3)) ^ [Rcon,0,0,0]
    // RotWord: [k12,k13,k14,k15] -> [k13,k14,k15,k12]
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
    eor  w18, w18, w22        // temp[0] ^= rcon

    // W4 = W0 ^ temp  → e0..e3 (w23..w26)
    eor  w23, w2,  w18
    eor  w24, w3,  w19
    eor  w25, w4,  w20
    eor  w26, w5,  w21

    // W5 = W1 ^ W4  → f0..f3 (w27..w30)
    eor  w27, w6,  w23
    eor  w28, w7,  w24
    eor  w29, w8,  w25
    eor  w30, w9,  w26

    // ===== W6 = ORIG.W2 ^ W5  (usar copia en stack, offsets 8..11) =====
    ldrb w2,  [sp, #8]   // orig k8
    ldrb w3,  [sp, #9]   // orig k9
    ldrb w4,  [sp, #10]  // orig k10
    ldrb w5,  [sp, #11]  // orig k11
    eor  w2,  w2,  w27   // g0
    eor  w3,  w3,  w28   // g1
    eor  w4,  w4,  w29   // g2
    eor  w5,  w5,  w30   // g3   // -> W6 en w2..w5

    // ===== W7 = ORIG.W3 ^ W6  (usar copia en stack, offsets 12..15) =====
    ldrb w6,  [sp, #12]  // orig k12
    ldrb w7,  [sp, #13]  // orig k13
    ldrb w8,  [sp, #14]  // orig k14
    ldrb w9,  [sp, #15]  // orig k15
    eor  w6,  w6,  w2    // h0
    eor  w7,  w7,  w3    // h1
    eor  w8,  w8,  w4    // h2
    eor  w9,  w9,  w5    // h3   // -> W7 en w6..w9

    // ===== Store W4..W7 en key (column-major) =====
    // W4
    strb w23, [x0, #0]
    strb w24, [x0, #1]
    strb w25, [x0, #2]
    strb w26, [x0, #3]
    // W5
    strb w27, [x0, #4]
    strb w28, [x0, #5]
    strb w29, [x0, #6]
    strb w30, [x0, #7]
    // W6
    strb w2,  [x0, #8]
    strb w3,  [x0, #9]
    strb w4,  [x0, #10]
    strb w5,  [x0, #11]
    // W7
    strb w6,  [x0, #12]
    strb w7,  [x0, #13]
    strb w8,  [x0, #14]
    strb w9,  [x0, #15]

    // epílogo
    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret
    .size keyExpansion, (. - keyExpansion)
