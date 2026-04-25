$fn = 50;

diameter    = 20;
length      = 80;
indent_size = 2;   // width of the knock slot

cut_depth = diameter / 2;

difference() {
  cylinder(h=length, d=diameter);

  // Slot cut along the top, running the full length
  translate([diameter/2 - cut_depth, -indent_size/2, -1])
  cube([cut_depth + 1, indent_size, length + 2]);
}
