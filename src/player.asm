.include "constants.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir: .res 1 ; 0: left, 1: right, 2: no movement
player_virt: .res 1; 0: down, 1: up, 2: no movement
.exportzp player_x, player_y
.importzp j1_buttons

.import read_joypad_1
 
.segment "CODE"
.export update_player
.proc update_player
    JSR player_joypad
    JSR player_vertical
    JSR player_horizontal
.endproc

.export player_joypad
.proc player_joypad

    LDA #NO_MOTION  
    STA player_virt
    STA player_dir


    LDA j1_buttons  ; load the buttons
    AND #BUTTON_UP  ; AND against up
    CMP #BUTTON_UP  ; check if it matches

    BNE down        ; if it doesn't check if down is pressed
    LDA #MOVE_UP    ; moving up
    STA player_virt

    JMP horizontal
    down:
        LDA j1_buttons      ; load the buttons
        AND #BUTTON_DOWN    ; AND against down
        CMP #BUTTON_DOWN    ; check if it matches

        BNE horizontal      ; if it doesn't then we aren't moving vert

        LDA #MOVE_DOWN      ; moving down
        STA player_virt
        ; fall over to horizontal check
    horizontal:
    ; TODO: check right and left, but these aren't exclusive to up and down
    ; TODO check left first
        LDA j1_buttons    
        AND #BUTTON_LEFT  
        CMP #BUTTON_LEFT 
        BNE right
        ; Moving left
        LDA #MOVE_LEFT
        STA player_dir
        jmp done
    right:
        LDA j1_buttons    
        AND #BUTTON_RIGHT  
        CMP #BUTTON_RIGHT 
        BNE done
        ; Moving right
        LDA #MOVE_RIGHT
        STA player_dir
    done:
        RTS
    
.endproc

.proc player_vertical

    LDA player_virt
    CMP #NO_MOTION
    BEQ done

    ; if we're supposed to move down
    LDA player_virt
    CMP #MOVE_DOWN
    BEQ down

    ; if we're at the top then we can't move
    LDA player_y
    CMP #PLAYER_Y_MIN
    BEQ done

    ; not at top so can move
    LDA player_y
    SEC
    SBC #MOVE_Y_PIXELS
    STA player_y
    ; movement done
    JMP done

    down:
        ; If we're at the bottom we can't move
        LDA player_y
        CMP #PLAYER_Y_MAX
        BCS done

        ; not at bottom
        LDA player_y
        SEC
        ADC #MOVE_Y_PIXELS
        STA player_y
        ; movement done

    done: 
    RTS
.endproc
.proc player_horizontal

    ; exit if not moving
    LDA player_dir
    CMP #NO_MOTION
    BEQ done

    ; Jump to right if moving right
    LDA player_dir
    CMP #MOVE_RIGHT
    BEQ right

    ; Moving left
    ; if at left edge, don't move
    LDA player_x
    CMP #PLAYER_X_MIN
    BEQ done

    ; not at left edge
    ; so room to move
    LDA player_x
    SEC
    SBC #MOVE_X_PIXELS
    STA player_x
    JMP done

    right:
        ; check if player is at the bottom
        LDA player_x
        CMP #PLAYER_X_MAX
        BCS done
        ; not at bottom
        LDA player_x
        CLC
        ADC #MOVE_X_PIXELS
        STA player_x
        ; fall over to done
    done: 
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
