#!/usr/bin/env python3

import PIL.Image # https://pillow.readthedocs.io/
import util

# snowflake.png is the source image. The source image MUST have a white background,
# but other colors and pixel depth are irrelevant. This one is black & white.
# Due to the Apple II pixel aspect ratio, we do a 1-time aspect-ratio-losing resize
# to squash the image to 92% height.
#
# $ gm convert snowflake.png -resize "100%x92%!" squash.png
# (Depending on your shell, you may need to escape the exclamation point. Grr.)
#
# Now we can create individual images for each "frame" of the animation, by
# resizing the (squashed) source image and putting it in a 280x192 frame.
#
# $ for w in `seq 1 500`; do \
#     gm convert -size 160x100 squash.png \
#                -resize "$w" \
#                -background white \
#                -compose Copy \
#                -gravity center \
#                -extent 160x100 thumb"$w".png; \
#   done
#
# Depending on the source image, you may need more or fewer than 500 frames. This
# number is duplicated below in the |frames| variable. Sorry.
#

frames = 500 # number of "thumbN.png" files

coords = []
for i in range(1,frames):
    p = PIL.Image.open("snowflake/thumb%s.png" % i)
    for x in range(0, 160//2):
        for y in range(0, 100//2):
            if p.getpixel((x,99-y))[0] != 255:
                coords.append((y*2,x))

unique_coords = util.unique(coords)

util.write("../../../src/fx/fx.shr.snowflake.data.a", unique_coords, header="""!cpu 6502
!to "build/FX/SHR.FLAKE.DATA",plain
*=$9F00
""")
