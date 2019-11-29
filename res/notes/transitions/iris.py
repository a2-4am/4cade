#!/usr/bin/env python3

from math import sqrt, sin, cos, pi
import util

radius_x = 280//2
radius_y = 192//2

def f(t):
    return (sqrt(t)*cos(2*pi*sqrt(t)), 0.87*sqrt(t)*sin(2*pi*sqrt(t)))

coords = []
for i in range(1000000):
    any = False
    a, b = f(float(i)/10.0)
    x = round(radius_x+a)
    y = round(radius_y+b)
    if y % 2 != 0:
        continue
    if x < 0 or x >= radius_x or y < 0 or y >= radius_y:
        continue
    coords.append((x,y))

unique_coords = util.unique(coords)
unique_vals = util.vals_1bit(unique_coords)

util.write("../../../src/fx/fx.hgr.iris.data.a", unique_vals)
util.write("../../../src/fx/fx.hgr.ripple.data.a", util.ripple(unique_vals))
unique_vals.reverse()
util.write("../../../src/fx/fx.hgr.iris.in.data.a", unique_vals)

corner4_coords = [(139-x,95-y) for (x,y) in unique_coords]
corner4_vals = util.vals_1bit(corner4_coords)
util.write("../../../src/fx/fx.hgr.corner4.in.data.a", corner4_vals)
corner4_vals.reverse()
util.write("../../../src/fx/fx.hgr.corner4.out.data.a", corner4_vals)
util.write("../../../src/fx/fx.hgr.swirl.data.a", util.ripple(util.ripple(corner4_vals)))
mult_coords = util.ripple(util.quadrant_multiply(util.ripple(util.quadrant_multiply(util.ripple(util.quadrant_multiply(unique_coords))))))
util.write("../../../src/fx/fx.hgr.bubbles.data.a", util.vals_1bit(mult_coords))
mult_coords.reverse()
util.write("../../../src/fx/fx.hgr.bubbles.in.data.a", util.vals_1bit(mult_coords))
mult_coords = util.halfripple(util.ripple(util.radial_multiply(util.radial_multiply(unique_coords))))
util.write("../../../src/fx/fx.hgr.radbubbles.data.a", util.vals_1bit(mult_coords))
