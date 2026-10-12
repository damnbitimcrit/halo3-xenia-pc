# Map packs (DLC)

Xenia installs Xbox 360 DLC packages directly. No game files need to be
edited.

## Installing

1. In Xenia, open **Content → Install Content**.
2. Select the map pack package files. These are the console's DLC files:
   one file per pack, usually with a long hexadecimal name, found under
   `Content/0000000000000000/4D5307E6/00000002/` on a console drive or in a
   backup. You can select several at once.
3. Xenia copies them to `content/0000000000000000/4D5307E6/00000002/` next
   to `xenia_canary.exe`. Start Halo 3; the maps appear in the map list for
   custom games and Forge.

Xenia accepts the original LIVE and PIRS packages as they are. Extracted
folders of map files won't install.

## Title updates

This build's frame-rate unlock, interpolation and mouse aim are tied to the
disc version of `default.xex` (no title update). If a Halo 3 title update is
installed, Xenia applies it automatically. The game still runs, but at 30 FPS
with no mouse aim, and the log says:

```
Halo 3: unsupported default.xex (hash ...); hooks disabled
```

To go back, remove the update from `content/0000000000000000/4D5307E6/000B0000/`
or set `apply_title_update = false` under `[Kernel]` in
`xenia-canary.config.toml`.

The Heroic and Legendary map packs are expected to work on the disc version.
The Mythic map packs may need a title update to show up in the map list
(unconfirmed). If they don't appear, report it: supporting the updated
`default.xex` means finding the same hook addresses in that build.
