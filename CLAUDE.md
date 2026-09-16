# 3D Printing SCAD — Project Notes

## The stack

OpenSCAD → OrcaSlicer → Moonraker, over the network. **Creality's software is
no longer in the path** — no Creality Print, no cloud account, no SD card, no
walking to the printer.

| | Where | Role |
|---|---|---|
| OpenSCAD | Mac app / CLI | CAD. `.scad` → `.stl` |
| OrcaSlicer 2.4.2 | Mac app / CLI | Slicing. `.stl` → `.gcode` |
| Moonraker | On the printer, `:7125` | HTTP API. Upload, query, start, abort |
| Mainsail | Browser, `http://192.168.1.65` | Monitor, control, edit config, Z babystep |
| Touchscreen | On the printer | Still works, unchanged |

### The printer

| | |
|---|---|
| Model | Creality Ender-3 V3 KE (`F005`), 220×220×240 mm |
| IP | **192.168.1.65** (give it a DHCP reservation) |
| Firmware | 1.1.0.17 — **do not update**, see task file |
| Host | Nebula Pad, Buildroot 2020.02.1, Ingenic MIPS |
| Klipper | Creality fork `09faed31-dirty` |
| SSH | `root@192.168.1.65`, password `Creality2023` |
| Moonraker | `:7125`, also proxied on `:80`. No API key needed from the LAN |
| Mainsail | `:80` and `:4409` |

Rooted and converted 2026-09-16. Full history, gotchas and rollback plan:
`~/tasks/switch-ke-off-creality-firmware.md`.

---

## Rules for the agent

**Never start a print without asking.** Every time, no exceptions, no matter
how routine it looks. The agent cannot see whether the bed is clear, whether
the last part was removed, or whether anyone is near the machine. A bad start
is the one step in this whole chain that is not undoable.

Everything else is fine unprompted:

| Action | Permission |
|---|---|
| Edit parameters, render, verify geometry | freely |
| Slice, report time / filament / layers | freely |
| Upload G-code (with `print=false`) | freely |
| **Start a print** | **ask every time** |
| Monitor, report status | freely |
| Pause, cancel, `emergency_stop` | freely — stopping is always safe |

---

## The normal flow

**Claude writes the CAD and configures the print. You preview and press Print.**

```
  OpenSCAD  .scad ──▶ .stl ──▶ .3mf project ──▶ [ you open it in OrcaSlicer ]
     (Claude)              (settings applied)      slice · preview · approve
                                                            │
                                                            ▼
                                                   Print → Moonraker → printer
```

One command produces the project:

```bash
tools/prepare-print.sh Plektrum/Plektrum.scad
tools/prepare-print.sh part.scad --process Fine --filament PETG
tools/prepare-print.sh part.scad -D 'width=42' -D 'wall=3'
```

Writes `<name>.stl` and `<name>.3mf` **next to the `.scad`**, in the project's
own folder — matching how the STLs in this repo are already laid out. **Open
the `.3mf` in OrcaSlicer** — the printer, process and filament are already
selected. Slice, look at the preview, hit Print. The upload goes over
Moonraker; no SD card, no Creality software.

Options: `--process Fine|Optimal|Standard|Draft` (0.12/0.16/0.20/0.24 mm),
`--filament PLA|PETG|ABS|TPU`, `--nozzle 0.2|0.4|0.6|0.8`, `--outdir`,
and `-D 'name=value'` (repeatable) for OpenSCAD parameters. `--outdir` only
matters when you want the artifacts somewhere other than beside the source.

**Why a project file and not gcode:** a `.3mf` project carries the model *and*
the settings, so the preview you approve is the thing that gets printed. Claude
never needs to touch the print button.

### Custom print settings

The four stock processes cover most cases. For anything else, derive a profile
rather than hand-editing gcode — `inherits` resolves fine from any directory:

```python
import json
SYS = "~/Library/Application Support/OrcaSlicer/system/Creality"
d = json.load(open(f"{SYS}/process/0.20mm Standard @Creality Ender3V3KE.json"))
d["name"] = "my-process"
d["sparse_infill_density"] = "45%"
d["wall_loops"] = "4"
json.dump(d, open("my-process.json", "w"), indent=1)
```

Then pass it where the stock process JSON would go. Verified working: overrides
land in the output gcode.

---

## Under the hood

Only needed when bypassing the normal flow — batch jobs, or slicing without
opening the GUI.

### OpenSCAD

```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o output.stl input.scad
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -D 'width=42' -o part.stl part.scad
```

### OrcaSlicer CLI — verified 2026-09-16

