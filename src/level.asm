.ramsection "ram_level" slot 3 align 256
	; RULE #1 ALWAYS USE EXACTLY ONE HALF OF RAM FOR *SOMETHING SPECIFIC*
	; (rule #2 is "use almost none of the remaining RAM")
	level_data dsb 64*64
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

	; TODO!

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
	; Input: -
	; Output: -
	; Clobbers: -
level_draw_full:
	push af
	push hl
	push bc
	push de

	; TODO!

	pop de
	pop bc
	pop hl
	pop af
	ret


.ends

