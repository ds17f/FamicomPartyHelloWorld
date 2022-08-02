.include "constants.inc"
.include "header.inc"
 
.segment "CODE"     ; CODE is all program code
.proc irq_handler
    RTI
.endproc

.proc nmi_handler
    ; Prepare to transfer to OAM at byte 0
    LDA #$00
    STA OAMADDR

    ; transfer the 256 bytes of data at $0200 - $02FF
    LDA #$02
    STA OAMDMA

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

    ; Now write the colors for that palette
    LDA #$29            ; The code for the color into the accumulator
    STA PPUDATA         ; Write the color to the PPUDATA
                        ; this will automatically increment the memaddr in PPUADDR
                        ; so PPUADDR will now point to 3F01, the next position
                        ; in the color palette table
    LDA #$19
    STA PPUDATA
    LDA #$09
    STA PPUDATA
    LDA #$0f
    STA PPUDATA

    ; Now write some sprite data
    LDA #$70
    STA $0200           ; y-coord of first sprite
    LDA #$05
    STA $0201           ; tile number of the first sprite
    LDA #$00
    STA $0202           ; special flags for the sprite
    LDA #$80
    STA $0203           ; x-coord of first sprite

    
vblankwait:             ; wait for another vblank before continuing
    BIT PPUSTATUS
    BPL vblankwait

    LDA #%10010000      ; turn on NMIs, sprites use first pattern table
    STA PPUCTRL

    LDA #%00011110      ; enable back/fore/groud colors for the whole screen
    STA PPUMASK

; create an endless loop
forever:
    JMP forever
.endproc

.segment "VECTORS"  ; Special code that goes at the end of the program rom
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"          ; Character rom
.incbin "graphics.chr"  ; load the graphics as binary
