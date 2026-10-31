// ============================================================
//  Braun / Oral-B "loop" holder
//  Layout (left -> right):  head  head  [charger + handle]  head  head
//
//  Parts:
//   - loop      : stadium-shaped band with top bar, teardrop openings,
//                 integrated posts + pegs, two splayed blade legs.
//                 Detachable: lift it off and wash it.
//   - drip_pad  : TPU dish the charger stands on (stays on the counter).
//   - leg_pads  : TPU strips pressed into grooves under the legs.
//
//  Coordinates (assembly): origin = charger center on the counter,
//  +X right, +Y back, +Z up.
//
//  PRINTING THE LOOP: part = "loop" is already rotated for printing:
//  lying on its BACK face. Everything prints without supports:
//   - openings in the top bar are teardrops pointing FRONT (= up in print)
//   - posts and pegs are teardrops pointing BACK (= down in print)
// ============================================================

/* [What to render] */
part = "assembly"; // [assembly, loop, drip_pad, leg_pads, test_peg]
show_ghosts = true; // show charger, handle and heads in the assembly

/* [Charger] */
charger_d        = 56.2;
charger_h_edge   = 18.0;   // height at outer edge
charger_h_center = 20.56;  // height near the spindle
charger_clear    = 1.0;    // radial clearance (test pocket at 0.4 was snug)

/* [Handle (electrical unit)] */
handle_d         = 24;
handle_h         = 200;
handle_hole_d    = 29;     // opening in the top bar for the handle

/* [Brush heads] */
head_h           = 81.34;
head_body_h      = 51;     // from bottom to where the bristles start
head_d_bottom    = 15.2;   // widest part (bottom) - must pass through the opening
head_d_neck      = 8.9;    // narrowest part, below bristles
head_hole_d      = 20;     // teardrop opening (circle part) for each head
bristle_gap      = 3;      // top bar sits this far below the bristles

/* [Layout] */
peg_inner_x      = 42;     // center of inner heads from the charger center
peg_pitch        = 32;     // inner -> outer head distance
bar_end_margin   = 4;      // material between the outer opening and the arch

/* [Loop body] */
loop_depth       = 52;     // front-to-back
wall             = 5;      // band / bar / arch thickness
lift             = 12;     // underside of the bottom band above the counter
edge_round       = 2.0;    // rounding of front & back edges
edge_steps       = 6;      // smoothness of that rounding
profile_round    = 1.5;    // rounding of corners in the side profile
hole_chamfer     = 1.0;    // chamfer on top of the openings

/* [Posts and pegs] */
post_d           = 16;     // head rests on this post
post_h           = 3;      // post height above the bottom band
post_top_inset   = 3;      // conical top (sheds water): radius shrinks by this
post_top_h       = 1.2;
peg_d            = 8.0;    // head bore measured 8.6; prints ~0.4 under nominal
peg_d_top        = 7.4;    // taper for easy insertion
peg_h            = 14;
peg_tip_chamfer  = 1.0;
peg_point_trunc  = 0.3;    // teardrop point of peg truncated this far beyond the circle

/* [Legs] */
leg_top_w        = 7;      // width where the leg joins the band
leg_foot_w       = 9;      // width of the foot
leg_attach_in    = 10;     // leg top center: this far inside the arch start
leg_splay        = 18;     // foot center is this far outward from the leg top center

/* [TPU leg pads] */
leg_pads         = true;
pad_groove_w     = 3.0;
pad_groove_h     = 1.6;
pad_groove_end   = 4;      // groove stops this far from front/back (closed ends)
pad_press        = 0.2;    // TPU strip is this much wider than the groove
pad_protrude     = 1.0;    // strip sticks out below the foot

/* [Drip pad] */
drip_h           = 2.5;    // charger stands this high above the counter
drip_floor       = 0.8;
drip_rim_extra   = 4;      // rim radius beyond the charger clearance
drip_rim_w       = 2;
drip_plateau_in  = 3;      // plateau radius = charger radius - this
drip_chamfer     = 0.6;

$fn = 96;
eps = 0.01;

// ------------------------------------------------------------
// Derived dimensions
// ------------------------------------------------------------
outer_x     = peg_inner_x + peg_pitch;
head_r      = head_hole_d / 2;
handle_r    = handle_hole_d / 2;
post_r      = post_d / 2;
S           = outer_x + head_r + bar_end_margin;     // half-length of straight part
band_top    = lift + wall;
head_bottom = band_top + post_h;
bar_top     = head_bottom + head_body_h - bristle_gap;
R           = (bar_top - lift) / 2;                  // outer arch radius
zc          = lift + R;                              // loop center height
bar_bot     = bar_top - wall;
gap_half    = charger_d/2 + charger_clear;
loop_len    = 2 * (S + R);
leg_top_x   = S - leg_attach_in;
leg_foot_x  = leg_top_x + leg_splay;
groove_len  = loop_depth - 2 * pad_groove_end;
sq2         = sqrt(2);

