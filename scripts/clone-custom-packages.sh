#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <openwrt-dir> <manifest>" >&2
  exit 2
fi

openwrt_dir="$1"
manifest="$2"

if [ ! -d "$openwrt_dir" ]; then
  echo "OpenWrt directory not found: $openwrt_dir" >&2
  exit 1
fi

if [ ! -f "$manifest" ]; then
  echo "Manifest not found: $manifest" >&2
  exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"
  read -r repo dest ref extra <<< "$line"

  if [ -z "${repo:-}" ]; then
    continue
  fi

  if [ -z "${dest:-}" ]; then
    echo "Invalid manifest line: missing destination for $repo" >&2
    exit 1
  fi

  if [ -n "${extra:-}" ]; then
    echo "Invalid manifest line: too many fields for $repo" >&2
    exit 1
  fi

  target="$openwrt_dir/$dest"
  mkdir -p "$(dirname "$target")"

  if [ -d "$target/.git" ]; then
    echo "Already cloned: $dest"
    continue
  fi

  if [ -e "$target" ]; then
    echo "Destination exists but is not a git checkout: $target" >&2
    exit 1
  fi

  if [ -n "${ref:-}" ]; then
    git clone --depth=1 --branch "$ref" "$repo" "$target"
  else
    git clone --depth=1 "$repo" "$target"
  fi
done < "$manifest"
