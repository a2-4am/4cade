#!/usr/bin/env python3
import sys

infile = sys.argv[1]
outfile = sys.argv[2]

with open(infile,"rb") as i:
  filedata = i.read()

# If the file has a JMP in the last screen hole, the
# game has an animated title, skip packing and copy
# the file as is instead.
# Some HGR files were saved as 8184 bytes (without
# final screen hole) so check file length first.
if(len(filedata) >= 8192 and filedata[8189] == 0x4c):
  print (infile, "has animation, not packing")
  outdata = bytearray(filedata[0:8192])
else:
  outdata = bytearray(filedata[0:7680])
  for h in range(60):
    oh = h*128+120
    ih = h*8+7680+(int(h/15)*8)
    outdata[oh:oh+8] = filedata[ih:ih+8]

with open(outfile,"wb") as o:
  o.write(outdata)
