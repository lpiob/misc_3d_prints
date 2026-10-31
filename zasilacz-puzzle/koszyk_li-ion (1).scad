// =====================================================================
//  Obudowa zasilania listwy LED (plansza do puzzli)  – wersja 2
//  2x ogniwo 801960 (obok siebie) + TP4056 z DW01 + włącznik 3-poz.
//  USB-C i włącznik na tej samej krótkiej ściance.
//  Pokrywa: języczek po stronie bez USB + 1 wkręt M3 (bez insertów).
//  Druk: PETG / ASA, warstwa 0.2 mm, 3 obrysy, bez podpór
//
//  part = "base" | "lid" | "shelf" | "print" | "assembly"
// =====================================================================
part = "assembly";

$fn = 48;
eps = 0.01;

// ---------- obudowa ----------
L = 76.5;  W = 50.5;  H = 19.3;
wall = 2.0;  fl = 1.4;  lid_t = 1.4;  r_out = 1.5;
zt = H - lid_t;                      // góra podstawy = spód pokrywy

// ---------- ogniwa 801960 (ZMIERZ!) ----------
cell_t = 8.0;  cell_w = 19.0;
cell_len = 64.0;                     // razem z płytką zabezpieczającą
cells_y0 = wall + 1.5;
cell_top = fl + cell_t + 0.4;

// ---------- TP4056 ----------
mod_w = 17.5;  mod_l = 27.5;  mod_h = 4.17;
usb_w = 8.94;  usb_h = 3.26;  mtol = 0.3;
mod_y1 = W - wall - 0.2;
mod_y0 = mod_y1 - (mod_w + mtol);
mod_yc = (mod_y0 + mod_y1)/2;
mod_x0 = L - wall - mod_l - mtol;    // płytka dosunięta do ścianki z USB

// ---------- półka ----------
shelf_t   = 1.2;
rail_top  = cell_top + 0.4;
shelf_top = rail_top + shelf_t;
shelf_x0  = mod_x0 - 1.2 - 4;        // początek półki
shelf_x1  = 62;                      // koniec części pełnej szerokości (przed nóżkami włącznika)

// ---------- włącznik ----------
sw_l = 15.7;  sw_h = 7.33;  sw_d = 7.3;  sw_leg = 3.78;
sw_edge   = 11;                      // odległość korpusu od zewn. krawędzi bocznej (>=10)
sw_yc     = sw_edge + sw_l/2;
sw_slot_l = 10.0;                    // okno na suwak (ZMIERZ: szer. suwaka + skok)
sw_slot_h = 3.6;                     // (ZMIERZ: wys. suwaka + 0.4)
sw_act_dz = 0;
sw_z0 = cell_top + 0.3;
sw_x0 = L - wall - sw_d;
sw_y1 = sw_yc + sw_l/2 + 0.15 + 1.2; // zewn. krawędź policzka

// ---------- wkręt M3 samogwintujący ----------
boss_r      = 3.5;
screw_pilot = 2.4;   // otwór pod gwint (2.3–2.5; mniejszy = ciaśniej, ASA może pękać)
screw_clear = 3.4;   // przelot w pokrywie
screw_depth = 12;    // wkręt M3x10–12
boss_x = L - wall - boss_r;
boss_y = wall + boss_r;

// ---------- zaczep pokrywy (ściana bez USB, X=0) ----------
hook_w = 20;  hook_yc = W/2;  hook_d = 2.5;
slot_z0 = 15.15;  slot_h = 1.5;  toe_t = 1.0;  leg_t = 1.2;

// ---------- przepust kabla do listwy ----------
wire_d = 3.5;  wire_y = mod_yc;  wire_z = fl + 4;

// ---------- kontrola ----------
if (wall + cell_len + 0.5 > sw_x0 - 0.2) echo("UWAGA: ogniwa za długie!");
if (sw_y1 + 0.3 > mod_y0 - 1.2)          echo("UWAGA: włącznik koliduje z modułem!");
if (boss_y + boss_r > sw_yc - sw_l/2 - 1.35) echo("UWAGA: słupek koliduje z włącznikiem!");
echo(str("Wnętrze: ", L-2*wall, " x ", W-2*wall, " x ", zt-fl, " mm"));
echo(str("Luz nad włącznikiem: ", zt-(sw_z0+sw_h), "  nad USB: ", zt-(shelf_top+mod_h)));

