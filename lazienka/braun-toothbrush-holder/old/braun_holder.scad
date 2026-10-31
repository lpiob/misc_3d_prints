// ============================================================
//  Braun / Oral-B toothbrush holder with 4 brush-head pegs
//  Layout (left -> right):  peg  peg  [charger]  peg  peg
// ============================================================
//  Origin: center of the charger pocket, z = 0 is the counter.
//  +Y is the BACK (cable side), -Y is the front.
// ============================================================

/* [What to render] */
// "all" = full holder, "test_peg" = small coupon to test head fit, "test_pocket" = ring to test charger fit
part = "all"; // [all, test_peg, test_pocket]

/* [Charger (measured)] */
charger_d        = 56.2;   // charger body diameter
charger_edge_h   = 18.0;   // charger height at outer edge
charger_cable_w  = 9.5;    // cable socket width (at back)
charger_cable_h  = 12.5;   // cable socket height, measured from bottom
charger_clear    = 0.4;    // radial clearance in pocket
cable_clear      = 1.0;    // extra room around cable plug (each side / top)
cable_slot_extra = 4.0;    // make slot wider than socket for the plug body

/* [Base / plinth] */
base_depth       = 72;     // front-to-back size (stadium width)
base_h_center    = 18.0;   // height of the flat charger "island"
end_drop         = 3.5;    // how much lower the ends are (drainage slope)
top_fillet       = 5.0;    // rounding of the top edge
bottom_chamfer   = 0.8;    // anti elephant-foot chamfer
end_margin       = 8;      // material beyond the outer post
pocket_chamfer   = 1.2;    // chamfer on pocket top edge
pocket_floor     = 0;      // 0 = open bottom (charger stands on counter), >0 = floor thickness

/* [Pegs] */
peg_inner_x      = 52;     // center of inner pegs from charger center
peg_pitch        = 38;     // distance between inner and outer peg
peg_center_offset = 0;     // Y shift of the 2 center pegs (+ = toward back)
post_d           = 18;     // diameter of the raised post the head rests on
post_h           = 8;      // post height above local base surface
post_top_slope   = 1.2;    // conical drop of the post top (sheds water)
post_fillet      = 1.5;    // rounding of post top edge
peg_d            = 7.6;    // peg diameter at bottom  (MEASURE your head bore!)
peg_d_top        = 7.0;    // peg diameter at top (taper = easy insertion)
peg_h            = 14;     // peg height above post
peg_tip_chamfer  = 1.0;
flute_count      = 4;      // vertical drainage/air grooves in the peg (0 = none)
flute_w          = 1.6;
flute_depth      = 1.0;

/* [Feet] */
foot_recess_d    = 10.5;   // recess for stick-on rubber bumpers (0 = none)
foot_recess_h    = 1.0;
foot_edge_margin = 8;      // distance from the outer edge to the foot recesses

/* [Drip groove (underside)] */
drip_groove       = true;  // V-groove around the underside so water drips off instead of creeping under
drip_groove_w     = 2.4;   // groove width at the bottom face (depth = width/2, 45° walls, prints without support)
drip_groove_inset = 2.5;   // distance from the outer edge to the groove (max ~4 near the charger at base_depth 72)

/* [Quality] */
$fn = 96;

// ------------------------------------------------------------
// Derived values
// ------------------------------------------------------------
eps        = 0.01;
outer_x    = peg_inner_x + peg_pitch;
base_len   = 2 * (outer_x + post_d/2 + end_margin);
end_cx     = base_len/2 - base_depth/2;      // x of end puck centers
flat_r     = base_depth/2 - top_fillet;       // radius of flat top of a puck
pocket_r   = charger_d/2 + charger_clear;
slot_w     = charger_cable_w + cable_slot_extra + 2*cable_clear;
slot_h     = charger_cable_h + cable_clear + pocket_floor;
base_h_end = base_h_center - end_drop;

groove_rc  = base_depth/2 - drip_groove_inset - drip_groove_w/2;  // groove centerline radius
groove_d   = drip_groove_w / 2;
foot_y     = base_depth/2 - foot_recess_d/2 - foot_edge_margin;

// Height of the sloped top surface at (x, y)
function top_z(x, y = 0) =
    let(half_w = sqrt(max(0, flat_r*flat_r - y*y)))
    base_h_center - end_drop * min(1, max(0, abs(x) - half_w) / end_cx);

// ------------------------------------------------------------
// Sanity checks
// ------------------------------------------------------------
assert(pocket_r + pocket_chamfer < flat_r,
       "Charger pocket is larger than the flat top: increase base_depth or reduce top_fillet");
assert(norm([peg_inner_x, peg_center_offset]) - post_d/2 > pocket_r + 3,
       "Inner post collides with charger pocket: increase peg_inner_x");
assert(abs(peg_center_offset) + post_d/2 <= flat_r,
       str("Center pegs too far from the middle: max |peg_center_offset| is ",
           flat_r - post_d/2, " (or increase base_depth)"));
assert(base_h_center - slot_h >= 3,
       "Less than 3 mm above the cable slot: increase base_h_center");
assert(!drip_groove || groove_rc - groove_d > pocket_r + 1,
       "Drip groove cuts into the charger pocket: reduce drip_groove_inset or drip_groove_w");
assert(!drip_groove || foot_recess_d == 0 ||
       foot_y + foot_recess_d/2 < groove_rc - groove_d - 0.5,
       "Drip groove overlaps the foot recesses: reduce drip_groove_inset or foot_recess_d");
assert(!drip_groove || drip_groove_inset > bottom_chamfer + 1,
       "Drip groove too close to the edge: increase drip_groove_inset");
