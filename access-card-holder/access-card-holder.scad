// ============================================================
// Access card holder V2  —  card + door tag + foldable drawer key
//
// ONE printed piece. Both pockets open FORWARD, so the tag and the
// key drop in through the front window and the access card, sliding
// in last, is what holds them in — the same trick that makes V1
// impossible to lose the tag out of.
//
// Layer stack, front (z=0) to back:
//   0         .. face_t     front face plate, with the window
//   face_t    .. ins_front  card groove (open at the top edge)
//   ins_front .. plain_bz   thin back plate
//
// On that plate sit two raised islands, each only a couple of mm
// bigger than what it holds, so there is open air everywhere else:
//
//   tag island — pocket opens FORWARD. The card slides in on top of
//                the tag and is what stops it falling out.
//   key box    — pocket also opens FORWARD, so the key can only go in
//                with the card out, and the card then locks it. The
//                back is opened out to a lip each side, to save
//                material and to push the key out with a finger.
//
// The card stops the key moving forward but not downward, so the key
// also sits on a short ledge at the bottom. Both that ledge and the
// key box's guide walls stay in FRONT of the blade's own plane, and
// the box steps back below key_fy0, so the blade keeps a clear
// 180-degree arc out of the bottom of the badge.
//
// Tag and shell numbers were measured off the V1 meshes
// (cardholder(1).stl, cardholder-tag-insert-thick.stl).
//
// Printing: as one piece, the roof of the card slot is a 54 mm bridge.
// It cannot usefully be supported — the slot is a 1.4 mm cavity, too
// shallow for support to stand up in, and the strips behind the front
// plate can only be cleared blind. So the model also splits at the
// card-slot plane into "front" + "back". Both halves then print dead
// flat with nothing worse than a 2 mm lip overhang, and glue together.
// V1 was two pieces for the same reason.
//
// part: "both" (the two halves, laid out side by side — the default)
//       | "front" | "back" | "holder" | "test_key" | "test_tag"
// ============================================================

part = "both";
$fn  = 64;

/* ---------- Access card (CR80) ---------- */
card_w   = 54.0;
card_l   = 85.6;
card_t   = 0.76;
card_clr = 0.4;

/* ---------- Door tag (measured from the V1 insert) ---------- */
tag_w      = 30.75;  // narrow dimension of the teardrop
tag_h      = 46.25;  // long dimension
tag_t      = 2.8;
tag_r_tip  = 12.5;   // narrow-end radius, back-calculated from V1
tag_clr    = 0.25;
tag_z_clr  = 0.2;
tag_lip_w  = 2.0;    // how far the back lip reaches in over the tag
tag_lip_t  = 1.2;    // back lip thickness
tag_frame_w = 2.5;   // material around the tag island
tag_sideways = true; // long axis across the badge width, as V1

// V1 had a peg through the tag's hole. Split in two, the back half prints
// with its pockets opening toward the bed, so the peg now builds up from
// the build plate instead of hanging unsupported.
tag_peg         = true;
tag_peg_d       = 3.4;
tag_peg_frm_tip = 4.95;

/* ---------- Drawer key, folded ---------- */
// Measured off photos of the real key: body is ~23.6 x 40.4 mm, against a
// 23.5 x 40.25 pocket. Marginal in both directions, hence "hard to fit".
key_w       = 23.5;
key_h       = 41.0;
key_t_hinge = 8.0;   // thickness at the hinge (bottom) end
key_t_far   = 5.0;   // thickness at the far (top) end
key_clr     = 0.4;
key_frame_w = 2.0;   // material around the key frame
key_lip_w   = 2.0;   // how far the back lip reaches in over the key
key_lip_t   = 1.2;   // back lip thickness

// The hinge sits on the badge's bottom edge, so the folded blade hangs
// below the badge rather than being tucked inside it.
// The key has an oblong slot through its top end. A post through it locks
// the key against sliding, lifting and rotating; the card stops it lifting
// off. Sized DELIBERATELY SMALL against a measured 14.8 x 3.8 mm slot,
// because the measurement is photo-derived and only good to ~0.5 mm — an
// undersized post still locates, an oversized one will not go in at all.
key_slot_l        = 13.5;
key_slot_w        = 3.0;
key_slot_from_top = 3.5;   // slot centre, down from the key's top edge

blade_w     = 10.0;  // blade width          (TODO confirm)
blade_z0    = 2.6;   // blade front face, back from the key's front face
blade_clr   = 0.4;

