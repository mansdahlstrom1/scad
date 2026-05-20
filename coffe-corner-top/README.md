# Coffee Corner Top — Stone Slab Template

A 3D-printable template for a stone slab top on a corner cabinet. Print the 8 pieces, assemble them, and hand the physical template + DXF to stone cutters who will trace and cut the slab.

## Measurements

Tape-measured from the actual cabinet/room corner:

| Dimension      | Value  | Description                          |
|----------------|--------|--------------------------------------|
| `back_width`   | 639 mm | Back wall: back-left → back-right    |
| `right_side`   | 330 mm | Right wall: back-right → front-right |
| `left_side`    | 329 mm | Left wall: front-left → back-left    |
| `diag_bl_fr`   | 713 mm | Diagonal: back-left → front-right    |
| `diag_fl_br`   | 733 mm | Diagonal: front-left → back-right    |

Diagonals were triple-measured and are the most reliable inputs. All four corners are analytically derived from these 6 measurements via circle intersection math — no angle was measured by hand.

## Overhangs

- Right side: +20 mm
- Front edge: +35 mm
- Back wall: flush (against wall)
- Left wall: flush (against wall)

## Computed corner positions

| Corner | X     | Y     | Angle  |
|--------|-------|-------|--------|
| BL     | 0     | ~330  | 92.8°  |
| BR     | 639   | ~330  | 88.8°  |
| FR     | ~632  | 0     | 91.1°  |
| FL     | ~-16  | ~1.3  | 87.3°  |

The right side leans ~7 mm inward over 330 mm (not perpendicular). The back wall is known to be crooked/bowed — the straight slab back edge will have a gap in places, filled with silicone caulk (standard practice).

Front width computes to ~648 mm (measured ~650 mm — within tape tolerance).

## Slab dimensions (final piece incl. overhangs)

| Sida            | DXF    | Verklighet (plastutskrift) | Stenhuggare |
|-----------------|--------|----------------------------|-------------|
| Bakkant         | 659 mm | 656 mm                     | 658 mm      |
| Framkant        | 668 mm | 667 mm                     | 670 mm      |
| Höger           | 365 mm | 364 mm                     | 350 mm ⚠️   |
| Vänster         | 364 mm | 364 mm                     | —           |
| Diag BL→FR      | 747 mm | 743 mm                     | —           |
| Diag BR→FL      | 767 mm | 764 mm                     | —           |

Hörnvinklar (från DXF): BL=92.6°, BR=88.9°, FR=91.0°, FL=87.6°
Stenhuggarens ritning: 93°, 89°, 91°, 87° (avrundade — OK).

Plastutskriften är det mest tillförlitliga referensmåttet då den provats på plats.

## Files

| File | Purpose |
|------|---------|
| `coffe-corner-top.scad` | Main OpenSCAD design file |
| `back-left.stl` … `front-right.stl` | 8 print pieces (1.88 mm thick) |
| `coffe-corner-top.dxf` | 2D outline for stone cutters / CNC |

## Piece layout

```
         back wall
┌──────────────────────────────────────────┐
│ back-left  │ back-ctr-L │ back-ctr-R │ back-right  │
│    (1)     │    (2)     │    (3)     │    (4)      │
├────────────┼────────────┼────────────┼─────────────┤
│ front-left │ front-ctr-L│ front-ctr-R│ front-right │
│    (5)     │    (6)     │    (7)     │    (8)      │
└──────────────────────────────────────────┘
         front (overhang)
```

Pieces connect with dovetail joints (trapezoidal, 12 mm deep, 10→16 mm wide).

## SCAD variables

| Variable     | Default | Description                                          |
|--------------|---------|------------------------------------------------------|
| `print_mode` | `false` | `true` = 1.88 mm thick, hides cabinet/walls, shows one piece |
| `piece`      | `1`     | Which piece to preview/export (1–8)                 |
| `dxf_mode`   | `false` | `true` = 2D outline only, for DXF export            |

## Exporting STLs

Run from the `scad/` directory:

```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  -D "print_mode=true" -D "piece=N" \
  -o coffe-corner-top/PIECE-NAME.stl \
  coffe-corner-top/coffe-corner-top.scad
```

Replace `N` with 1–8 and `PIECE-NAME` with the piece name.

## Exporting DXF

```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  -D "dxf_mode=true" \
  -o coffe-corner-top/coffe-corner-top.dxf \
  coffe-corner-top/coffe-corner-top.scad
```

## Print settings (Ender 3 KE, standard PLA)

| Setting        | Value                          |
|----------------|--------------------------------|
| Layer height   | 0.28 mm (first layer 0.20 mm) |
| Total thickness| 1.88 mm (7 layers)            |
| Print speed    | 150 mm/s                       |
| Travel speed   | 250 mm/s                       |
| First layer    | 25 mm/s                        |
| Walls          | 1                              |
| Top layers     | 0                              |
| Bottom layers  | 1                              |
| Infill         | 0%                             |
| Brim           | 8 mm                           |
| Nozzle temp    | 215°C                          |
| Bed temp       | 60°C                           |
| Fan            | 100% from layer 2              |

## Status

- [x] Geometry derived and verified
- [x] 8-piece split with dovetail joints
- [x] All 8 STLs exported at print thickness
- [x] DXF exported for stone cutters
- [ ] Print all 8 pieces and assemble full template
- [ ] Measure if/how much wider the template needs to be
- [ ] Adjust model if needed and re-export
- [ ] Hand DXF + physical template to stone cutters
