# Xenia changes

This repository does not vendor Xenia's source. `UPSTREAM_COMMIT` pins the
[Xenia Canary](https://github.com/xenia-canary/xenia-canary) commit the
changes are based on (`cc4981a46`), and `patches/` holds them as a
`git format-patch` series, applied on top of it in filename order.

The CI workflow (`.github/workflows/build-windows.yml`) clones that commit,
applies the series, builds `xenia_canary.exe` and packages it with `dist/`.

| File | Purpose |
| --- | --- |
| `scripts/xenia-checkout.sh [dir]` | Clones the pinned commit into `dir` (default `_xenia`) and applies the series as commits |
| `scripts/xenia-export-patches.sh [dir]` | Regenerates `patches/` from those commits |
| `scripts/linux-build.sh [dir]` | Builds Xenia and its unit tests on Linux with clang |
| `tools/clang-format-18.yaml` | Xenia's formatting style for clang-format 18 |
