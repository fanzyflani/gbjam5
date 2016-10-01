import sys, struct

#
# DETERMINE MODE
#

mode = sys.argv[1]

mode_player = False
mode_sprite = False
mode_tile = False
if mode == "-p":
	mode_player = True
elif mode == "-s":
	mode_sprite = True
elif mode == "-t":
	mode_tile = True
else:
	assert False, "invalid mode"

#
# LOAD IMAGE
#

tiles = []
fp = open(sys.argv[2], "rb")
fp.read(12)
width, height, = struct.unpack("<HH", fp.read(4))
assert width%8 == 0
assert height%8 == 0
fp.read(2)
fp.read(256*3)

print width, height
for cy in xrange(height//8):
	tiles.append([])
	lbufs = []
	for sy in xrange(8):
		lbufs.append(list(ord(v) for v in fp.read(width)))
	
	for cx in xrange(0,width,8):
		t = []
		for sy in xrange(8):
			for sx in xrange(8):
				t.append(lbufs[sy][sx+cx])
	
		tiles[-1].append(t)

fp.close()

#
# PROCESS PER MODE
#

fp = open(sys.argv[3], "wb")

LUT4 = [
	0b0000,
	0b0101,
	0b0110,
	0b1001,
	0b1010,
	0b1110,
	0b1011,
	0b1111,
]

LUT3 = [
	0b000,
	0b000,
	0b001,
	0b010,
	0b011,
	0b100,
	0b101,
	0b110,
]

def decompose_4bpp(t):
	s0 = ""
	s1 = ""
	for y in xrange(8):
		v00 = 0
		v01 = 0
		v10 = 0
		v11 = 0
		for x in xrange(8):
			b = LUT4[t[y*8+x]]
			if b&1: v00 |= 128>>x
			if b&2: v01 |= 128>>x
			if b&4: v10 |= 128>>x
			if b&8: v11 |= 128>>x

		s0 += chr(v00)+chr(v01)
		s1 += chr(v10)+chr(v11)

	return s0, s1

def decompose_3bpp(t):
	s = ""
	for y in xrange(8):
		v0 = 0
		v1 = 0
		v2 = 0
		for x in xrange(8):
			b = LUT3[t[y*8+x]]
			if b&1: v0 |= 128>>x
			if b&2: v1 |= 128>>x
			if b&4: v2 |= 128>>x

		s += chr(v0)+chr(v1)+chr(v2)

	return s

def proc_tile(cx, cy):
	return decompose_3bpp(tiles[cy][cx])

def proc_sprite(cx, cy):
	t00, t01 = decompose_4bpp(tiles[2*cy+0][cx])
	t10, t11 = decompose_4bpp(tiles[2*cy+1][cx])

	return t00+t10+t01+t11

if mode_player:
	assert height == 16*4
	for cx in xrange(width//8):
		for cy in xrange(4):
			s = proc_sprite(cx, cy)
			assert len(s) == 16*4
			fp.write(s)
elif mode_tile:
	for cy in xrange(height//8):
		for cx in xrange(width//8):
			s = proc_tile(cx, cy)
			assert len(s) == 8*3
			fp.write(s)

fp.close()



