.ramsection "ram_player" bank 0 slot 2
	player_x db
	player_y db
.ends

.section "file_player"
	; player_update: Updates the player
	;
	; Input: -
	; Output:
	; - A: Current joypad state (same order as GBA)
	; Clobbers: F
player_update:
	call joy_update
	ld c, a

	ld hl, player_x
	bit 4, c
	jp nz, +
		inc (hl)
	+:
	bit 5, c
	jp nz, +
		dec (hl)
	+:
	ld hl, player_y
	bit 6, c
	jp nz, +
		dec (hl)
	+:
	bit 7, c
	jp nz, +
		inc (hl)
	+:
	ret

	; player_redraw: Uploads the next player sprite
	;
	; Input: -
	; Output: -
	; Clobbers: -
player_redraw:
	push af
	push hl
	push de
	ld hl, psprite01_beg + 64*0
	ld de, $8800
	push hl
	call load_tile_sprite
	pop hl
	inc h
	call load_tile_sprite

	; Set player X,Y
	ld hl, $FE00
	ld a, (player_y)
	add $10
	ld (hl), a
	ld l, $04
	ld (hl), a
	ld l, $01
	ld a, (player_x)
	add $08
	ld (hl), a
	ld l, $05
	add $08
	ld (hl), a

	; Return
	pop de
	pop hl
	pop af
	ret
.ends

