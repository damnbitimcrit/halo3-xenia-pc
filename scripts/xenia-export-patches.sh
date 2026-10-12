#!/usr/bin/env bash
# Regenerate xenia/patches/ from the commits on top of the pinned upstream commit.
set -euo pipefail
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
src="${1:-$repo_root/_xenia}"
commit="$(tr -d '[:space:]' < "$repo_root/xenia/UPSTREAM_COMMIT")"
rm -f "$repo_root"/xenia/patches/*.patch
git -C "$src" format-patch -q -N --no-signature --zero-commit -o "$repo_root/xenia/patches" "$commit..HEAD"
ls "$repo_root/xenia/patches"