```bash
ORCA="/Applications/OrcaSlicer.app/Contents/MacOS/OrcaSlicer"
SYS="$HOME/Library/Application Support/OrcaSlicer/system/Creality"

# project file (what prepare-print.sh does)
"$ORCA" --load-settings "$SYS/machine/Creality Ender-3 V3 KE 0.4 nozzle.json;$SYS/process/0.20mm Standard @Creality Ender3V3KE.json" \
        --load-filaments "$SYS/filament/Creality Generic PLA @Ender-3V3-all.json" \
        --export-3mf "/absolute/path/out/project.3mf" part.stl

# straight to gcode, no GUI
"$ORCA" --slice 1 --load-settings "<machine>;<process>" \
        --load-filaments "<filament>" --outputdir ./out part.stl
```

**Gotchas, all hit in practice:**

- **`--export-3mf` requires an ABSOLUTE path.** A relative one fails with a
  misleading `Project export to ./x.3mf failed`.
- `--load-settings` takes **one** quoted, semicolon-joined argument, **machine
  first**, then process.
- `--slice` output is **always `plate_1.gcode`**, whatever the input was named.
- The CLI **succeeds silently** and fails inconsistently — check the artifact
  exists, do not trust the exit code.
- `--version` is not a valid flag; the version prints in the usage header.
- There are **no per-setting override flags** (no `--layer-height`). Derive a
  process JSON instead.
- **Pin the OrcaSlicer version.** Flag names shift between releases.

Sanity-check gcode before it goes anywhere:

```bash
grep -m1 "^; printer_model" out/plate_1.gcode   # Creality Ender-3 V3 KE
grep -m1 "gcode_flavor"     out/plate_1.gcode   # klipper
```

### Moonraker directly

```bash
# upload WITHOUT printing
curl -X POST "http://192.168.1.65:7125/server/files/upload" \
  -F "file=@out/plate_1.gcode" -F "root=gcodes" -F "print=false"

# status
curl -s "http://192.168.1.65:7125/printer/objects/query" \
  -G --data-urlencode "print_stats" --data-urlencode "extruder" | python3 -m json.tool

# files, health
curl -s "http://192.168.1.65:7125/server/files/list?root=gcodes"
curl -s "http://192.168.1.65:7125/server/info"
```

`print_stats.state`: `standby` `printing` `paused` `complete` `cancelled` `error`.

**Starting a print — ask first, every time:**

```bash
curl -X POST "http://192.168.1.65:7125/printer/print/start?filename=NAME.gcode"
```

Uploading with `print=true` starts immediately. **Never use that form from an
agent** — upload and start are two separately-approved steps.

**Stopping — never needs permission:**

```bash
curl -X POST "http://192.168.1.65:7125/printer/print/pause"
curl -X POST "http://192.168.1.65:7125/printer/print/cancel"
curl -X POST "http://192.168.1.65:7125/printer/emergency_stop"
```

After `emergency_stop`, Klipper needs `FIRMWARE_RESTART` (button in Mainsail).

**Quote URLs containing `?` in zsh** — it globs them and throws "no matches found".

## Printer config

`printer-config/stock/` holds the factory Klipper config, pulled before any
modification. See the README there — it explains which sections are
Creality-fork-only (`prtouch_v2`, `z_compensate`, `bl24c16f`) and why that
matters if the printer ever moves to a Raspberry Pi host.

Live config is at `/usr/data/printer_data/config/` on the printer, and is
editable from Mainsail's MACHINE tab.

Klipper config updates from Creality's side are disabled (Tools → 1 in the
helper script), so edits will not be silently overwritten.

## The helper script

Installed at `/usr/data/helper-script`. Relaunch over SSH with:

```bash
helper
```

Menus: Install, Remove, Customize, Backup & Restore, Tools, Information.
Tools → 11 restores a previous firmware from a `.img` on a USB drive — the
rollback path.

---

## What is gone, and why not to bring it back

- **Creality Print** — replaced by OrcaSlicer. Its 4.3 profiles are Cura-format
  and will not import into anything current. Do not port them forward.
- **Creality Cloud** — the printer was never bound, and does not phone home
  (verified: zero external connections). The *account* is still worth keeping,
  because it is where stock firmware `.img` files are downloaded.
- **Creality's web UI on :80** — replaced by Mainsail. The `web-server` and
  `Monitor` binaries are renamed to `.disabled`, reversible from the helper
  script's Customize menu.

The touchscreen, automatic Z-offset (`prtouch_v2`) and the CR-Touch bed mesh
are all unaffected and still work.

## Rollback

The documented recovery is a stock firmware `.img` on a FAT32 USB stick
(4096 allocation), via helper script Tools → 11. **Unlike the K1 series, there
is no low-level recovery guide for the Ender-3 series** — that stick is the
whole safety net. Download the `.img` from Creality Cloud.
