#!/usr/bin/env python3

from math import sqrt, sin, cos, acos, pi
import util

max_x = 280
max_y = 192

def f(t):
    return (sqrt(t)*cos(2*pi*sqrt(t)), 0.87*sqrt(t)*sin(2*pi*sqrt(t)))

coords = []
for i in range(2000000):
    a, b = f(float(i)/10.0)
    x = round(max_x+a)
    y = round(b)
    if x % 2 != 0 or y % 3 != 0:
        continue
    if x < 0 or x >= max_x or y < 0 or y >= max_y:
        continue
    coords.append((x,y))

unique_coords = util.unique(coords)
unique_vals = util.vals_3bit(unique_coords)
ripple_vals = util.ripple(util.ripple(unique_vals))
with open("../../../src/fx/fx.hgr.corner.superripple.data.a", "w") as f:
    for aval, bval in ripple_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))
