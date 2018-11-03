#!/usr/bin/env python3

import math

def f(x,r):
    x = float(x)
    r = float(r)
    try:
        return math.sqrt(r*r*(1.0-((x-21.0)*(x-21.0)/(r*r*0.25))))
    except:
        return -1

coords = [(255,255)]
for r in range(0, 80):
    any = False
    for x in range(1, 41):
        y = round(f(x,r))
        if y < 0 or y > 48:
            continue
        for n in range(1, y+1):
            if (x-1,n-1) not in coords:
                coords.append((x-1,n-1))
                any = True
    if any:
        coords.append((255,255))
coords.pop()
coords.append((0,47))
coords.append((255,255))

with open("../../src/fx/fx.hgr.sunrise.data.a", "w") as f:
    for x, y in coords:
        if x == 255:
            f.write("         !byte 255,255\n")
        else:
            f.write("         !byte %s,%s\n" % (47-y,39-x))
