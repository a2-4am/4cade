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
radius_x = max_x//2
radius_y = max_y//2

def f(t, k):
    return (k*16*sin(t)*sin(t)*sin(t), k*(13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t)))

coords = []
for k_mul in range(2000):
    for t_mul in range(int(2*pi*1000+1)):
        a, b = f(float(t_mul)/1000.0, float(k_mul)/100.0)
        x = round(radius_x+a*1.2)
        y = round(radius_y+b)
        if (x % 2 != 0) or (y % 2 != 0):
            continue
        if x < 0 or x >= max_x//2 or y < 0 or y >= max_y:
            continue
        coords.append((x,y))

unique_coords = util.unique(coords)
unique_vals = util.vals_2bit(unique_coords)

with open("../../../src/fx/fx.hgr.heart.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

ripple_vals = []
for i, j, k, l in zip(range(1920), range(1920,3840), range(3840,5760), range(5760,7680)):
    ripple_vals.append(unique_vals[i])
    ripple_vals.append(unique_vals[j])
    ripple_vals.append(unique_vals[k])
    ripple_vals.append(unique_vals[l])
with open("../../../src/fx/fx.hgr.heart.ripple.data.a", "w") as f:
    for aval, bval in ripple_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

unique_vals.reverse()
with open("../../../src/fx/fx.hgr.heart.in.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))
