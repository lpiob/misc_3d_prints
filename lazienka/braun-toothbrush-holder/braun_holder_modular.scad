// ============================================================
//  Braun / Oral-B loop holder  -  modular (v4)
//  Layout (left -> right):  head  head  [charger + handle]  head  head
//
//  Two main parts:
//   - base : open-top tray. Floor, walls, charger pocket walls, cable
//            chambers + front cable channel, lock ledges. Prints UPRIGHT,
//            no supports, nothing to bridge.
//   - loop : stadium hoop. Its bottom band is the shelf / lid of the base,
//            with the charger lip, posts, pegs, hooks and the top bar.
//            Prints on its BACK, no supports (as the first loop did).
//
//  SLIDE LOCK: four hooks under the shelf, four ledges in the base.
//   1. Put the loop on the base shifted `slide` mm toward the back.
//   2. Push it forward until it stops and the detent clicks.
//   3. Lower the assembled stand over the charger (charger + mat on the
//      counter, cable plugged in).
//   To clean: lift the stand off the charger, slide the loop back, lift.
//
//  Extra parts (TPU): charger_mat, leg_pads.
//
//  Coordinates (assembly): origin = center of the stand on the counter,
//  +X right, +Y back, +Z up. The charger sits at Y = charger_y.
// ============================================================

/* [What to render] */
part = "assembly"; // [assembly, assembly_unlocked, base, loop, charger_mat, leg_pads, test_lock]
show_ghosts = true;

/* [Charger] */
charger_d        = 56.2;
charger_h_edge   = 18.0;
charger_h_center = 20.56;
charger_clear    = 0.3;
charger_y        = 9;      // charger / handle / head row, behind the middle
lip_overlap      = 2.5;
lip_clear        = 0.4;
plug_w           = 9.5;
plug_slot_extra  = 3;

/* [Charger mat (TPU)] */
charger_mat      = true;
mat_h            = 1.0;

/* [Handle] */
handle_d         = 24;
handle_h         = 200;
handle_hole_d    = 29;

/* [Brush heads] */
head_h           = 81.34;
head_body_h      = 51;
head_d_bottom    = 15.2;
head_d_neck      = 8.9;
head_hole_d      = 20;
bristle_gap      = 3;

/* [Layout] */
peg_inner_x      = 42;
peg_pitch        = 32;
bar_end_margin   = 4;

/* [Loop] */
depth            = 74;     // loop front-to-back
wall             = 4;      // band / top bar / shelf thickness
edge_round       = 2.0;    // loop: rounded front edges
back_chamfer     = 1.0;    // loop: chamfered back edges (bed side)
edge_steps       = 6;
profile_round    = 1.5;
hole_chamfer     = 1.0;

/* [Base] */
overhang         = 1.0;    // shelf overhangs the base all around (drip edge)
front_wall       = 3;
back_wall        = 3;
end_wall         = 3.5;
floor_t          = 3;
pocket_side_wall = 3;
front_channel    = 14;     // cable channel in front of the charger
plinth_splay     = 12;
base_chamfer     = 1.0;
cable_notch_h    = 10;     // passages from the plug slot into both chambers
cable_notch_from = 18;     // ... starting this far behind the charger center
cable_exit_x     = 55;     // cable exits through the back wall at +/- this X
cable_exit_w     = 8;
cable_exit_h     = 8;

/* [Slide lock] */
lock_x           = 78;     // inner face of the lock pillars
ledge_w          = 3;      // ledge sticks out this far from the pillar
ledge_t          = 1.5;    // vertical part of the ledge, then 45° underside
foot_len         = 8;      // hook length along Y
foot_t           = 3;      // foot thickness below its sloped top
stem_t           = 3;
lock_gap         = 0.3;    // horizontal clearance hook <-> ledge / pillar
lock_vclear      = 0.4;    // vertical clearance foot <-> ledge underside
back_ledge_y     = 5;      // start of the back ledges (front ledges start at the front wall)
detent           = true;
detent_x         = 20;
detent_r         = 1.0;    // bump under the shelf
detent_h         = 0.6;    // how far the bump sticks out

