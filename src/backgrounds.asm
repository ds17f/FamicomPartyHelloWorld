.include "constants.inc"

.segment "CODE"
.export load_nametables
.proc load_nametables
    ; preserve registers to stack
    PHP
    PHA
    TXA
    PHA
    TYA
    PHA

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
        BNE load_small_star2    ; if we haven't read them all loop
    ; ----------- Satellite -------------------------
        LDX #$01                ; we'll set the offset to the position after the tile
    load_satellite:
        LDA PPUSTATUS           ; clear PPUADDR by reading PPUSTATUS

        LDA satellite,X         ; read the low bit
        STA PPUADDR             ; and store it
        INX                     ; move the index to the high bit
        LDA satellite,X         ; read the high bit
        STA PPUADDR             ; store it

        LDY satellite           ; load the tile into Y
        STY PPUDATA             ; write the tile

        ; --- attribute data
        LDA PPUSTATUS

        INX
        LDA satellite,X         ; read the low bit
        STA PPUADDR             ; and write it

        INX
        LDA satellite,X         ; read the high bit
        STA PPUADDR             ; and write it

        INX
        LDA satellite,X         ; read the attribute flags
        STA PPUDATA             ; and write them

        INX                     ; move to the next tile set
        CPX #$06                ; we have 8 bits, but only 1 tile sets, but we start at 1
        BNE load_satellite      ; if we haven't read them all loop
    ; ------------------------------------

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
nametables:
large_star:
;     T#    
.byte $2f
;     thi  tlo  ahi  alo  atable
.byte $20, $6b, $23, $c2, %01000000
.byte $21, $57, $23, $d5, %01000000
.byte $22, $23, $23, $e0, %00000100
.byte $23, $52, $23, $f4, %01000000

small_star1:
;     T#    
.byte $2d
;      hi lo    ahi  alo  atable 
.byte $20, $c3, $23, $c8, %01000000
.byte $21, $1d, $23, $d7, %00000001
.byte $21, $93, $23, $dc, %00000100
.byte $23, $28, $23, $f2, %00000001

small_star2:
;     T#    
.byte $2e
;      hi lo    ahi  alo  atable 
.byte $20, $77, $23, $c5, %01000000
.byte $21, $3a, $23, $d6, %00000100
.byte $22, $4b, $23, $e2, %01000000
.byte $23, $3f, $23, $f7, %00000100

satellite:
;     T#    
.byte $65
;      hi lo    ahi  alo  atable 
.byte $20, $5d, $23, $c7, %00100000
