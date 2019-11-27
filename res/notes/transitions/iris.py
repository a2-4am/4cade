#!/usr/bin/env python3

from math import sqrt, sin, cos, pi
import util

radius_x = 280//2
radius_y = 192//2

def f(t):
    return (sqrt(t)*cos(2*pi*sqrt(t)), 0.87*sqrt(t)*sin(2*pi*sqrt(t)))

coords = []
for i in range(1000000):
    any = False
    a, b = f(float(i)/10.0)
    x = round(radius_x+a)
    y = round(radius_y+b)
    if y % 2 != 0:
        continue
    if x < 0 or x >= radius_x or y < 0 or y >= radius_y:
        continue
    coords.append((x,y))

unique_coords = util.unique(coords)
unique_vals = util.vals_1bit(unique_coords)

with open("../../../src/fx/fx.hgr.iris.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

unique_vals.reverse()
with open("../../../src/fx/fx.hgr.iris.in.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

unique_vals.reverse()
ripple_vals = util.ripple(unique_vals)
with open("../../../src/fx/fx.hgr.ripple.data.a", "w") as f:
    for aval, bval in ripple_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

corner4_coords = [(139-x,95-y) for (x,y) in unique_coords]
corner4_vals = util.vals_1bit(corner4_coords)
with open("../../../src/fx/fx.hgr.corner4.in.data.a", "w") as f:
    for aval, bval in corner4_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))
corner4_vals.reverse()
with open("../../../src/fx/fx.hgr.corner4.out.data.a", "w") as f:
    for aval, bval in corner4_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

swirl_vals = util.ripple(util.ripple(corner4_vals))
with open("../../../src/fx/fx.hgr.swirl.data.a", "w") as f:
    for aval, bval in swirl_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))
