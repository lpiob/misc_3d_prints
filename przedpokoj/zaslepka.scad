// =====================================================================
//  Zaślepka gwintowana do okrągłego otworu + wieszak (PETG)
//  Część 1: nakrętka (niewidoczna, od tyłu)  – gwint wewnętrzny
//  Część 2: zaślepka z kołnierzem (widoczna) – gwint zewnętrzny + wieszak
// =====================================================================

/* [Co wyświetlić] */
// "assembly" = złożenie z panelem, "print" = obie części do druku,
// "outer" = tylko zaślepka, "inner" = tylko nakrętka
part = "assembly"; // [assembly, print, outer, inner]

/* [Otwór / panel] */
hole_d        = 32.8;  // średnica otworu [mm]
panel_t       = 2.0;   // grubość panelu [mm]
hole_clear    = 0.3;   // luz promieniowy trzpienia w otworze [mm]

/* [Gwint] */
thread_pitch  = 2.5;   // skok gwintu [mm]
thread_depth  = 1.0;   // głębokość gwintu (płytki) [mm]
thread_clear  = 0.25;  // luz promieniowy gwintu dla PETG [mm] (0.2–0.35)

/* [Nakrętka – część niewidoczna] */
nut_d         = 44;    // średnica zewnętrzna [mm]
nut_h         = 5;     // wysokość = długość gwintu [mm]
nut_grips     = 12;    // liczba wycięć chwytowych

/* [Zaślepka – część widoczna] */
flange_d      = 42;    // średnica kołnierza [mm]
flange_h      = 3;     // grubość kołnierza [mm]

/* [Wieszak] */
hook_len      = 50;    // długość wystającego trzpienia [mm]
hook_d        = 7;     // średnica trzpienia [mm]
hook_knob     = true;  // talerzyk na końcu, żeby ściereczka nie zsuwała się
hook_knob_d   = 10;    // średnica talerzyka [mm]
hook_fillet   = 3;     // promień zaokrąglenia u nasady [mm]

$fn = 96;

// ---------------- wartości wyliczane ----------------
e         = thread_depth / 2;                // mimośród profilu gwintu
r_major   = hole_d / 2 - hole_clear;         // zewn. promień gwintu trzpienia
r0        = r_major - e;                     // promień koła profilu
engage    = nut_h - 0.5;                     // trzpień nieco krótszy niż nakrętka
shank_len = panel_t + engage;                // długość trzpienia
z_flange  = shank_len;                       // spód kołnierza (= przód panelu)
z_top     = shank_len + flange_h;            // wierzch kołnierza
z_nut     = shank_len - panel_t - nut_h;     // położenie nakrętki w złożeniu

// ---------------- gwint ----------------
// Gwint "okrągły": koło przesunięte o mimośród e, skręcane po helisie.
// Profil jest łagodny, płytki i bardzo dobrze drukuje się bez podpór.
// Faza helisy zależy od bezwzględnego z, więc nakrętka i trzpień
// zawsze do siebie pasują (gwint prawoskrętny).
module thread_body(z_from, h, r) {
    translate([0, 0, z_from])
        rotate([0, 0, 360 * z_from / thread_pitch])
            linear_extrude(height = h,
                           twist  = -360 * h / thread_pitch,
                           slices = ceil(h / thread_pitch * 72),
                           convexity = 4)
                translate([e, 0]) circle(r = r);
}

// ---------------- część widoczna ----------------
module outer_part() {
    // trzpień gwintowany z fazą wejściową
    intersection() {
        thread_body(0, shank_len + 0.01, r0);
        cylinder(h = shank_len + 0.01,
                 r1 = r_major - thread_depth - 0.3,
                 r2 = r_major - thread_depth - 0.3 + shank_len);
    }
    // kołnierz z fazką na widocznej krawędzi
    translate([0, 0, z_flange]) {
        cylinder(h = flange_h - 1, d = flange_d);
        translate([0, 0, flange_h - 1])
            cylinder(h = 1, r1 = flange_d / 2, r2 = flange_d / 2 - 1);
    }
    // wieszak
    translate([0, 0, z_top - 0.01]) hook();
}

module hook() {
    r  = hook_d / 2;
    kr = hook_knob_d / 2;
    // zaokrąglenie u nasady (wzmocnienie)
    rotate_extrude()
        difference() {
            square([r + hook_fillet, hook_fillet]);
            translate([r + hook_fillet, hook_fillet]) circle(r = hook_fillet);
        }
    if (hook_knob) {
        knob_cone = kr - r;          // stożek 45° – drukuje się bez podpór
        knob_top  = 1.5;
        cylinder(h = hook_len - knob_cone - knob_top + 0.01, r = r);
        translate([0, 0, hook_len - knob_cone - knob_top]) {
            cylinder(h = knob_cone + 0.01, r1 = r, r2 = kr);
            translate([0, 0, knob_cone])
                cylinder(h = knob_top, r1 = kr, r2 = kr - 0.8);
        }
    } else {
        cylinder(h = hook_len - r, r = r);
        translate([0, 0, hook_len - r]) sphere(r = r);
    }
}

// ---------------- część niewidoczna (nakrętka) ----------------
// Modelowana w układzie złożenia (z0), potem przesuwana do druku.
module inner_part_assembled() {
    rb = r_major + thread_clear;          // promień otworu gwintowanego (max)
    difference() {
        // korpus z wycięciami chwytowymi i fazkami
        translate([0, 0, z_nut]) difference() {
            hull() {
                translate([0, 0, 0.6]) cylinder(h = nut_h - 1.2, d = nut_d);
                cylinder(h = nut_h, d = nut_d - 1.2);
            }
            for (i = [0 : nut_grips - 1])
                rotate([0, 0, i * 360 / nut_grips])
                    translate([nut_d / 2 + 0.6, 0, -1])
                        cylinder(h = nut_h + 2, r = 2.2, $fn = 32);
        }
        // gwint wewnętrzny
        thread_body(z_nut - 1, nut_h + 2, r0 + thread_clear);
        // fazki wejściowe po obu stronach
        translate([0, 0, z_nut - 0.01])
            cylinder(h = 1.2, r1 = rb + 0.6, r2 = rb - 0.6);
        translate([0, 0, z_nut + nut_h - 1.19])
            cylinder(h = 1.2, r1 = rb - 0.6, r2 = rb + 0.6);
    }
}

module inner_part() {
    translate([0, 0, -z_nut]) inner_part_assembled();
}

// ---------------- panel (tylko do podglądu) ----------------
module panel() {
    color("silver", 0.35)
        translate([0, 0, z_flange - panel_t])
            difference() {
                cylinder(h = panel_t, d = 70);
                translate([0, 0, -1]) cylinder(h = panel_t + 2, d = hole_d);
            }
}

// ---------------- wybór ----------------
if (part == "assembly") {
    color("white") outer_part();
    color("dimgray") inner_part_assembled();
    panel();
} else if (part == "print") {
    outer_part();
    translate([nut_d / 2 + flange_d / 2 + 8, 0, 0]) inner_part();
} else if (part == "outer") {
    outer_part();
} else if (part == "inner") {
    inner_part();
}

echo(str("Długość gwintu w nakrętce: ", engage, " mm  (~",
         engage / thread_pitch, " zwoju)"));
echo(str("Średnica zewn. gwintu trzpienia: ", 2 * r_major, " mm"));
