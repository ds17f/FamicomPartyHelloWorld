.include "constants.inc"

; we reserve one byte for storing the data that is read from controller
.segment "ZEROPAGE"
j1_buttons: .res 1
.exportzp j1_buttons


.segment "CODE"     ; CODE is all program code
.export read_joypad_1
.proc read_joypad_1
; At the same time that we strobe bit 0, we initialize the ring counter
; so we're hitting two birds with one stone here
readjoy:
    lda #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from JOYPAD1 will only return the state of the
    ; first button: button A.
    sta JOYPAD1
    sta j1_buttons
    lsr a        ; now A is 0
    ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
    sta JOYPAD1
loop:
    lda JOYPAD1
    lsr a	       ; bit 0 -> Carry
    rol j1_buttons  ; Carry -> bit 0; bit 7 -> Carry
    bcc loop
    rts
.endproc