/* [Posts and pegs] */
post_d           = 16;
post_h           = 3;
post_top_inset   = 3;
post_top_h       = 1.2;
peg_d            = 8.0;
peg_d_top        = 7.4;
peg_h            = 14;
peg_tip_chamfer  = 1.0;
peg_point_trunc  = 0.3;

/* [TPU leg pads] */
leg_pads         = true;
pad_groove_w     = 3.0;
pad_groove_h     = 1.6;
pad_groove_end   = 4;
pad_press        = 0.2;
pad_protrude     = 1.0;
pad_inset        = 8;

$fn = 96;
eps = 0.01;
sq2 = sqrt(2);

// ------------------------------------------------------------
// Derived dimensions (absolute Z, counter = 0)
// ------------------------------------------------------------
outer_x     = peg_inner_x + peg_pitch;
head_xs     = [-outer_x, -peg_inner_x, peg_inner_x, outer_x];
head_r      = head_hole_d / 2;
handle_r    = handle_hole_d / 2;
post_r      = post_d / 2;
pocket_r    = charger_d / 2 + charger_clear;
lip_r       = charger_d / 2 - lip_overlap;
block_x     = pocket_r + pocket_side_wall;

z0          = leg_pads ? pad_protrude : 0;
mat_z       = charger_mat ? mat_h : 0;
lid_bot     = mat_z + charger_h_edge + lip_clear;   // shelf underside = base top
band_top    = lid_bot + wall;
head_bottom = band_top + post_h;
bar_top     = head_bottom + head_body_h - bristle_gap;
bar_bot     = bar_top - wall;
R           = (bar_top - lid_bot) / 2;
zc          = lid_bot + R;
S           = outer_x + head_r + bar_end_margin;
total_len   = 2 * (S + R);

base_depth  = depth - 2 * overhang;
base_top_x  = S - overhang;
base_bot_x  = base_top_x + plinth_splay;
front_in    = -base_depth/2 + front_wall;
back_in     = base_depth/2 - back_wall;
block_front = front_in + front_channel;
cav_lo      = z0 + floor_t;
pad_x       = base_bot_x - pad_inset;
groove_len  = base_depth - 2 * pad_groove_end;

ledge_len   = foot_len + 1;
slide       = foot_len + 1;
ledge_ys    = [front_in, back_ledge_y];
front_mid   = -base_depth/2 + front_wall/2;

// hook geometry (right side)
function ledge_under(x) = lid_bot - ledge_t - (x - (lock_x - ledge_w));   // ledge underside line
sx1   = lock_x - ledge_w - lock_gap;
sx0   = sx1 - stem_t;
fx1   = lock_x - lock_gap;
foot_top_out = ledge_under(fx1) - lock_vclear;
hook_zb = foot_top_out - foot_t;
hook_tail   = lid_bot - hook_zb + 1;   // length of the 45° tail behind each foot

// ------------------------------------------------------------
// Checks
// ------------------------------------------------------------
assert(head_hole_d >= head_d_bottom + 2, "head_hole_d too small for the head's widest part");
assert(handle_hole_d >= handle_d + 3, "handle_hole_d too small");
assert(charger_y - pocket_r < block_front + 2, "Pocket walls do not reach the charger front");
assert(charger_y - handle_r * sq2 >= -depth/2 + 3, "Handle teardrop too close to the front");
assert(charger_y + post_r * sq2 <= depth/2 - back_chamfer - 1, "Post teardrops run into the back edge");
assert(peg_inner_x - post_r >= block_x - 2, "Inner posts overlap the charger opening");
assert(peg_inner_x - head_r - handle_r >= 6, "Inner head opening too close to the handle opening");
assert(peg_pitch - head_hole_d >= 6, "Head openings too close: increase peg_pitch");
assert(back_ledge_y > front_in + 0.5 + slide + foot_len + hook_tail,
       "Back ledges too close to the front ones: increase back_ledge_y");
assert(back_ledge_y + 0.5 + slide + foot_len + hook_tail < back_in,
       "Back hooks hit the back wall when unlocked: reduce back_ledge_y");
assert(lock_x - ledge_w - lock_gap - stem_t > block_x + 2, "Hooks collide with the pocket walls");
assert(lock_x + 3 < base_top_x - end_wall, "Lock pillars stick out of the end walls: reduce lock_x");

