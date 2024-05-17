// mm
// Height of the plant-pot

// 20mm
width = 200;
// print thickness 2mm
thickness=20;
// 1600mm minus the rounded corners with a radius of print thickness
height = 1600 - thickness * 2;
// The support length (wall to plant pot)
suppportLength = 750 - thickness * 2;

// Support angle
angle=62.047;
rad=1.08292;

module rounded_corner(move_up = false) {
  translate(v = [0, 0, move_up ? 0 : thickness]) {
    rotate(a = 90, v = [0, 1, 0]) {
      cylinder(h = width, r = thickness);
    }
  }
}

module support() {
  support_pad_size = 200;
  cube(size = [width, suppportLength, thickness]);

  translate(v = [0, suppportLength, (-support_pad_size + thickness) / 2]) {
    rotate(a = 90, v = [1, 0, 0]) {
      cube(size = [width, support_pad_size, 10]);
    }
  }
}


module beam() {
  // triangle
  c = suppportLength;
  b = c * sin(angle);
  a = sqrt(pow(c, 2) - pow(b, 2));

  translate(v = [0, a - thickness, b + thickness / 2]) {
    rotate(a = -angle, v = [1, 0, 0]) {
      cube(size = [width, c + thickness / 2, thickness]);
    }
  }

}


// running next to Planter
cube([width, height, thickness]);
rounded_corner();

// Support
translate(v = [0, 0, thickness]) {
  rotate(a = angle, v = [1, 0, 0]) {
    support();
  }
}

// Beam
beam();

// latch
translate(v = [0, height, 0]) {
  rounded_corner(true);
  rotate(a = 180 + 28.072, v = [1, 0, 0]) {
    cube(size = [width, width, thickness]);
  }
}
