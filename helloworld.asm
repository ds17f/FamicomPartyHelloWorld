.segment "HEADER"   ; HEADER is information which tells an emulator what chips are in the cartridge
.byte $4e, $45, $53, $1a, $02, $01, $00, $00

.segment "CODE"     ; CODE is all program code
.proc irq_handler
    RTI
.endproc

.proc nmi_handler
    RTI
.endproc

.proc reset_handler
    SEI
    CLD
    LDX #$00
    STX $2000
    STX $2001
vblankwait:
    BIT $2002
    BPL vblankwait
    JMP main
.endproc

.proc main

    ; Setup PPUADDR to write to the first color of the first pallet
    LDX $2002       ; Read PPUSTATUS, this resets PPUADDR so we can write both bytes
    LDX #$3f        ; Load high byte
    STX $2006       ; Store into PPUADDR
    LDX #$00        ; Load the low byte
    STX $2006       ; Store into PPUADDR

    ; Now write the color that we want to the PPUDATA
    LDA #$29        ; The code for the color into the accumulator
    STA $2007       ; Write the color to the PPUDATA
                    ; this will automatically increment the memaddr in PPUADDR
                    ; so PPUADDR will now point to 3F01, the next position
                    ; in the color palette table

    LDA #%00011110  ; enable back/fore/groud colors for the whole screen
    STA $2001       ; Store it in PPUMASK

; create an endless loop
forever:
    JMP forever
.endproc

.segment "VECTORS"  ; Special code that goes at the end of the program rom
.addr nmi_handler, reset_handler, irq_handler

.segment "CHARS"    ; Character rom
.res 8192           ; Reserves 8192 bytes of memory

.segment "STARTUP"
