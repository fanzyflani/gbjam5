#!/bin/sh
python sconv.py -t tga/tile01.tga bin/tile01.bin && \
python sconv.py -p tga/psprite01.tga bin/psprite01.bin && \
wla-gb -o obj/main.o src/main.asm && \
wlalink -r linkfile output.gb && \
true

