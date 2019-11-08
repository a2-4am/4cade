#!/usr/bin/env python3

import PIL.Image # https://pillow.readthedocs.io/
import util

# mandelbrot.jpg is the source image. The source image MUST have a white background,
# but other colors and pixel depth are irrelevant. This one is black & white.
# Due to the Apple II pixel aspect ratio, we do a 1-time aspect-ratio-losing resize
# to squash the image to 87% height.
#
# $ gm convert mandelbrot.jpg -resize "100%x87%!" squash.png
# (Depending on your shell, you may need to escape the exclamation point. Grr.)
#
# Now we can create individual images for each "frame" of the animation, by
# resizing the (squashed) source image and putting it in a 280x192 frame.
#
# $ for w in `seq 1 1500`; do \
#     gm convert -size 280x192 squash.png \
#                -resize "$w" \
#                -background white \
#                -compose Copy \
#                -gravity center \
#                -extent 280x192 thumb"$w".png; \
#   done
#
# Depending on the source image, you may need more or fewer than 500 frames. This
# number is duplimandelbroted below in the |frames| variable. Sorry.
#
# Now we have 1500 (or so) PNG images of what the HGR screen should look like at
# each stage. Despite each frame being 280x192 and in the correct aspect ratio,
# only coordinates
#  - on every 3rd row
#  - on even columns
# are included in the final data set.
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

frames = 1500 # number of "thumbN.png" files

coords = []
for i in range(5, frames, 5):
    p = PIL.Image.open("mandelbrot/thumb%s.png" % i)
    for x in range(0, 280, 2):
        for y in range(0, 192, 3):
            if p.getpixel((x,191-y)) == (0,0,0):
                coords.append((x,y))

unique_coords = util.unique(coords)
unique_vals = util.vals_3bit(unique_coords)
with open("../../../src/fx/fx.hgr.mandelbrot.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

ripple_vals = util.ripple(unique_vals)
with open("../../../src/fx/fx.hgr.mandelbrot.ripple.data.a", "w") as f:
    for aval, bval in ripple_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))

unique_vals.reverse()
with open("../../../src/fx/fx.hgr.mandelbrot.in.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))
