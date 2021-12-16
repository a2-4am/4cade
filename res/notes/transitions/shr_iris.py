#!/usr/bin/env python3

from math import sqrt, sin, cos, pi
import util

radius_x = 160//2
radius_y = 100//2

def f(t):
    return (sqrt(t)*cos(2*pi*sqrt(t)), 0.92*sqrt(t)*sin(2*pi*sqrt(t)))

coords = []
for i in range(1000000):
    any = False
    a, b = f(float(i)/10.0)
    x = round(radius_x+a)
    y = round(radius_y+b)
    if x < 0 or x >= radius_x or y < 0 or y >= radius_y:
        continue
    coords.append((y*2,x))

unique_coords = util.unique(coords)

util.write("../../../src/fx/fx.shr.iris.data.a", unique_coords, header="""!cpu 6502
!to "build/FX/SHR.IRIS.DATA",plain
*=$9F00
""", footer="""         !byte 128
""")

unique_coords.reverse()
util.write("../../../src/fx/fx.shr.iris.in.data.a", unique_coords, header="""!cpu 6502
!to "build/FX/SHR.IRISIN.DATA",plain
*=$9F00
""", footer="""         !byte 128
""")
unique_coords.reverse()

util.write("../../../src/fx/fx.shr.ripple.data.a", util.ripple(unique_coords), header="""!cpu 6502
!to "build/FX/SHR.RIPPLE.DATA",plain
*=$9F00
""", footer="""         !byte 128
""")
