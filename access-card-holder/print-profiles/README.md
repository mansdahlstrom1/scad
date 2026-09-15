# Print profile — Creality Print 4.3, Ender-3 V3 KE, 0.4 nozzle

`access-card-holder.default` is the stock **low** (0.2 mm) profile for your
printer with 27 settings changed. It is generated from your own installed
profile, so every key in it is one the slicer already recognises.

## Why supports are ON here

The earlier advice — "no supports" — was for the **one-piece** model, where
the card slot is a sealed 1.4 mm cavity that support can neither stand up in
nor be removed from.

That does not apply to the split halves:

| Half | Overhangs | Support |
|---|---|---|
| Front | **0 mm²** — nothing overhangs at all | none gets generated |
| Back | 594 mm², all inside the tag and key pockets | **yes, and it works** |

Both pockets open *downward onto the build plate*, so support builds from the
plate and lifts straight back out. One profile covers both halves — the front
simply produces no support because nothing exceeds the overhang angle.

What actually gets supported on the back half:

- **3.0 mm** — tag pocket floor and its lip ring (~352 mm², the biggest)
- **5.4–5.9 mm** — key pocket floor band, the ~24 mm span either side of the post
- **7.9 mm** — the 2 mm back lips over the key

## Install

Close Creality Print first, then:

```bash
cp print-profiles/access-card-holder.default \
  ~/Library/Application\ Support/Creality/Creative3D/4.3/Profiles/Ender-3\ V3\ KE_0.4/
```

Reopen it and pick the profile. If it doesn't appear in the list, Creality
Print only offers its built-in names — use the table below instead, it's a
short list.

## What changed from stock (for entering by hand)

| Setting | Stock | Here | Why |
|---|---|---|---|
| `support_enable` | false | **true** | the whole point |
| `support_structure` | normal | normal | flat pocket floors, not spindly — tree is wrong here |
| `support_type` | everywhere | everywhere | equivalent here; nothing overhangs model material |
| `support_angle` | 60 | **50** | catches shallower overhangs |
| `support_xy_distance` | 0.8 | **0.5** | at 0.8 there is almost nothing left under a 2 mm lip |
| `support_interface_density` | 33.3 | **80** | this is what fixes the surface |
| `support_roof_density` | 40 | **85** | |
| `support_roof_line_distance` | 1.2 | **0.5** | matches the density above |
| `support_bottom_density` | 33.3 | **60** | |
| `support_bottom_line_distance` | 1.2 | **0.67** | |
| `support_infill_rate` | 15 | **20** | keeps the interface from sagging |
| `support_wall_count` | 0 | 0 | no perimeter, so it snaps out |
| `speed_support_interface` | 200 | **40** | slow interface = clean surface |
| `speed_support_roof` | 200 | **40** | |
| `speed_support` | 300 | **100** | |
| `speed_print` | 300 | **180** | KE defaults are aggressive for a part this small |
| `speed_wall_0` | 200 | **60** | outer wall finish |
| `speed_wall_x` | 300 | **120** | |
| `speed_topbottom` | 200 | **120** | |
| `wall_line_count` | 2 | **3** | 2 mm lips and walls come out solid |
| `infill_sparse_density` | 15 | **30** | |
| `top_bottom_thickness` | 0.8 | **1.0** | better surface over the bridges |

The four `support_z_distance` / `support_top_distance` / `support_bottom_distance`
/ `support_interface_height` values are left at stock — 0.2 mm gap is the right
balance between surface quality and getting the support back out.

## Not in this file

Fan and cooling settings live in the **material** profile in Creality Print
4.3, not the process profile. If bridging still looks poor, raise the fan to
100 % there.