/* ---------- Shell ---------- */
face_t     = 1.4;
// Deliberately generous: printed front-down, the roof of this slot is a
// 54 mm bridge, and whatever it sags comes straight out of the slot.
card_ch    = 1.4;    // card groove depth
base_t     = 1.2;    // thin back plate
side_wall  = 2.5;
// The bottom rim is the strip below the key pocket. At 2 mm it was a thin
// bar across the full width and it was the brittle part. It sits in FRONT
// of the blade's plane, so unlike the depth it can grow freely; the badge
// just gets that much taller.
bottom_rim = 5.0;
corner_r   = 5.0;
tab_h      = 12.0;

lanyard_w  = 14.0;
lanyard_h  = 4.0;
lanyard_from_top = 7.0;

window_clr = 1.5;    // slack so the tag can be dropped straight in
window_r   = 3.0;
thumb_r    = 6.0;

key_tag_gap = 2.0;   // tightened to buy room for the ID window

/* ---------- Card ID window (point 4) ---------- */
// The ID is printed on the back of the card, top left, 7 characters. These
// are PLACEHOLDERS — the card was not to hand. Everything is anchored to the
// card, not the badge. id_side is which side of the card the measurement was
// taken from, as seen looking at the BACK of the badge; flip it if mirrored.
id_window         = true;
id_w              = 24.0;
id_h              = 6.0;
id_r              = 1.5;
id_from_card_top  = 1.5;   // card's top edge -> window's top edge
id_from_card_side = 3.0;   // card's side edge -> window's outer edge
id_side           = "left";

/* ---------- Two-piece split, at the card-slot plane ---------- */
// The front half carries an outer lip that the back half nests into, so
// the two self-align and the seam is hidden. Glue on the flat land
// inside the lip.
split_lip_w = 0.8;
split_lip_h = 1.2;
split_clr   = 0.15;

/* ---------- Derived: z ---------- */
ins_front = face_t + card_ch;                 // back of the card groove
plain_bz  = ins_front + base_t;               // thin back plate
tag_bz    = ins_front + tag_t + tag_z_clr + tag_lip_t;
key_front = ins_front;                        // the key's front face
// back of the shallow guide channel below the key: it has to stay in
// front of the blade so the blade can swing past it
guide_z   = key_front + blade_z0 - blade_clr;

/* ---------- Derived: widths ---------- */
card_cw = card_w + card_clr;
outer_w = card_cw + 2 * side_wall;
key_pw  = key_w + 2 * key_clr;                // key pocket width
key_bw  = key_pw + 2 * key_frame_w;           // key box width

/* ---------- Derived: heights ---------- */
card_y0 = bottom_rim;
card_y1 = card_y0 + card_l + card_clr;
outer_h = card_y1 + tab_h;

// The hinge sits as low as it can while still leaving the key a ledge
// to rest on — that ledge is the only thing stopping it sliding out.
key_y0 = bottom_rim;                // hinge line / bottom of the key body
key_y1 = key_y0 + key_h + key_clr;
// the key box has to stop clear of the blade's swing, which reaches
// blade_w/2 above the hinge when the blade is horizontal
blade_clear = blade_w / 2 + 1.5;
key_fy0 = key_y0 + blade_clear;

tag_pl = tag_h + 2 * tag_clr;
tag_pw = tag_w + 2 * tag_clr;
tag_span_y = tag_sideways ? tag_pw : tag_pl;
tag_y0 = key_y1 + key_tag_gap;
tag_y1 = tag_y0 + tag_span_y;
tag_cy = (tag_y0 + tag_y1) / 2;

// The window has two jobs: show the card, and be the door the tag and
// key go in through. So it is derived from the tag, never hand-set.
window_w  = tag_pl + window_clr;
window_y0 = card_y0 + 2;
window_y1 = card_y1 - 4;

// key back face inside the badge, as a function of height
// post through the key's slot, and where the key's back has to stay closed
// so the post stands on floor instead of floating
key_post_y   = key_y1 - key_slot_from_top;
key_open_y1  = key_post_y - key_slot_w / 2 - 1.5;

// ID window, positioned off the card
card_top_y = card_y0 + card_l;
id_y = card_top_y - id_from_card_top - id_h / 2;
id_x = (id_side == "left" ? -1 : 1) * (card_w / 2 - id_from_card_side - id_w / 2);

