$fn = 50;

// ── Measured dimensions (mm) ──────────────────────────────────────────────────
back_width     = 639;   // back wall: BL → BR
right_side     = 330;   // right wall: BR → FR
left_side      = 329;   // left wall:  FL → BL
cabinet_height = 870;

// Cross-diagonal measurements — fully define the shape together with the sides
diag_bl_fr = 713;       // back-left  → front-right
diag_fl_br = 733;       // front-left → back-right

overhang_right = 20;
overhang_front = 35;

// ── Analytically derived corner positions ─────────────────────────────────────
// Solved from side lengths + diagonals via circle intersections.
// Right side leans ~7mm inward over 330mm (not perpendicular).

// x-positions of front corners
FR_x = (pow(diag_bl_fr,2) - pow(right_side,2) + pow(back_width,2)) / (2*back_width); // ≈ 632
FL_x = (pow(left_side,2)  + pow(back_width,2) - pow(diag_fl_br,2)) / (2*back_width); // ≈ -16

// Back wall y-level (= right side length projected to y-axis)
back_y = sqrt(pow(diag_bl_fr,2) - pow(FR_x,2));  // ≈ 330

// Front-left y position (slightly above 0 due to left-wall angle)
FL_y = back_y - sqrt(pow(left_side,2) - pow(FL_x,2));  // ≈ 1.3

// ── Print mode ────────────────────────────────────────────────────────────────
// Set print_mode = true to export a single flat piece (thin, no cabinet/walls).
// Set piece = 1–8 to select which piece to export.
//
// Piece layout (top view, back wall at top, left wall at left):
//
//   back wall
//   ┌──────────────────────────────────────────┐
//   │ back-left  │ back-ctr-L │ back-ctr-R │ back-right  │
//   │    (1)     │    (2)     │    (3)     │    (4)      │
//   ├────────────┼────────────┼────────────┼─────────────┤
//   │ front-left │ front-ctr-L│ front-ctr-R│ front-right │
//   │    (5)     │    (6)     │    (7)     │    (8)      │
//   └──────────────────────────────────────────┘
//   front (overhang)

print_mode = false;
piece      = 1;
dxf_mode   = false;  // true = export flat 2D outline for stone cutters (save as .dxf)

top_thickness = print_mode ? 1.88 : 30;  // 1.88 = 0.20 first layer + 6 × 0.28mm

// ── Coordinate system ─────────────────────────────────────────────────────────
// y=0 is the cabinet front edge; positive y goes toward the back wall.
// In OpenSCAD top view (press 2): back wall at top, front at bottom.

X_MIN = FL_x;                           // leftmost point (front-left ≈ -16)
X_MAX = back_width + overhang_right;    // rightmost point: back-right (659) > front-right (652)
Y_MIN = -overhang_front;                // front edge (with overhang)
Y_MAX = back_y;                         // back wall y level (~330)

// ── Cut positions ─────────────────────────────────────────────────────────────
// 3 vertical cuts → 4 columns (all ≤ 180mm wide, fits 220×220mm bed)
// 1 horizontal cut → 2 rows (≤ 180mm tall each)
CUT_X = [160, 320, 480];
CUT_Y = 160;

function col_x0(c) = (c == 1) ? X_MIN : CUT_X[c-2];
function col_x1(c) = (c == 4) ? X_MAX : CUT_X[c-1];
function row_y0(r) = (r == 2) ? Y_MIN : CUT_Y;
function row_y1(r) = (r == 2) ? CUT_Y : Y_MAX;

// ── Dovetail parameters ───────────────────────────────────────────────────────
dt_narrow = 10;   // width at base (mm)
dt_wide   = 16;   // width at tip  (mm)
dt_depth  = 12;   // protrusion depth (mm)
dt_tol    = 0.25; // extra clearance on female socket

// Male pointing in +x from (cx, cy)
module dt_male_x(cx, cy, h) {
  linear_extrude(h)
  polygon([
    [cx,            cy - dt_narrow/2],
    [cx + dt_depth, cy - dt_wide/2  ],
    [cx + dt_depth, cy + dt_wide/2  ],
    [cx,            cy + dt_narrow/2],
  ]);
}

// Female socket matching a +x male at (cx, cy)
module dt_female_x(cx, cy, h) {
  translate([0, 0, -0.05])
  linear_extrude(h + 0.1)
  polygon([
    [cx,            cy - dt_narrow/2 - dt_tol],
    [cx + dt_depth, cy - dt_wide/2   - dt_tol],
    [cx + dt_depth, cy + dt_wide/2   + dt_tol],
    [cx,            cy + dt_narrow/2 + dt_tol],
  ]);
}

