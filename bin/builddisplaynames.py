#!/usr/bin/env python3

# usage:
# builddisplaynames.py < res/GAMES.CONF > build/GAMES.CONF.WITH.NAMES

import sys

for line in sys.stdin:
    if "," not in line: continue
    if line.startswith("#"): continue
    if "=" not in line:
        prefix, key = line.split(",")
        line = prefix + "," + key.strip() + "=" + key.replace(".", " ").title().replace(" Ii", " II")
    print(line, end="")
