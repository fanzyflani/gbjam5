#!/bin/sh
python sconv.py -t tga/tile01.tga bin/tile01.bin && \
python sconv.py -p tga/psprite01.tga bin/psprite01.bin && \
wla-gb -v -o obj/main.o src/main.asm && \
wlalink -v -r linkfile output.tmp && \
dd if=output.tmp of=output.gb bs=32K count=1 && \
(rm output.tmp || true) && \
true

