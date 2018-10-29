#!/usr/bin/env python3

import sys

alphabet = 'MNOPQRSTUVWXYZABCDEFGHIJKL'
with open(sys.argv[1]) as f:
    lines = f.readlines()
for c in alphabet:
    for line, row in zip(lines, range(len(lines))):
        for l, col in zip(line, range(len(line))):
            if l == c:
                print("%s,%s," % (row,col), end=' ')
    print("255,255")
