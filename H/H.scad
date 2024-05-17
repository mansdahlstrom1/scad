$fn = $preview ? 8 : 50;

module roundedCube(width, depth, height) {
  radius = width / 2;

  color("red")
  union() {
    cube([width, depth, height]);

    rotate([90, 0, 0])
    translate([radius, height, -depth])
    cylinder(depth, radius, radius);
  }
}

module H(
  width,
  depth,
  height,
  middleSectionWidth,
  gap
) {

  offset = (width - middleSectionWidth) / 2;

  difference() {
    color("blue")
    cube([width, depth, height]);


    translate([offset, 0, 0])
    roundedCube(middleSectionWidth, depth, (height - gap) / 2);

    rotate([180, 0, 0])
    translate([offset, -depth, -height])
    roundedCube(middleSectionWidth, depth, (height - gap) / 2);
  }
}



// The thickness of the outside walls of the model
modelThickness = 1.5;

modelWidth = 30;
modelHeight = 100;
modelDepth = 10;

// The width of the GAP in the H (X-axis)
modelMiddleSectionWidth = 15;
// The width of the GAP in the H (Y-axis)
modelGap = 25;

render()
difference() {
  H(
    modelWidth,
    modelDepth,
    modelHeight,
    modelMiddleSectionWidth,
    modelGap
  );


  // The thickness of the thinnest part of the model
  thickness = 5;
  // The amount of material to be removed from the front and back of the model
  toBeRemoved = (modelDepth - thickness) / 2;

  translate([
    modelThickness,
    modelDepth - toBeRemoved,
    modelThickness
  ])
  H(
    modelWidth - modelThickness * 2,
    toBeRemoved,
    modelHeight - modelThickness * 2,
    modelMiddleSectionWidth + modelThickness * 2,
    modelGap
  );

  translate([
    modelThickness,
    0,
    modelThickness
  ])
  H(
    modelWidth - modelThickness * 2,
    toBeRemoved,
    modelHeight - modelThickness * 2,
    modelMiddleSectionWidth + modelThickness * 2,
    modelGap
  );
}
