// src/shiftRows.s
// x0 = &state[16] (column-major)
// Rotaciones por fila: r=0..3 → desplaza r posiciones a la izq
// offsets de una fila r: r, 4+r, 8+r, 12+r

    .text
    .global shiftRows
    .type   shiftRows, %function

shiftRows:
    STP     x29, x30, [sp, #-16]!
    MOV     x29, sp

    // r = 0..3
    MOV     w2, #0
row_loop:
    // idx0 = r
    // idx1 = r + 4
    // idx2 = r + 8
    // idx3 = r + 12
    MOV     w3, w2
    ADD     w4, w2, #4
    ADD     w5, w2, #8
    ADD     w6, w2, #12

    // cargar a0..a3
    LDRB    w7,  [x0, w3, UXTW]   // a0
    LDRB    w8,  [x0, w4, UXTW]   // a1
    LDRB    w9,  [x0, w5, UXTW]   // a2
    LDRB    w10, [x0, w6, UXTW]   // a3

    // rotar izquierda por r
    CMP     w2, #0
    BEQ     rot0
    CMP     w2, #1
    BEQ     rot1
    CMP     w2, #2
    BEQ     rot2
    // r == 3
rot3:
    // a0..a3 → a3 a0 a1 a2
    // (ya cargados en w7..w10)
    // escribir: idx0=a3, idx1=a0, idx2=a1, idx3=a2
    STRB    w10, [x0, w3, UXTW]
    STRB    w7,  [x0, w4, UXTW]
    STRB    w8,  [x0, w5, UXTW]
    STRB    w9,  [x0, w6, UXTW]
    B       store_done

rot2:
    // a0..a3 → a2 a3 a0 a1
    STRB    w9,  [x0, w3, UXTW]
    STRB    w10, [x0, w4, UXTW]
    STRB    w7,  [x0, w5, UXTW]
    STRB    w8,  [x0, w6, UXTW]
    B       store_done

rot1:
    // a0..a3 → a1 a2 a3 a0
    STRB    w8,  [x0, w3, UXTW]
    STRB    w9,  [x0, w4, UXTW]
    STRB    w10, [x0, w5, UXTW]
    STRB    w7,  [x0, w6, UXTW]
    B       store_done

rot0:
    // sin cambios
    STRB    w7,  [x0, w3, UXTW]
    STRB    w8,  [x0, w4, UXTW]
    STRB    w9,  [x0, w5, UXTW]
    STRB    w10, [x0, w6, UXTW]

store_done:
    ADD     w2, w2, #1
    CMP     w2, #4
    B.NE    row_loop

    LDP     x29, x30, [sp], #16
    RET
    .size shiftRows, (. - shiftRows)
    