# Settings

Two files decide how Xenia runs Halo 3:

- `xenia-canary.config.toml`, Xenia's main config next to `xenia_canary.exe`.
- `config/4D5307E6.config.toml`, the Halo 3 config that ships with the build.
  Xenia loads it when Halo 3 starts, on top of the main config. It holds
  most of this build's settings; the tables below mark the ones that are in
  the main config instead.

Halo 3 renders at **1152x640** internally (Bungie traded resolution for two
HDR framebuffers). The upscaling presets at the end are about scaling that up
cheaply.

## Keep these as they are

```toml
[GPU]
vsync = true
framerate_limit = 0           # the *emulated vblank* rate; 0 (Xenia's default) means 60; see below
readback_memexport = false
render_target_path_d3d12 = "rtv"
```

`readback_resolve` can stay at whatever your main config has: the Halo 3
config sets it to `"small"` (see below).

These keys are already in `xenia-canary.config.toml`. Change the existing
line; don't add a second copy of a key, or Xenia stops at start.

### Frame rate and `framerate_limit`

`framerate_limit` is the rate of the emulated console's vblank (screen
refresh), not your FPS cap. Leave it at Xenia's default, 0, which means 60
while `vsync` is on. The FPS cap is `halo3_framerate_limit` in the Halo 3
config.

Halo 3 presents each frame with a D3D presentation interval: when a frame
took a little longer than one vblank, the GPU waited for the next emulated
vblank, so frame times snapped to whole vblanks. That held busy scenes at
about 82 frames/s with a 165 Hz vblank and about 100 with 200 Hz, and at
60 Hz it would cap the game at 60. `halo3_immediate_present` (on by default)
presents at once while the frame rate is unlocked, so nothing waits for the
vblank any more:

- At the same scene load, frames/s rise by 25-40 (a median of about 160
  against 119 without it).
- With `framerate_limit = 60` the frame rates match those at 200.
- With `halo3_unlock_framerate = false` the game runs at normal speed at 30
  frames/s without touching `framerate_limit`.

Two rules:

- `framerate_limit` has to be in `xenia-canary.config.toml`: Xenia reads it
  once at start, before the Halo 3 config is loaded.
- If you turn `halo3_immediate_present` off, the game can't present more
  often than the vblank rate again: set `framerate_limit` to your FPS cap
  (165 for a 165 Hz screen, at most 200), and back to 60 whenever
  `halo3_unlock_framerate` is off (the original game counts vblanks as
  1/60 s each and would run almost three times too fast at 165).

### Auto exposure and `readback_resolve`

`readback_resolve` copies render-to-texture results back to the console's
memory so the game can read them on the CPU. **Halo 3 needs it for its auto
exposure.** Each frame it reads the scene brightness the GPU measured (a few
pixels) and adjusts the exposure. With `"none"` (Xenia's default since
December 2025) that value never arrives, so the exposure stays at the area's
minimum: darker or flatter lighting than on a console. `"fast"` and `"full"`
fix it but make the game very laggy: `"fast"` waits for the GPU on every
resolve here, because Halo cycles through a ring of eight brightness targets.

`"small"` (set in the Halo 3 config) reads back only resolves of up to
16 KB, such as that brightness sample, a frame or two later and without
waiting for the GPU; larger ones behave like `"none"`. It only works at
`draw_resolution_scale` 1 (preset A below): with resolution scaling the
sample isn't read back, so the exposure is stuck as with `"none"`.
Xenia's readback hotkey cycles `fast`, `full`, `none`, `small`.

### GPU effects, screenshots and saves

`readback_memexport` copies data written by shader memory export back to the
CPU after every export, waiting for the GPU each time: it removes the
stretched trails but takes the frame rate from about 160 down to 26-150.
Leave it `false`. Halo 3 simulates particles, contrails, light volumes and
beams on the GPU, and its CPU writes next to that memory every frame, which
made Xenia put stale data back over it (the stretched plasma trails and
drop-pod smoke). `memexport_keep_gpu_data = true`, set in the Halo 3 config,
keeps the GPU's data in those four buffers, which Halo 3's hooks register
(the game's CPU writes its other export targets, such as the water ripple
buffers, so those stay as in stock Xenia). It costs nothing measurable and
doesn't change the game's memory. Before loading a checkpoint, Save and Quit
game or film, the game unprotects its whole game state, which drops the kept
data, so console saves and films load exactly as in stock Xenia.

