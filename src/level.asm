.ramsection "ram_level" slot 3 align 256
	; RULE #1 ALWAYS USE EXACTLY ONE HALF OF RAM FOR *SOMETHING SPECIFIC*
	; (rule #2 is "use almost none of the remaining RAM")
	level_data dsb 64*64
.ends

.section "level_chunk_mapping_vis" align 1024
chunk_mapping_vis00:
	.db $00,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01

	.db $19,$19,$19,$19,$19,$19,$19,$19
	.db $19,$19,$19,$19,$19,$19,$19,$19

	.db $29,$29,$29,$29,$29,$29,$29,$29
	.db $29,$29,$29,$29,$29,$29,$29,$29

	.dsb $100-$30, $01

chunk_mapping_vis01:
	.db $00,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01

	.db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A
	.db $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A

	.db $2A,$2A,$2A,$2A,$2A,$2A,$2A,$2A
	.db $2A,$2A,$2A,$2A,$2A,$2A,$2A,$2A

	.dsb $100-$30, $01

chunk_mapping_vis10:
	.db $00,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01

	.db $15,$15,$15,$15,$15,$15,$15,$15
	.db $15,$15,$15,$15,$15,$15,$15,$15

	.db $25,$25,$25,$25,$25,$25,$25,$25
	.db $25,$25,$25,$25,$25,$25,$25,$25

	.dsb $100-$30, $01

chunk_mapping_vis11:
	.db $00,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01

	.db $16,$16,$16,$16,$16,$16,$16,$16
	.db $16,$16,$16,$16,$16,$16,$16,$16

	.db $26,$26,$26,$26,$26,$26,$26,$26
	.db $26,$26,$26,$26,$26,$26,$26,$26

	.dsb $100-$30, $01
.ends

.section "level_chunk_mapping_flags" align 256
chunk_mapping_flags:
	.db %00000000, %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000, %00000000

	.db %00000001, %00000001, %00000001, %00000001
	.db %00000001, %00000001, %00000001, %00000001
	.db %00000001, %00000001, %00000001, %00000001
	.db %00000001, %00000001, %00000001, %00000001

	.db %00000000, %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000, %00000000
.ends

.section "file_level"
	; level_generate: Generates a level
	;
	; Input: -
	; Output: -
	; Clobbers: -
level_generate:
	push af
	push hl
	push bc
	push de

	; Clear level data
	ld b, $00
	ld hl, level_data
	ld a, $10 ; This'll probably be $00
	-:
		; Unroll for convenience
		; (pfft, you thought I was doing this for speed?)
		.repeat 16
		ldi (hl), a
		.endr
		dec b
		jp nz, -

	; Put player in a sensible spot
	; X
	ld hl, player_x
	ld de, 512
	ld (hl), e
	inc l
	ld (hl), d
	inc l
	; Y
	ld de, 512
	ld (hl), e
	inc l
	ld (hl), d

	; Update camera
	call player_cam_update

	pop de
	pop bc
	pop hl
	pop af
	ret

	; level_draw_full: Draws a full screen of the level
	; SCREEN MUST BE TURNED OFF BEFORE CALLING THIS
	;
	; TODO: do this in terms of some level scroll tile update thing
	;
	; Input: -
	; Output: -
	; Clobbers: -
level_draw_full:
	push af
	push hl
	push bc
	push de

	; TODO: factor in camera
	ld hl, level_data
	ld de, $9800
	ld c, 16
	--:
		; Draw upper row
		ld b, 16
		-:
			ldi a, (hl)
			push hl
			ld h, chunk_mapping_vis00>>8
			ld l, a
			ld a, (hl)
			ld (de), a
			inc de
			inc h
			ld a, (hl)
			ld (de), a
			inc de
			pop hl
			dec b
			jp nz, -

		; Step back a tile
		ld a, l
		sub $10
		ld l, a
		ld a, h
		sbc $00
		ld h, a

		; Draw lower row
		ld b, 16
		-:
			ldi a, (hl)
			push hl
			ld h, chunk_mapping_vis10>>8
			ld l, a
			ld a, (hl)
			ld (de), a
			inc de
			inc h
			ld a, (hl)
			ld (de), a
			inc de
			pop hl
			dec b
			jp nz, -

		dec c
		jp nz, --

	pop de
	pop bc
	pop hl
	pop af
	ret


.ends

