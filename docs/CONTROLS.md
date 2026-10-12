# Keyboard and mouse

The build ships a keyboard and mouse layout in `config/4D5307E6.config.toml`.
It is active only while Halo 3 runs.

## Using it

1. Start Halo 3 and **click inside the game window**. The cursor disappears
   and the mouse now aims. That first click only grabs the mouse; it doesn't
   fire.
2. **Escape** opens the pause menu, as Start does. The cursor stays locked,
   since Halo's menus are driven by the keyboard (arrows, Enter, Space,
   Escape).
3. **Alt+Tab** (or the Windows key) gives the cursor back. Click into the
   game window to lock it again.
4. **F11** toggles fullscreen. Escape and double-click no longer do, because
   they are game input now.
5. **Xenia's own windows** (signing in, profile selection, message boxes)
   release the cursor while they are open, so you can click them. Click into
   the game again when they close. To reach Xenia's menu bar in windowed
   mode, Alt+Tab away and back without clicking into the game.

The keyboard and mouse play as controller 1. While the mouse is locked they
take priority over a connected gamepad. To switch to a gamepad, Alt+Tab
away and back without clicking into the window.

## Default layout

| Action | Key | Xbox button |
| --- | --- | --- |
| Move | W A S D | left stick |
| Aim | mouse | right stick |
| Fire | left mouse | RT |
| Zoom / scope | right mouse | right stick click |
| Throw grenade / fire left weapon | G | LT |
| Melee | Q, mouse side button (back) | B |
| Jump | Space | A |
| Crouch | Ctrl, C | left stick click |
| Reload / pick up / interact | R, E | RB |
| Use equipment | F | X |
| Switch weapon | mouse wheel, 1 | Y |
| Switch grenade / left weapon (dual wield) | Z | LB |
| Pause menu | Escape, Enter | Start |
| Scoreboard | Tab | Back |
| D-pad (forge, theater, menus) | arrow keys | D-pad |

### Changing a binding

Edit the `[HID.Key]` section of `config/4D5307E6.config.toml`. Each value is
a list of keys separated by spaces:

- a capital letter or a digit: `"G"`, `"1"`
- any Windows virtual-key code in hex: `"0x20"` (Space), `"0x10"` (Shift),
  `"0x12"` (Alt)
- mouse: `0x01` left, `0x02` right, `0x04` middle, `0x05` back side button,
  `0x06` forward side button, `0x0A` wheel up, `0x0B` wheel down

Avoid F1-F12, Pause and the numpad `+ - *` keys: Xenia uses them as hotkeys.
Changes take effect the next time Halo 3 starts.

## Mouse settings (`[Halo3]` section)

| Setting | Default | Meaning |
| --- | --- | --- |
| `halo3_mouse_aim` | `true` | Aim with the mouse while it is locked |
| `halo3_mouse_sensitivity` | `1.0` | 1.0 = 0.057° per mouse count, a full turn in about 20 cm at 800 DPI. No acceleration. |
| `halo3_mouse_zoom_sensitivity` | `1.0` | Extra multiplier while scoped. The game already slows aim down by the zoom magnification, as it does for the stick. |
| `halo3_mouse_invert_y` | `false` | Invert vertical aim |

The mouse feeds into the game's own aim input, so the game's rules still
apply: aim stops while the pause menu or a scripted scene disables player
input, and vehicle and turret seats keep their aiming limits. Mouse aim gets
no aim acceleration and no aim assist magnetism; the in-game look sensitivity
setting affects only the stick.

Mouse aiming is applied once per drawn frame, so it stays responsive at high
frame rates.

## Wooting and other analog keyboards

With an analog keyboard such as the Wooting 60HE, W A S D drive the left
stick by how far they are pressed: press part way to walk, all the way to
run.

Requirements:

- **Wootility 3.4 or newer.** It installs the Wooting Analog SDK in
  `C:\Program Files\wooting-analog-sdk\`, which this build looks for. If you
  installed the SDK yourself, the default location works too.
- `keyboard_analog_movement = true` in the `[HID]` section (the default).

Xenia's log says `Wooting Analog SDK loaded, 1 device(s) found` when it
works. Without the SDK, or on a regular keyboard, the keys act fully on or
off as usual. Keys bound to movement that the analog keyboard doesn't report
(for example on a second keyboard) also still work digitally.

Tune how much travel counts as "walk" and "full speed" with the actuation and
analog curve settings in Wootility; the build passes the analog value through
unchanged, and Halo 3 applies its own stick dead zone on top.
