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

## After exporting

Open the `.stl` in your slicer (Creality Print or Cura) to configure print settings for the Creality Ender 3 KE before sending to the printer. Printer-specific settings (layer height, infill, supports, temperature) live in the slicer — not in OpenSCAD.