Guest memory still never gets the GPU's results during play, but the game
reads them on the CPU at two moments: a Theater screenshot (it JPEG-encodes
an image the GPU exported) and a save (checkpoint, Save and Quit, co-op
state). `halo3_gpu_readback` (on by default) copies what the GPU wrote into
the game's memory at exactly those moments, after the game has waited for
the GPU itself: the screenshot's image (about 8 MB, a pause of tens of
milliseconds inside the screenshot's own hitch) and, for a save, the bytes
of the four effect buffers the GPU has newer (under 1 MB, a few
milliseconds; nothing to copy right after a load). Without it, Theater
screenshots come out black and a save carries stale effect state, so effects
alive at a checkpoint glitch after a revert. Nothing else changes: the
game's memory layout and checksums stay as they are (the copy lands before
the game hashes or writes the save), so console saves and films load as
before, and there is no cost during play. Each copy writes one `Halo 3:
Theater screenshot` or `Halo 3: game state save` line to the log, with the
bytes copied and the pause.

Theater's rewind snapshots are covered without any pause by
`halo3_gpu_readback_film_snapshots` (on by default, needs
`halo3_gpu_readback`). While a multiplayer film plays in Theater (any film,
wherever it was recorded; never in live multiplayer, campaign films or
saves), the game copies its state into its rewind cache,
`cache1:\sf_history.blob`, every 10 seconds, and a seek back restores the
nearest one. The GPU copies each snapshot's effect state in the background,
Xenia keeps it in memory (up to 16 snapshots, under 1 MB each) and puts it
back into the restored state before the game checks it or makes a clip from
it. Off: effects alive at that moment glitch after seeking back. Each seek
that lands on a snapshot taken while you watched logs one `Halo 3: Theater
seek` line (a seek to the film's start logs none).

## Pacing, presenting, audio, files and diagnostics

These are in the Halo 3 config (`config/4D5307E6.config.toml`), which wins
over the main config, except those marked as being in
`xenia-canary.config.toml`: they aren't in the Halo 3 config, so the main
config decides (a line for them in the Halo 3 config would override it).
The on/off switches are on by default except `halo3_present_spacing`,
`gpu_thread_profile` and `guest_profile`; set one to `false` to compare.

| Setting | Section | What it does |
| --- | --- | --- |
| `halo3_pace_to_render` | `[Halo3]` | the main loop waits for the render thread to take each frame instead of building frames that are never drawn (about half of them at 80 FPS); off below about 33 FPS |
| `halo3_pace_late_start` | `[Halo3]` | starts each frame just late enough to be ready when the render thread needs it, so pacing adds no input latency |
| `halo3_pacer_spin_us` | `[Halo3]` | 0: the frame cap only sleeps (high-resolution timer). Try 300 on a fixed-refresh screen if frame times look uneven |
| `halo3_render_thread_sleep` | `[Halo3]` | the game's render thread sleeps while waiting for a frame and during loads instead of spinning a core |
| `apu_prebuffer_frames` | `[APU]` | when sound runs dry, fade out instead of cutting off, then fade back in once 3 frames (16 ms) are queued. 0 is Xenia's original behaviour |
| `apu_fade_ms` | `[APU]` | length of those fades (3 ms) |
| `apu_max_catchup_frames` | `[APU]` | after a late audio frame, ask the game for up to 2 more at once to refill the queue |
| `apu_raise_thread_priority` | `[APU]` | the game's audio threads and Xenia's XMA decoder at the PC's highest thread priority |
| `halo3_immediate_present` | `[Halo3]` | present each frame as soon as it is drawn instead of on the next emulated vblank (the 82 / 100 FPS floor) |
| `halo3_present_spacing` | `[Halo3]` | off by default: holds the game's presents at least one `halo3_framerate_limit` period apart. Once a frame is late it keeps later frames at that phase, which adds latency; try it only for tearing or uneven pacing near the cap |
| `apu_exact_pump_interval` | `[APU]` | ask the game for audio at exactly the rate it plays; otherwise the sound falls about a frame (5.3 ms) further behind the picture every 80 seconds |
| `apu_target_queued_frames` | `[APU]` | audio frames kept queued (9, 48 ms): enough to carry the sound through map loads, where the game's audio takes up to 44 ms per frame. Lower means less delay but gaps at loads |
| `apu_max_queued_frames` | `[APU]` | skip a request to the game while more than 9 + 8 audio frames are queued, so the audio delay stays bounded |
| `xma_reset_decoder_per_stream` | `[APU]` | restart the audio decoder for each new sound, also when the game cuts a sound off by zeroing the decoder's work buffer (how Halo 3 does it); stock Xenia carries the rest of the previous sound into the first samples of the next, a likely source of occasional pops |
| `host_present_thread` | `[Display]` | in `xenia-canary.config.toml` (on by default): paint each frame and hand it to Windows on a separate thread, so Xenia's GPU thread doesn't wait for that; 1-4% more frames/s, 10% in the heaviest scenes |
| `halo3_gpu_readback` | `[Halo3]` | on by default: copies the GPU's results into the game's memory when it reads them on the CPU, so Theater screenshots aren't black and saves carry the right effect state; a short pause at that moment only. Set `false` to compare |
| `halo3_gpu_readback_film_snapshots` | `[Halo3]` | on by default (needs `halo3_gpu_readback`): keeps the effect state of Theater's rewind snapshots and puts it back when you seek back in a multiplayer film; no pause. Set `false` to compare |
| `memexport_keep_gpu_data` | `[GPU]` | in the Halo 3 config: keeps what the GPU wrote for particles, contrails, light volumes and beams when the CPU writes next to it, instead of reloading stale data (stretched trails). Set `false` to compare |
| `d3d12_submission_thread` | `[D3D12]` | in `xenia-canary.config.toml`, on by default (a line in the Halo 3 config works too): Xenia's GPU thread hands each finished command list to a separate thread, which replays it to the driver and submits it, instead of doing that itself (about 2.8 ms of its 7 ms per frame in a busy scene). Set `false` to compare |
| `gpu_thread_profile` | `[GPU]` | in `xenia-canary.config.toml`, off by default. For a profiling run: logs where Xenia's GPU thread spends each frame (`Halo 3 GPU profile` line, with `halo3_log_stats`); costs about 3% of the frame rate while on |
| `guest_profile` | `[CPU]` | in `xenia-canary.config.toml`, off by default (Windows). For a profiling run: samples the game's threads about every `guest_profile_period_us` (1000) and every `guest_profile_report_s` (30) seconds logs `Guest profile:` lines: frame times, then per busy thread the time per frame by game function (its own code and the emulator code it called), by call tree, by emulator function, the hottest game instructions, the waits, and what grew in slow frames (`guest_profile_slow_frame_ms`, 0: 1.5 times the median frame). Keep `xenia_canary.map` next to the exe so Xenia's own functions have names. Costs about 1% of the frame rate while on. Works for any game |
| `file_share_access` | `[Kernel]` | in `xenia-canary.config.toml`, on by default: files follow the console's rules for sharing, deleting and renaming (the console's cache drive does this inside the game itself). Files the game has open can't be deleted or opened in a conflicting way; Halo 3 tries to delete leftover recordings while the new one is open, which made stock Xenia delete new Theater recordings. Set `false` to compare (don't: recordings may be lost) |
| `halo3_author_from_profile` | `[Halo3]` | in `xenia-canary.config.toml`, on by default: films, clips, screenshots and map and game variants you make name your signed-in profile as their author, as on a console signed in to Xbox Live (Xenia signs in locally, so the author would stay empty, as for an offline profile). Content made without it keeps no author. Set `false` to compare |
| `halo3_fp_snap` | `[Halo3]` | `animation` by default: the first-person weapon and arms are drawn as a tick left them (not blended) only when the weapon, models or unit change, a part jumps further than any animation moves it (over 0.5 units or 150 degrees in a tick), or turns over 60 degrees in a tick its animation changed in. `any` snaps on any turn over 60 degrees in a tick (fast melee and grenade throws step); `off` keeps only the weapon, model and unit changes. Leave it on `animation` |
| `thread_priority_floor_normal` | `[Kernel]` | no thread below normal priority: stock Xenia runs the game's render and streaming threads at the lowest, where shader compilation starves them |

