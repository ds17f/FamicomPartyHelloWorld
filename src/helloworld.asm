.include "constants.inc"
.include "header.inc"
 
.segment "CODE"     ; CODE is all program code
.proc irq_handler
    RTI
.endproc

.proc nmi_handler
    ; ; Prepare to transfer to OAM at byte 0
    ; LDA #$00
    ; STA OAMADDR

    ; ; transfer the 256 bytes of data at $0200 - $02FF
    ; LDA #$02
    ; STA OAMDMA

    ; RTI
    LDA #$00
    STA OAMADDR
    LDA #$02
    STA OAMDMA
    LDA #$00
    STA $2005
    STA $2005
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
    CPX #$10                ; set flags
    BNE load_palettes       ; branch if Zero flag unset, we are not at 4 yet

    LDX #$00
load_sprites:
    ; Now write some sprite data
    LDA sprites,X
    STA $0200,X             ; Here we write to an indexed memory location which is equally offset
    INX
    CPX #$20
    BNE load_sprites

load_nametable:
; ----------- Large Star ---------------------
    LDX #$01                ; we'll set the offset to the position after the tile
    LDY large_star          ; load the tile into Y
load_large_star:
    LDA PPUSTATUS           ; clear PPUADDR by reading PPUSTATUS

    ; --- tile data
    LDA large_star,X        ; read the low bit
    STA PPUADDR             ; and store it
    INX                     ; move the index to the high bit
    LDA large_star,X        ; read the high bit
    STA PPUADDR             ; store it

    STY PPUDATA             ; write the tile

    ; --- attribute data
    LDA PPUSTATUS

    INX
    LDA large_star,X        ; read the low bit
    STA PPUADDR             ; and write it

    INX
    LDA large_star,X        ; read the high bit
    STA PPUADDR             ; and write it

    INX
    LDA large_star,X        ; read the attribute flags
    STA PPUDATA             ; and write them

    INX                     ; move to the next tile set
    CPX #$15                ; we have 8 bits, but only 4 tile sets, but we start at 1
    BNE load_large_star     ; if we haven't read them all loop
; ----------- Small Star 1 ----------------------
    LDX #$01                ; we'll set the offset to the position after the tile
load_small_star1:
    LDA PPUSTATUS           ; clear PPUADDR by reading PPUSTATUS

    LDA small_star1,X       ; read the low bit
    STA PPUADDR             ; and store it
    INX                     ; move the index to the high bit
    LDA small_star1,X       ; read the high bit
    STA PPUADDR             ; store it

    LDY small_star1         ; load the tile into Y
    STY PPUDATA             ; write the tile

    INX                     ; move to the next bit pair
    CPX #$15                ; we have 8 bits, but only 4 bit pairs, but we start at 1
    BNE load_small_star1    ; if we haven't read them all loop
; ----------- Small Star 2 -------------------------
    LDX #$01                ; we'll set the offset to the position after the tile
load_small_star2:
    LDA PPUSTATUS           ; clear PPUADDR by reading PPUSTATUS

    LDA small_star2,X       ; read the low bit
    STA PPUADDR             ; and store it
    INX                     ; move the index to the high bit
    LDA small_star2,X       ; read the high bit
    STA PPUADDR             ; store it

    LDY small_star2         ; load the tile into Y
    STY PPUDATA             ; write the tile

    INX                     ; move to the next bit pair
    CPX #$15                ; we have 8 bits, but only 4 bit pairs, but we start at 2
    BNE load_small_star2    ; if we haven't read them all loop
; ------------------------------------


    
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

.segment "RODATA"       ; Read Only Data
; ----------------- PALETTES ------------------------
palettes:
; .byte $0d, $0c, $1c, $2c
; .byte $0d, $19, $29, $3a
; .byte $0d, $00, $10, $20
; .byte $0d, $06, $16, $26

.byte $0f, $12, $23, $27
.byte $0f, $2b, $3c, $39
.byte $0f, $0c, $07, $13
.byte $0f, $19, $09, $29

.byte $0f, $2d, $10, $15
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29


; ----------------- SPRITES -------------------------
sprites:
ship_sprite:
;      Y    T#  ATR   X
.byte $70, $05, $00, $80
.byte $70, $06, $00, $88
.byte $78, $07, $00, $80
.byte $78, $08, $00, $88

ball_sprite:
;      Y    T#  ATR   X
.byte $40, $04, %00000001, $80
.byte $40, $04, %01000010, $88
.byte $48, $04, %10000011, $80
.byte $48, $04, %11000000, $88

; ----------------- NAMETABLES ------------------------
nametables:
large_star:
;     T#    
.byte $2f
;     thi  tlo  ahi  alo  atable
.byte $20, $6b, $23, $ca, %01000000
.byte $21, $57, $23, $ca, %01000000
.byte $22, $23, $23, $ca, %01000000
.byte $23, $52, $23, $ca, %01000000

small_star1:
;     T#    
.byte $2d
;      hi lo    ahi  alo  atable 
.byte $20, $c3, $23, $ca, %01000000
.byte $21, $1d, $23, $ca, %01000000
.byte $21, $93, $23, $ca, %01000000
.byte $23, $28, $23, $ca, %01000000

small_star2:
;     T#    
.byte $2e
;      hi lo    ahi  alo  atable 
.byte $20, $77, $23, $ca, %01000000
.byte $21, $3a, $23, $ca, %01000000
.byte $22, $4b, $23, $ca, %01000000
.byte $23, $3f, $23, $ca, %01000000
