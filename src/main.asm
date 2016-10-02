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

.ramsection "hram_dma_copy" slot 2
	; hram_dma_copy: Perform DMA OAM copy.
	;
	; Input:
	; - A: Top byte of source OAM table address
	; Output: -
	; Clobbers: A,F
	hram_dma_copy dsb 10
.ends

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

.org $0040
.section "Vec_Jump_VBlank" force
jp irq_vblank
.ends

.org $0100
.section "Vec_Jump_Start" size 4 force
nop
jp start
.ends

;
; MAIN CODE
;

.section "Code1x"
hram_dma_copy_base_beg:
	ld (DMA), a ; 2b
	ld a, $28 ; 2b
	-: dec a ; 1b 1c
	jr nz, - ; 2b 4c
	ret ; 1b
hram_dma_copy_base_end:

start:
	; Usual setup
	di
	ld sp, $DFF0
	ld a, %00000
	ld (IE), a
	xor a
	ld (IF), a

	; Copy hram_dma_copy to high RAM
	ld de, hram_dma_copy
	ld hl, hram_dma_copy_base_beg
	ld b, 10
	-:
		ldi a, (hl)
		ld (de), a
		inc de
		dec b
		jp nz, -

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

	; Clear real OAM
	ld hl, $FE00
	xor a
	ld b, 40*4
	-:
		ld (hl), a
		inc l
		dec b
		jp nz, -

	; Clear OAM buffer
	ld hl, oam_buf
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
	;ld hl, $9800
	;ld b, 0
	;-:
	;	ld a, b
	;	ldi (hl), a
	;	inc b
	;	jr z, ++
	;	ld a, b
	;	and $0F
	;	jp nz, -
	;	ld de, $20-$10
	;	add hl, de
	;	jp -
	;++:

	; Set up a sprite
	ld hl, oam_buf + $00
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
	ld a, $82
	ld (hl), a
	inc l
	ld a, %00000000
	ld (hl), a

	; Set palettes
	ld a, %00011011
	ld (BGP), a
	ld a, %00011100
	ld (OBP0), a
	ld a, %00101100
	ld (OBP1), a

	; Update player stuff
	ld a, $00
	ld (player_tile_src), a

	; Turn screen on
	call screen_on

	; Hang off the vblank IRQ for now
	ld hl, IE
	set 0, (hl)
	ld hl, IF
	res 0, (hl)
	ei
	-: jp -

irq_vblank:
	push af
	push hl
	push bc
	push de

	; DEBUG: Mark BG inverted
	ld a, %11100100
	ld (BGP), a

	; Update player sprite
	call player_redraw_unsafe

	; Do DMA
	ld a, oam_buf>>8
	call hram_dma_copy

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

	;
	; VBLANK CRITICAL SECTION ENDS HERE
	;

	; DEBUG: Restore BG
	ld a, %00011011
	ld (BGP), a

	; Swap sprite bits
	;ld hl, oam_buf+$02
	;ld a, (hl)
	;xor $02
	;ld (hl), a
	;inc l
	;inc l
	;inc l
	;inc l
	;ld a, (hl)
	;xor $02
	;ld (hl), a

	; Update stuff
	call player_update

	pop de
	pop bc
	pop hl
	pop af
	ei
	ret
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