// ------------------------------------------------------------
// 2D / extrusion helpers
// ------------------------------------------------------------
module teardrop2d(r, trunc = -1) {   // point toward +Y
    intersection() {
        hull() {
            circle(r = r);
            polygon([[-r/sq2, r/sq2], [r/sq2, r/sq2], [0, r * sq2]]);
        }
        translate([-r - 1, -r - 1])
            square([2*r + 2, trunc > 0 ? r + 1 + trunc : 3 * r]);
    }
}
module teardrop2d_front(r, trunc = -1) { mirror([0, 1]) teardrop2d(r, trunc); }

module stadium2d(s, r) { hull() for (k = [-1, 1]) translate([k * s, 0]) circle(r = r); }

// Profile (X, Z) extruded from Y = y0 to y1
module extrude_y(y0, y1) { translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children(); }
// Profile (Y, Z) extruded along X, centered
module extrude_x(w) { translate([-w/2, 0, 0]) rotate([90, 0, 90]) linear_extrude(w) children(); }

// Loop body: chamfered back edges (bed), rounded front edges
module loop_extrude(d) {
    er = edge_round; bc = back_chamfer;
    rotate([90, 0, 0]) translate([0, 0, -d/2]) union() {
        for (i = [0 : 3]) {
            t0 = bc * i / 4; t1 = bc * (i + 1) / 4;
            translate([0, 0, t0]) linear_extrude(t1 - t0 + eps) offset(delta = -(bc - t0)) children();
        }
        translate([0, 0, bc - eps]) linear_extrude(d - bc - er + 2 * eps) children();
        for (i = [0 : edge_steps - 1]) {
            t0 = er * i / edge_steps; t1 = er * (i + 1) / edge_steps;
            tm = (t0 + t1) / 2;
            translate([0, 0, d - er + t0]) linear_extrude(t1 - t0 + eps)
                offset(delta = -(er - sqrt(er * er - tm * tm))) children();
        }
    }
}

// Base body: chamfered front and back edges
module base_extrude(d) {
    c = base_chamfer;
    rotate([90, 0, 0]) translate([0, 0, -d/2]) union() {
        for (i = [0 : 3]) {
            t0 = c * i / 4; t1 = c * (i + 1) / 4;
            translate([0, 0, t0]) linear_extrude(t1 - t0 + eps) offset(delta = -(c - t0)) children();
            translate([0, 0, d - t1]) linear_extrude(t1 - t0 + eps) offset(delta = -(c - t0)) children();
        }
        translate([0, 0, c - eps]) linear_extrude(d - 2 * c + 2 * eps) children();
    }
}

// ------------------------------------------------------------
// LOOP
// ------------------------------------------------------------
module loop_profile() {
    offset(r = profile_round) offset(delta = -2 * profile_round) offset(r = profile_round)
    difference() {
        translate([0, zc]) stadium2d(S, R);
        translate([0, zc]) stadium2d(S, R - wall);
    }
}

module post3d() {
    linear_extrude(post_h - post_top_h + eps) teardrop2d(post_r);
    translate([0, 0, post_h - post_top_h])
        linear_extrude(post_top_h, scale = (post_r - post_top_inset) / post_r) teardrop2d(post_r);
}

module peg3d() {
    trunc  = peg_d/2 + peg_point_trunc;
    body_h = peg_h - peg_tip_chamfer;
    s_body = 1 - (1 - peg_d_top / peg_d) * body_h / peg_h;
    linear_extrude(body_h + eps, scale = s_body) teardrop2d(peg_d/2, trunc);
    translate([0, 0, body_h])
        linear_extrude(peg_tip_chamfer,
                       scale = (peg_d * s_body - 2 * peg_tip_chamfer) / (peg_d * s_body))
            scale(s_body) teardrop2d(peg_d/2, trunc);
}

module opening(r, z_lo, z_hi, trunc = -1) {
    translate([0, 0, z_lo]) linear_extrude(z_hi - z_lo) teardrop2d_front(r, trunc);
    translate([0, 0, z_hi - hole_chamfer])
        linear_extrude(hole_chamfer + eps, scale = (r + hole_chamfer) / r) teardrop2d_front(r, trunc);
}

