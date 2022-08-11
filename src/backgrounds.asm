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
    ;---- nt_large_star
    ; load the label's address into zero page
    LDX #0
    LDA #<nt_large_star
    STA _nt_addr,X
    INX
    LDA #>nt_large_star
    STA _nt_addr,X

    ; write to the nametable
    STY _nt_hi_byte_0
    JSR draw_nametable_tile

    ;---- nt_small_star1
    ; load the label's address into zero page
    LDX #0
    LDA #<nt_small_star1
    STA _nt_addr,X
    INX
    LDA #>nt_small_star1
    STA _nt_addr,X

    ; write to the nametable
    STY _nt_hi_byte_0
    JSR draw_nametable_tile

    ;---- nt_small_star2
    ; load the label's address into zero page
    LDX #0
    LDA #<nt_small_star2
    STA _nt_addr,X
    INX
    LDA #>nt_small_star2
    STA _nt_addr,X

    ; write to the nametable
    STY _nt_hi_byte_0
    JSR draw_nametable_tile

    ;---- nt_satellite
    ; load the label's address into zero page
    LDX #0
    LDA #<nt_satellite
    STA _nt_addr,X
    INX
    LDA #>nt_satellite
    STA _nt_addr,X

    ; write to the nametable
    STY _nt_hi_byte_0
    JSR draw_nametable_tile

    RTS

.endproc

; -----------
; draws a tile to the nametable
;
; @param _nt_addr
; @param _nt_hi_byte_0
;
; @internal _nt_len
; @internal _nt_tile
.proc draw_nametable_tile
    ; preserve registers to stack
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

    ; -----------
        LDY #$00                
        LDA (_nt_addr),Y        ; load the tile into X
        TAX
        INY                     ; we need to get the the length of the data structure which is the second byte
        LDA (_nt_addr),Y        ; so use Y to get the offset and load the byte to X
        STA _nt_len             ; and write it to zero page
        INY                     ; and move Y to the next position, the first byte of the
                                ; location data for the first entry

    load_tile:
        LDA PPUSTATUS           ; clear PPUADDR by reading PPUSTATUS

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
nametable_offsets:
; Each block of data should contain: 
; 1 byte for the tile location
; 1 byte for the total length of the data
; Then as set of 5 bytes for each placement
; tile_offset_hi, tile_offset_lo, att_table_hi, att__lo, a_table_data
nt_large_star:
; Tile #
.byte $2f
; length 
.byte 22
;     thi  tlo  ahi  alo  atable
.byte $00, $6b, $23, $c2, %01000000
.byte $01, $57, $23, $d5, %01000000
.byte $02, $23, $23, $e0, %00000100
.byte $03, $52, $23, $f4, %01000000

nt_small_star1:
; Tile #
.byte $2d
; length 
.byte 22
;      hi lo    ahi  alo  atable 
.byte $00, $c3, $23, $c8, %01000000
.byte $01, $1d, $23, $d7, %00000001
.byte $01, $93, $23, $dc, %00000100
.byte $03, $28, $23, $f2, %00000001

nt_small_star2:
; Tile #
.byte $2e
; length 
.byte 22
;      hi lo    ahi  alo  atable 
.byte $00, $77, $23, $c5, %01000000
.byte $01, $3a, $23, $d6, %00000100
.byte $02, $4b, $23, $e2, %01000000
.byte $03, $3f, $23, $f7, %00000100

nt_satellite:
;     T#    
.byte $65
.byte 7
;      hi lo    ahi  alo  atable 
.byte $20, $5d, $23, $c7, %00100000
