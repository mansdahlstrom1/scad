
radius = 6;
y = 32 - radius * 2;
x = 27 - radius * 2;
h=2;

module branding() {
  linear_extrude(height = h + 1) {
    translate([0, y * 0.8, 0])
    text("MD", size=12, halign="center", valign="center");
  }
}

module pick() {
  linear_extrude(height=h)     
  minkowski() {
    polyhedron(points=[[0,0], [-x/2, y], [x/2, y]]);
    sphere(r=radius);
  }
  branding();
}

pick();
