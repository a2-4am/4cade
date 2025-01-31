#!/usr/bin/env python3
import sys

infile = sys.argv[1]
outfile = sys.argv[2]

with open(infile,"rb") as i:
  filedata = i.read()

outaux = bytearray(filedata[0:7680])
outmain = bytearray(filedata[8192:15872])
for h in range(60):
  oh = h*128+120
  ih = h*8+7680+(int(h/15)*8)
  outaux[oh:oh+8] = filedata[ih:ih+8]
  outmain[oh:oh+8] = filedata[ih+8192:ih+8192+8]

with open(outfile,"wb") as o:
  o.write(outaux)
  o.write(outmain)
