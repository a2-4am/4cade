#!/usr/bin/env python3

import sys
import os
import os.path

indir = sys.argv[1]
with open(os.path.join(indir, "_FileInformation.txt"), "w") as writer:
    writer.write("\r\n".join(["%s=Type(06),AuxType(2000),Access(C3)" % f for f in os.listdir(indir)]))
