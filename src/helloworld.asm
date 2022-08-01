.include "constants.inc"
.include "header.inc"
 
.segment "CODE"     ; CODE is all program code
.proc irq_handler
    RTI
.endproc

.proc nmi_handler
    RTI
.endproc

.import reset_handler

.export main
.proc main

    ; Setup PPUADDR to write to the first color of the first pallet
    LDX PPUSTATUS       ; Read PPUSTATUS, this resets PPUADDR so we can write both bytes
    LDX #$3f            ; Load high byte
    STX PPUADDR         ; Store into PPUADDR
    LDX #$00            ; Load the low byte
    STX PPUADDR         ; Store into PPUADDR

    ; Now write the color that we want to the PPUDATA
    LDA #$29            ; The code for the color into the accumulator
    STA PPUDATA         ; Write the color to the PPUDATA
                        ; this will automatically increment the memaddr in PPUADDR
                        ; so PPUADDR will now point to 3F01, the next position
                        ; in the color palette table

    LDA #%00011110      ; enable back/fore/groud colors for the whole screen
    STA PPUMASK         ; Store it in PPUMASK

; create an endless loop
forever:
    JMP forever
.endproc

.segment "VECTORS"  ; Special code that goes at the end of the program rom
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"    ; Character rom
.res 8192           ; Reserves 8192 bytes of memory
