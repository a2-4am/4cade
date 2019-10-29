#!/usr/bin/env python3

from math import sqrt, sin, cos, acos, pi
import util

# Graph is plotted across the entire HGR screen, but only coordinates
#  - in the left half of the screen, AND
#  - on even rows, AND
#  - on even columns
# are included. It is assumed that the graph is symmetrical across
# the left and half sides of the screen (along an axis at X=140).
#
# X coordinates are converted to byte+bitmask (but see notes below).
# Y coordinates are flipped (so 0,0 ends up on the bottom left) then
# incremented by 1 so that 0 can terminate the loop,
#
# 6502 code will be responsible for plotting each of these coordinates
# in a 2x2 block. The bitmask usually includes 2 adjacent pixels;
# the code will also plot the same 2 adjacent pixels in the adjacent row,
# AND mirror both of those plots in the right half of the screen.
#
# Unfortunately, since bytes are 7 bits across, some blocks will cross a
# byte boundary. To simplify the 6502 code, those are simply listed as
# separate coordinate pairs, each with a bitmask that includes 1 pixel
# instead of 2.

max_x = 280
max_y = 192

def f(t, k):
    r = k/cos(0.4*acos(sin(2.5*(t+pi/2))))
    return r*cos(t+pi-(pi*k/50)),r*sin(t+pi-(pi*k/50))

coords = []
for k_mul in range(5000):
    for t_mul in range(int(pi*1000+1)):
        a, b = f(float(t_mul/100), float(k_mul)/5.0)
        x = round(max_x//2+a*1.2)
        y = round(max_y//2+b)
        if (x % 2 != 0) or (y % 2 != 0):
            continue
        if x < 0 or x >= max_x//2 or y < 0 or y >= max_y:
            continue
        coords.append((x,y))

unique_coords = util.unique(coords)
unique_vals = util.vals_2bit(unique_coords)
unique_vals.reverse()
with open("../../../src/fx/fx.hgr.star.bloom.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))
