# Access Card Holder V2

One printed piece that carries three things at once: the access card, the
teardrop door tag, and the folding Steelcase desk-drawer key.

V1 (`cardholder(1).stl` + `cardholder-tag-insert-thick.stl`, photos in
`images/`) had no source file, so V2 is a fresh parametric model. Its tag
and shell numbers were measured off those V1 meshes rather than guessed.

## How it goes together

1. Drop the **door tag** into the teardrop pocket, face down.
2. Drop the **key** into the key pocket, bottom edge first under the front
   border, then swing the top in. It sits on a ledge at the bottom.
3. Slide the **access card** down the front slot. It covers both pockets
   and is what locks them in — nothing can come forward past it.
4. Thread the reel strap through the top slot.

To get the key or tag back out, pull the card first. The key's back is
open so you can push it out with a finger.

The key's hinge sits 2 mm above the bottom edge. Everything within reach
of the blade's swing — the ledge and the guide walls — sits in *front* of
the blade's own plane, so the blade has a clear 180° arc out of the
bottom of the badge.

## Dimensions

| | V2 | V1 |
|---|---|---|
| Outer | 59.4 × 100.0 mm | 58 × 100 |
| Thickness, most of the badge | 4.0 mm | 4 |
| Thickness, over the tag | 6.6 mm | — |
| Thickness, over the key | 11.8 mm | — |
| Window | 48.25 × 80 mm | 74 × 42 |
| Border beside the window | 5.6 mm | 8 |
| Lanyard slot | 14 × 4 mm | ~14 × 4 |

### What it holds

| Item | Size | Source |
|---|---|---|
| Access card | CR80, 85.6 × 54 × 0.76 mm | standard |
| Door tag | teardrop 30.75 × 46.25 × 2.8 mm | measured from the V1 tag insert |
| Drawer key, folded | 23 × 40 mm, 8 mm at the hinge tapering to 5 mm | measured by hand |

The tag lies **sideways** (long axis across the badge), the same way V1
carried it — upright it would not leave room for the key.

## Printing

**Front face down, no supports, no rotation** — the STL is already
exported in the print orientation, so it drops straight into the slicer.

Nothing on the part needs support, but three surfaces bridge:

| Height | What bridges | Span |
|---|---|---|
| 2.6 mm | roof of the card slot | **54 mm** |
| 5.6 mm | back of the tag pocket | 31 mm |
| 7.8–10.4 mm | key box steps, key back lips | 2–4 mm |

The 54 mm one is the only one worth caring about, and it sags *into the
card slot*. The slot is 1.4 mm for a 0.76 mm card, so there is 0.64 mm of
sag budget — but it is worth helping it along:

- part cooling **100 %** over the bridge layers
- bridge speed **~25 mm/s**, bridge flow **~95 %**
- layer height **0.2 mm** (0.16 mm gives a nicer front face)
- 3 perimeters, 25–30 % infill
- **5 mm brim** — bed contact is a thin 5.6 mm ring around the window and
  the corners can lift without one

The front face prints against the bed, so it takes the build plate's
finish. On a textured PEI sheet that gives a nice matte badge front; use a
smooth sheet if you want it glossy.

```bash
# from the repo root (scad/)
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  -o access-card-holder/access-card-holder.stl \
  access-card-holder/access-card-holder.scad
```

### Test coupons — print these first

`test-key.stl` is the bottom 44 mm, `test-tag.stl` is the tag pocket. Both
are ~10 minute prints and check the two fits that matter before you commit
to the full part. `test-key.stl` also includes a stretch of the card-slot
bridge, so it doubles as a check that your bridging settings are right.

```bash
OS=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
$OS -o access-card-holder/test-key.stl -D 'part="test_key"' access-card-holder/access-card-holder.scad
$OS -o access-card-holder/test-tag.stl -D 'part="test_tag"' access-card-holder/access-card-holder.scad
```

## Still to confirm

`blade_w` (10 mm) and `blade_z0` (2.6 mm — how far back the blade sits
from the key's front face) are estimates. They set how much clearance the
blade's swing gets. `test-key.stl` exists to check them: put the key in
and flip the blade all the way out. If it catches, raise `blade_z0` or
`blade_clear` and reprint the coupon.

`tag_peg` is off. V1 had a 3.4 mm peg through the tag's hole, but the
teardrop pocket already locates the tag and a forward-facing peg would
print unsupported. Set `tag_peg = true` if you want it back.
