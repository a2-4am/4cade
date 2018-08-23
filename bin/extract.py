#!/usr/bin/env python3

import sys
import glob
import os.path

indir = sys.argv[1]
for infile in glob.glob(os.path.join(indir, "*.po")):
    print("cadius EXTRACTVOLUME \"" + infile + "\" build/X/ || cadius EXTRACTVOLUME \"" + infile + "\" build/X/")
