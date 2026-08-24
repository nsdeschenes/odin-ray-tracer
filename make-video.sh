#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/temp"

ffmpeg -y \
  -framerate 30 \
  -start_number 0 \
  -i 'image-%d.ppm' \
  -vf 'pad=ceil(iw/2)*2:ceil(ih/2)*2' \
  -c:v libx264 \
  -preset medium \
  -crf 18 \
  -pix_fmt yuv420p \
  ray-trace.mp4
