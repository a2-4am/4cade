#!/bin/bash

# Add or unconditionally replace SHR file with newly converted PNG file
# Also saves final error score from conversion
# Also removes old compressed asset of the same name, if any

# parameters
# 1 - input file (PNG, must be properly sized and named)

# Python 3
PYTHON="python"

# https://github.com/KrisKennaway/ii-pix/
CONVERT_PY="$HOME/Documents/a2/ii-pix/convert.py"

# directories within Total Replay repository
SHR_SCORES="./res/ARTWORK.SHR.SCORES"
SHR_COMPRESSED="./res/ARTWORK.SHR"
SHR_UNCOMPRESSED="./res/ARTWORK.SHR.UNCOMPRESSED"

inputname=$(basename "$1") # e.g. "ZAXXON.png"
shr_name="${inputname%.*}" # e.g. "ZAXXON"

"$PYTHON" "$CONVERT_PY" shr \
          --no-show-output \
          --no-save-preview \
          --fixed-colours=1 \
          --show-final-score \
          "$1" \
          "$SHR_UNCOMPRESSED/$shr_name" | \
    grep FINAL_SCORE | \
    cut -d":" -f2 \
        > "$SHR_SCORES/$shr_name"
rm -f "$SHR_COMPRESSED/$shr_name"