// Male pointing in +y from (cx, cy)
module dt_male_y(cx, cy, h) {
  linear_extrude(h)
  polygon([
    [cx - dt_narrow/2, cy          ],
    [cx - dt_wide/2,   cy + dt_depth],
    [cx + dt_wide/2,   cy + dt_depth],
    [cx + dt_narrow/2, cy          ],
  ]);
}

// Female socket matching a +y male at (cx, cy)
module dt_female_y(cx, cy, h) {
  translate([0, 0, -0.05])
  linear_extrude(h + 0.1)
  polygon([
    [cx - dt_narrow/2 - dt_tol, cy          ],
    [cx - dt_wide/2   - dt_tol, cy + dt_depth],
    [cx + dt_wide/2   + dt_tol, cy + dt_depth],
    [cx + dt_narrow/2 + dt_tol, cy          ],
  ]);
}

// ── Top panel 2D footprint ────────────────────────────────────────────────────
module top_2d() {
  polygon([
    [0,                    back_y          ],  // back-left  (flush to walls)
    [back_width + overhang_right, back_y  ],  // back-right (right overhang)
    [FR_x + overhang_right, Y_MIN         ],  // front-right (right + front overhang)
    [FL_x,                 FL_y + Y_MIN   ],  // front-left  (front overhang only)
  ]);
}

module top_solid() {
  linear_extrude(height = top_thickness) top_2d();
}

// ── Single piece ──────────────────────────────────────────────────────────────
// Vertical joints: left column gets male (+x), right column gets female socket.
// Horizontal joint: front row (row 2) gets male (+y), back row (row 1) gets female.
module make_piece(col, row) {
  x0 = col_x0(col);  x1 = col_x1(col);
  y0 = row_y0(row);  y1 = row_y1(row);
  h  = top_thickness;

  // 3 dovetails evenly spaced along each joint edge
  dt_ys = [y0 + 35, (y0 + y1) / 2, y1 - 35];
  dt_xs = [x0 + 35, (x0 + x1) / 2, x1 - 35];

  difference() {
    union() {
      // Base: full top shape clipped to this piece's bounding box
      intersection() {
        top_solid();
        translate([x0, y0, -0.05])
          cube([x1 - x0, y1 - y0, h + 0.1]);
      }
      // Males added after intersection so they extend beyond the bbox
      if (col < 4) for (dy = dt_ys) dt_male_x(x1, dy, h);  // right edge
      if (row == 2) for (dx = dt_xs) dt_male_y(dx, CUT_Y, h);  // top edge
    }
    // Female sockets cut into this piece
    if (col > 1) for (dy = dt_ys) dt_female_x(x0, dy, h);  // left edge
    if (row == 1) for (dx = dt_xs) dt_female_y(dx, CUT_Y, h);  // bottom edge
  }
}

// ── Scene ─────────────────────────────────────────────────────────────────────
// dxf_mode: set true, then export with:
//   openscad -o coffe-corner-top.dxf coffe-corner-top.scad

if (dxf_mode) {

  // 2D outline only — export as DXF for stone cutters
  // Use: openscad -o coffe-corner-top.dxf coffe-corner-top.scad
  top_2d();

} else if (print_mode) {

  // Single flat piece ready to slice and print
  col = ((piece - 1) % 4) + 1;
  row = floor((piece - 1) / 4) + 1;
  make_piece(col, row);

} else {

  // Cabinet body
  color("burlywood")
  linear_extrude(height = cabinet_height)
    polygon([
      [0,          back_y],
      [back_width, back_y],
      [FR_x,       0     ],
      [FL_x,       FL_y  ],
    ]);

  // Top panel (all 8 pieces assembled)
  color("black")
  translate([0, 0, cabinet_height])
    for (c = [1:4]) for (r = [1:2])
      make_piece(c, r);

  // Wall visualization (ghost — not exported)
  wall_h  = cabinet_height + top_thickness + 50;
  wall_t  = 15;
  wall_hl = 400;

  % color("steelblue") {
    // Back wall
    translate([-wall_hl, left_side, 0])
      cube([X_MAX + wall_hl, wall_t, wall_h]);
    // Left angled section
    linear_extrude(height = wall_h)
      polygon([
        [0,             back_y],
        [FL_x,          FL_y  ],
        [FL_x - wall_t, FL_y  ],
        [-wall_t,       back_y],
      ]);
    // Left horizontal section
    translate([FL_x - wall_hl, FL_y, 0])
      cube([wall_hl, wall_t, wall_h]);
  }

}
