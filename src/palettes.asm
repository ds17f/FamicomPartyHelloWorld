.include "constants.inc"

.segment "CODE"
.export init_palettes
.proc init_palettes
        ; preserve registers to stack
        PHP
        PHA
        TXA
        PHA
        TYA
        PHA

        ; Set the PPUADDR up to point to the pallets ($3f00)
        ; PPUADDR will automatically INC after each write to PPUDAT
        ; this allows next bytes of palette data to be written
        ; without resetting PPUADDR
        LDX PPUSTATUS       ; Read PPUSTATUS, this resets PPUADDR so we can write both bytes
        LDX #$3f            ; Load high byte
        STX PPUADDR         ; Store into PPUADDR
        LDX #$00            ; Load the low byte
        STX PPUADDR         ; Store into PPUADDR

        LDX #$00
    load_palettes:
        LDA palettes, X         ; load the pallet color with offest
        STA PPUDATA             ; store it in the PPU and auto increment store location
        INX                     ; increment the X reg
        CPX #$20                ; set flags
        BNE load_palettes       ; branch if Zero flag unset, we are not at 4 yet

        LDX #$00

        ; restore the registers from stack
        PLA
        TAY
        PLA
        TAX
        PLA
        PLP
        
        RTS
.endproc


.segment "RODATA" 
palettes:
; background_palettes
.byte $0f, $12, $23, $27
.byte $0f, $2b, $3c, $39
.byte $0f, $0c, $07, $13
.byte $0f, $19, $09, $29

; sprit palettes
.byte $0f, $2d, $10, $15
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29
