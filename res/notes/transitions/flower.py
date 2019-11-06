#!/usr/bin/env python3

from math import sqrt, sin, cos, acos, pi
import util

# Graph is plotted across the entire HGR screen, but only coordinates
#  - on every 3rd row
#  - on even columns
# are included.
#
# X coordinates are converted to byte+bitmask (but see notes below).
# Y coordinates are flipped (so 0,0 ends up on the bottom left) then
# divided by 3.
#
# 6502 code will be responsible for plotting each of these coordinates
# in a 2x3 block. The bitmask usually includes 2 adjacent pixels;
# the code will also plot the same 2 adjacent pixels in the next two rows.
#
# Unfortunately, since bytes are 7 pixels across, some of the 2-pixel-wide
# blocks will cross a byte boundary. To simplify the 6502 code, these are
# simply listed as separate coordinate pairs, each with a bitmask that
# includes 1 pixel instead of 2.

max_x = 280
max_y = 192

def f(theta, k):
    r = k*(5+2*cos(5*theta))
    return r*cos(theta),r*sin(theta)

coords = []
for k_mul in range(5000):
    for t_mul in range(int(pi*1000+1)):
        a, b = f(float(t_mul/100), float(k_mul)/100.0)
        x = round(max_x//2+a*1.2)
        y = round(max_y//2+b)
        if (x % 2 != 0) or (y % 3 != 0):
            continue
        if x < 0 or x >= max_x or y < 0 or y >= max_y:
            continue
        coords.append((x,y))

unique_coords = util.unique(coords)
unique_vals = util.vals_3bit(unique_coords)
with open("../../../src/fx/fx.hgr.flower.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

ripple_vals = util.ripple(unique_vals)
with open("../../../src/fx/fx.hgr.flower.ripple.data.a", "w") as f:
    for aval, bval in ripple_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

unique_vals.reverse()
with open("../../../src/fx/fx.hgr.flower.in.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))
