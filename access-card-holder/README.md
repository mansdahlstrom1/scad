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

To get the key or tag back out, pull the card first. Both pockets are
open at the back, so you can push either one out with a finger.

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

Print it as **two halves and glue them** — `access-card-holder-front.stl`
and `access-card-holder-back.stl`. Both are already exported in their
print orientation, so they drop straight into the slicer. **No supports,
on either half.**

The one-piece `access-card-holder.stl` is still there and is
geometrically identical when assembled, but it is much harder to print:

| | Unsupported area | Worst span |
|---|---|---|
| One piece | 3542 mm² | **54 mm** — the roof of the card slot |
| Front half | **0 mm²** | none at all |
| Back half | 375 mm² | 2 mm lip overhangs only |

That 54 mm bridge is the roof of the card slot, and it cannot usefully be
supported. The slot is a 1.4 mm cavity — too shallow for support to stand
up in, so it prints as a floppy sheet that welds to the roof rather than
holding it — and the 3 mm strips behind the front plate could only be
cleared blind along 98 mm. Splitting removes the bridge instead of
propping it up. V1 was two pieces for the same reason.

### Assembly

The front half carries a 0.8 mm lip around its outer edge; the back half
is inset 0.95 mm so it drops inside that lip with 0.15 mm of slack. It
self-aligns — no clamping jig needed. Glue on the flat land inside the
lip (~1.5 mm wide, all the way round). The lip is interrupted across the
top edge, which is where the card slides in.

Assembled thickness is 11.76 mm, the same as the one-piece — the back
half's first 1.2 mm sits down inside the lip.

### Settings

- **no supports** — turn off auto-generation if your slicer offers it
- layer height 0.2 mm (0.16 mm gives a nicer front face)
- 3 perimeters, 25–30 % infill
- **5 mm brim on the front half** — its bed contact is only a ~5.6 mm ring
  around the window, and on Smooth PEI it wants glue stick too

The front face prints against the bed, so it takes the plate's finish —
Smooth PEI gives a glossy badge front.

```bash
# from the repo root (scad/)
OS=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
D=access-card-holder
$OS --export-format binstl -o $D/access-card-holder-front.stl -D 'part="front"' $D/access-card-holder.scad
$OS --export-format binstl -o $D/access-card-holder-back.stl  -D 'part="back"'  $D/access-card-holder.scad
```

### Test coupons — print these first

`test-key.stl` is the bottom 44 mm, `test-tag.stl` is the tag pocket. Both
are ~10 minute prints and check the two fits that matter before you commit
to the full part. Note they are cut from the one-piece body, so they do
include the bridge; print them mainly for fit, not for surface quality.

```bash
$OS -o $D/test-key.stl -D 'part="test_key"' $D/access-card-holder.scad
$OS -o $D/test-tag.stl -D 'part="test_tag"' $D/access-card-holder.scad
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
