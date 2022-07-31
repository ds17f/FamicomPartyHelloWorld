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

    LDX $2002
    LDX #$3f
    STX $2006

    LDX #$00
    STX $2006

    LDA #$29    ; The code for the color into the accumulator
    STA $2007   ; Write the color to the /

    LDA #%00011110
    STA $2001

forever:
    JMP forever
.endproc

.segment "VECTORS"  ; Special code that goes at the end of the program rom
.addr nmi_handler, reset_handler, irq_handler

.segment "CHARS"    ; Character rom
.res 8192           ; Reserves 8192 bytes of memory

.segment "STARTUP"
