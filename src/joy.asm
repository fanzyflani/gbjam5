.section "file_joy"
	; joy_update: Reads the joystick state from JOYP
	;
	; Input: -
	; Output:
	; - A: Current joypad state (same order as GBA)
	; Clobbers: F
joy_update:
	push hl
	push bc

	; Get input
	ld hl, JOYP
	ld a, $10
	ld (hl), a
	ld a, (hl)
	ld a, (hl)
	and $0F
	ld c, a
	ld a, $20
	ld (hl), a
	ld a, (hl)
	ld a, (hl)
	ld a, (hl)
	ld a, (hl)
	ld a, (hl)
	ld a, (hl)
	and $0F
	swap a
	or c
	ld c, $30
	ld (hl), c
	pop bc
	pop hl
	ret
.ends
