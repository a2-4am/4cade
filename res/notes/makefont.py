#!/usr/bin/env python3

import sys
import os.path

fontfile, srcfile = sys.argv[1:]
with open(fontfile, 'rb') as f:
    fontdata = f.read()
assert(len(fontdata) == 1024)
with open(srcfile, 'w') as f:
    for row in range(8):
        f.write("FontDataRow%s\n" % row)
        for i in range(128):
            b = fontdata[i*8+(7-row)]
            f.write("         !byte $%s\n" % hex(b)[2:].rjust(2, '0').upper())
