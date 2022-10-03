#!/bin/bash

# directory of PNG files (assume they are properly sized and named)
PNGS="$HOME/Dropbox/a2/4cade/artwork/cropped-and-named-320x200"

# Python 3
export PYTHON="python"

# https://github.com/KrisKennaway/ii-pix/
export CONVERT_PY="$HOME/Documents/a2/ii-pix/convert.py"

# directories within Total Replay repository
export SHR_SCORES="./res/ARTWORK.SHR.SCORES"
export SHR_UNCOMPRESSED="./res/ARTWORK.SHR.UNCOMPRESSED"

# convert.py flags:
# --no-show-output   to suppress focus-stealing popup window during conversion
# --no-save-preview  to suppress saving -preview.png file
# --fixed-colours=1  to prevent visual glitches during transition from black
# --show-final-score to get score so the score matching can work

while true; do
    parallel '
      tmp=$(mktemp)
      newscore=$("$PYTHON" "$CONVERT_PY" shr --no-show-output --no-save-preview --fixed-colours=1 --show-final-score {} "$tmp" | grep FINAL_SCORE | cut -d":" -f2)
      oldscore=$(<"$SHR_SCORES"/{/.})
      if [ -z "$oldscore" ]; then
        oldscore=10000
      fi
      if (( $(echo "$newscore < $oldscore" | bc) )); then
        cp "$tmp" "$SHR_UNCOMPRESSED/"{/.}
        echo "$newscore" > "$SHR_SCORES/"{/.}
      fi
      rm "$tmp"' ::: "$PNGS"/*.png
done