// ------------------------------------------------------------
// Sanity checks
// ------------------------------------------------------------
assert(head_hole_d >= head_d_bottom + 2,
       "head_hole_d too small: the head's widest part must pass through");
assert(handle_hole_d >= handle_d + 3, "handle_hole_d too small for the handle");
assert(handle_r * sq2 <= loop_depth/2 - 3,
       "Handle teardrop too close to the front: increase loop_depth or reduce handle_hole_d");
assert(head_r * sq2 <= loop_depth/2 - 3,
       "Head teardrop too close to the front: increase loop_depth or reduce head_hole_d");
assert(post_r * sq2 <= loop_depth/2 - edge_round,
       "Post teardrop runs into the rounded back edge: reduce post_d");
assert(peg_inner_x - post_r > gap_half + 3,
       "Inner posts too close to the charger gap: increase peg_inner_x");
assert(peg_inner_x - head_r - handle_r >= 6,
       "Inner head opening too close to the handle opening: increase peg_inner_x");
assert(peg_pitch - head_hole_d >= 6, "Head openings too close: increase peg_pitch");
assert(R - wall > 10, "Loop too low");
assert(leg_foot_x + leg_foot_w/2 < S + R - 2, "Legs stick out past the loop: reduce leg_splay");
assert(drip_h < lift - 2, "Drip pad would touch the loop: increase lift");

// ------------------------------------------------------------
// 2D helpers
// ------------------------------------------------------------

// Teardrop pointing +Y; optional truncation of the point at distance `trunc`
module teardrop2d(r, trunc = -1) {
    intersection() {
        hull() {
            circle(r = r);
            polygon([[-r/sq2, r/sq2], [r/sq2, r/sq2], [0, r * sq2]]);
        }
        if (trunc > 0) translate([-r - 1, -r - 1]) square([2*r + 2, r + 1 + trunc]);
        else translate([-r - 1, -r - 1]) square([2*r + 2, r * 3]);
    }
}

module stadium2d(s, r) {
    hull() for (k = [-1, 1]) translate([k * s, 0]) circle(r = r);
}

module legs2d() {
    for (k = [-1, 1]) mirror([k < 0 ? 1 : 0, 0])
        polygon([
            [leg_top_x - leg_top_w/2,   lift + wall/2],
            [leg_top_x + leg_top_w/2,   lift + wall/2],
            [leg_foot_x + leg_foot_w/2, 0],
            [leg_foot_x - leg_foot_w/2, 0]
        ]);
}

// Side profile of the loop (X = length, Y = height)
module loop_profile() {
    offset(r = profile_round) offset(delta = -2 * profile_round) offset(r = profile_round)
    difference() {
        union() {
            difference() {
                translate([0, zc]) stadium2d(S, R);
                translate([0, zc]) stadium2d(S, R - wall);
            }
            legs2d();
        }
        // gap in the bottom band for the charger
        translate([-gap_half, lift - 1]) square([2 * gap_half, wall + 2]);
    }
}

// Extrude the profile along Y (depth) with rounded front & back edges
module rounded_extrude_y(depth, er, steps) {
    rotate([90, 0, 0]) translate([0, 0, -depth/2]) union() {
        for (i = [0 : steps - 1]) {
            t0 = er * i / steps;
            t1 = er * (i + 1) / steps;
            tm = (t0 + t1) / 2;
            inset = er - sqrt(er * er - (er - tm) * (er - tm));
            for (z = [t0, depth - t1])
                translate([0, 0, z]) linear_extrude(t1 - t0 + eps)
                    offset(delta = -inset) children();
        }
        translate([0, 0, er - eps]) linear_extrude(depth - 2 * er + 2 * eps) children();
    }
}

// ------------------------------------------------------------
// 3D parts of the loop
// ------------------------------------------------------------

// Post (teardrop pointing back) with conical top
module post3d() {
    linear_extrude(post_h - post_top_h + eps) teardrop2d(post_r);
    translate([0, 0, post_h - post_top_h])
        linear_extrude(post_top_h, scale = (post_r - post_top_inset) / post_r)
            teardrop2d(post_r);
}

// Tapered peg (truncated teardrop pointing back)
module peg3d() {
    trunc = peg_d/2 + peg_point_trunc;
    body_h = peg_h - peg_tip_chamfer;
    s_top  = peg_d_top / peg_d;
    s_body = 1 - (1 - s_top) * body_h / peg_h;
    linear_extrude(body_h + eps, scale = s_body) teardrop2d(peg_d/2, trunc);
    translate([0, 0, body_h])
        linear_extrude(peg_tip_chamfer,
                       scale = (peg_d * s_body - 2 * peg_tip_chamfer) / (peg_d * s_body))
            scale(s_body) teardrop2d(peg_d/2, trunc);
}

