#!/usr/bin/env python3

from math import sqrt, sin, cos, acos, pi

# Graph is plotted across the entire HGR screen, but only coordinates
#  - in the left half of the screen, AND
#  - on even rows, AND
#  - on even columns
# are included. It is assumed that the graph is symmetrical across
# the left and half sides of the screen (along an axis at X=140).
#
# X coordinates are converted to byte+bitmask (but see notes below).
# Y coordinates are incremented by 1 so that 0 can terminate the loop.
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
    t = float(t)
    r = k/cos(0.4*acos(sin(2.5*(t+pi/2))))
    return r*cos(t),r*sin(t)

coords = []
for k_mul in range(1000):
    for t_mul in range(int(pi*1000+1)):
        a, b = f(float(t_mul/100), float(k_mul)/10.0)
        x = round(max_x//2+a*1.2)
        y = round(max_y//2+b)
        if (x % 2 != 0) or (y % 2 != 0):
            continue
        if x < 0 or x >= max_x//2 or y < 0 or y >= max_y:
            continue
        coords.append((x,y))

d = {}
unique_coords = []
for c in coords:
    if not d.get(c):
        unique_coords.append(c)
        d[c] = 1

unique_vals = []
even_byte_bitmask = (0, 0, 1, 1, 2, 2, 3)
odd_byte_bitmask = (5, 5, 6, 6, 7, 7, 4)
for x, y in unique_coords:
    y = y + 1
    aval = "$" + hex(y)[2:].rjust(2, "0").upper()
    byte = x//7
    if byte % 2 == 0:
        # high 3 bits are 0-3, low 5 bits are 0-39
        bval = "%" + bin(even_byte_bitmask[x % 7])[2:].rjust(3, "0") + bin(byte)[2:].rjust(5, "0")
        unique_vals.append((aval, bval))
        if x % 7 == 6:
            # this 2x2 block will be split across bytes, so add an extra coordinate pair with the adjacent byte and high 3 bits = 4
            bval = "%100" + bin(byte+1)[2:].rjust(5, "0") + ";"
            unique_vals.append((aval, bval))
    else:
        # high 3 bits are 5-7 or 4, low 5 bits are 0-39
        bval = "%" + bin(odd_byte_bitmask[x % 7])[2:].rjust(3, "0") + bin(byte)[2:].rjust(5, "0")
        unique_vals.append((aval, bval))
        if x % 7 == 6:
            # this 2x2 block will be split across bytes, so add an extra coordinate pair with the adjacent byte and high 3 bits = 3
            bval = "%011" + bin(byte+1)[2:].rjust(5, "0") + ";"
            unique_vals.append((aval, bval))

with open("../../../src/fx/fx.hgr.star.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

ripple_vals = []
for i, j, k, l in zip(range(1920), range(1920,3840), range(3840,5760), range(5760,7680)):
    ripple_vals.append(unique_vals[i])
    ripple_vals.append(unique_vals[j])
    ripple_vals.append(unique_vals[k])
    ripple_vals.append(unique_vals[l])
with open("../../../src/fx/fx.hgr.star.ripple.data.a", "w") as f:
    for aval, bval in ripple_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

unique_vals.reverse()
with open("../../../src/fx/fx.hgr.star.in.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))
