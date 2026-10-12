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

## Why not X?

The aim is Halo 3 as the 2007 disc plays it, at high frame rates. The game's
own executable runs unmodified (no instruction is overwritten) and its
simulation keeps 30 ticks per second. Each alternative below is better at
something, so here's where each one stands

**The Master Chief Collection** is the right answer for most people. It's
official and native, needs no disc dump, and has matchmaking, crossplay, mod
tools and ongoing patches. It isn't the 2007 game, though: it runs Halo 3 at a
higher tick rate than the console's 30, and at the 2020 PC release Halo Support
[listed](https://support.halowaypoint.com/hc/en-us/articles/360045689252-Halo-3-Known-Issues-07-14-2020)
a shorter Battle Rifle hitscan range than on the 360 as a known issue for that
reason. Some behaviour has been patched back toward the 360 since, content the
original never had has been added, and updates can invalidate saved films and
campaign saves. For online play and a living game, MCC; for the original
simulation drawn at high frame rates, this

**[Project Sunrise](https://github.com/Blam-Network/sunrise_plugin)** isn't a
PC version. It's a DashLaunch plugin for modded (RGH/JTAG) Xbox 360s that
reconnects Halo 3 to fan-run servers, replacing the online services Microsoft
ended in January 2022. It runs on title update 2, the last build matchmaking
used, and an unmodded console on that update can join when a modded player
invites it to a lobby. That's the original game online on the original
hardware, at 30 FPS with a controller. On PC, Xenia's netplay fork reaches the
same servers on build v13.2. This project can't join them yet: it supports only
the disc build and has no online play, and both are next on its roadmap

**A decompilation** would be the best outcome: the game rebuilt from source,
running natively with no emulator. One was
[announced](https://x.com/lostbutlucky/status/2105499810971439192) in October
2026, and if it's released and plays like the disc, it'll be the better way to
play. It hasn't been released, though, and when and in what form it will be is
still open. Until then this is a way to play now, a stand-in rather than a
rival, and two parts of it carry over. A native build above 30 FPS faces the
same choice this one did: raise the tick rate, as MCC did and then spent years
patching back, or draw between ticks, and what has to be drawn between ticks
is worked out in the patches here. And 20 of the 38 patches are general
emulator fixes, while Xenia also underpins the recompilation efforts:
[xenon-pc-comp](https://github.com/summers-aaron/xenon-pc-comp), which builds a
Linux binary from your own disc image, draws through Xenia's emulated GPU.
Either way, running the untouched executable stays useful as the reference

**Where this falls short**

- Your own disc dump, plus your own map pack files for the DLC maps (see
  [DLC](docs/DLC.md)); the disc release only for now, without title updates;
  Windows with Direct3D 12
- Everything drawn between ticks is up to one tick (33 ms) behind the
  simulation. Where you look is updated every frame
- Camera shake, screen effects and exposure adaptation haven't been checked
  above 30 FPS
- Mouse aim has no aim acceleration or aim assist magnetism, and drives
  player 1 only
- No online play or system link yet. Xenia's netplay fork lists a patch for
  this disc build
  ([Netplay Compatibility](https://github.com/AdrianCassar/xenia-canary/wiki/Netplay-Compatibility));
  not tested here
- Emulation isn't exact. In this release `fres` and `vrefp` give exact results
  where the 360's CPU approximates, and Halo 3 uses them every tick in
  animation and physics, so the simulation can drift slightly from a
  console's. An Xbox 360 remains the reference
- Version 1.0 is a proof of concept. Netplay and support for both title
  updates are next. Admittedly a niche within a niche within a niche

### stats-for-nerds

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
