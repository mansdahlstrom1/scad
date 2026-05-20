// Corner + slot test — flat quarter-ring with groove
corner_r = 35;
bar_r    = 10;
slot_w   = 3;
slot_d   = 10;

path_r = corner_r - bar_r;
h      = bar_r * 2;
thick  = bar_r * 2;  // radial wall thickness

difference() {
    // Flat quarter-ring
    linear_extrude(h)
        difference() {
            intersection() { circle(r = corner_r);        square(corner_r + 1); }
            intersection() { circle(r = corner_r - thick); square(corner_r + 1); }
        }

    // Groove from top, running along the arc
    rotate_extrude(angle = 92)
        translate([path_r - slot_w / 2, h - slot_d])
            square([slot_w, slot_d + 1]);
}
