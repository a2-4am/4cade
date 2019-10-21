#!/usr/bin/env python3

from math import sqrt, sin, cos, pi

radius_x = 280/2
radius_y = 192/2

def f(t):
    return (sqrt(t)*cos(2*pi*sqrt(t)), 0.82*sqrt(t)*sin(2*pi*sqrt(t)))

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

d = {}
unique_coords = []
for c in coords:
    if not d.get(c):
        unique_coords.append(c)
        d[c] = 1
    if len(unique_coords) == 10000:
        break
with open("../../../src/fx/fx.hgr.iris.data.a", "w") as f:
    for x, y in unique_coords:
        aval = "$" + hex(y)[2:].rjust(2, "0").upper()
        bval = "%" + \
            bin(x%7)[2:].rjust(3, "0") + \
            bin(x//7)[2:].rjust(5, "0")
        f.write("         !byte %s,%s\n" % (aval, bval))
