#!/usr/bin/env python3

from math import sqrt, sin, cos, pi

def f(t):
    t = float(t)
    return (0.6*sqrt(t)*cos(2*pi*sqrt(t)), sqrt(t)*sin(2*pi*sqrt(t)))

coords = []
for i in range(20000):
    any = False
    a, b = f(float(i)/10.0)
    x = round(20+a)
    y = round(24+b)
    if x < 0 or x > 39 or y < 0 or y > 47 or (x,y) in coords:
        continue
    coords.append((x,y))

with open("../../src/fx/fx.hgr.iris.data.a", "w") as f:
    for x, y in coords:
        f.write("         !byte %s,%s\n" % (y,x))
