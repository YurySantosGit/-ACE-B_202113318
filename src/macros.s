
.macro print stdout, reg, len
    MOV x0, \stdout
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, #64
    SVC #0
.endm

.macro read stdin, buffer, len
    MOV x0, \stdin
    LDR x1, =\buffer
    MOV x2, \len
    MOV x8, #63
    SVC #0
.endm

.macro bytesAvailable value
    MOV x0, #0
    MOV x1, #21531
    LDR x2, =\value
    MOV x8, #29
    SVC #0
.endm
