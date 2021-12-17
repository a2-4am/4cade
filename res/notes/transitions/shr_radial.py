#!/usr/bin/env python3

import math
import util

radius_x = 160//2
radius_y = 100//2

def f(x,r=36.3):
    try:
        return math.sqrt(r*r*(1.0-(x*x/(r*r*0.6))))
    except:
        return -1

coords = []
for i in range(30000, 0, -1):
    a = float(i)/1000.0
    b = f(a)
    for x in range(80, 0, -1):
        y = round(float(x)*b/a)
        if x < 1 or x > radius_x or y < 1 or y > radius_y:
            continue
        for m in range(1, y+1):
            coords.append((2*(radius_y - m), radius_x - x))

unique_coords = util.unique(coords)

util.write("../../../src/fx/fx.shr.radial.data.a",  unique_coords, header="""!cpu 6502
!to "build/FX/SHR.RADIAL.DATA",plain
*=$9F00
""", footer="""         !byte 128
""")