// Hook cross-section (X, Z), right side: see derived values at the top

module hook2d() {
    polygon([[sx0, lid_bot + 1], [sx1, lid_bot + 1],
             [sx1, ledge_under(sx1) - lock_vclear],
             [fx1, foot_top_out], [fx1, hook_zb], [sx0, hook_zb]]);
}

// One hook (right side) with its foot at Y = y_f0 .. y_f0 + foot_len.
// Behind the foot the hook tapers back into the shelf at 45° (prints without support).
module hook3d(y_f0) {
    yb = y_f0 + foot_len;
    H  = lid_bot + 1 - hook_zb;
    intersection() {
        extrude_y(y_f0, yb + H + 2) hook2d();
        extrude_x(1000)
            polygon([[y_f0 - 1, hook_zb - 1], [yb, hook_zb - 1],
                     [yb + H + 2, lid_bot + 1 + eps], [y_f0 - 1, lid_bot + 1 + eps]]);
    }
}

module hooks() {
    for (k = [-1, 1], y = ledge_ys)
        mirror([k < 0 ? 1 : 0, 0, 0]) hook3d(y + 0.5);
}

module detent_bumps() {
    if (detent)
        for (k = [-1, 1])
            intersection() {
                translate([k * detent_x, front_mid, lid_bot - detent_h + detent_r]) sphere(r = detent_r, $fn = 24);
                translate([k * detent_x - 5, front_mid - 5, lid_bot - detent_h - 1]) cube([10, 10, detent_h + 1 + eps]);
            }
}

module loop() {
    difference() {
        loop_extrude(depth) loop_profile();
        translate([0, charger_y, 0]) {
            opening(lip_r, lid_bot - 1, band_top + eps, charger_y - block_front);
            opening(handle_r, bar_bot - 1, bar_top + eps);
            for (x = head_xs) translate([x, 0, 0]) opening(head_r, bar_bot - 1, bar_top + eps);
        }
    }
    for (x = head_xs)
        translate([x, charger_y, band_top - eps]) {
            post3d();
            translate([0, 0, post_h - eps]) peg3d();
        }
    hooks();
    detent_bumps();
}

// ------------------------------------------------------------
// BASE
// ------------------------------------------------------------
module base_profile() {
    offset(r = profile_round) offset(delta = -2 * profile_round) offset(r = profile_round)
        polygon([[-base_bot_x, z0], [base_bot_x, z0], [base_top_x, lid_bot], [-base_top_x, lid_bot]]);
}

module interior2d() {
    offset(r = 2) offset(delta = -2)
    intersection() {
        offset(delta = -end_wall)
            polygon([[-base_bot_x, z0], [base_bot_x, z0], [base_top_x, lid_bot + 20], [-base_top_x, lid_bot + 20]]);
        translate([-500, cav_lo]) square([1000, 100]);
    }
}

module lock_pillar(y0) {   // right side
    extrude_y(y0, y0 + ledge_len) {
        translate([lock_x, z0]) square([base_top_x - lock_x, lid_bot - z0]);
        polygon([[lock_x - ledge_w, lid_bot], [lock_x + eps, lid_bot],
                 [lock_x + eps, lid_bot - ledge_t - ledge_w], [lock_x - ledge_w, lid_bot - ledge_t]]);
    }
}

