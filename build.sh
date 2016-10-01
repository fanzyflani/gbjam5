#!/bin/sh
python sconv.py -p tga/psprite01.tga bin/psprite01.bin && \
wla-gb -o obj/main.o src/main.asm && \
wlalink -r linkfile output.gb && \
true

