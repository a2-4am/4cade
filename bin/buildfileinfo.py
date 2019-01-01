#!/usr/bin/env python3

import sys
import os
import os.path

indir, intype, inaddress = sys.argv[1:]
with open(os.path.join(indir, "_FileInformation.txt"), "w") as writer:
    writer.write("\r\n".join(["%s=Type(%s),AuxType(%s),Access(C3)" % (f, intype, inaddress) for f in os.listdir(indir)]))
