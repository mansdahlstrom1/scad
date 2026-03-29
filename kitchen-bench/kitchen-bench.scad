$fn = 50;

debug = false;
show_supports = true;
show_barlina = true;
show_top = true;
show_cushion = true;


depth = 330;

cabinet_stone_top_thickness = 30;
cabinet_plywood_top_thickness = 12;
cabinet_height = 897 - cabinet_stone_top_thickness - cabinet_plywood_top_thickness;
cabinet_width = 660;
cabinet_overhang = 20;

bench_cushion_height = 40;
bench_top_thickness = 18;
bench_height = 450 - bench_cushion_height - bench_top_thickness;
bench_width = 1600;
bench_overhang = 50;

plywood_thickness = 12;
stud_thickness = 45;

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

  if (show_barlina) {
    // bärlina bak
    translate([0, plywood_thickness, cabinet_height - stud_thickness])
    45x45(cabinet_width - 2*plywood_thickness);
  }

  if (show_supports) {
    // Regel fram uppe
    translate([depth - stud_thickness, 0, cabinet_height - stud_thickness])
    45x45(cabinet_width);

    // "bärlina" fram nere
    translate([depth - stud_thickness, 0, 0])
    45x45(cabinet_width);

    // Väggar
    Cube(depth, plywood_thickness, cabinet_height);

    translate([0, cabinet_width - plywood_thickness, 0])
    Cube(depth, plywood_thickness, cabinet_height);

    // playwood top
    translate([0, 0, cabinet_height])
    Cube(depth, cabinet_width, cabinet_plywood_top_thickness);
  }

  if (show_top) {
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
    if (debug)
    color("#80000085")
    %Cube(depth, bench_width, bench_height);

    if (show_top) {
      // skiva
      translate([0, 0, bench_height])
      Cube(depth + bench_overhang, bench_width, bench_top_thickness);
    }

    if (show_cushion) {
      translate([5, 5, bench_height])
      Cube(depth + bench_overhang - 10, bench_width - 10, bench_cushion_height, "#bca895");
    }

    if (show_barlina) {
      // bärlina bak
      translate([0,0, bench_height - stud_thickness])
      45x45(bench_width);
    }

    if (show_supports) {
      // Regel fram uppe
      translate([depth - stud_thickness, 0, bench_height - stud_thickness])
      45x45(bench_width);

      // Regel fram nere
      translate([depth - stud_thickness, 0, 0])
      45x45(bench_width);


      // legs
      translate([stud_thickness, 0, 0])
      Cube(depth-stud_thickness, plywood_thickness, bench_height);

      translate([stud_thickness, bench_width/2 - plywood_thickness/2, 0])
      Cube(depth-stud_thickness, plywood_thickness, bench_height);

      translate([stud_thickness, bench_width/2 + plywood_thickness/2, 0])
      Cube(depth-stud_thickness, plywood_thickness, bench_height);

      translate([stud_thickness, bench_width - plywood_thickness, 0])
      Cube(depth-stud_thickness, plywood_thickness, bench_height);
    }
  }
}

module 45x45(length = 100) {
  Cube(stud_thickness, length, stud_thickness);
}

module Cube(width, length, height, color = "#bab09e") {
  color(color)
  cube([width, length, height]);
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
