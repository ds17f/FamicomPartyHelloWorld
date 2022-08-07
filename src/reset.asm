.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y

.segment "CODE"

.import main

.export reset_handler
.proc reset_handler
    SEI
    CLD
    LDX #$00
    STX PPUCTRL
    STX PPUMASK

; hide all sprites off screen to prevent artifacting
    LDX #$00
    LDA #$ff
clear_oam:
    STA SPRITE_PAGE,X
    INX ; there are 4 bytes in sprite data
    INX
    INX
    INX
    BNE clear_oam
vblankwait:
    BIT PPUSTATUS
    BPL vblankwait

    ; init player X/Y
    LDA #$80
    STA player_x
    LDA #$a0
    STA player_y

    JMP main
.endproc
