#!/usr/bin/env python3

from math import sin, cos, pi, sqrt

def f(t):
    return (0.67*sqrt(t)*cos(2*pi*sqrt(t)), 0.5*sqrt(t)*sin(2*pi*sqrt(t)))

coords = []
for i in range(70000):
    a, b = f(i/10.0)
    x = round(40+a)
    y = round(24+b)
    if x < 0 or x > 79 or y < 0 or y > 47 or (x,y) in coords:
        continue
    coords.append((x,y))

with open("../../src/fx/fx.dhgr.iris.data.a", "w") as f:
    for x, y in coords:
        f.write("         !byte %s,%s\n" % (y,x))

radialcoords = []
L = len(coords)
for cs in zip(
        coords[:L//4],
        coords[L//4:L//2],
        coords[L//2:L*3//4],
        coords[L*3//4:]):
    for c in cs:
        radialcoords.append(c)
with open("../../src/fx/fx.dhgr.ripple.data.a", "w") as f:
    for x, y in radialcoords:
        f.write("         !byte %s,%s\n" % (y,x))
