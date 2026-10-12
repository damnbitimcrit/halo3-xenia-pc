#!/usr/bin/env bash
# Clone xenia-canary at the pinned commit and apply the patch series on branch "blam".
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
dest="${1:-$repo_root/_xenia}"
commit="$(tr -d '[:space:]' < "$repo_root/xenia/UPSTREAM_COMMIT")"
if [ ! -d "$dest/.git" ]; then
  git init -q "$dest"
  git -C "$dest" remote add origin https://github.com/xenia-canary/xenia-canary
fi
git -C "$dest" fetch -q --depth 1 origin "$commit"
git -C "$dest" checkout -q -B blam "$commit"
shopt -s nullglob
patches=("$repo_root"/xenia/patches/*.patch)
if [ ${#patches[@]} -gt 0 ]; then
  git -C "$dest" -c user.name=blam -c user.email=blam@localhost am -q --3way --keep-non-patch "${patches[@]}"
fi
echo "xenia-canary $commit + ${#patches[@]} patch(es) at $dest"