assert(peg_pitch > post_d + 10,
       "Pegs too close: increase peg_pitch");

// ------------------------------------------------------------
// Building blocks
// ------------------------------------------------------------

// Round "puck" with filleted top edge and chamfered bottom edge
module puck(d, h, fr, ch) {
    rotate_extrude()
        hull() {
            square([d/2 - ch, eps]);
            translate([0, ch]) square([d/2, eps]);
            translate([0, h - eps]) square([d/2 - fr, eps]);
            translate([d/2 - fr, h - fr]) circle(r = fr, $fn = 48);
        }
}

// Stadium-shaped plinth whose top slopes from the center to both ends
module plinth() {
    hull() {
        puck(base_depth, base_h_center, top_fillet, bottom_chamfer);
        for (s = [-1, 1])
            translate([s * end_cx, 0, 0])
                puck(base_depth, base_h_end, top_fillet, bottom_chamfer);
    }
}

// Post with conical, rounded top
module post() {
    rotate_extrude()
        hull() {
            square([post_d/2, eps]);
            square([eps, post_h]);
            translate([post_d/2 - post_fillet, post_h - post_top_slope - post_fillet])
                circle(r = post_fillet, $fn = 32);
        }
}

// Tapered, fluted peg that mimics the handle neck
module peg() {
    difference() {
        union() {
            cylinder(h = peg_h - peg_tip_chamfer, d1 = peg_d,
                     d2 = peg_d_top + (peg_d - peg_d_top) * peg_tip_chamfer / peg_h);
            translate([0, 0, peg_h - peg_tip_chamfer - eps])
                cylinder(h = peg_tip_chamfer,
                         d1 = peg_d_top + (peg_d - peg_d_top) * peg_tip_chamfer / peg_h,
                         d2 = peg_d_top - 2 * peg_tip_chamfer);
        }
        if (flute_count > 0)
            for (i = [0 : flute_count - 1])
                rotate([0, 0, i * 360 / flute_count + 45])
                    translate([peg_d/2, 0, peg_h/2 - 1])
                        cube([2 * flute_depth, flute_w, peg_h + 4], center = true);
    }
}

// Post + peg, placed on the sloping top at position (x, y)
module peg_station(x, y = 0) {
    z0 = top_z(x, y);
    translate([x, y, z0 - 3]) {             // sink 3 mm into the plinth
        // post (extended down so it fuses with the slope)
        translate([0, 0, 0]) cylinder(h = 3 + eps, d = post_d);
        translate([0, 0, 3]) post();
        translate([0, 0, 3 + post_h - post_top_slope - eps]) peg();
    }
}

// Everything removed from the plinth for the charger
module charger_cut() {
    // main pocket
    translate([0, 0, pocket_floor])
        cylinder(h = base_h_center + 1, r = pocket_r);
    // top chamfer
    translate([0, 0, base_h_center - pocket_chamfer])
        cylinder(h = pocket_chamfer + eps, r1 = pocket_r, r2 = pocket_r + pocket_chamfer);
    // cable slot to the back, open at the bottom
    translate([-slot_w/2, 0, -1])
        cube([slot_w, base_depth, slot_h + 1]);
}

// Flat stadium slab with end-circle radius r at height z
module stadium_slab(r, z) {
    translate([0, 0, z])
        linear_extrude(eps)
            hull() for (s = [-1, 1]) translate([s * end_cx, 0]) circle(r = r);
}

// V-shaped groove following the outline, open at the bottom face.
// At height z the groove spans +/-(groove_d - z) around the centerline.
module drip_groove_cut() {
    translate([0, 0, -eps])
    difference() {
        hull() {   // outer cone: shrinks from rc+d to rc
            stadium_slab(groove_rc + groove_d, 0);
            stadium_slab(groove_rc, groove_d);
        }
        hull() {   // inner cone: grows from rc-d to rc
            stadium_slab(groove_rc - groove_d, 0);
            stadium_slab(groove_rc, groove_d);
        }
    }
}

module foot_recesses() {
    if (foot_recess_d > 0) {
        fx = end_cx;
        fy = foot_y;
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * fx, sy * fy, -eps])
                cylinder(h = foot_recess_h + eps, d = foot_recess_d);
    }
}

// ------------------------------------------------------------
// Assemblies
// ------------------------------------------------------------
module holder() {
    difference() {
        plinth();
        charger_cut();
        foot_recesses();
        if (drip_groove) drip_groove_cut();
    }
    for (s = [-1, 1]) {
        peg_station(s * outer_x);
        peg_station(s * peg_inner_x, peg_center_offset);
    }
}

// Small test coupon: one post + peg on a disc
module test_peg() {
    cylinder(h = 2, d = post_d + 6);
    translate([0, 0, 2 - eps]) post();
    translate([0, 0, 2 + post_h - post_top_slope - eps]) peg();
}

// Thin ring with cable notch to check charger fit
module test_pocket() {
    difference() {
        cylinder(h = 4, r = pocket_r + 3);
        translate([0, 0, -1]) cylinder(h = 6, r = pocket_r);
        translate([-slot_w/2, 0, -1]) cube([slot_w, pocket_r + 5, 6]);
    }
}

if (part == "all")              holder();
else if (part == "test_peg")    test_peg();
else if (part == "test_pocket") test_pocket();

echo(str("Overall size: ", base_len, " x ", base_depth, " x ",
         base_h_center + 0, " mm (base), peg tops at ~",
         top_z(peg_inner_x, peg_center_offset) + post_h + peg_h, " mm"));
