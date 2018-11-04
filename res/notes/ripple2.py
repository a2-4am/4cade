#!/usr/bin/env python3

from math import sqrt, sin, cos, acos, pi

def f(t, k):
    t = float(t)
    r = k*(1-cos(t)*sin(3*t))
    return r*cos(t),r*sin(t)

coords = []
for k_mul in range(3013):
    print(k_mul)
    for t_mul in range(int(pi*100+1)):
        a, b = f(float(t_mul/10), float(k_mul)/10.0)
        x = round(20+a*.6)
        y = round(24+b)
        if x < 0 or x > 39 or y < 0 or y > 47 or (x,y) in coords:
            continue
        coords.append((x,y))

L = len(coords)
q1 = coords[0:L//4]
q2 = coords[L//4:L//2]
q3 = coords[L//2:L*3//4]
q4 = coords[L*3//4:]
q1.reverse()
q3.reverse()
coords = []
for cs in zip(q1, q2, q3, q4):
    for c in cs:
        coords.append(c)
    coords.append((255,255))
with open("../../src/fx/fx.hgr.ripple2.data.a", "w") as f:
    for x, y in coords:
        f.write("         !byte %s,%s\n" % (y,x))
