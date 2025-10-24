// utils.s — rutinas de apoyo:
//  - toMatrixColMajor(src=x0, dst=x1)   → copia 16 bytes
//  - printMatrix(mat=x0)                → imprime 4x4 en hex (column-major)
//  - printHexByte(w0)                   → imprime un byte en HEX + espacio

    .include "macros.s"

    .text

// ------------------------------------------------------------
// void toMatrixColMajor(uint8_t* src16, uint8_t* dst16)
// Copia lineal de 16 bytes. Para nuestras entradas de 16 chars,
// esto ya es suficiente; printMatrix indexa en column-major.
    .global toMatrixColMajor
    .type   toMatrixColMajor, %function
toMatrixColMajor:
    STP x29, x30, [sp, #-16]!
    MOV x29, sp

    MOV x2, #16                // contador de bytes
1:
    LDRB w3, [x0], #1
    STRB w3, [x1], #1
    SUBS x2, x2, #1
    B.NE 1b

    LDP x29, x30, [sp], #16
    RET
    .size toMatrixColMajor, (. - toMatrixColMajor)


// ------------------------------------------------------------
// void printMatrix(uint8_t* mat16)
// Imprime 4 filas de 4 bytes interpretando memoria en
// column-major: byte(r,c) = mat[c*4 + r].
//
// ¡OJO! Las macros print usan x0/x1/x2. Por eso:
//  - Guardamos el puntero de la matriz en x21 (callee-saved).
//  - Usamos x19 = fila, x20 = col (callee-saved).
    .global printMatrix
    .type   printMatrix, %function
printMatrix:
    // Guardar FP/LR y callee-saved que usaremos (x19,x20,x21)
    STP x29, x30, [sp, #-16]!
    MOV x29, sp
    STP x19, x20, [sp, #-16]!
    STR x21, [sp, #-16]!
    MOV x21, x0                // x21 = puntero a la matriz

    // Cabeceras (vacías por ahora; estilizamos luego si quieres)
    print 1, hex_head_open, hex_head_open_len

    // r = 0..3  (usar x19)
    MOV x19, #0
pm_row:
    // c = 0..3  (usar x20)
    MOV x20, #0
pm_col:
    // idx = c*4 + r
    MOV x3, x20
    LSL x3, x3, #2            // c*4
    ADD x3, x3, x19           // + r
    ADD x3, x3, x21           // x21 = base mat
    LDRB w4, [x3]             // byte en w4

    // Convertir w4 → 2 ASCII HEX en hexbuf2[0..1]
    BL  hex_byte_to_ascii

    // Imprimir 2 chars + espacio (print pisa x0/x1/x2; no afecta x19/x20/x21)
    print 1, hexbuf2, 2
    print 1, hex_space, 1

    ADD x20, x20, #1
    CMP x20, #4
    B.NE pm_col

    // Fin de fila → salto de línea
    print 1, hex_newline, 1

    ADD x19, x19, #1
    CMP x19, #4
    B.NE pm_row

    print 1, hex_head_close, hex_head_close_len

    // Restaurar callee-saved y FP/LR
    LDR x21, [sp], #16
    LDP x19, x20, [sp], #16
    LDP x29, x30, [sp], #16
    RET
    .size printMatrix, (. - printMatrix)


// ------------------------------------------------------------
// helper: hex_byte_to_ascii
// in : w4 = byte (0..255)
// out: hexbuf2[0] = hi nibble ASCII, hexbuf2[1] = lo nibble ASCII
// Usa ADRP/ADD para direccionar .data/.bss con alcance seguro.
    .type   hex_byte_to_ascii, %function
hex_byte_to_ascii:
    // Extraer nibbles
    AND w5, w4, #0xF0
    LSR w5, w5, #4            // hi (0..15)
    AND w6, w4, #0x0F         // lo (0..15)

    // x7 = &hextab
    ADRP x7, hextab
    ADD  x7, x7, :lo12:hextab
    LDRB w5, [x7, w5, UXTW]   // hextab[hi]
    LDRB w6, [x7, w6, UXTW]   // hextab[lo]

    // x8 = &hexbuf2
    ADRP x8, hexbuf2
    ADD  x8, x8, :lo12:hexbuf2
    STRB w5, [x8]
    STRB w6, [x8, #1]
    RET
    .size hex_byte_to_ascii, (. - hex_byte_to_ascii)


// ------------------------------------------------------------
// void printHexByte(uint32_t w0_byte)
// Entrada: w0 = byte (0..255) a imprimir en HEX mayúsculas, seguido de un espacio.
// Efecto: write(1, "HH ", 3)
    .global printHexByte
    .type   printHexByte, %function
printHexByte:
    // Asegurar byte
    and     w0, w0, #0xFF

    // nibbles
    ubfx    w1, w0, #4, #4         // hi
    and     w2, w0, #0x0F          // lo

    // hi -> ASCII
    cmp     w1, #9
    ble     1f
    add     w1, w1, #('A' - 10)
    b       2f
1:  add     w1, w1, #'0'
2:
    // lo -> ASCII
    cmp     w2, #9
    ble     3f
    add     w2, w2, #('A' - 10)
    b       4f
3:  add     w2, w2, #'0'
4:
    // Guardar "HH "
    adrp    x10, hex_out_buf
    add     x10, x10, :lo12:hex_out_buf
    strb    w1, [x10]
    strb    w2, [x10, #1]
    mov     w3, #' '
    strb    w3, [x10, #2]

    // write(1, hex_out_buf, 3)
    mov     x0, #1
    mov     x1, x10
    mov     x2, #3
    mov     x8, #64
    svc     #0
    ret
    .size printHexByte, (. - printHexByte)


// -------------------- Datos auxiliares ----------------------
    .data
hextab:
    .ascii "0123456789ABCDEF"

hex_space:      .ascii " "
hex_newline:    .ascii "\n"
hex_head_open:  .ascii ""
hex_head_close: .ascii ""

    .set hex_head_open_len,  0
    .set hex_head_close_len, 0

    .bss
    .balign 2
hexbuf2:
    .space 2, 0

hex_out_buf:
    .space 3, 0