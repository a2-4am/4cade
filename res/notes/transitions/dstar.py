#!/usr/bin/env python3

from math import sqrt, sin, cos, acos, pi

def f(t, k):
    t = float(t)
    r = k/cos(0.4*acos(sin(2.5*(t+pi/2))))
    return r*cos(t),r*sin(t)

coords = []
for k_mul in range(500):
    for t_mul in range(int(pi*1000+1)):
        a, b = f(float(t_mul/100), float(k_mul)/10.0)
        x = round(40+a*1.2)
        y = round(24+b)
        if x < 0 or x > 79 or y < 0 or y > 47 or (x,y) in coords:
            continue
        coords.append((x,y))

with open("../../src/fx/fx.dhgr.star.data.a", "w") as f:
    for x, y in coords:
        f.write("         !byte %s,%s\n" % (y,x))
