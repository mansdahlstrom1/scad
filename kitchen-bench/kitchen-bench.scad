$fn = 50;

debug = false;
show_supports = true;
show_top = false;
show_cushion = false;


depth = 330;

cabinet_stone_top_thickness = 30;
cabinet_plywood_top_thickness = 18;
cabinet_height = 897 - cabinet_stone_top_thickness - cabinet_plywood_top_thickness; // 897 - 30 - 18 = 849
cabinet_width = 660;
cabinet_overhang = 20;

// bench_cushion_height = 40;
bench_top_thickness = 27;
bench_height = 450 - bench_top_thickness; // 423
bench_width = 1600;
bench_overhang = 50;
bench_top_corner_radius = 15;

plywood_thickness = 18;
stud_thickness = 45;
module stud(length = 100) {
  Cube(stud_thickness, length, stud_thickness);
}
//

Cabinet();
Bench();

//

module Cabinet() {
  // Skåp
  if (debug) {
    color("#80000085")
    %Cube(depth, cabinet_width, cabinet_height);
  }

  if (show_supports) {
    // Regel bak
    translate([0, plywood_thickness, cabinet_height - stud_thickness])
    stud(cabinet_width - 2*plywood_thickness);

    // Regel bak nere
    translate([0, 0, 0])
    stud(bench_width);

    // Regel fram uppe
    translate([depth - stud_thickness, 0, cabinet_height - stud_thickness])
    stud(cabinet_width);

    // Regel fram nere
    translate([depth - stud_thickness, 0, 0])
    stud(cabinet_width);

    // Väggar
    Cube(depth, plywood_thickness, cabinet_height);

    translate([0, cabinet_width - plywood_thickness, 0])
    Cube(depth, plywood_thickness, cabinet_height);
  }

  if (show_top) {
    // plywood top
    translate([0, 0, cabinet_height])
    Cube(depth, cabinet_width, cabinet_plywood_top_thickness);

    // Sten Bänkskiva
    color("#000000")
    translate([0, 0, cabinet_height])
    Cube(depth + cabinet_overhang, cabinet_width + cabinet_overhang, cabinet_stone_top_thickness);

    // hyllplan
    translate([0, 0, stud_thickness])
    Cube(depth, cabinet_width, 12);

    translate([0, 0, bench_height - 12])
    Cube(depth, cabinet_width, 12);

    // dörr
    translate([depth, 0, 0])
    Rotate([0, 0, -45 - 45 * sin($t*360)])
    Cube(12, cabinet_width, cabinet_height - cabinet_stone_top_thickness);
  }
}

module Bench() {
  // Bänk
  translate([0, cabinet_width, 0]) {
    if (debug) {
      color("#80000085")
      %Cube(depth, bench_width, bench_height);
    }

    if (show_top) {
      // skiva
      translate([0, 0, bench_height])
      RoundedFrontCube(depth + bench_overhang, bench_width, bench_top_thickness, bench_top_corner_radius);
    }

    if (show_cushion) {
      translate([5, 5, bench_height])
      Cube(depth + bench_overhang - 10, bench_width - 10, bench_cushion_height, "#bca895");
    }


    if (show_supports) {
      // Regel bak
      translate([0,0, bench_height - stud_thickness])
      stud(bench_width);

      // Regel bak nere
      translate([0, 0, 0])
      stud(bench_width);

      // Regel fram uppe
      translate([depth - stud_thickness, 0, bench_height - stud_thickness])
      stud(bench_width);

      // Regel fram nere
      translate([depth - stud_thickness, 0, 0])
      stud(bench_width);

      // legs
      Cube(depth, plywood_thickness, bench_height);

      translate([0, bench_width/2 - plywood_thickness/2, 0])
      Cube(depth, plywood_thickness, bench_height);

      translate([0, bench_width/2 + plywood_thickness/2, 0])
      Cube(depth, plywood_thickness, bench_height);

      translate([0, bench_width - plywood_thickness, 0])
      Cube(depth, plywood_thickness, bench_height);
    }
  }
}


module Cube(width, length, height, color = "#bab09e") {
  color(color)
  cube([width, length, height]);
}

module RoundedFrontCube(width, length, height, r = 10, color = "#bab09e") {
  color(color)
  linear_extrude(height)
  hull() {
    square([width - r, length]);
    translate([width - r, r]) circle(r);
    translate([width - r, length - r]) circle(r);
  }
}

module Rotate(rotation = [0, 0, 0], originOffset = [0, 0, 0], debug = false) {
  translate(originOffset)
  rotate(rotation)
  translate(-originOffset)
  children();

  if (debug) {
    translate(originOffset)
    #sphere(r=20);
  }
}
