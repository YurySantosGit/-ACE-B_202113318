// Prueba Hito 0 → Round 0 completo paso a paso:
// - Lectura de 16+16 chars
// - Mapeo column-major
// - Impresiones
// - AddRoundKey (clave original)
// - ByteSub (test)
// - ShiftRows (test)
// - MixColumns (test)
// - keyExpansion(round=0) + AddRoundKey (subclave de ronda 1)

    .include "macros.s"

    .extern toMatrixColMajor
    .extern printMatrix
    .extern addRoundKey
    .extern byteSub
    .extern shiftRows
    .extern mixColumns
    .extern keyExpansion

    .data
msg_in_txt:   .asciz "Ingrese matriz de estado de texto (16 caracteres): "
len_in_txt = . - msg_in_txt

msg_in_key:   .asciz "Ingrese clave de texto (16 caracteres): "
len_in_key = . - msg_in_key

msg_title:    .asciz "\n=== PROCESAMIENTO AES (Round 0 test) ===\n"
len_title = . - msg_title

msg_state_o:  .asciz "Matriz de Estado ORIGINAL (column-major):\n"
len_state_o = . - msg_state_o

msg_key_o:    .asciz "\nMatriz de Clave ORIGINAL (column-major):\n"
len_key_o = . - msg_key_o

msg_ark0:     .asciz "\n--- ROUND 0 ---\nAddRoundKey:\n"
len_ark0 = . - msg_ark0

// Mensajes temporales de prueba
msg_tmp_bs:   .asciz "\n--- ByteSub (test) ---\n"
len_tmp_bs = . - msg_tmp_bs

msg_tmp_sr:   .asciz "\n--- ShiftRows (test) ---\n"
len_tmp_sr = . - msg_tmp_sr

msg_tmp_mc:   .asciz "\n--- MixColumns (test) ---\n"
len_tmp_mc = . - msg_tmp_mc

msg_ark1:     .asciz "\nAddRoundKey (con subclave de ronda 1):\n"
len_ark1 = . - msg_ark1

nl:           .asciz "\n"

    .bss
    .align 4
bufferTxt:    .space 16, 0
bufferKey:    .space 16, 0
dummy:        .space 8, 0
matState:     .space 16, 0
key:          .space 16, 0

    .text
    .global _start
    .type   _start, %function
_start:
    // ---- leer CADENA (16) ----
    print 1, msg_in_txt, len_in_txt
    read  0, bufferTxt, #16

    // limpiar stdin si quedó basura (usar bytesAvailable del auxiliar)
flush_txt:
    read 0, dummy, #1
    bytesAvailable dummy
    ldr  x2, =dummy
    ldr  x2, [x2]
    cbnz x2, flush_txt

    // ---- leer CLAVE (16) ----
    print 1, msg_in_key, len_in_key
    read  0, bufferKey, #16

flush_key:
    read 0, dummy, #1
    bytesAvailable dummy
    ldr  x2, =dummy
    ldr  x2, [x2]
    cbnz x2, flush_key

    // ---- título ----
    print 1, msg_title, len_title

    // ---- a Column-Major: bufferTxt -> matState ----
    adr  x0, bufferTxt
    adr  x1, matState
    bl   toMatrixColMajor

    // ---- a Column-Major: bufferKey -> key ----
    adr  x0, bufferKey
    adr  x1, key
    bl   toMatrixColMajor

    // ---- imprimir originales ----
    print 1, msg_state_o, len_state_o
    adr  x0, matState
    bl   printMatrix

    print 1, msg_key_o, len_key_o
    adr  x0, key
    bl   printMatrix

    // ---- Round 0: AddRoundKey inicial ----
    print 1, msg_ark0, len_ark0
    adr  x0, matState
    adr  x1, key
    bl   addRoundKey

    adr  x0, matState
    bl   printMatrix

    // ======= BLOQUE TEMPORAL: ByteSub (test) =======
    // Esperado:
    // 77 20 7B 1B
    // 15 50 EF 36
    // 07 C5 67 FD
    // C3 F3 5B 7D
    print 1, msg_tmp_bs, len_tmp_bs
    adr  x0, matState
    bl   byteSub

    adr  x0, matState
    bl   printMatrix
    // ======= FIN BLOQUE TEMPORAL =======

    // ======= BLOQUE TEMPORAL: ShiftRows (test) =======
    // Esperado:
    // 77 20 7B 1B
    // 50 EF 36 15
    // 67 FD 07 C5
    // 7D C3 F3 5B
    print 1, msg_tmp_sr, len_tmp_sr
    adr  x0, matState
    bl   shiftRows

    adr  x0, matState
    bl   printMatrix
    // ======= FIN BLOQUE TEMPORAL =======

    // ======= BLOQUE TEMPORAL: MixColumns (test) =======
    // Esperado:
    // 04 54 58 97
    // 03 3A ED 3E
    // 6E 70 4D 72
    // 54 EF 41 4B
    print 1, msg_tmp_mc, len_tmp_mc
    adr  x0, matState
    bl   mixColumns

    adr  x0, matState
    bl   printMatrix
    // ======= FIN BLOQUE TEMPORAL =======

    // ======= Generar subclave de ronda 1 y aplicar AddRoundKey =======
    // Esperado tras este AddRoundKey:
    // D4 E1 DC 7A
    // E0 98 7D DA
    // F2 A9 AC E0
    // DB 33 FF D4
    print 1, msg_ark1, len_ark1

    // keyExpansion(key, round=0)
    adr  x0, key
    mov  w1, #0
    bl   keyExpansion

    // state ^= roundKey1
    adr  x0, matState
    adr  x1, key
    bl   addRoundKey

    // imprimir estado
    adr  x0, matState
    bl   printMatrix

    // ---- exit(0) ----
    mov  x0, #0
    mov  x8, #93        // SYS_exit
    svc  #0