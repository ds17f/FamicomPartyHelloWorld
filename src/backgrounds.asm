.include "constants.inc"
.segment "ZEROPAGE"
_nt_addr:       .res 2  ; address of the data structure for a tile to write to nt
_nt_hi_byte_0:  .res 1  ; the high byte of the first addr of the nametable
_nt_len:        .res 1  ; the length of the data in the nametable
_nt_tile:       .res 1  ; the tile that's being written

.exportzp _nt_addr, _nt_len, _nt_hi_byte_0, _nt_tile


.segment "CODE"

.export draw_starfield
; draw the starfield to a nametable
; @param: Y : set Yreg to the high byte of the base address of the nametable ($20, $24, $28, $2c)
.proc draw_starfield
    ; load the label's address into zero page
    LDX #0
    LDA #<starfield
    STA _nt_addr,X
    INX
    LDA #>starfield
    STA _nt_addr,X

    ; write to the nametable
    STY _nt_hi_byte_0
    JSR draw_nametable_struct

    RTS
.endproc

; draw the objects to the nametable
; @param: Y : set Yreg to the high byte of the base address of the nametable ($20, $24, $28, $2c)
.export draw_objects
.proc draw_objects
    ; load the label's address into zero page
    LDX #0
    LDA #<satellite
    STA _nt_addr,X
    INX
    LDA #>satellite
    STA _nt_addr,X

    ; write to the nametable
    STY _nt_hi_byte_0
    JSR draw_nametable_struct

    RTS

.endproc

; -----------
; draws a set of tiles to the nametable
; tileset should be 
;    Each block of data should contain: 
;    1 byte for the total length of the data
;    Then as set of 6 bytes for each placement
;    tile, tile_offset_hi, tile_offset_lo, att_table_hi, att__lo, a_table_data
; EXAMPLE:
;  some_tile_data:
;  ; length 
;  .byte 7
;  ; some tile
;  ;     tile, thi  tlo  ahi  alo  atable
;  .byte $2f, $00, $6b, $23, $c2, %01000000
;
; @param _nt_addr
; @param _nt_hi_byte_0
;
; @internal _nt_len
; @internal _nt_tile
.proc draw_nametable_struct
    ; preserve registers to stack
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    ; -----------
        LDY #$00                ; we need to get the the length of the data structure which is the first byte
        LDA (_nt_addr),Y        ; so use Y to get the offset and load the byte to X
        STA _nt_len             ; and write it to zero page
        INY                     ; and move Y to the next position, the tile

    load_tile:
        LDA PPUSTATUS           ; clear PPUADDR by reading PPUSTATUS

        ; Y offset should be pointing at the next tile
        LDA (_nt_addr),Y        ; load the tile into X
        TAX

        INY                     ; move the index to the high byte offset of the tile

        ; --- tile data
        LDA (_nt_addr),Y        ; read the hi byte offset
        CLC                     ; add the nametable address to the offset so we get the proper nametable
        ADC _nt_hi_byte_0       
        STA PPUADDR             ; and store it
        INY                     ; move the index to the lo bit
        LDA (_nt_addr),Y        ; read the lo bit
        STA PPUADDR             ; store it

        STX PPUDATA             ; write the tile

        ; --- attribute data
        LDA PPUSTATUS

        INY
        LDA (_nt_addr),Y        ; read the hi bit
        STA PPUADDR             ; and write it

        INY
        LDA (_nt_addr),Y        ; read the lo bit
        STA PPUADDR             ; and write it

        INY
        LDA (_nt_addr),Y        ; read the attribute flags
        STA PPUDATA             ; and write them

        INY                     ; move to the next tile set
        CPY _nt_len             ; make sure we haven't gone past the length
        BNE load_tile           ; if we haven't read them all loop

    ; restore registers from stack
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP

    ; exit
    RTS
.endproc

.segment "RODATA"       ; Read Only Data
; Each block of data should contain: 
; 1 byte for the total length of the data
; Then as set of 6 bytes for each placement
; tile, tile_offset_hi, tile_offset_lo, att_table_hi, att__lo, a_table_data
starfield:
; length 
.byte 61
; large star
;     tile, thi  tlo  ahi  alo  atable
.byte $2f, $00, $6b, $23, $c2, %01000000
;.byte $2f, $01, $57, $23, $d5, %01000000
.byte $2f, $02, $23, $23, $e0, %00000100
.byte $2f, $03, $52, $23, $f4, %01000000
;nt_small_star1:
;     tile  hi lo    ahi  alo  atable 
.byte $2d, $00, $c3, $23, $c8, %01000000
.byte $2d, $01, $1d, $23, $d7, %00000001
.byte $2d, $01, $93, $23, $dc, %00000100
.byte $2d, $03, $28, $23, $f2, %00000001
;nt_small_star2:
;     tile  hi   lo  ahi  alo  atable 
.byte $2e, $00, $77, $23, $c5, %01000000
;.byte $2e, $01, $3a, $23, $d6, %00000100
.byte $2e, $02, $4b, $23, $e2, %01000000
.byte $2e, $03, $3f, $23, $f7, %00000100


satellite:
; length 
.byte 121
; top left
;     tile, thi  tlo  ahi  alo  atable
.byte $44, $01, $14, $23, $d5, %00000000
.byte $44, $01, $15, $23, $d5, %00000000
.byte $54, $01, $34, $23, $d5, %00000000
.byte $54, $01, $35, $23, $d5, %00000000
; top right
.byte $44, $01, $18, $23, $d6, %00000000
.byte $44, $01, $19, $23, $d6, %00000000
.byte $54, $01, $38, $23, $d6, %00000000
.byte $54, $01, $39, $23, $d6, %00000000
; bottom left
.byte $44, $01, $54, $23, $d5, %00000000
.byte $44, $01, $55, $23, $d5, %00000000
.byte $44, $01, $74, $23, $d5, %00000000
.byte $44, $01, $75, $23, $d5, %00000000
; bottom right
.byte $44, $01, $58, $23, $d6, %00000000
.byte $44, $01, $59, $23, $d6, %00000000
.byte $44, $01, $78, $23, $d6, %00000000
.byte $44, $01, $79, $23, $d6, %00000000
; center
.byte $45, $01, $36, $23, $d5, %00000000
.byte $46, $01, $37, $23, $d5, %00000000
.byte $55, $01, $56, $23, $d5, %00000000
.byte $56, $01, $57, $23, $d5, %00000000

