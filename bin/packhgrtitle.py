#!/usr/bin/env python3
import sys

infile = sys.argv[1]
outfile = sys.argv[2]

i = open(infile,"rb")
filedata = i.read()
i.close

outdata = bytearray(filedata[0:7680])

for h in range(60):
  oh = h*128+120
  ih = h*8+7680+(int(h/15)*8)
  outdata[oh:oh+8] = filedata[ih:ih+8]

o = open(outfile,"wb")
o.write(outdata)
o.close

