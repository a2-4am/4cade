#!/usr/bin/env python3

from math import sqrt, sin, cos, acos, pi
import util

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

unique_coords = util.unique(coords)
unique_vals = util.vals_1bit(unique_coords)

util.write("../../../src/fx/fx.hgr.slow.star.data.a",  unique_vals)

unique_vals.reverse()
util.write("../../../src/fx/fx.hgr.slow.star.in.data.a", unique_vals)

mult_coords = util.ripple(util.radial_multiply(unique_coords))
util.write("../../../src/fx/fx.hgr.full.of.stars.data.a", util.vals_1bit(mult_coords))
