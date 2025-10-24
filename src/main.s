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

msg_title:    .asciz "\n=== PROCESAMIENTO AES (hasta ROUND 8 + FINAL BS/SR/ARK) ===\n"
len_title = . - msg_title

msg_state_o:  .asciz "Matriz de Estado ORIGINAL (column-major):\n"
len_state_o = . - msg_state_o

msg_key_o:    .asciz "\nMatriz de Clave ORIGINAL (column-major):\n"
len_key_o = . - msg_key_o

msg_round:    .asciz "\n--- ROUND "
len_round = . - msg_round
msg_round_end:.asciz " ---\n"
len_round_end = . - msg_round_end

msg_ark:      .asciz "AddRoundKey:\n"
len_ark = . - msg_ark

msg_bs:       .asciz "ByteSub:\n"
len_bs = . - msg_bs

msg_sr:       .asciz "ShiftRows:\n"
len_sr = . - msg_sr

msg_mc:       .asciz "MixColumns:\n"
len_mc = . - msg_mc

msg_stop:     .asciz "\n=== HASTA ROUND 8 ===\n"
len_stop = . - msg_stop

msg_final_hdr:.asciz "\n--- ROUND FINAL --- \nByteSub:\n"
len_final_hdr = . - msg_final_hdr

msg_final_txt:.asciz "\n=== TEXTO ENCRIPTADO FINAL ===\n"
len_final_txt = . - msg_final_txt

nl:           .asciz "\n"

    .bss
    .align 4
bufferTxt:    .space 16, 0
bufferKey:    .space 16, 0
dummy:        .space 8, 0
state:        .space 16, 0
key:          .space 16, 0

    .text
    .global _start
    .type   _start, %function
_start:
    // Leer texto
    print 1, msg_in_txt, len_in_txt
    read  0, bufferTxt, #16
flush_txt:
    read 0, dummy, #1
    bytesAvailable dummy
    ldr  x2, =dummy
    ldr  x2, [x2]
    cbnz x2, flush_txt

    // Leer clave
    print 1, msg_in_key, len_in_key
    read  0, bufferKey, #16