// Through-opening in the top bar (teardrop pointing front) with top chamfer
module bar_opening(r) {
    translate([0, 0, bar_bot - 1])
        linear_extrude(wall + 2) mirror([0, 1]) teardrop2d(r);
    translate([0, 0, bar_top - hole_chamfer])
        linear_extrude(hole_chamfer + eps, scale = (r + hole_chamfer) / r)
            mirror([0, 1]) teardrop2d(r);
}

module leg_grooves() {
    for (k = [-1, 1])
        translate([k * leg_foot_x - pad_groove_w/2, -groove_len/2, -1])
            cube([pad_groove_w, groove_len, pad_groove_h + 1]);
}

head_xs = [-outer_x, -peg_inner_x, peg_inner_x, outer_x];

module loop() {
    difference() {
        rounded_extrude_y(loop_depth, edge_round, edge_steps) loop_profile();
        bar_opening(handle_r);
        for (x = head_xs) translate([x, 0, 0]) bar_opening(head_r);
        if (leg_pads) leg_grooves();
    }
    for (x = head_xs)
        translate([x, 0, band_top - eps]) {
            post3d();
            translate([0, 0, post_h - eps]) peg3d();
        }
}

// ------------------------------------------------------------
// Drip pad (TPU) - charger stands on the plateau, drips go to the moat
// ------------------------------------------------------------
module drip_pad() {
    rim_in  = gap_half + drip_rim_extra;
    rim_out = rim_in + drip_rim_w;
    plateau = charger_d/2 - drip_plateau_in;
    rim_h   = drip_h - 0.5;
    difference() {
        union() {
            cylinder(h = drip_chamfer, r1 = rim_out - drip_chamfer, r2 = rim_out);
            translate([0, 0, drip_chamfer - eps])
                cylinder(h = rim_h - drip_chamfer + eps, r = rim_out);
        }
        translate([0, 0, drip_floor]) cylinder(h = drip_h, r = rim_in);
    }
    cylinder(h = drip_h - drip_chamfer, r = plateau);
    translate([0, 0, drip_h - drip_chamfer - eps])
        cylinder(h = drip_chamfer + eps, r1 = plateau, r2 = plateau - drip_chamfer);
}

// ------------------------------------------------------------
// TPU leg pads - strips pressed into the grooves under the feet
// ------------------------------------------------------------
module leg_pad() {
    w = pad_groove_w + pad_press;
    h = pad_groove_h + pad_protrude;
    l = groove_len - 0.4;
    c = 0.4;
    hull() {
        translate([c, 0, 0]) cube([l - 2*c, w, h]);
        translate([0, c, c]) cube([l, w - 2*c, h - 2*c]);
    }
}

// ------------------------------------------------------------
// Test coupon: piece of bottom band with one post + peg, printed
// in the same orientation as the loop (back face down)
// ------------------------------------------------------------
module test_peg_coupon() {
    translate([-12, -loop_depth/2, 0]) cube([24, loop_depth, wall]);
    translate([0, 0, wall - eps]) {
        post3d();
        translate([0, 0, post_h - eps]) peg3d();
    }
}

// ------------------------------------------------------------
// Ghosts for the assembly view
// ------------------------------------------------------------
module ghosts() {
    // charger
    translate([0, 0, drip_h]) {
        cylinder(h = charger_h_edge, d = charger_d);
        cylinder(h = charger_h_center, d = 30);
    }
    // handle
    translate([0, 0, drip_h + charger_h_center]) cylinder(h = handle_h, d = handle_d);
    // heads
    for (x = head_xs) translate([x, 0, head_bottom]) {
        cylinder(h = head_body_h, d1 = head_d_bottom, d2 = head_d_neck);
        translate([0, 0, head_body_h])
            hull() {
                cylinder(h = head_h - head_body_h - 4, d = head_d_neck + 2);
                translate([0, -2, 6]) cylinder(h = head_h - head_body_h - 10, d = 14);
            }
    }
}

// ------------------------------------------------------------
// Output
// ------------------------------------------------------------
if (part == "assembly") {
    color("#2b2b2b") loop();
    color("#9a9a9a") drip_pad();
    if (leg_pads)
        for (k = [-1, 1])
            color("#777")
                translate([k * leg_foot_x + (pad_groove_w + pad_press)/2,
                           -(groove_len - 0.4)/2, -pad_protrude])
                    rotate([0, 0, 90]) leg_pad();
    if (show_ghosts) %ghosts();
}
else if (part == "loop")
    translate([0, 0, loop_depth/2]) rotate([-90, 0, 0]) loop();
else if (part == "drip_pad")
    drip_pad();
else if (part == "leg_pads")
    for (i = [0, 1]) translate([0, i * 8, 0]) leg_pad();
else if (part == "test_peg")
    translate([0, 0, loop_depth/2]) rotate([-90, 0, 0]) test_peg_coupon();

echo(str("Loop: ", loop_len, " x ", loop_depth, " x ", bar_top, " mm (L x D x H); ",
         "top bar at ", bar_bot, "-", bar_top, " mm; head bottoms at ", head_bottom,
         " mm; charger gap ", 2 * gap_half, " mm"));
