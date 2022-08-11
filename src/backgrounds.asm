.include "constants.inc"
.segment "ZEROPAGE"
_nt_addr:       .res 2  ; address of the data structure for a tile to write to nt
_nt_hi_byte_0:  .res 1  ; the high byte of the first addr of the nametable
_atr_page:      .res 1  ; the high byte of the attribute table ($23, $27, $2b, $2f)
_nt_len:        .res 1  ; the length of the data in the nametable
_nt_tile:       .res 1  ; the tile that's being written

.exportzp _nt_addr, _nt_len, _nt_hi_byte_0, _nt_tile, _atr_page


.segment "CODE"

.export draw_starfield
; draw the starfield to a nametable
; @param: _nt_hi_byte_0 : the high byte of the base address of the nametable ($20, $24, $28, $2c)
; @param: _atr_page : the high byte of the attribute table ($23, $27, $2b, $2f)
.proc draw_starfield
    ; load the label's address into zero page
    LDX #0
    LDA #<starfield
    STA _nt_addr,X
    INX
    LDA #>starfield
    STA _nt_addr,X

    ; write to the nametable
    JSR draw_nametable_struct

    RTS
.endproc

; draw the objects to the nametable
; @param: _nt_hi_byte_0 : the high byte of the base address of the nametable ($20, $24, $28, $2c)
; @param: _atr_page : the high byte of the attribute table ($23, $27, $2b, $2f)
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
    JSR draw_nametable_struct

    ; load the label's address into zero page
    LDX #0
    LDA #<nebula
    STA _nt_addr,X
    INX
    LDA #>nebula
    STA _nt_addr,X

    ; write to the nametable
    JSR draw_nametable_struct
    RTS

.endproc

; -----------
; draws a set of tiles to the nametable
; tileset should be 
;    Each block of data should contain: 
;    1 byte for the total length of the data
;    Then as set of 6 bytes for each placement
;    tile, tile_offset_hi, tile_offset_lo, att__lo, a_table_data
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
; @param _atr_page
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

        ; we read the hi bit from input
        LDA _atr_page           ; read the hi bit
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
; Then as set of 5 bytes for each placement
; tile, tile_offset_hi, tile_offset_lo, att__lo, a_table_data
starfield:
; length 
.byte 51
; large star
;     tile, thi  tlo alo  atable
.byte $2f, $00, $6b, $c2, %01000000
;.byte $2f, $01, $57,$d5, %01000000
.byte $2f, $02, $23, $e0, %00000100
.byte $2f, $03, $52, $f4, %01000000
;nt_small_star1:
;     tile  hi lo    alo  atable 
.byte $2d, $00, $c3, $c8, %01000000
.byte $2d, $01, $1d, $d7, %00000001
.byte $2d, $01, $93, $dc, %00000100
.byte $2d, $03, $28, $f2, %00000001
;nt_small_star2:
;     tile  hi   lo  alo  atable 
.byte $2e, $00, $77, $c5, %01000000
;.byte $2e, $01, $3a, $d6, %00000100
.byte $2e, $02, $4b, $e2, %01000000
.byte $2e, $03, $3f, $f7, %00000100


satellite:
; length 
.byte 101
; top left
;     tile, thi  tlo  alo  atable
.byte $44, $01, $14, $d5, %00000000
.byte $44, $01, $15, $d5, %00000000
.byte $54, $01, $34, $d5, %00000000
.byte $54, $01, $35, $d5, %00000000
; top right
.byte $44, $01, $18, $d6, %00000000
.byte $44, $01, $19, $d6, %00000000
.byte $54, $01, $38, $d6, %00000000
.byte $54, $01, $39, $d6, %00000000
; bottom left
.byte $44, $01, $54, $d5, %00000000
.byte $44, $01, $55, $d5, %00000000
.byte $44, $01, $74, $d5, %00000000
.byte $44, $01, $75, $d5, %00000000
; bottom right
.byte $44, $01, $58, $d6, %00000000
.byte $44, $01, $59, $d6, %00000000
.byte $44, $01, $78, $d6, %00000000
.byte $44, $01, $79, $d6, %00000000
; center
.byte $45, $01, $36, $d5, %00000000
.byte $46, $01, $37, $d5, %00000000
.byte $55, $01, $56, $d5, %00000000
.byte $56, $01, $57, $d5, %00000000

nebula:
; ; length
.byte 71
;     tile thi  tlo  alo  atable
.byte $41, $02, $68, $e2, %11110000
.byte $42, $02, $69, $e2, %11110000
.byte $43, $02, $6a, $e2, %11110000
.byte $50, $02, $87, $e9, %11001100
.byte $51, $02, $88, $ea, %00111111
.byte $52, $02, $89, $ea, %00111111
.byte $53, $02, $8a, $ea, %00111111
.byte $60, $02, $a7, $e9, %11001100
.byte $61, $02, $a8, $ea, %00111111
.byte $62, $02, $a9, $ea, %00111111
.byte $63, $02, $aa, $ea, %00111111
.byte $70, $02, $c7, $e9, %11001100
.byte $71, $02, $c8, $ea, %00111111
.byte $72, $02, $c9, $ea, %00111111
