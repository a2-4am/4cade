#!/usr/bin/env python3

import math

def f(x,r):
    x = float(x)
    r = float(r)
    try:
        return math.sqrt(r*r*(1.0-(x*x/(r*r*0.6))))
    except:
        return 0

coords = [(255,255)]
for r in range(72, 0, -1):
    any = False
    for x in range(1, 41):
        y = round(f(x,r))
        if y > 48:
            continue
        for m in range(x, 41):
            for n in range(max(y,1), 49):
                if (m-1,n-1) not in coords:
                    coords.append((m-1,n-1))
                    any = True
    if any:
        coords.append((255,255))

coords.reverse()
with open("../../src/fx/fx.hgr.corner.circle.data.a", "w") as f:
    for x, y in coords:
        if x == 255:
            f.write("         !byte 255,255\n")
        else:
            f.write("         !byte %s,%s\n" % (47-y,39-x))
