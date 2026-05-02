#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <openwrt-dir> <patch-dir>" >&2
  exit 2
fi

openwrt_dir="$1"
patch_dir="$2"

if [ ! -d "$openwrt_dir/.git" ]; then
  echo "OpenWrt git checkout not found: $openwrt_dir" >&2
  exit 1
fi

if [ ! -d "$patch_dir" ]; then
  echo "Patch directory not found: $patch_dir" >&2
  exit 1
fi

+openwrt_dir="$(cd "$openwrt_dir" && pwd -P)"
+patch_dir="$(cd "$patch_dir" && pwd -P)"

shopt -s nullglob
patches=("$patch_dir"/*.patch)

if [ "${#patches[@]}" -eq 0 ]; then
  echo "No patches found in $patch_dir"
  exit 0
fi

for patch in "${patches[@]}"; do
  name="$(basename "$patch")"

  if git -C "$openwrt_dir" apply --check "$patch" 2>/dev/null; then
    echo "Applying $name"
    git -C "$openwrt_dir" apply "$patch"
    continue
  fi

  if git -C "$openwrt_dir" apply --reverse --check "$patch" 2>/dev/null; then
    echo "Already applied: $name"
    continue
  fi

  echo "Failed to apply $name" >&2
  git -C "$openwrt_dir" apply --check "$patch"
done
