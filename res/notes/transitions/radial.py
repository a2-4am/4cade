#!/usr/bin/env python3

import math
import util

radius_x = 280//2
radius_y = 192//2

def f(x,r=36.3):
    try:
        return math.sqrt(r*r*(1.0-(x*x/(r*r*0.6))))
    except:
        return -1

coords = []
for i in range(30000, 0, -1):
    a = float(i)/1000.0
    b = f(a)
    for x in range(140, 0, -1):
        y = round(float(x)*b/a)
        if x < 1 or x > radius_x or y < 1 or y > radius_y:
            continue
        for m in range(1, y+1):
            if m % 2 != 0:
                continue
            coords.append((radius_x - x,radius_y - m))

d = {}
unique_coords = []
for c in coords:
    if not d.get(c):
        unique_coords.append(c)
        d[c] = 1

unique_vals = []
for x, y in unique_coords:
    aval = "$" + hex(y)[2:].rjust(2, "0").upper()
    bval = "%" + \
        bin(x%7)[2:].rjust(3, "0") + \
        bin(x//7)[2:].rjust(5, "0")
    unique_vals.append((aval, bval))

with open("../../../src/fx/fx.hgr.radial.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

with open("../../../src/fx/fx.hgr.radial2.data.a", "w") as f:
    for aval, bval in util.halfripple(unique_vals):
        f.write("         !byte %s,%s\n" % (aval, bval))

with open("../../../src/fx/fx.hgr.radial4.data.a", "w") as f:
    for aval, bval in util.ripple(unique_vals):
        f.write("         !byte %s,%s\n" % (aval, bval))

with open("../../../src/fx/fx.hgr.radial5.data.a", "w") as f:
    for aval, bval in util.ripple(util.halfripple(unique_vals)):
        f.write("         !byte %s,%s\n" % (aval, bval))
