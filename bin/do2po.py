#!/usr/bin/env python3

import sys
import glob
import os.path

kMap = {0x00: 0x00,
        0x07: 0x08,
        0x0E: 0x01,
        0x06: 0x09,
        0x0D: 0x02,
        0x05: 0x0A,
        0x0C: 0x03,
        0x04: 0x0B,
        0x0B: 0x04,
        0x03: 0x0C,
        0x0A: 0x05,
        0x02: 0x0D,
        0x09: 0x06,
        0x01: 0x0E,
        0x08: 0x07,
        0x0F: 0x0F}

indir, outdir = sys.argv[1:3]

for infile in glob.glob(os.path.join(indir, "*.dsk")):
    outfile = os.path.join(outdir, os.path.splitext(os.path.basename(infile))[0] + ".po")
    with open(infile, 'rb') as f, open(outfile, 'wb') as g:
        for track in range(0, 0x23):
            sectors = [bytes(256)] * 0x10
            for dos_sector in range(0, 0x10):
                sectors[kMap[dos_sector]] = f.read(256)
            g.write(b"".join(sectors))
