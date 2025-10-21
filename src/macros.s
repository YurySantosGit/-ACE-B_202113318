// =============================================
// MACROS.S - Macros para operaciones comunes
// =============================================

// =============================================
// MACRO: IMPRIMIR CADENA
// =============================================
.macro print stdout, buffer, length
    mov x0, \stdout          // File descriptor (1 = stdout)
    ldr x1, =\buffer         // Dirección del buffer
    mov x2, \length          // Longitud del mensaje
    mov x8, #64              // Syscall write
    svc #0                   // Llamar al sistema
.endm

// =============================================
// MACRO: LEER ENTRADA
// =============================================
.macro read stdin, buffer, length
    mov x0, \stdin           // File descriptor (0 = stdin)
    ldr x1, =\buffer         // Dirección del buffer
    mov x2, \length          // Longitud máxima a leer
    mov x8, #63              // Syscall read
    svc #0                   // Llamar al sistema
.endm

// =============================================
// MACRO: VERIFICAR BYTES DISPONIBLES
// =============================================
.macro bytesAvailable buffer
    mov x0, #0               // STDIN_FILENO
    mov x1, #21531           // FIONREAD
    ldr x2, =\buffer         // Donde guardar el resultado
    mov x8, #29              // Syscall ioctl
    svc #0
.endm

// =============================================
// MACRO: SALIR DEL PROGRAMA
// =============================================
.macro exit status
    mov x0, \status          // Código de salida
    mov x8, #93              // Syscall exit
    svc #0
.endm