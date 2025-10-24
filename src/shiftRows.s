// src/shiftRows.s

    .text
    .global shiftRows
    .type   shiftRows, %function

shiftRows:
    STP     x29, x30, [sp, #-16]!
    MOV     x29, sp

    MOV     w2, #0
row_loop:
    MOV     w3, w2
    ADD     w4, w2, #4
    ADD     w5, w2, #8
    ADD     w6, w2, #12

    LDRB    w7,  [x0, w3, UXTW]
    LDRB    w8,  [x0, w4, UXTW]
    LDRB    w9,  [x0, w5, UXTW]
    LDRB    w10, [x0, w6, UXTW]

    CMP     w2, #0
    BEQ     rot0
    CMP     w2, #1
    BEQ     rot1
    CMP     w2, #2
    BEQ     rot2

rot3:
    STRB    w10, [x0, w3, UXTW]
    STRB    w7,  [x0, w4, UXTW]
    STRB    w8,  [x0, w5, UXTW]
    STRB    w9,  [x0, w6, UXTW]
    B       store_done

rot2:
    STRB    w9,  [x0, w3, UXTW]
    STRB    w10, [x0, w4, UXTW]
    STRB    w7,  [x0, w5, UXTW]
    STRB    w8,  [x0, w6, UXTW]
    B       store_done

rot1:
    STRB    w8,  [x0, w3, UXTW]
    STRB    w9,  [x0, w4, UXTW]
    STRB    w10, [x0, w5, UXTW]
    STRB    w7,  [x0, w6, UXTW]
    B       store_done

rot0:
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
    