// Only ~8 mm of clear plate between the tag island and the card's top edge,
// so the window has nowhere else to go. Fail loudly rather than in the print.
assert(!id_window || id_y - id_h / 2 > tag_y1 + tag_frame_w + 0.4,
       "ID window overlaps the tag island - raise it, shrink id_h, or drop key_tag_gap");

function key_depth(y) =
    key_t_hinge + (key_t_far - key_t_hinge) * (y - key_y0) / key_h;
function key_bz(y) = key_front + key_depth(y) + key_clr + key_lip_t;

// ============================================================
// 2D helpers
// ============================================================

module rrect(w, h, r) {
    hull() for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * (w / 2 - r), sy * (h / 2 - r)]) circle(r = r);
}

module outline2d() {
    translate([0, outer_h / 2]) rrect(outer_w, outer_h, corner_r);
}

// teardrop, narrow tip at the origin, growing along +Y
module teardrop2d(len, r_wide, r_tip) {
    d = len - r_wide - r_tip;
    hull() {
        translate([0, r_tip])     circle(r = r_tip);
        translate([0, r_tip + d]) circle(r = r_wide);
    }
}

module tag_pocket2d() {
    if (tag_sideways)
        translate([-tag_pl / 2, tag_cy]) rotate(-90)
            teardrop2d(tag_pl, tag_w / 2 + tag_clr, tag_r_tip + tag_clr);
    else
        translate([0, tag_y0])
            teardrop2d(tag_pl, tag_w / 2 + tag_clr, tag_r_tip + tag_clr);
}

// Back opening for the tag. Stopped short of the peg: the opening removes
// the very floor the peg stands on, and its other end opens into the card
// groove, so without this the peg renders as a detached floating cylinder.
module tag_back_open2d() {
    keep = tag_peg_d / 2 + 3;
    if (tag_peg)
        intersection() {
            offset(r = -tag_lip_w) tag_pocket2d();
            if (tag_sideways)
                translate([peg_pos[0] + keep, tag_cy - 100]) square([200, 200]);
            else
                translate([-100, peg_pos[1] + keep]) square([200, 200]);
        }
    else
        offset(r = -tag_lip_w) tag_pocket2d();
}

peg_pos = tag_sideways
    ? [-tag_pl / 2 + tag_clr + tag_peg_frm_tip, tag_cy]
    : [0, tag_y0 + tag_clr + tag_peg_frm_tip];

// ============================================================
// 3D helpers
// ============================================================

// extrude a (y, z) profile across the badge width
module yz_prism(pts, width) {
    translate([-width / 2, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height = width)
                polygon(pts);
}

module box(w, y0, y1, z0, z1) {
    translate([-w / 2, y0, z0]) cube([w, y1 - y0, z1 - z0]);
}

// Raised frame behind the key: a shallow guide channel at the bottom,
// then the frame proper, starting clear of the blade's swing.
key_profile = [
    [key_y1 + key_frame_w, ins_front],
    [key_y1 + key_frame_w, key_bz(key_y1)],
    [key_fy0,              key_bz(key_fy0)],
    [key_fy0,              guide_z],
    [-1,                   guide_z],
    [-1,                   ins_front]
];

// ============================================================
// The holder
// ============================================================

// window, thumb notch and lanyard slot — everything cut through the
// face plate, shared by the one-piece body and the front half
module face_cuts() {
    // window: shows the card, and is how the tag and key go in
    translate([0, (window_y0 + window_y1) / 2, -1])
        linear_extrude(face_t + 2)
            rrect(window_w, window_y1 - window_y0, window_r);

    // thumb notch, for pushing the card back up
    translate([0, card_y1 - thumb_r - 2, -1])
        linear_extrude(face_t + 2) circle(r = thumb_r);

