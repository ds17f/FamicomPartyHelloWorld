.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
ppuctrl_settings: .res 1
.importzp _nt_hi_byte_0, _atr_page, scroll

.segment "CODE"     ; CODE is all program code
.proc irq_handler
    RTI
.endproc

; player routines
.import read_joypad_1
.import update_player
.import draw_player

.proc nmi_handler
    ; Prepare to transfer to OAM at byte 0
    LDA #$00
    STA OAMADDR
    ; transfer the 256 bytes of data at $0200 - $02FF
    LDA #$02
    STA OAMDMA

    JSR read_joypad_1
    JSR update_player
    JSR draw_player

    JSR scroll_background

    RTI
.endproc

.proc scroll_background
    
    LDA scroll
    CMP #Y_TOP                  ; has scrolling reached the top?
    BNE update_positions        ; if not, skip the nametable swap
    ; if yes, update nametable
    LDA ppuctrl_settings
    EOR #%00000010          ; XOR the bit for the vertical nametable
                            ; this will swap it to the other one
    STA ppuctrl_settings
    STA PPUCTRL
    LDA #Y_BOTTOM
    STA scroll

    update_positions:
        LDA #00
        STA PPUSCROLL   ; set x scroll

        DEC scroll      ; move scrolling down 1 pixel
        LDA scroll
        STA PPUSCROLL   ; set y scroll

    RTS
.endproc

.import reset_handler
.import init_palettes
.import init_nametables

.export main
.proc main

    JSR init_palettes

    JSR init_nametables
        
    vblankwait:             ; wait for another vblank before continuing
        BIT PPUSTATUS
        BPL vblankwait

        LDA #%10010000      ; turn on NMIs, sprites use first pattern table
        STA ppuctrl_settings
        STA PPUCTRL

        LDA #%00011110      ; enable back/fore/groud colors for the whole screen
        STA PPUMASK

    ; create an endless loop
    forever:
        JMP forever
.endproc

.segment "VECTORS"  ; Special code that goes at the end of the program rom
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"              ; Character rom
.incbin "scrolling.chr"     ; load the graphics as binary
