#!/usr/bin/env python3

import math

def f(x,r=36.3):
    try:
        return math.sqrt(r*r*(1.0-(x*x/(r*r*0.6))))
    except:
        return -1

coords = [(255,255)]
for i in range(300, 0, -1):
    a = float(i)/10.0
    any = False
    b = f(a)
    for x in range(20, 0, -1):
        y = round(float(x)*b/a)
        if y < 1 or y > 24:
            continue
        for m in range(1, y+1):
            if (x-1,m-1) not in coords:
                coords.append((x-1,m-1))
                any = True
    if any:
        coords.append((255,255))

q1 = coords.copy()
q2 = [(-x-1,y) for x,y in coords]
q2.reverse()
q3 = [(-x-1,-y-1) for x,y in coords]
q4 = [(x,-y-1) for x,y in coords]
q4.reverse()
coords = q4 + q1 + q2 + q3
with open("../../src/fx/fx.hgr.radial.data.a", "w") as f:
    for x, y in coords:
        if x not in range(-40,40):
            f.write("         !byte 255,255\n")
        else:
            f.write("         !byte %s,%s\n" % ((23-y,19-x)))

coords = []
for cs in list(zip(q1,q3)) + list(zip(q2,q4)):
    for c in cs:
        coords.append(c)
with open("../../src/fx/fx.hgr.radial2.data.a", "w") as f:
    for x, y in coords:
        if x not in range(-40,40):
            f.write("         !byte 255,255\n")
        else:
            f.write("         !byte %s,%s\n" % ((23-y,19-x)))

coords = []
for cs in zip(q1,q2,q3,q4):
    for c in cs:
        coords.append(c)
with open("../../src/fx/fx.hgr.radial3.data.a", "w") as f:
    for x, y in coords:
        if x not in range(-40,40):
            f.write("         !byte 255,255\n")
        else:
            f.write("         !byte %s,%s\n" % ((23-y,19-x)))

q1.reverse()
q3.reverse()
coords = []
for cs in zip(q1,q2,q3,q4):
    for c in cs:
        coords.append(c)
with open("../../src/fx/fx.hgr.radial4.data.a", "w") as f:
    for x, y in coords:
        if x not in range(-40,40):
            f.write("         !byte 255,255\n")
        else:
            f.write("         !byte %s,%s\n" % ((23-y,19-x)))

q1.reverse()
q2.reverse()
q3.reverse()
q4.reverse()
coords = []
for cs in zip(q1,q2,q3,q4):
    for c in cs:
        coords.append(c)
with open("../../src/fx/fx.hgr.radial5.data.a", "w") as f:
    for x, y in coords:
        if x not in range(-40,40):
            f.write("         !byte 255,255\n")
        else:
            f.write("         !byte %s,%s\n" % ((23-y,19-x)))
