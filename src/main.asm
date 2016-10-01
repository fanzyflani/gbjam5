.memorymap
slotsize $8000
slot 0 $0000
slotsize $2000
slot 1 $D000
slotsize $7F
slot 2 $FF80
slotsize $2000
slot 3 $C000
defaultslot 0
.endme

.rombankmap
; work around a bug in WLA-GB: apparently you cannot only define one bank
bankstotal 2
banksize $8000
banks 2
.endro

.gbheader
name "GBJAM5ENTRY"
cartridgetype $00
ramsize $00
.endgb
.nintendologo

.include "src/hwdefs.asm"

;
; Main includes
;
.include "src/joy.asm"
.include "src/level.asm"
.include "src/player.asm"
.include "src/screen.asm"
.include "src/tile.asm"

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
		jp nz, -

	; Load tiles
	ld b, 16*8
	ld hl, tile01_beg
	ld de, $8000
	-:
		call load_tile_bg
		dec b
		jp nz, -
	
	; Generate + draw first level
	call level_generate
	call level_draw_full

	; TEST: Draw tilemap
	ld hl, $9800
	ld b, 0
	-:
		ld a, b
		ldi (hl), a
		inc b
		jr z, ++
		ld a, b
		and $0F
		jp nz, -
		ld de, $20-$10
		add hl, de
		jp -
	++:

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
	ld a, $84
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
		; Update stuff
		call player_update

		; Wait for vblank start
		-:
			ld a, (LY)
			cp 144
			jp c, -

		; Update player sprite
		call player_redraw

		; Swap sprite bits
		ld hl, $FE02
		ld a, (hl)
		xor $02
		ld (hl), a
		inc l
		inc l
		inc l
		inc l
		ld a, (hl)
		xor $02
		ld (hl), a

		; Scroll
		ld a, (cam_y)
		ld (SCY), a
		ld a, (cam_x)
		ld (SCX), a

		; Swap BG banks
		ld a, (LCDC)
		xor $10
		ld (LCDC), a

		; Screw with object palette
		ld a, (OBP0)
		xor %00110000
		ld (OBP0), a

		; Wait for vblank end
		-:
			ld a, (LY)
			cp 144
			jp nc, -
		jp --
.ends


.section "Tiles1x" align 256
tile01_beg:
	.incbin "bin/tile01.bin"
tile01_end:
.ends

.section "Sprites1x" align 256
psprite01_beg:
	.incbin "bin/psprite01.bin"
psprite01_end:
.ends

