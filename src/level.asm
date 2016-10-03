.ramsection "ram_level" slot 3 align 256
	level_data dsb (1<<MAP_SIZE_BITS)*(1<<MAP_SIZE_BITS)
.ends

.section "level_chunk_mapping_vis" align 1024
chunk_mapping_vis00:
	.db $00,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01

	.db $19,$19,$1B,$1B,$1D,$1D,$1F,$1F
	.db $19,$19,$1B,$1B,$1D,$1D,$1F,$1F

	.db $29,$29,$2B,$2B,$2D,$2D,$2F,$2F
	.db $29,$29,$2B,$2B,$2D,$2D,$2F,$2F

	.dsb $100-$30, $01

chunk_mapping_vis01:
	.db $00,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01

	.db $1A,$1B,$1A,$1B,$1E,$1F,$1E,$1F
	.db $1A,$1B,$1A,$1B,$1E,$1F,$1E,$1F

	.db $2A,$2B,$2A,$2B,$2E,$2F,$2E,$2F
	.db $2A,$2B,$2A,$2B,$2E,$2F,$2E,$2F

	.dsb $100-$30, $01

chunk_mapping_vis10:
	.db $00,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01

	.db $15,$15,$17,$17,$15,$15,$17,$17
	.db $1D,$1D,$1F,$1F,$1D,$1D,$1F,$1F

	.db $25,$25,$27,$27,$25,$25,$27,$27
	.db $2D,$2D,$2F,$2F,$2D,$2D,$2F,$2F

	.dsb $100-$30, $01

chunk_mapping_vis11:
	.db $00,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$01,$01,$01,$01,$01,$01

	.db $16,$17,$16,$17,$16,$17,$16,$17
	.db $1E,$1F,$1E,$1F,$1E,$1F,$1E,$1F

	.db $26,$27,$26,$27,$26,$27,$26,$27
	.db $2E,$2F,$2E,$2F,$2E,$2F,$2E,$2F

	.dsb $100-$30, $01
.ends

.section "level_chunk_mapping_flags" align 256
	; For autojoiners:
	; 0 = R
	; 1 = L
	; 2 = U
	; 3 = D
chunk_mapping_flags:
	.db %00000000, %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000, %00000000

	.db %00000011, %00000011, %00000011, %00000011
	.db %00000011, %00000011, %00000011, %00000011
	.db %00000011, %00000011, %00000011, %00000011
	.db %00000011, %00000011, %00000011, %00000011

	.db %00000010, %00000010, %00000010, %00000010
	.db %00000010, %00000010, %00000010, %00000010
	.db %00000010, %00000010, %00000010, %00000010
	.db %00000010, %00000010, %00000010, %00000010
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
	ld c, (1<<MAP_SIZE_BITS)
	ld hl, level_data
	ld a, $00
	--:
		ld b, (1<<MAP_SIZE_BITS)
	-:
		ldi (hl), a
		dec b
		jp nz, -
		dec c
		jp nz, --

	; TEST: Fill level with random data
	ld c, (1<<MAP_SIZE_BITS)
	ld hl, level_data
	ld de, $2B16
	--:
		ld b, (1<<MAP_SIZE_BITS)
	-:
		; Clock LFSR
		srl d
		rr e
		jp nc, +
			ld a, $90
			xor d
			ld d, a
		+:

		; Some randomness
		ld a, e
		rrca
		rrca
		rrca
		xor d
		rrca
		rrca
		xor e
		rrca
		xor d

		; Mask + range it
		;and $1F
		and $10
		add $10

		; Advance
		ldi (hl), a
		dec b
		jp nz, -
		dec c
		jp nz, --

	; Apply autostitch
	ld c, (1<<MAP_SIZE_BITS)
	ld hl, level_data
	---:
		; Loop
		ld b, (1<<MAP_SIZE_BITS)
	--:

		; Get tile + flags
		ld d, chunk_mapping_flags>>8
		ld e, (hl)
		ld a, (de)

		; Check for autostitch flag
		bit 1, a
		jp z, +++
			; Check right (if not at edge)

			ld a, b
			cp $01
			jp z, ++
				inc l
				ld a, (hl)
				xor e
				and $F0
				jp nz, +
					set 0, e
					set 1, (hl)
				+:
				dec l
			++:

			; Check down (if not at edge)
			ld a, c
			cp $01
			jp z, ++
				push hl
				push bc
				ld bc, (1<<MAP_SIZE_BITS)
				add hl, bc
				ld a, (hl)
				xor e
				and $F0
				jp nz, +
					set 3, e
					set 2, (hl)
				+:
				pop bc
				pop hl
			++:

			; Save new value
			ld (hl), e
		+++:

		; Advance
		inc hl
		dec b
		jp nz, --
		dec c
		jp nz, ---

	; Put player in a sensible spot
	; X
	ld hl, player_x
	ld de, 128
	ld (hl), e
	inc l
	ld (hl), d
	inc l
	; Y
	ld de, 128
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

		; Step forward to the next line
		ld a, l
		add 0+((1<<MAP_SIZE_BITS)-16)
		ld l, a
		ld a, h
		adc $00
		ld h, a

		dec c
		jp nz, --

	pop de
	pop bc
	pop hl
	pop af
	ret


.ends