// =====================================================================
module rcube(s, r) {
    hull() for (x = [r, s[0]-r], y = [r, s[1]-r])
        translate([x, y, 0]) cylinder(r = r, h = s[2]);
}
module rounded_slot(w, h, d) {       // otwór wzdłuż X
    rr = min(w, h)/2 - eps;
    hull() for (y = [-w/2+rr, w/2-rr], z = [-h/2+rr, h/2-rr])
        translate([0, y, z]) rotate([0, 90, 0]) cylinder(r = rr, h = d);
}

// ------------------------------ PODSTAWA ------------------------------
module base() {
    usb_z = shelf_top + mod_h - usb_h/2;
    difference() {
        union() {
            difference() {
                rcube([L, W, zt], r_out);
                translate([wall, wall, fl]) cube([L-2*wall, W-2*wall, H]);
            }
            // szyny pod półkę
            translate([shelf_x0, wall, 0]) cube([shelf_x1 - shelf_x0, 1.5, rail_top]);
            translate([shelf_x0, W-wall-2.5, 0]) cube([L - wall - shelf_x0, 2.5, rail_top]);
            // podest + policzki włącznika
            translate([sw_x0 - 0.2, sw_yc - sw_l/2 - 1.35, 0])
                cube([sw_d + 0.2 + eps, sw_l + 2.7, sw_z0 + 4.5]);
            // podpora półki obok włącznika
            translate([sw_x0 - 0.2, sw_y1 - eps, 0])
                cube([sw_d + 0.2 + eps, mod_y0 - 0.8 - sw_y1, rail_top]);
            // słupek wkrętu (narożnik po stronie włącznika)
            translate([boss_x, boss_y, 0]) cylinder(r = boss_r, h = zt);
            translate([boss_x, wall - eps, 0])
                cube([L - wall - boss_x + eps, boss_y - wall + eps, zt]);
            // bloczek zaczepu ze sfazowanym spodem
            hull() {
                translate([wall-eps, hook_yc-hook_w/2, slot_z0-1.2])
                    cube([hook_d, hook_w, zt-(slot_z0-1.2)]);
                translate([wall-eps, hook_yc-hook_w/2, cell_top+0.3])
                    cube([0.1, hook_w, 1]);
            }
        }
        // kieszeń korpusu włącznika
        translate([sw_x0 - 2, sw_yc - sw_l/2 - 0.15, sw_z0])
            cube([sw_d + 2 + eps, sw_l + 0.3, H]);
        // okno suwaka
        translate([L - wall - 1, sw_yc - sw_slot_l/2, sw_z0 + sw_h/2 + sw_act_dz - sw_slot_h/2])
            cube([wall + 2, sw_slot_l, sw_slot_h]);
        // USB-C + wybranie na wtyczkę
        translate([L - wall - 1, mod_yc, usb_z]) rounded_slot(usb_w+0.6, usb_h+0.6, wall+2);
        translate([L - 0.6, mod_yc, usb_z])      rounded_slot(12.5, 7.0, 2);
        // szczelina zaczepu
        translate([wall + 0.7, hook_yc - hook_w/2 + 1, slot_z0])
            cube([hook_d + 1, hook_w - 2, slot_h]);
        // otwór pod wkręt
        translate([boss_x, boss_y, zt - screw_depth])
            cylinder(d = screw_pilot, h = screw_depth + 1);
        // fazka wejściowa
        translate([boss_x, boss_y, zt - 0.6]) cylinder(d1 = screw_pilot, d2 = screw_pilot + 1.2, h = 0.6 + eps);
        // przepust kabla
        translate([L - wall - 1, wire_y, wire_z]) rotate([0, 90, 0]) cylinder(d = wire_d, h = wall + 2);
    }
}

