#!/usr/bin/env python3

# usage:
# builddisplaynames.py < build/GAMES.CONF > build/DISPLAY.CONF

import sys

for line in sys.stdin:
    if line.startswith("["): continue
    if "=" not in line:
        prefix, key = line.split(",")
        line = prefix + "," + key.strip() + "=" + key.replace(".", " ").title().replace(" Ii", " II")
    print(line, end="")
