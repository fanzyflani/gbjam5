.section "file_tile"
	; load_tile_bg: Loads a single 3bpp bg tile.
	; Input:
	; - HL = source location
	; - DE = VRAM address to write it to
	;   - use $8000-$87FF only!
	; Output:
	; - HL = pointer after given tile
	; - DE = VRAM address after given tile
	; Clobbers: -
load_tile_bg:
	push af
	push bc

	; NOTE:
	;
	; 000 -> 00 00
	; 001 -> 00 01
	; 010 -> 01 01
	; 011 -> 01 10
	; 100 -> 10 10
	; 101 -> 10 11
	; 110 -> 11 11
	;
	; 111 -> INVALID (we probably clamp this to 11 11)
	ld b, 8
	-:
		; Load dither bits
		ldi a,(hl)
		ld c, a

		; L F0
		ldi a,(hl)
		ld (de), a
		; L F1
		set 4, d
		xor c
		ld (de), a
		res 4, d
		; Advance
		inc e
		; (A^C)^C = A; then use A&C for carry
		xor c
		and c
		ld c, a

		; H F0
		ldi a,(hl)
		ld (de), a
		; H F1
		set 4, d
		or c
		ld (de), a
		res 4, d
		; Advance
		inc de

		; Dec and loop
		dec b
		jp nz, -

	pop bc
	pop af
	ret

	; load_tile_sprite: Loads a single 4bpp 8x16 sprite.
	; Input:
	; - HL = source location
	; - DE = VRAM address to write it to
	;   - use $8000-$8FFF only!
	; Output:
	; - HL = pointer after given sprite
	; - DE = VRAM address after given sprite
	; Clobbers: -
load_tile_sprite:
	push af
	push bc

	; NOTE:
	;
	; .|3 1 0
	; -+-----
	; 3|6 4 3
	; 2|5 3 2
	; 0|3 1 0
	;
	; Full ramp:
	; 01 01 = 0 0 = 0
	; 10 01 = 1 0 = 1
	; 01 10 = 0 2 = 2
	; 10 10 = 1 2 = 3
	; 10 11 = 1 3 = 4
	; 11 10 = 3 2 = 5
	; 11 11 = 3 3 = 6
	;
	; Full transparency:
	; 00 00 = - - = -
	;
	; Translucency:
	; 00 01 = - 0 = 0 .5
	; 10 00 = 1 - = 2 .5
	; 00 10 = - 2 = 4 .5
	; 11 00 = 3 - = 6 .5
	;
	; Redundancies:
	; 01 00 = 0 - = 0 .5
	; 00 11 = - 3 = 6 .5
	; 00 11 = 0 3 = 3
	; 11 00 = 3 0 = 3
	;
	ld b, 64
	-:
		; Load it all
		ldi a,(hl)
		ld (de), a
		inc e
		dec b
		jr nz, -

	; Carry for DE
	ld a, e
	and a
	jr nz, +
	inc d
	+:

	pop bc
	pop af
	ret
.ends

