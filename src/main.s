// main.s — AES-128 completo (10 rondas) con salida verbose.
// Pipeline:
//  - Round 0: AddRoundKey (clave original)
//  - Rounds 1..9: ByteSub → ShiftRows → MixColumns → RK(r) → AddRoundKey
//  - Round 10:   ByteSub → ShiftRows → RK(9)     → AddRoundKey   (sin MixColumns)

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

msg_title:    .asciz "\n=== PROCESAMIENTO AES (10 ROUNDS) ===\n"
len_title = . - msg_title

msg_state_o:  .asciz "Matriz de Estado ORIGINAL (column-major):\n"
len_state_o = . - msg_state_o

msg_key_o:    .asciz "\nMatriz de Clave ORIGINAL (column-major):\n"
len_key_o = . - msg_key_o

msg_r0_ark:   .asciz "\n--- ROUND 0 ---\nAddRoundKey:\n"
len_r0_ark = . - msg_r0_ark

msg_bs:       .asciz "\nByteSub:\n"
len_bs = . - msg_bs

msg_sr:       .asciz "ShiftRows:\n"
len_sr = . - msg_sr

msg_mc:       .asciz "MixColumns:\n"
len_mc = . - msg_mc

msg_ark:      .asciz "AddRoundKey:\n"
len_ark = . - msg_ark

msg_r_prefix: .asciz "\n--- ROUND "
len_r_prefix = . - msg_r_prefix

msg_r_suffix: .asciz " ---\n"
len_r_suffix = . - msg_r_suffix

msg_final:    .asciz "\n=== TEXTO ENCRIPTADO FINAL ===\n"
len_final = . - msg_final

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

    // ---- a Column-Major ----
    adr  x0, bufferTxt
    adr  x1, matState
    bl   toMatrixColMajor

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

    // ---- ROUND 0: AddRoundKey inicial ----
    print 1, msg_r0_ark, len_r0_ark
    adr  x0, matState
    adr  x1, key
    bl   addRoundKey

    adr  x0, matState
    bl   printMatrix

    // ----- Rounds 1..9 -----
    // Usamos w19 como contador de ronda (1..9). Para keyExpansion:
    //   Rcon index = round-1  → w1 = w19 - 1
    mov  w19, #1

round_loop_1_9:
    cmp  w19, #10
    b.ge after_rounds_1_9

    // Imprimir cabecera de ronda: "\n--- ROUND %d ---\n"
    print 1, msg_r_prefix, len_r_prefix
    // Imprimir número de ronda (simple): convertimos 1..9 a ASCII
    // w19 en [1..9], lo pasamos a char
    mov  w0, w19
    add  w0, w0, #'0'
    // buffer temporal: reutilizamos 'dummy' para 1 char
    adr  x1, dummy
    strb w0, [x1]
    print 1, dummy, 1
    print 1, msg_r_suffix, len_r_suffix

    // ByteSub
    print 1, msg_bs, len_bs
    adr  x0, matState
    bl   byteSub
    adr  x0, matState
    bl   printMatrix

    // ShiftRows
    print 1, msg_sr, len_sr
    adr  x0, matState
    bl   shiftRows
    adr  x0, matState
    bl   printMatrix

    // MixColumns
    print 1, msg_mc, len_mc
    adr  x0, matState
    bl   mixColumns
    adr  x0, matState
    bl   printMatrix

    // keyExpansion para esta ronda: w1 = round-1
    adr  x0, key
    mov  w1, w19
    sub  w1, w1, #1
    bl   keyExpansion

    // AddRoundKey
    print 1, msg_ark, len_ark
    adr  x0, matState
    adr  x1, key
    bl   addRoundKey
    adr  x0, matState
    bl   printMatrix

    // siguiente ronda
    add  w19, w19, #1
    b    round_loop_1_9

after_rounds_1_9:
    // ---- ROUND 10 (sin MixColumns) ----
    // Cabecera
    print 1, msg_r_prefix, len_r_prefix
    // imprimir "10"
    adr  x1, dummy
    mov  w0, #'1'
    strb w0, [x1]
    mov  w0, #'0'
    strb w0, [x1, #1]
    print 1, dummy, 2
    print 1, msg_r_suffix, len_r_suffix

    // ByteSub
    print 1, msg_bs, len_bs
    adr  x0, matState
    bl   byteSub
    adr  x0, matState
    bl   printMatrix

    // ShiftRows
    print 1, msg_sr, len_sr
    adr  x0, matState
    bl   shiftRows
    adr  x0, matState
    bl   printMatrix

    // keyExpansion para round 10: w1 = 9
    adr  x0, key
    mov  w1, #9
    bl   keyExpansion

    // AddRoundKey
    print 1, msg_ark, len_ark
    adr  x0, matState
    adr  x1, key
    bl   addRoundKey
    adr  x0, matState
    bl   printMatrix

    // ---- Final ----
    print 1, msg_final, len_final
    adr  x0, matState
    bl   printMatrix

    // exit(0)
    mov  x0, #0
    mov  x8, #93
    svc  #0
