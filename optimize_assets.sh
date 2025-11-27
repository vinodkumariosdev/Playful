#!/usr/bin/env bash
set -euo pipefail

# KidLearn asset optimization script
# - Compress PNGs losslessly using sips
# - Convert WAV audio to M4A (AAC) to reduce size
# - Report before/after total sizes

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)
ASSETS_DIR="$ROOT_DIR/KidLearn/Assets.xcassets"
RESOURCES_DIR="$ROOT_DIR/KidLearn/Resources"

echo "[Asset Optimization] Starting..."

if [[ ! -d "$ASSETS_DIR" ]]; then
  echo "Assets directory not found: $ASSETS_DIR" >&2
fi
if [[ ! -d "$RESOURCES_DIR" ]]; then
  echo "Resources directory not found: $RESOURCES_DIR" >&2
fi

before_size=$(du -sh "$ASSETS_DIR" "$RESOURCES_DIR" 2>/dev/null | awk '{print $1}' | paste -sd+ -)
echo "Before sizes:"
du -sh "$ASSETS_DIR" "$RESOURCES_DIR" 2>/dev/null || true

optimize_png() {
  local png="$1"
  # sips will rewrite the file; use a temp to be safe
  local tmp="${png%.png}.tmp.png"
  sips -s format png "$png" --out "$tmp" >/dev/null 2>&1 || return 0
  # Replace if tmp exists and is smaller or equal
  if [[ -f "$tmp" ]]; then
    local orig_size=$(stat -f%z "$png")
    local new_size=$(stat -f%z "$tmp")
    if [[ "$new_size" -le "$orig_size" ]]; then
      mv "$tmp" "$png"
      echo "Optimized: $png ($orig_size -> $new_size bytes)"
    else
      rm -f "$tmp"
    fi
  fi
}

convert_wav_to_m4a() {
  local wav="$1"
  local m4a="${wav%.*}.m4a"
  # Use afconvert if available (macOS built-in)
  if command -v afconvert >/dev/null 2>&1; then
    afconvert -f m4af -d aac -s 2 "$wav" "$m4a" >/dev/null 2>&1 || return 0
    local wsize=$(stat -f%z "$wav")
    local msize=$(stat -f%z "$m4a")
    if [[ "$msize" -lt "$wsize" ]]; then
      echo "Converted: $wav -> $m4a ($wsize -> $msize bytes)"
    else
      echo "No size benefit for: $wav"
    fi
  else
    echo "afconvert not found; skipping audio conversion"
  fi
}

# Optimize PNGs in xcassets (imagesets) and resources
shopt -s nullglob
pngs=("$ASSETS_DIR"/**/*.png "$RESOURCES_DIR"/**/*.png)
for p in "${pngs[@]}"; do
  optimize_png "$p"
done

# Convert WAV to M4A in resources
wavs=("$RESOURCES_DIR"/*.wav)
for w in "${wavs[@]}"; do
  convert_wav_to_m4a "$w"
done

echo "After sizes:"
du -sh "$ASSETS_DIR" "$RESOURCES_DIR" 2>/dev/null || true
echo "[Asset Optimization] Done."

#!/bin/bash
# optimize_assets.sh
# Reduce PNG image size without noticeable quality loss using sips (macOS built-in)
# Usage: ./optimize_assets.sh

PROJECT_DIR="$(dirname "$0")/KidLearn"
ASSETS_DIR="$PROJECT_DIR/Resources"

if [ ! -d "$ASSETS_DIR" ]; then
  echo "Resources directory not found: $ASSETS_DIR"
  exit 1
fi

find "$ASSETS_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" \) | while read -r img; do
  echo "Optimizing $img"
  # Resize if larger than 1024px width (maintain aspect ratio)
  width=$(sips -g pixelWidth "$img" | awk '/pixelWidth/ {print $2}')
  if [ "$width" -gt 1024 ]; then
    sips -Z 1024 "$img" >/dev/null
  fi
  # Reduce quality for JPEG
  if [[ "$img" == *.jpg || "$img" == *.jpeg ]]; then
    sips -s format jpeg -s formatOptions 80 "$img" --out "$img" >/dev/null
  fi
  # For PNG, reduce bit depth to 8 if possible
  if [[ "$img" == *.png ]]; then
    sips -s format png -s formatOptions 8 "$img" --out "$img" >/dev/null
  fi
done

echo "Asset optimization complete."
