#!/usr/bin/env python3

import PIL.Image # https://pillow.readthedocs.io/
import util

# star7.png is the source image. The source image MUST have a white background,
# but other colors and pixel depth are irrelevant. This one is black & white.
# Due to the Apple II pixel aspect ratio, we do a 1-time aspect-ratio-losing resize
# to squash the image to 87% height.
#
# $ gm convert star7.png -resize "100%x87%!" squash.png
# (Depending on your shell, you may need to escape the exclamation point. Grr.)
#
# Now we can create individual images for each "frame" of the animation, by
# resizing the (squashed) source image and putting it in a 280x192 frame.
#
# $ for w in $(seq 1 1500); do \
#     gm convert -size 280x192 squash.png \
#                -resize "$w" \
#                -background white \
#                -compose Copy \
#                -gravity center \
#                -extent 280x192 thumb"$w".png; \
#   done
#
# Depending on the source image, you may need more or fewer than 1500 frames. This
# number is duplicated below in the |frames| variable. Sorry.
#
# Now we have 1500 (or so) PNG images of what the HGR screen should look like at
# each stage. Despite each frame being 280x192 and in the correct aspect ratio,
# only coordinates
#  - in the left half of the screen, AND
#  - on even rows, AND
#  - on even columns
# are included. It is assumed that the image is symmetrical across
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

frames = 1500 # number of "thumbN.png" files

coords = []
for i in range(1, frames):
    p = PIL.Image.open("star7/thumb%s.png" % i)
    for x in range(0, 280//2, 2):
        for y in range(0, 192, 2):
            if p.getpixel((x,191-y)) == (0,0,0,255):
                coords.append((x,y))

unique_coords = util.unique(coords)
unique_vals = util.vals_2bit(unique_coords)
with open("../../../src/fx/fx.hgr.star7.data.a", "w") as f:
    for aval, bval in unique_vals:
        f.write("         !byte %s,%s\n" % (aval, bval))
