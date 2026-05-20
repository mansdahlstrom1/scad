// IKEA HALLBAR bin corner (measured)
corner_r = 35;   // bin outer corner radius (confirmed fit)
bar_r    = 10;   // bar cross-section radius (20 mm diameter)
slot_w   = 3;    // knock slot width
slot_d   = 10;   // knock slot depth (min half bar diameter = 10)
arm_l    = 50;   // straight arm length (5 cm)
path_r = corner_r - bar_r;

difference() {
    union() {
        // Seamless quarter-torus — curved corner section
        rotate_extrude(angle = 90)
            translate([path_r, bar_r])
                circle(r = bar_r);

        // Arm at 0° end — extends in -Y direction (away from curve)
        translate([path_r, 0, bar_r])
            rotate([90, 0, 0])
                cylinder(r = bar_r, h = arm_l);

        // Arm at 90° end — extends in -X direction (away from curve)
        translate([0, path_r, bar_r])
            rotate([0, -90, 0])
                cylinder(r = bar_r, h = arm_l);
    }

    // Knock slot — curved section
    rotate_extrude(angle = 92)
        translate([path_r - slot_w / 2, 2 * bar_r - slot_d])
            square([slot_w, slot_d + 1]);

    // Knock slot — arm at 0° end (runs in -Y direction)
    translate([path_r - slot_w / 2, -arm_l, 2 * bar_r - slot_d])
        cube([slot_w, arm_l + 1, slot_d + 1]);

    // Knock slot — arm at 90° end (runs in -X direction)
    translate([-arm_l, path_r - slot_w / 2, 2 * bar_r - slot_d])
        cube([arm_l + 1, slot_w, slot_d + 1]);
}