module base() {
    difference() {
        union() {
            difference() {
                base_extrude(base_depth) base_profile();
                // hollow, open at the top
                difference() {
                    extrude_y(front_in, back_in) interior2d();
                    translate([-block_x, block_front, -1]) cube([2 * block_x, base_depth, lid_bot + 2]);
                }
            }
            for (k = [-1, 1], y = ledge_ys) mirror([k < 0 ? 1 : 0, 0, 0]) lock_pillar(y);
        }
        // charger pocket (open bottom), plug slot
        translate([0, charger_y, -1]) {
            cylinder(h = lid_bot + 2, r = pocket_r);
            translate([-(plug_w/2 + plug_slot_extra/2), 0, 0])
                cube([plug_w + plug_slot_extra, base_depth, lid_bot + 2]);
        }
        // cable passages into both chambers
        translate([-block_x - 1, charger_y + cable_notch_from, cav_lo - eps])
            cube([2 * block_x + 2, base_depth, cable_notch_h]);
        // cable exits through the back wall
        for (k = [-1, 1])
            translate([k * cable_exit_x - cable_exit_w/2, back_in - 1, z0 - 1])
                cube([cable_exit_w, back_wall + 2, floor_t + cable_exit_h + 1]);
        // detent dimples + lead-in chamfer on the front wall top
        if (detent) {
            for (k = [-1, 1])
                translate([k * detent_x, front_mid, lid_bot - detent_h + detent_r])
                    sphere(r = detent_r + 0.25, $fn = 24);
            extrude_x(2 * (lock_x - ledge_w - 1))
                polygon([[front_in - 1, lid_bot + eps], [front_in, lid_bot - 1],
                         [front_in + 2, lid_bot - 1], [front_in + 2, lid_bot + 1]]);
        }
        // TPU pad grooves
        if (leg_pads)
            for (k = [-1, 1])
                translate([k * pad_x - pad_groove_w/2, -groove_len/2, z0 - 1])
                    cube([pad_groove_w, groove_len, pad_groove_h + 1]);
    }
}

// ------------------------------------------------------------
// TPU parts
// ------------------------------------------------------------
module charger_mat_part() {
    r = pocket_r - 0.6;
    cylinder(h = 0.4, r1 = r - 0.4, r2 = r);
    translate([0, 0, 0.4 - eps]) cylinder(h = mat_h - 0.4 + eps, r = r);
}

module leg_pad() {
    w = pad_groove_w + pad_press; h = pad_groove_h + pad_protrude;
    l = groove_len - 0.4; c = 0.4;
    hull() {
        translate([c, 0, 0]) cube([l - 2*c, w, h]);
        translate([0, c, c]) cube([l, w - 2*c, h - 2*c]);
    }
}

// ------------------------------------------------------------
// Ghosts
// ------------------------------------------------------------
module ghosts() {
    translate([0, charger_y, mat_z]) {
        cylinder(h = charger_h_edge, d = charger_d);
        cylinder(h = charger_h_center, d = 30);
    }
    translate([0, charger_y, mat_z + charger_h_center]) cylinder(h = handle_h, d = handle_d);
    for (x = head_xs) translate([x, charger_y, head_bottom]) {
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
module loop_print_pose() { translate([0, 0, depth/2]) rotate([-90, 0, 0]) children(); }

module tpu_pads_in_place() {
    for (k = [-1, 1])
        translate([k * pad_x + (pad_groove_w + pad_press)/2, -(groove_len - 0.4)/2, z0 - pad_protrude])
            rotate([0, 0, 90]) leg_pad();
}

if (part == "assembly" || part == "assembly_unlocked") {
    color("#bdbdbd") base();
    translate([0, part == "assembly" ? 0 : slide, 0]) color("#2b2b2b") loop();
    if (charger_mat) color("#888") translate([0, charger_y, 0]) charger_mat_part();
    if (leg_pads) color("#777") tpu_pads_in_place();
    if (show_ghosts && part == "assembly") %ghosts();
}
else if (part == "base")        translate([0, 0, -z0]) base();
else if (part == "loop")        loop_print_pose() loop();
else if (part == "charger_mat") charger_mat_part();
else if (part == "leg_pads")    for (i = [0, 1]) translate([0, i * 8, 0]) leg_pad();
else if (part == "test_lock") {
    // one lock corner of each part, printed in their real orientations
    translate([0, 0, -z0]) intersection() {
        base();
        translate([lock_x - 14, front_in - 4, z0 - 1]) cube([24, ledge_len + 8, lid_bot - z0 + 2]);
    }
    translate([0, 40, 0]) loop_print_pose() intersection() {
        loop();
        translate([lock_x - 14, -depth/2 - 1, hook_zb - 1]) cube([24, 30, band_top - hook_zb + 1.5]);
    }
}

echo(str("Loop ", total_len, " x ", depth, " x ", bar_top - lid_bot, " mm (stand height ", bar_top, " mm); base ",
         2 * base_bot_x, " x ", base_depth, " x ", lid_bot - z0, " mm; slide ", slide,
         " mm; hooks reach ", lid_bot - hook_zb, " mm below the shelf"));
