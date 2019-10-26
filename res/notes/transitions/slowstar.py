#!/usr/bin/env python3

from math import sqrt, sin, cos, acos, pi

max_x = 280//2
max_y = 192//2

def f(t, k):
    t = float(t)
    r = k/cos(0.4*acos(sin(2.5*(t+pi/2))))
    return r*cos(t),r*sin(t)

coords = []
for k_mul in range(500):
    for t_mul in range(int(pi*1000+1)):
        a, b = f(float(t_mul/100), float(k_mul)/10.0)
        x = round(max_x//2+a*1.2)
        y = round(max_y//2+b)
        if y % 2 != 0:
            continue
        if x < 0 or x >= max_x or y < 0 or y >= max_y:
            continue
        coords.append((x,y))

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

with open("../../../src/fx/fx.hgr.slow.star.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))
