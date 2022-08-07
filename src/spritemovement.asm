.segment "ZEROPAGE"
player_dir: .res 1 ; 0: left, 1: right
.importzp player_x, player_y

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
