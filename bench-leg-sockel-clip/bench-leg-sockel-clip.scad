// Bench leg sockel clip — Z-step bracket
//
// Cross-section (side view):
//
//   |  <- back plate (screws into beam face)
//   |
//   --------|
//            |  <- sockel face (double-sided tape here)
//            |
//
// Back plate attaches to one face of the 45×45 beam.
// Horizontal spans the beam depth so the sockel face is flush with the opposite face.
// Sockel face hangs down to cover the leg extension.

// === Parameters ===
beam_face    = 45;    // 45×45 beam width / depth
back_height  = 45;    // how far up the beam the back plate grips
sockel_h     = 20;    // height of the sockel face (hanging down)
width        = 30;    // bracket width (Y axis, along beam length)
wall_t       = 3;     // wall thickness throughout
screw_d      = 3.5;   // screw shaft diameter
head_d       = 7;     // countersink head diameter
head_depth   = 2.5;   // countersink depth

// === Geometry ===
// Origin: bottom of back plate (junction with horizontal).
// Z goes UP along back plate.
// X goes outward (toward front of beam).

module sockel_clip() {
    difference() {
        union() {
            // Back plate — goes UP, screws into beam face
            cube([wall_t, width, back_height]);

            // Horizontal connector — at the bottom, spans beam depth in X
            translate([0, 0, -wall_t])
                cube([beam_face, width, wall_t]);

            // Sockel face — hangs down from far end of horizontal
            translate([beam_face - wall_t, 0, -wall_t - sockel_h])
                cube([wall_t, width, sockel_h]);
        }

        // Countersunk screw holes through back plate
        for (i = [0.25, 0.75]) {
            translate([0, width / 2, back_height * i])
            rotate([0, 90, 0]) {
                translate([0, 0, -1])
                    cylinder(d = screw_d, h = wall_t + 2, $fn = 24);
                cylinder(d1 = head_d, d2 = screw_d, h = head_depth, $fn = 24);
            }
        }
    }
}

sockel_clip();
