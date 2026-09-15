# 3D Printing SCAD — Project Notes

## Exporting STL for printing

Use the OpenSCAD CLI to export a `.stl` file from a `.scad` file:

```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o output.stl input.scad
```

Example for the knock box:

```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  -o hallbar-knock-box/hallbar-knock-box.stl \
  hallbar-knock-box/hallbar-knock-box.scad
```

Run from the repo root (`scad/`).

## Exporting 3MF

OpenSCAD exports 3MF natively — no conversion step needed:

```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  --export-format 3mf -o output.3mf input.scad
```

Note `*.3mf` is in `.gitignore`, so these stay local unless deliberately forced.

## 3MF is geometry only — it will not satisfy Creality Cloud

Creality Cloud's "Print Settings" upload page rejects an OpenSCAD 3MF with:

> This file does not contain Creality's machine models

This is expected and not fixable from here. That page wants a **slicer-authored
project file** with Creality's machine definition and print settings embedded.
OpenSCAD only writes geometry. Do not try to hand-build one — a fabricated
machine definition fails in ways that only surface mid-print.

The page also requires **Creality Print 5.0+**. The installed version is
**4.3**, so that upload flow is unavailable regardless of the file.

To get a file it accepts: upgrade to Creality Print 5.x, load the model, apply
settings, and save a project from the slicer itself.

## Slicer: Creality Print 4.3 (Cura-based)

Profiles live at:

```
~/Library/Application Support/Creality/Creative3D/4.3/Profiles/Ender-3 V3 KE_0.4/
```

They are flat `key=value` files under a `[Default]` header, using Cura setting
names — the stock ones are `low.default` (0.2 mm) and `high.default` (0.1 mm).

**Build a custom profile by copying a stock one and overriding keys that already
exist in it.** Inventing keys risks a profile the slicer silently ignores.
`access-card-holder/print-profiles/` has a worked example.

Two gotchas:

- Fan and cooling settings are **not** in the process profile — they live in the
  **material** profile.
- Creality Print **5.x is Orca-based**, so 4.3's Cura-format profiles will not
  import into it. Any tuned profile should also be recorded as a table of
  overrides so it can be re-entered in another slicer.

## After exporting

Open the `.stl` or `.3mf` in your slicer (Creality Print or Cura) to configure
print settings for the Creality Ender 3 KE before sending to the printer.
Printer-specific settings (layer height, infill, supports, temperature) live in
the slicer — not in OpenSCAD.
