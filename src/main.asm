.memorymap
slotsize $4000
slot 0 $0000
slot 1 $4000
defaultslot 0
.endme

.rombankmap
bankstotal 2
banksize $4000
banks 2
.endro

.gbheader
name "GBJAM5ENTRY"
cartridgetype $00
ramsize $00
.endgb
.nintendologo

;
; HARDWARE DEFINES
;
.define LCDC $FF40
.define STAT $FF41
.define SCY  $FF42
.define SCX  $FF43
.define LY   $FF44
.define LYC  $FF45
.define DMA  $FF46
.define BGP  $FF47
.define OBP0 $FF48
.define OBP1 $FF49

;
; JUMP VECTORS
;

.bank 0 slot 0
.org $0100
.section "Vec_Jump" size 4 force
nop
jp start
.ends

;
; MAIN CODE
;

.section "Code1x"
start:
	; Usual setup
	di
	ld sp, $DFF0

	; Set up LCDC
	ld a, (LCDC)
	and %10000000
	or  %00000111
	ld (LCDC), a

	; Turn screen off
	call screen_off

	; Clear VRAM
	ld hl, $8000
	xor a
	-:
		ldi (hl), a
		bit 5, h
		jp z, -

	; Clear OAM
	ld hl, $FE00
	xor a
	ld b, 40*4
	-:
		ld (hl), a
		inc l
		dec b
		jp z, -

	; Test tile
	ld hl, tiles1_beg
	ld de, $8000
	;call load_tile_bg
	ld de, $8000
	;call load_tile_bg

	ld hl, sprites1_beg
	ld de, $8800
	call load_tile_sprite
	call load_tile_sprite
	call load_tile_sprite
	call load_tile_sprite
	call load_tile_sprite

	; Set up a sprite
	ld hl, $FE00
	ld a, 0+16
	ld (hl), a
	inc l
	ld a, 0+8
	ld (hl), a
	inc l
	ld a, $80
	ld (hl), a
	inc l
	ld a, %00000000
	ld (hl), a
	inc l
	ld a, 0+16
	ld (hl), a
	inc l
	ld a, 8+8
	ld (hl), a
	inc l
	ld a, $90
	ld (hl), a
	inc l
	ld a, %00000000
	ld (hl), a

	; Set palettes
	ld a, %00011011
	ld (BGP), a
	ld a, %00101100
	ld (OBP0), a
	ld a, %00011100
	ld (OBP1), a

	; Turn screen on
	call screen_on

	; TEST: Swap tile banks each frame
	ld c, $00
	--:
		-:
			ld a, (LY)
			cp 144
			jp c, -

		ld a, (LCDC)
		xor $10
		ld (LCDC), a

		ld hl, $FE02
		ld a, (hl)
		xor $02
		ld (hl), a
		ld l, $06
		ld a, (hl)
		xor $02
		ld (hl), a
		ld a, (OBP0)
		xor %00110000
		ld (OBP0), a

		ld a, c
		rlca
		rlca
		ld (BGP), a
		inc c

		-:
			ld a, (LY)
			cp 144
			jp nc, -
		jp --


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

.section "Tiles1x" align 256
tiles1_beg:
	.db %00000000, %00000000, %00000000
	.db %00011000, %00000000, %00000000
	.db %00011000, %01100110, %01100000
	.db %00000000, %01100110, %01100000
	.db %01100110, %00000110, %01100000
	.db %01100110, %00000110, %01111000
	.db %00000000, %00000000, %00011000
	.db %00000000, %00000000, %00000000

	.db %00010000, %10100000, %11000000
	.db %01000000, %10010000, %11100000
	.db %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000
	.db %00000000, %00000000, %00000000
tiles1_end:

sprites1_beg:
	.incbin "bin/psprite01.bin"
sprites1_end:
.ends

