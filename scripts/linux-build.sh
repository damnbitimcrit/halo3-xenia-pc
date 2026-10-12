#!/usr/bin/env bash
# Build the patched Xenia and its unit tests on Linux (clang) to check that
# the series compiles. The Windows exe comes from CI.
#
#   scripts/linux-build.sh [xenia-dir]   then e.g.
#   <xenia-dir>/build/bin/Linux/Release/xenia-cpu-tests "[guest_hooks]"
#
# scripts/localbin/spirv-opt hides the --canonicalize-ids flag that the
# distro's spirv-opt doesn't know.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
xenia="${1:-$root/_xenia}"
cd "$xenia"
export PATH="$root/scripts/localbin:$PATH" CC=clang CXX=clang++
# xenia-checkout.sh fetches only the pinned commit: fetch the submodules once.
if [ ! -f third_party/snappy/CMakeLists.txt ]; then
  python3 xenia-build.py setup
fi
python3 xenia-build.py build --config=Release --build-tests