flush_key:
    read 0, dummy, #1
    bytesAvailable dummy
    ldr  x2, =dummy
    ldr  x2, [x2]
    cbnz x2, flush_key

    // Título
    print 1, msg_title, len_title

    // Preparar matrices en column-major
    adr  x0, bufferTxt
    adr  x1, state
    bl   toMatrixColMajor

    adr  x0, bufferKey
    adr  x1, key
    bl   toMatrixColMajor

    // Imprimir originales
    print 1, msg_state_o, len_state_o
    adr  x0, state
    bl   printMatrix

    print 1, msg_key_o, len_key_o
    adr  x0, key
    bl   printMatrix

    // --------------------------
    // ROUND 0 — bloque 1 (ARK con K0)
    // --------------------------
    print 1, msg_round, len_round
    adr  x1, dummy
    mov  w0, #'0'
    strb w0, [x1]
    print 1, dummy, 1
    print 1, msg_round_end, len_round_end

    print 1, msg_ark, len_ark
    adr  x0, state
    adr  x1, key          // K0
    bl   addRoundKey
    adr  x0, state
    bl   printMatrix

    // --------------------------------------------
    // ROUND 0 — bloque 2: BS → SR → MC → ARK con K1  (keyExpansion round=0)
    // --------------------------------------------
    print 1, msg_round, len_round
    adr  x1, dummy
    mov  w0, #'0'
    strb w0, [x1]
    print 1, dummy, 1
    print 1, msg_round_end, len_round_end

    // BS
    print 1, msg_bs, len_bs
    adr  x0, state
    bl   byteSub
    adr  x0, state
    bl   printMatrix

    // SR
    print 1, msg_sr, len_sr
    adr  x0, state
    bl   shiftRows
    adr  x0, state
    bl   printMatrix

    // MC
    print 1, msg_mc, len_mc
    adr  x0, state
    bl   mixColumns
    adr  x0, state
    bl   printMatrix

    // keyExpansion: round=0 → K1
    adr  x0, key
    mov  w1, #0
    bl   keyExpansion

    // ARK con K1
    print 1, msg_ark, len_ark
    adr  x0, state
    adr  x1, key
    bl   addRoundKey
    adr  x0, state
    bl   printMatrix

    // --------------------------------------------
    // ROUND 1 — (BS → SR → MC → ARK con K2) [keyExpansion round=1]
    // --------------------------------------------
    print 1, msg_round, len_round
    adr  x1, dummy
    mov  w0, #'1'
    strb w0, [x1]
    print 1, dummy, 1
    print 1, msg_round_end, len_round_end

    // BS
    print 1, msg_bs, len_bs
    adr  x0, state
    bl   byteSub
    adr  x0, state
    bl   printMatrix

    // SR
    print 1, msg_sr, len_sr
    adr  x0, state
    bl   shiftRows
    adr  x0, state
    bl   printMatrix

    // MC
    print 1, msg_mc, len_mc
    adr  x0, state
    bl   mixColumns
    adr  x0, state
    bl   printMatrix

    // keyExpansion: round=1 → K2
    adr  x0, key
    mov  w1, #1
    bl   keyExpansion

    // ARK con K2
    print 1, msg_ark, len_ark
    adr  x0, state
    adr  x1, key
    bl   addRoundKey
    adr  x0, state
    bl   printMatrix

    // --------------------------------------------
    // ROUND 2 — (BS → SR → MC → ARK con K3) [keyExpansion round=2]
    // --------------------------------------------
    print 1, msg_round, len_round
    adr  x1, dummy
    mov  w0, #'2'
    strb w0, [x1]
    print 1, dummy, 1
    print 1, msg_round_end, len_round_end

    // BS
    print 1, msg_bs, len_bs
    adr  x0, state
    bl   byteSub
    adr  x0, state
    bl   printMatrix

    // SR
    print 1, msg_sr, len_sr
    adr  x0, state
    bl   shiftRows
    adr  x0, state
    bl   printMatrix

    // MC
    print 1, msg_mc, len_mc
    adr  x0, state
    bl   mixColumns
    adr  x0, state
    bl   printMatrix

    // keyExpansion: round=2 → K3
    adr  x0, key
    mov  w1, #2
    bl   keyExpansion

    // ARK con K3
    print 1, msg_ark, len_ark
    adr  x0, state
    adr  x1, key
    bl   addRoundKey
    adr  x0, state
    bl   printMatrix

    // --------------------------------------------
    // ROUND 3 — (BS → SR → MC → ARK con K4) [keyExpansion round=3]
    // --------------------------------------------
    print 1, msg_round, len_round
    adr  x1, dummy
    mov  w0, #'3'
    strb w0, [x1]
    print 1, dummy, 1
    print 1, msg_round_end, len_round_end

    // BS
    print 1, msg_bs, len_bs
    adr  x0, state
    bl   byteSub
    adr  x0, state
    bl   printMatrix

    // SR
    print 1, msg_sr, len_sr
    adr  x0, state
    bl   shiftRows
    adr  x0, state
    bl   printMatrix

    // MC
    print 1, msg_mc, len_mc
    adr  x0, state
    bl   mixColumns
    adr  x0, state
    bl   printMatrix

    // keyExpansion: round=3 → K4
    adr  x0, key
    mov  w1, #3
    bl   keyExpansion

    // ARK con K4
    print 1, msg_ark, len_ark
    adr  x0, state
    adr  x1, key
    bl   addRoundKey
    adr  x0, state
    bl   printMatrix

    // --------------------------------------------
    // ROUND 4 — (BS → SR → MC → ARK con K5) [keyExpansion round=4]
    // --------------------------------------------
    print 1, msg_round, len_round
    adr  x1, dummy
    mov  w0, #'4'
    strb w0, [x1]
    print 1, dummy, 1
    print 1, msg_round_end, len_round_end

    // BS
    print 1, msg_bs, len_bs
    adr  x0, state
    bl   byteSub
    adr  x0, state
    bl   printMatrix

    // SR
    print 1, msg_sr, len_sr
    adr  x0, state
    bl   shiftRows
    adr  x0, state
    bl   printMatrix

    // MC
    print 1, msg_mc, len_mc
    adr  x0, state
    bl   mixColumns
    adr  x0, state
    bl   printMatrix

    // keyExpansion: round=4 → K5
    adr  x0, key
    mov  w1, #4
    bl   keyExpansion

    // ARK con K5
    print 1, msg_ark, len_ark
    adr  x0, state
    adr  x1, key
    bl   addRoundKey
    adr  x0, state
    bl   printMatrix

    // --------------------------------------------
    // ROUND 5 — (BS → SR → MC → ARK con K6) [keyExpansion round=5]
    // --------------------------------------------
    print 1, msg_round, len_round
    adr  x1, dummy
    mov  w0, #'5'
    strb w0, [x1]
    print 1, dummy, 1
    print 1, msg_round_end, len_round_end

    // BS
    print 1, msg_bs, len_bs
    adr  x0, state
    bl   byteSub
    adr  x0, state
    bl   printMatrix

    // SR
    print 1, msg_sr, len_sr
    adr  x0, state
    bl   shiftRows
    adr  x0, state
    bl   printMatrix

    // MC
    print 1, msg_mc, len_mc
    adr  x0, state
    bl   mixColumns
    adr  x0, state
    bl   printMatrix

    // keyExpansion: round=5 → K6
    adr  x0, key
    mov  w1, #5
    bl   keyExpansion

    // ARK con K6
    print 1, msg_ark, len_ark
    adr  x0, state
    adr  x1, key
    bl   addRoundKey
    adr  x0, state
    bl   printMatrix

    // --------------------------------------------
    // ROUND 6 — (BS → SR → MC → ARK con K7) [keyExpansion round=6]
    // --------------------------------------------
    print 1, msg_round, len_round
    adr  x1, dummy
    mov  w0, #'6'
    strb w0, [x1]
    print 1, dummy, 1
    print 1, msg_round_end, len_round_end

    // BS
    print 1, msg_bs, len_bs
    adr  x0, state
    bl   byteSub
    adr  x0, state
    bl   printMatrix

    // SR
    print 1, msg_sr, len_sr
    adr  x0, state
    bl   shiftRows
    adr  x0, state
    bl   printMatrix

    // MC
    print 1, msg_mc, len_mc
    adr  x0, state
    bl   mixColumns
    adr  x0, state
    bl   printMatrix

    // keyExpansion: round=6 → K7
    adr  x0, key
    mov  w1, #6
    bl   keyExpansion

    // ARK con K7
    print 1, msg_ark, len_ark
    adr  x0, state
    adr  x1, key
    bl   addRoundKey
    adr  x0, state
    bl   printMatrix

    // --------------------------------------------
    // ROUND 7 — (BS → SR → MC → ARK con K8) [keyExpansion round=7]
    // --------------------------------------------
    print 1, msg_round, len_round
    adr  x1, dummy
    mov  w0, #'7'
    strb w0, [x1]
    print 1, dummy, 1
    print 1, msg_round_end, len_round_end

    // BS
    print 1, msg_bs, len_bs
    adr  x0, state
    bl   byteSub
    adr  x0, state
    bl   printMatrix

    // SR
    print 1, msg_sr, len_sr
    adr  x0, state
    bl   shiftRows
    adr  x0, state
    bl   printMatrix

    // MC
    print 1, msg_mc, len_mc
    adr  x0, state
    bl   mixColumns
    adr  x0, state
    bl   printMatrix

    // keyExpansion: round=7 → K8
    adr  x0, key
    mov  w1, #7
    bl   keyExpansion

    // ARK con K8
    print 1, msg_ark, len_ark
    adr  x0, state
    adr  x1, key
    bl   addRoundKey
    adr  x0, state
    bl   printMatrix

    // --------------------------------------------
    // ROUND 8 — (BS → SR → MC → ARK con K9) [keyExpansion round=8]
    // --------------------------------------------
    print 1, msg_round, len_round
    adr  x1, dummy
    mov  w0, #'8'
    strb w0, [x1]
    print 1, dummy, 1
    print 1, msg_round_end, len_round_end

    // BS
    print 1, msg_bs, len_bs
    adr  x0, state
    bl   byteSub
    adr  x0, state
    bl   printMatrix

    // SR
    print 1, msg_sr, len_sr
    adr  x0, state
    bl   shiftRows
    adr  x0, state
    bl   printMatrix

    // MC
    print 1, msg_mc, len_mc
    adr  x0, state
    bl   mixColumns
    adr  x0, state
    bl   printMatrix

    // keyExpansion: round=8 → K9
    adr  x0, key
    mov  w1, #8
    bl   keyExpansion

    // ARK con K9
    print 1, msg_ark, len_ark
    adr  x0, state
    adr  x1, key
    bl   addRoundKey
    adr  x0, state
    bl   printMatrix

    // ================================
    //   FINAL: ByteSub → ShiftRows → AddRoundKey(K10)
    // ================================
    print 1, msg_final_hdr, len_final_hdr
    // ByteSub final
    adr  x0, state
    bl   byteSub
    adr  x0, state
    bl   printMatrix

    // ShiftRows final
    print 1, msg_sr, len_sr
    adr  x0, state
    bl   shiftRows
    adr  x0, state
    bl   printMatrix

    // Generar K10: keyExpansion round=9
    adr  x0, key
    mov  w1, #9
    bl   keyExpansion

    // AddRoundKey final con K10
    print 1, msg_ark, len_ark
    adr  x0, state
    adr  x1, key
    bl   addRoundKey
    adr  x0, state
    bl   printMatrix

    print 1, msg_final_txt, len_final_txt
    adr  x0, state
    bl   printMatrix

    // exit(0)
    mov  x0, #0
    mov  x8, #93
    svc  #0
