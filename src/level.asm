.ramsection "ram_level" slot 3 align 256
	; RULE #1 ALWAYS USE EXACTLY ONE HALF OF RAM FOR *SOMETHING SPECIFIC*
	; (rule #2 is "use almost none of the remaining RAM")
	level_data dsb 64*64
.ends

