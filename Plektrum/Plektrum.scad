// Guitar pick, 351-style outline.
//
// The shape is the hull of three circles: two big ones for the shoulders and
// a small one for the playing tip. Different radii are the whole point - one
// radius everywhere gives a rounded triangle, not a pick.

width      = 29;    // across the widest point
length     = 31;    // tip to top edge
thickness  = 0.8;   // 4 layers at 0.2 mm. Close to the ~0.65 mm gauge Måns
                    // plays, rounded to a clean layer multiple - 0.65 is 3.25
                    // layers and the slicer would round it unevenly.
shoulder_r = 10;    // roundness of the two top corners
tip_r      = 3.5;   // roundness of the tip - smaller is pointier and brighter

initials   = "MD";
font_size  = 7;
engrave    = true;  // true: cut in. false: raised on top.
depth      = 0.2;   // 1 layer. Shallow on purpose: leaves 0.6 mm under
                    // the letters so a thin pick is not weakened.

// Shoulder centres, derived so width/length come out exactly as set above.
sx = width / 2 - shoulder_r;
sy = length - shoulder_r - tip_r;

module outline() {
  hull() {
    circle(r = tip_r, $fn = 64);                          // tip, at origin
    translate([-sx, sy]) circle(r = shoulder_r, $fn = 64);
    translate([ sx, sy]) circle(r = shoulder_r, $fn = 64);
  }
}

module body() {
  linear_extrude(height = thickness) outline();
}

module branding(z, h) {
  translate([0, sy, z])
    linear_extrude(height = h)
      text(initials, size = font_size, halign = "center", valign = "center");
}

module pick() {
  if (engrave) {
    difference() {
      body();
      // overshoot the top face so difference() leaves no skin over the letters
      branding(thickness - depth, depth + 1);
    }
  } else {
    body();
    branding(0, thickness + depth);
  }
}

pick();
