#!/usr/bin/env python3

from math import sqrt, sin, cos, acos, pi
import util

max_x = 320
max_y = 200

def f(t, k, a):
    r = k/cos(0.4*acos(sin(2.5*(t+pi/2))))
    return r*cos(t+a),r*sin(t+a)

coords = []
for k_mul in range(1000):
    a = float(k_mul*pi/1000)
    for t_mul in range(int(pi*1000+1)):
        a, b = f(float(t_mul/100), float(k_mul)/10.0, a)
        x = round(max_x//2+a*1.2)
        y = round(max_y//2+b)
        if (y % 2 != 0):
            continue
        if x < 0 or x >= max_x//2 or y < 0 or y >= max_y//2:
            continue
        coords.append((y,x//2))

unique_coords = util.unique(coords)

util.write("../../../src/fx/fx.shr.soft.iris.data.a", unique_coords, header="""!cpu 6502
!to "build/FX/SHR.SFIRIS.DATA",plain
*=$9F00
""", footer="""         !byte 128
""")