Don't set `ignore_thread_priorities = true`: it also turns off the raised
audio priorities.

## Lens flares and occlusion queries

Halo 3 dims and hides lens flares (the glow of lights, Regenerators and
other equipment) with occlusion queries: how much of a small test quad at
the light is visible. Its flares are the only thing these queries are used
for.

- `occlusion_query = "fast-alt"` is set in the Halo 3 config (this build lets
  that file switch between `"fast"` and `"fast-alt"`; other values only
  work in `xenia-canary.config.toml`). With `"fast"`, Xenia's guess for a
  query not answered yet is "1 sample visible", so a small flare behind a
  wall stays drawn for as long as its object exists (the green dots of a
  dropped Regenerator). `"fast-alt"` reuses the last real answer, which
  hides them at the same frame rate. A flare that comes back into view can
  fade in a frame late.
- Leave `occlusion_query_viz = false` (Xenia's default). It adds a test draw
  and a separate GPU copy per flare, makes the glows stutter, and doesn't
  hide them.
- `"strict"` waits for the GPU at every query: slower, and at high frame
  rates the game drops queries that take longer than 3 frames.

If the menu blur flickers, try `render_target_path_d3d12 = "rov"` (slower,
more accurate render targets). The upscaling presets below use FSR or CAS
sharpening, which makes the dithered fade of distant objects stand out more.
Plain FXAA softens it.

## Fullscreen and G-SYNC / FreeSync

```toml
[Display]
fullscreen = true

[D3D12]
d3d12_allow_variable_refresh_rate_and_tearing = true
```

Windowed mode goes through the desktop compositor, so variable refresh and
tearing control do not apply there.

## Upscaling presets

Pick one block. The costs given are estimates.

### A. Performance (native render, FSR to your screen)

Cheapest option: renders at 1152x640 and uses AMD FSR 1.0 plus FXAA to upscale.
GPU cost over native is well under a millisecond.

```toml
[GPU]
draw_resolution_scale_x = 1
draw_resolution_scale_y = 1

[Display]
postprocess_antialiasing = "fxaa"
postprocess_scaling_and_sharpening = "fsr"
postprocess_ffx_fsr_sharpness_reduction = 0.2
```

### B. Balanced (2x horizontal, 2304x640, then FSR)

Half the cost of full 2x. Sharpens horizontal detail, which is where 1152 wide
hurts most on a 16:9 screen.

```toml
[GPU]
draw_resolution_scale_x = 2
draw_resolution_scale_y = 1
draw_resolution_scaled_texture_offsets = true
resolve_resolution_scale_fill_half_pixel_offset = true

[Display]
postprocess_antialiasing = "fxaa"
postprocess_scaling_and_sharpening = "fsr"
```

### C. Quality (2x2, 2304x1280, about 1440p, then CAS)

About four times the native pixel cost. Compare it against B on your PC.

```toml
[GPU]
draw_resolution_scale_x = 2
draw_resolution_scale_y = 2
draw_resolution_scaled_texture_offsets = true
resolve_resolution_scale_fill_half_pixel_offset = true

[Display]
postprocess_antialiasing = "fxaa"
postprocess_scaling_and_sharpening = "cas"
postprocess_ffx_cas_additional_sharpness = 0.2
```

Resolution scales are whole numbers only (1x to 7x per axis).

Presets B and C scale the resolution, so the auto exposure stays stuck as
described under `readback_resolve` above.
