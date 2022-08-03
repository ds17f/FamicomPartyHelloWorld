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

    LDX #$00
load_palettes:
    LDA palettes, X         ; load the pallet color with offest
    STA PPUDATA             ; store it in the PPU and auto increment store location
    INX                     ; increment the X reg
    CPX #$04                ; set flags
    BNE load_palettes       ; branch if Zero flag unset, we are not at 4 yet

    LDX #$00
load_sprites:
    ; Now write some sprite data
    LDA sprites,X
    STA $0200,X             ; Here we write to an indexed memory location which is equally offset
    INX
    CPX #$04
    BNE load_sprites

    
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

.segment "RODATA"       ; Read Only Data
palettes:
.byte $29, $19, $09, $0f

sprites:
.byte $70, $05, $00, $80
