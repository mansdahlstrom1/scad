---
name: print
description: Prepare a 3D print for the Ender-3 V3 KE. Renders a .scad, applies print settings, sanity-checks the geometry, and produces an OrcaSlicer project ready to preview and print. Use whenever the user wants to print, slice, or prepare a model - "print the pick", "slice this", "make me one of these in PETG".
---

# Preparing a print

The user codes in OpenSCAD. You configure the print. **They** preview it in
OrcaSlicer and press Print. Never start a print yourself — see the rule at the
bottom, it is not negotiable.

## 1. Work out what to build

Ask only what you genuinely cannot infer. If they named a model, use it. If the
repo has one obvious candidate, use it and say which you picked.

Worth asking about, when it is not implied:

- **Which model**, if ambiguous.
- **Filament** — defaults to **PolyTerra PLA**, the spool normally loaded. Only
  ask if the part suggests otherwise (outdoor, hot, flexible, structural).
- **Quality** — defaults to `Standard` (0.20 mm). Offer `Fine` (0.12) for
  something detailed or visible, `Draft` (0.24) for a rough test fit.
- **Parameters** — if the `.scad` has tunable top-level variables and the
  request implies changing one, use `-D` rather than editing the file.

Do not interrogate. One round of questions at most, then build.

## 2. Sanity-check the geometry — do not skip this

A model that renders without error can still be wrong, and a bad print wastes
filament and an hour. Check before handing anything over:

**Watch OpenSCAD's warnings.** `WARNING: Ignoring 3D child object for 2D
operation` means a `linear_extrude`/`offset`/`hull` was handed 3D children and
**silently discarded them**. This exact bug left `Plektrum.scad` exporting only
its lettering, with no pick, from Jan 2024 until it was caught in Sep 2026.
Treat any "Ignoring" warning as a failure, not a nuisance.

**Measure the mesh.** Compare the bounding box against what the model claims to
be. If the code says a 27 mm pick and the mesh is 23 mm of text, something is
wrong. The bed is **220 × 220 × 240 mm** — flag anything close to that.

**Look for trouble:** walls thinner than ~0.8 mm (below two perimeters at a
0.4 mm nozzle), unsupported overhangs, text or detail under ~0.4 mm deep that
will not survive at the chosen layer height.

If something looks wrong, **say so before building** rather than producing a
project you expect to fail.

## 3. Build the project

```bash
./tools/prepare-print.sh <path/to/model.scad>
./tools/prepare-print.sh part.scad --process Fine --filament PETG
./tools/prepare-print.sh part.scad -D 'width=42' -D 'wall=3'
```

Options: `--process Fine|Optimal|Standard|Draft`, `--filament` (PolyTerra,
PolyLite, PLA, PETG, ABS, TPU, or any Orca library name), `--nozzle`,
`--outdir`, and repeatable `-D`.

Writes `<name>.stl` and `<name>.3mf` **beside the `.scad`**, in the project's
own folder. The `.3mf` is a project file: printer, process and filament are
already selected when it opens.

The CLI **succeeds silently and fails inconsistently** — the script checks the
artifact exists rather than trusting the exit code. Trust the same signal.

**Check the temperatures the script reports.** The CLI does not resolve a
profile's `inherits` chain; it reads the leaf file and fills the rest from its
own defaults. `prepare-print.sh` flattens the chain itself and prints what it
resolved:

```
   flattened PolyTerra PLA @System: 4 profiles, nozzle 220C, bed 55C, Polymaker
```

A nozzle of **200 C** or a vendor of **(Undefined)** means the flattening did
not happen and the project would print cold. Do not hand it over — the `.3mf`
carries the numbers, so a wrong value there is what actually gets printed.

## 4. Report, then hand over

Slice once to gather numbers (to a temp dir, not the project folder) and report:

- Final dimensions
- Print time, filament volume, layer count
- Anything worth eyeballing in the preview — a shallow engraving, a thin wall,
  a first layer that looks marginal

Then tell them the path and stop. They open it, slice, preview, press Print.

## Checking on a running print

```bash
curl -s "http://192.168.1.65:7125/printer/objects/query" \
  -G --data-urlencode "print_stats" --data-urlencode "extruder" | python3 -m json.tool
```

Pausing, cancelling and `emergency_stop` never need permission — stopping is
always the safe direction. See `CLAUDE.md` for those endpoints.

## The one hard rule

**Never start a print.** Not via `printer/print/start`, not by uploading with
`print=true`, not because it seems routine or the user seems ready. You cannot
see whether the bed is clear, whether the last part was removed, or whether
anyone is near the machine. It is the only step in this pipeline that cannot be
undone. The user presses Print.
