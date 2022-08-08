.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir: .res 1 ; 0: left, 1: right
.exportzp player_x, player_y
 
.segment "CODE"
.export update_player
.proc update_player
        ; preserve registers to stack
        PHP
        PHA
        TXA
        PHA
        TYA
        PHA

        ; check if player at right edge
        LDA player_x
        CMP #$e0                ; right edge
        BCC not_at_right_edge   ; check if less than the right edge
        ; if BCC not taken we are at the right edge ($0e)
        LDA #$00
        STA player_dir          ; start moving left
        JMP direction_set       ; we have set the dir so skip left check

    not_at_right_edge:          ; left check
        LDA player_x
        CMP #$10                ; left edge
        BCS direction_set       ; check if greater than or equal to the left edge
        ; if BCS not taken we are at the left edge
        LDA #$01                
        STA player_dir          ; start moving right

    direction_set:
        LDA player_dir
        CMP #$01
        BEQ move_right
    ; move left
        ; direction is #$00 so move left
        DEC player_x
        JMP exit_sub
    move_right:
        INC player_x
    exit_sub:
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

.export draw_player
.proc draw_player
    ; Save registers
    PHP
    PHA
    TXA
    PHA 
    TYA
    PHA

    ; -- write player ship tile numbers
    ; $0200 is the first sprite position
    ; each sprite is 4 bytes wide
    ; the second byte is the tile
    ; so each of these writes the second byte
    ; in the first 4 sprites
    LDA #$05
    STA $0201
    LDA #$06
    STA $0205
    LDA #$07
    STA $0209
    LDA #$08
    STA $020d

    ; write the player sprite attributes
    ; each uses palette 0
    ; as above, each sprite is 4 bytes wide
    ; and we need to write the 3rd byte in each sprite
    ; so they'll be offset by 3 from $2000, $2004, etc...
    LDA #$00
    STA $0202
    STA $0206
    STA $020a
    STA $020e

    ; set player position
    ; first sprite, top left
    LDA player_y
    STA $0200
    LDA player_x
    STA $0203
    ; next sprite, top right
    LDA player_y
    STA $0204
    LDA player_x
    CLC
    ADC #$08        ; add 8 pixels to the right position to find the top right sprite
    STA $0207
    ; next sprite, bot left
    LDA player_y
    CLC
    ADC #$08        ; add 8 pixels to the top position to find the left bottom
    STA $0208
    LDA player_x
    STA $020b
    ; next sprite, bot right
    LDA player_y
    CLC
    ADC #$08        ; add 8 pixels to the top position to find the left bottom
    STA $020c
    LDA player_x
    CLC
    ADC #$08        ; add 8 pixels to the right position to find the right bottom
    STA $020f

    ; restore the registers from the stack
    PLA
    TAY
    PLA
    TAX
    PLA
    PLP

    RTS
.endproc
