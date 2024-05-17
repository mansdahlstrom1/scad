// 20mm
width = 200;

// print thickness 2mm
thickness=20;

// Height of the plant-pot 160mm minus the rounded corners with a radius of print thickness
height = 1600 - thickness * 2;


// 2mm
support_pad_size = 200;
// 1mm
support_pad_thickness = 10;
// The support length (wall to plant pot)
suppportLength = 750 - (thickness + support_pad_thickness);

// Support angle
angle=62.047;

module rounded_corner(move_up = false) {
  translate(v = [0, 0, move_up ? 0 : thickness]) {
    rotate(a = 90, v = [0, 1, 0]) {
      cylinder(h = width, r = thickness);
    }
  }
}

module support() {
  cube(size = [width, suppportLength, thickness]);

  translate(v = [0, suppportLength, (-support_pad_size + thickness) / 2]) {
    rotate(a = 90, v = [1, 0, 0]) {
      cube(size = [width, support_pad_size, support_pad_thickness]);
    }
  }
}


module beam() {
  // Right angle triangle calculations
  c = suppportLength;
  b = c * sin(angle);
  a = sqrt(pow(c, 2) - pow(b, 2));

  translate(v = [0, a - thickness, b + thickness / 2]) {
    rotate(a = -angle, v = [1, 0, 0]) {
      cube(size = [width, c + thickness / 2, thickness]);
    }
  }
}

// TODO - Make a rounder more elegant latch
module latch() {
  translate(v = [0, height, 0]) {
    rounded_corner(true);
    rotate(a = 180 + 28.072, v = [1, 0, 0]) {
      cube(size = [width, width, thickness]);
    }
  }
}


// Part running next to Planter
rounded_corner();
cube([width, height, thickness]);

// Wall Support
translate(v = [0, 0, thickness]) {
  rotate(a = angle, v = [1, 0, 0]) {
    support();
  }
}

// Beam for more sturdyness
beam();

// Latch that hooks on to planter
latch();
