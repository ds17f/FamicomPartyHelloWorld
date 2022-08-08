.include "constants.inc"
.include "header.inc"

.segment "CODE"     ; CODE is all program code
.proc irq_handler
    RTI
.endproc

; player routines
.import update_player
.import draw_player

.proc nmi_handler
    ; Prepare to transfer to OAM at byte 0
    LDA #$00
    STA OAMADDR
    ; transfer the 256 bytes of data at $0200 - $02FF
    LDA #$02
    STA OAMDMA

    JSR update_player
    JSR draw_player

    ; set scrolling window to 0,0
    ; https://www.nesdev.org/wiki/PPU_scrolling
    LDA #$00
    STA PPUSCROLL
    STA PPUSCROLL

    RTI
.endproc

.import reset_handler
.import init_palettes
.import load_nametables

.export main
.proc main

    JSR init_palettes
    JSR load_nametables
        
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
.incbin "starfield.chr"  ; load the graphics as binary
