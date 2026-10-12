# halo3-xenia-pc

A patch series for [Xenia Canary](https://github.com/xenia-canary/xenia-canary)
that improves Halo 3 (Xbox 360, disc release) on PC

## Features

- Unlocked frame rate. The simulation stays at 30 ticks per second; rendering
  is interpolated between ticks
- Raw mouse aim, rebindable keyboard controls, and analog movement on Wooting
  keyboards (Wooting Analog SDK)
- Frame pacing; command submission and presentation on dedicated threads
- Audio output fixes
- Theater screenshots and recordings; effect state preserved in saves and
  rewinds
- File sharing and deletion rules as on the console
- Diagnostics: stats logging, a GPU thread profiler, a guest sampling
  profiler and extended crash reports

Halo 3 settings are in `config/4D5307E6.config.toml`; see
[docs/SETTINGS.md](docs/SETTINGS.md)

## Stats for nerds

- 38 patches on Xenia Canary
  [`cc4981a46`](https://github.com/xenia-canary/xenia-canary/commit/cc4981a4659086acb1c25a485adebefc3f432ae1):
  18 for Halo 3, 20 general (GPU 8, APU 4, CPU 2, Kernel 2, UI 2, D3D12 1,
  HID 1)
- 105 files changed, 13,279 lines added and 246 removed, 28 new files; the
  Halo 3 code is 5,057 lines
- 79 guest hooks in `default.xex`, handled by 63 host functions. No game
  instruction is overwritten
- 245 game addresses documented in the Halo 3 sources, 92 of them functions
- Drawn between ticks: objects and their node matrices, first-person weapons,
  arms and hand IK, the first-person eye, cutscene, vehicle and follow
  cameras, shader, tree and wind time, and HUD animations
- Made frame-rate independent: HUD fades, scrolling and clocks, debris and
  wind
- 40 new settings (19 for Halo 3) and 77 counters in the stats log

## Requirements

- Halo 3 for Xbox 360, disc release, without a title update (title ID
  `4D5307E6`, `default.xex` module hash `19EB90F06A070ED6`). With any other
  executable the Halo 3 changes stay off
- Windows with a Direct3D 12 GPU

## Installation

1. Download the zip from [Releases](../../releases/latest)
2. Extract it to a folder
3. Run `xenia_canary.exe` and open the game with **File → Open**

## Documentation

- [Settings](docs/SETTINGS.md)
- [Controls](docs/CONTROLS.md)
- [DLC](docs/DLC.md)

## Building

[`.github/workflows/build-windows.yml`](.github/workflows/build-windows.yml)
applies [`xenia/patches/`](xenia/patches/) to the Xenia Canary commit in
[`xenia/UPSTREAM_COMMIT`](xenia/UPSTREAM_COMMIT) and builds the Windows
release. For local work, see [xenia/README.md](xenia/README.md)

## Credits

- [Xenia](https://github.com/xenia-project/xenia) and
  [Xenia Canary](https://github.com/xenia-canary/xenia-canary)
- `dist/patches/` is from the Xenia Canary
  [game patch collection](https://github.com/xenia-canary/game-patches)
- Developed by AI (Claude)

## License

BSD 3-Clause, except `dist/patches/`; see [LICENSE](LICENSE). Xenia is covered
by its own license, included in builds as `LICENSE-xenia.txt`

Not affiliated with Microsoft, Xbox Game Studios, Bungie or 343 Industries.
Halo and Xbox are trademarks of Microsoft. No game data is included
