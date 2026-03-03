Load R1, N
Load R2, =NUMBERS
Load R3, clear

Loop: Beq R1, DONE

Load R4, (R2)
Bgt R4, SKIP
Beq R4, SKIP
Addi R3, R3, 1

SKIP: Addi R2, R2, 4
Subi R1, R1, 1
Br LOOP

DONE: Store R3, NEGNUM
Halt

N: .WORD 6

NEGNUM: .WORD 0

NUMBERS:
.WORD 1
.WORD 2
.WORD -3
.WORD -4
.WORD 5
.WORD -6