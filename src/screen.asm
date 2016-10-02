.struct oam
	y db
	x db
	tile db
	flags db
.endst

.ramsection "ram_screen_sprite" slot 1 align 256
	oam_buf instanceof oam 40
.ends

.section "file_screen"
	; screen_on: Turns the screen on.
	;
	; Input: -
	; Output: -
	; Clobbers: -
screen_on:
	push af
	ld a, (LCDC)
	set 7, a
	ld (LCDC), a
	+: pop af
	ret

	; screen_off: Turns the screen off safely (waits for vblank).
	;
	; Input: -
	; Output: -
	; Clobbers: -
screen_off:
	push af
	ld a, (LCDC)
	bit 7, a
	jr z, +
	
	; Wait for vblank
	-:
		ld a, (LY)
		cp 145
		jr nz, -

	ld a, (LCDC)
	res 7, a
	ld (LCDC), a
	+: pop af
	ret
.ends

