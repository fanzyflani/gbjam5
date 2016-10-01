.ramsection "ram_player" slot 1
	player_x dw
	player_y dw
	cam_x dw
	cam_y dw
.ends

.section "file_player"
	; player_update: Updates the player
	;
	; Input: -
	; Output:
	; - A: Current joypad state (same order as GBA)
	; Clobbers: -
player_update:
	push af
	push hl
	push bc
	push de

	call joy_update
	ld c, a

	; X
	ld hl, player_x
	ld e, (hl)
	inc l
	ld d, (hl)
	bit 4, c
	jp nz, +
		inc de
	+:
	bit 5, c
	jp nz, +
		dec de
	+:
	ld (hl), d
	dec l
	ld (hl), e

	; Y
	ld hl, player_y
	ld e, (hl)
	inc l
	ld d, (hl)
	bit 6, c
	jp nz, +
		dec de
	+:
	bit 7, c
	jp nz, +
		inc de
	+:
	ld (hl), d
	dec l
	ld (hl), e

	; Update camera
	call player_cam_update

	pop de
	pop bc
	pop hl
	pop af
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
	push bc
	ld hl, psprite01_beg + 64*0
	ld de, $8800
	push hl
	call load_tile_sprite
	pop hl
	inc h
	call load_tile_sprite

	; Get camera pos
	; X
	ld hl, cam_x
	ld c, (hl)
	inc l
	inc l
	; Y
	ld b, (hl)

	; Set player sprite pos
	; Y
	ld hl, $FE00
	ld a, (player_y)
	sub b
	add $10
	ld (hl), a
	ld l, $04
	; X
	ld (hl), a
	ld l, $01
	ld a, (player_x)
	sub c
	add $08
	ld (hl), a
	ld l, $05
	add $08
	ld (hl), a

	; Return
	pop de
	pop bc
	pop hl
	pop af
	ret

	; player_cam_update: Centre the camera on the player
	;
	; Input: -
	; Output: -
	; Clobbers: -
player_cam_update:
	push af
	push hl
	push de

	; Set up player camera
	; X get raw
	ld hl, player_x
	ld a, (hl)
	inc l
	ld h, (hl)
	ld l, a
	; X clamp -ve
	ld de, -(160-16)/2
	add hl, de
	bit 7, h
	jr z, +
		ld hl, $0000
	+:
	; X clamp +ve
	ld de, 160
	add hl, de
	bit 2, h
	jr z, +
		ld hl, 64*16
	+:
	ld de, -160
	add hl, de
	; X write
	ld a, l
	ld (cam_x+0), a
	ld a, h
	ld (cam_x+1), a

	; Y
	ld hl, player_y
	ld a, (hl)
	inc l
	ld h, (hl)
	ld l, a
	; Y clamp -ve
	ld de, -(144-16)/2
	add hl, de
	bit 7, h
	jr z, +
		ld hl, $0000
	+:
	; Y clamp +ve
	ld de, 144
	add hl, de
	bit 2, h
	jr z, +
		ld hl, 64*16
	+:
	ld de, -144
	add hl, de
	; Y write
	ld a, l
	ld (cam_y+0), a
	ld a, h
	ld (cam_y+1), a

	pop de
	pop hl
	pop af
	ret

.ends