    // lanyard slot
    translate([0, outer_h - lanyard_from_top, -1])
        linear_extrude(plain_bz + 2)
            rrect(lanyard_w, lanyard_h, lanyard_h / 2);
}

module holder() {
    union() {
        difference() {
            union() {
                // face plate + perimeter wall around the card groove
                linear_extrude(ins_front) outline2d();
                // thin back plate
                translate([0, 0, ins_front])
                    linear_extrude(base_t) outline2d();
                // raised island around the tag only
                translate([0, 0, ins_front])
                    linear_extrude(tag_bz - ins_front)
                        offset(r = tag_frame_w) tag_pocket2d();
                // Bottom band, full width. The blade-clearance region used
                // to be only as wide as the key box, leaving a bare 1.2 mm
                // plate either side of it - that was the brittle edge. This
                // adds nothing behind guide_z, so the blade still clears.
                intersection() {
                    translate([0, 0, ins_front])
                        linear_extrude(guide_z - ins_front) outline2d();
                    translate([-outer_w, -1, ins_front])
                        cube([2 * outer_w, key_fy0 + 1, 40]);
                }
                // raised frame around the key only
                intersection() {
                    linear_extrude(40)
                        translate([0, (key_y1 + key_frame_w) / 2])
                            rrect(key_bw, key_y1 + key_frame_w, 2);
                    yz_prism(key_profile, key_bw + 2);
                }
            }

            // card groove — card slides down from the top edge
            box(card_cw, card_y0, outer_h + 1, face_t, ins_front);

            face_cuts();

            // key pocket — opens forward, ramped to match the key's
            // wedge, sitting on the ledge at key_y0
            yz_prism([
                [key_y0, ins_front - 1],
                [key_y0, key_front + key_depth(key_y0) + key_clr],
                [key_y1, key_front + key_depth(key_y1) + key_clr],
                [key_y1, ins_front - 1]
            ], key_pw);

            // Open the key's back, leaving a lip down each side. It stops
            // below the post so the top of the pocket keeps its floor for
            // the post to stand on - that retained band is also the "block"
            // that holds the key. The post supports it mid-span, so it
            // bridges ~5 mm a side rather than the full pocket width.
            box(key_pw - 2 * key_lip_w, key_y0, key_open_y1, key_front, 40);

            // card ID window, so the ID on the card's back can be read
            // without pulling the card. Cut from inside the card groove
            // backward, so the front half is untouched.
            if (id_window)
                translate([id_x, id_y, ins_front - 1])
                    linear_extrude(40) rrect(id_w, id_h, id_r);

            // tag pocket — opening forward, card sits flush on the tag
            translate([0, 0, ins_front - 1])
                linear_extrude(tag_t + tag_z_clr + 1) tag_pocket2d();

            // open the tag's back too, leaving a lip all round. Saves
            // material, lets you push the tag out, and leaves a 2 mm
            // overhang here instead of a 31 mm bridge.
            translate([0, 0, ins_front + tag_t + tag_z_clr])
                linear_extrude(40) tag_back_open2d();
        }

        // post through the key's slot. Spans the full pocket depth, so in
        // the back half it builds from the bed up into the retained floor.
        translate([0, key_post_y, ins_front])
            linear_extrude(key_depth(key_post_y) + key_clr)
                rrect(key_slot_l, key_slot_w, key_slot_w / 2);

        if (tag_peg)
            translate([peg_pos[0], peg_pos[1], ins_front])
                cylinder(d = tag_peg_d, h = tag_t + tag_z_clr);
    }
}

// ============================================================
// Output
// ============================================================

// ---- the two printable halves ----

// outer lip on the front half; interrupted where the card slides in.
// Extruded with an overlap so it merges into the wall instead of
// butting onto it, which would leave coincident faces.
module split_lip(h) {
    linear_extrude(h)
        difference() {
            difference() { outline2d(); offset(r = -split_lip_w) outline2d(); }
            translate([-card_cw / 2, card_y0]) square([card_cw, outer_h]);
        }
}

module front_piece() {
    difference() {
        union() {
            linear_extrude(ins_front) outline2d();
            translate([0, 0, ins_front - 0.6]) split_lip(split_lip_h + 0.6);
        }
        // card groove, run out past the top so it leaves no coplanar face
        box(card_cw, card_y0, outer_h + 1, face_t, ins_front + 2);
        face_cuts();
    }
}

// sits on the bed on its split face, pockets opening downward
module back_piece() {
    translate([0, 0, -ins_front])
        intersection() {
            holder();
            translate([-outer_w, -1, ins_front])
                cube([2 * outer_w, outer_h + 2, 60]);
            translate([0, 0, ins_front - 1]) linear_extrude(60)
                offset(r = -(split_lip_w + split_clr)) outline2d();
        }
}

module coupon(y0, y1) {
    intersection() {
        holder();
        translate([-outer_w, y0, -1]) cube([2 * outer_w, y1 - y0, 40]);
    }
}

if (part == "front")         front_piece();
else if (part == "back")     back_piece();
else if (part == "holder")   holder();
else if (part == "test_key") coupon(-1, key_y1 + 4);
else if (part == "test_tag") coupon(tag_y0 - 5, tag_y1 + 5);
else {
    front_piece();
    translate([outer_w + 8, 0, 0]) back_piece();
}