// ------------------------------ POKRYWA -------------------------------
module lid_asm() {
    tw = hook_w - 2 - 0.6;
    leg_x = wall + hook_d + 0.2;
    difference() {
        union() {
            translate([0, 0, zt]) rcube([L, W, lid_t], r_out);
            // języczek
            translate([leg_x, hook_yc - tw/2, slot_z0 + 0.15])
                cube([leg_t, tw, zt - slot_z0 - 0.15 + eps]);
            translate([wall + 0.9, hook_yc - tw/2, slot_z0 + 0.15])
                cube([leg_x + leg_t - wall - 0.9, tw, toe_t]);
            // docisk gniazda USB
            translate([L - wall - 6.5, mod_yc - 4, shelf_top + mod_h + 0.25])
                cube([6, 8, zt - (shelf_top + mod_h + 0.25) + eps]);
            // docisk włącznika
            translate([sw_x0 + 1, sw_yc - sw_l/2 + 1, sw_z0 + sw_h + 0.2])
                cube([sw_d - 2, sw_l - 2, zt - (sw_z0 + sw_h + 0.2) + eps]);
            // listki ustalające
            for (y = [wall + 0.25, W - wall - 0.25 - 1.2])
                translate([22, y, zt - 2]) cube([10, 1.2, 2 + eps]);
        }
        translate([boss_x, boss_y, zt - 1]) cylinder(d = screw_clear, h = 5);
    }
}
module lid_print() { translate([0, W, H]) rotate([180, 0, 0]) lid_asm(); }

// ------------------------------- PÓŁKA --------------------------------
module shelf_asm() {
    fy0 = mod_y0 - 1.2;
    difference() {
        union() {
            // część pełnej szerokości
            translate([shelf_x0, wall + 0.3, rail_top])
                cube([shelf_x1 - shelf_x0, W - 2*wall - 0.6, shelf_t]);
            // wysięgnik pod moduł aż do ścianki
            translate([shelf_x0, sw_y1 + 0.3, rail_top])
                cube([L - wall - 0.2 - shelf_x0, mod_y1 + 0.1 - sw_y1 - 0.3, shelf_t]);
            // kieszeń modułu: tylna ścianka + ścianka od strony włącznika
            translate([mod_x0 - 1.2, fy0, shelf_top - eps]) cube([1.2, mod_w + mtol + 1.2, 1.5]);
            translate([mod_x0 - 1.2, fy0, shelf_top - eps]) cube([L - wall - 0.2 - mod_x0 + 1.2, 1.2, 1.5]);
        }
        // przepust przewodów ogniw (za modułem)
        translate([shelf_x0 + 0.8, mod_y0 + 2, rail_top - 1]) cube([2.6, mod_w - 4, shelf_t + 2]);
    }
}
module shelf_print() { translate([0, 0, -rail_top]) shelf_asm(); }

// ------------------------- atrapy do podglądu -------------------------
module dummies() {
    color("silver") for (i = [0, 1])
        translate([wall + 0.25, cells_y0 + 0.25 + i*(cell_w + 0.5), fl]) cube([cell_len, cell_w, cell_t]);
    color("royalblue") translate([mod_x0 + mtol/2, mod_y0 + mtol/2, shelf_top]) cube([mod_l, mod_w, 1.2]);
    color("lightgray") translate([L - wall - 7.3 + 1.5, mod_yc - usb_w/2, shelf_top + mod_h - usb_h])
        cube([7.3, usb_w, usb_h]);
    color("dimgray") translate([sw_x0, sw_yc - sw_l/2, sw_z0]) cube([sw_d, sw_l, sw_h]);
    color("gold") for (i = [-1, 0, 1])
        translate([sw_x0 - sw_leg, sw_yc + i*4.7 - 0.4, sw_z0 + 2]) cube([sw_leg, 0.8, 3]);
}

// =====================================================================
if (part == "base") base();
else if (part == "lid") lid_print();
else if (part == "shelf") shelf_print();
else if (part == "print") {
    base();
    translate([0, W + 8, 0]) lid_print();
    translate([L + 8, 0, 0]) shelf_print();
}
else if (part == "assembly") {
    color("tan") base();
    color("orange") shelf_asm();
    color("wheat", 0.35) translate([0, 0, 8]) lid_asm();
    dummies();
}
