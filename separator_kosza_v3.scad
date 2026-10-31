// =====================================================================
//  Krzyżowy separator do kosza na pranie – wersja 2 (piętrowa)
//
//  Elementy (na jedno piętro 2 panele "width" + 2 panele "depth"):
//    - panel   : parametry `tier` (piętro) i `panel_dir` (kierunek)
//    - end_cap : 2 szt. – nasadka "+" na górę krzyżaka i podstawka na dno
//    - seam_cap: 1 szt. na każdy styk pięter – łączy piętra i środki paneli
//
//  Układ współrzędnych panelu (= pozycja do druku, płasko na stole):
//    X – promieniowo: X=0 koniec przy środku kosza, X=$rx oś prętów
//    Y – wysokość panelu (0 = dół piętra)
//  Wysokości w świecie (Z złożenia) liczone od dolnej krawędzi pręta pod koszem.
//    Z – grubość (panel 0..panel_thickness, zgrubienia haków rosną w +Z)
//  Wszystkie zatrzaski są profilami 2D -> sprężynują w płaszczyźnie warstw.
//
//  Montaż (wszystkie ruchy w dół):
//    1. end_cap na dno kosza (gniazdami do góry)
//    2. 4 panele dolnego piętra: wcisnąć dolnym końcem w nasadkę,
//       siodełka nasuwają się na pręty pośrednie
//    3. seam_cap wcisnąć z góry na wewnętrzne końce dolnych paneli
//    4. 4 panele górnego piętra: dolny koniec w seam_cap, hak na pręt brzegowy
//    5. drugi end_cap odwrócony wcisnąć z góry na górę krzyżaka
// =====================================================================

/* [Kosz] */
// Wszystkie wymiary wpisuj tak, jak mierzone: PO ZEWNĘTRZNYCH ściankach prętów.
// Skrypt sam przelicza je na osie prętów (odejmuje rod_diameter).
basket_width_outer  = 431;   // szerokość kosza (X złożenia)
basket_depth_outer  = 420;   // głębokość kosza (Y złożenia)
basket_height_outer = 412;   // dolna krawędź pręta pod koszem -> górna krawędź pręta brzegowego
rod_diameter        = 5.0;   // średnica drutów (mm)
floor_z             = 5.0;   // powierzchnia dna nad dolną krawędzią pręta pod koszem
                             // (domyślnie dno leży na pręcie; skoryguj, jeśli wyżej)
// Pręt brzegowy -> pręt k (k = 2, 3, 4...), zewnętrzne ścianki. Dopisz kolejne pomiary,
// jeśli chcesz mieć siodełka także na dolnym piętrze.
rod_spans_outer = [46.84, 85.20, 129.32];
saddle_rods     = [3, 4];    // numery prętów z siodełkami (1 = brzegowy); pręty poza piętrem są pomijane

/* [Piętra] */
tier_heights_top = [205]; // wysokości pięter od góry; najniższe piętro liczone automatycznie
                          // []        -> jedno piętro na całą wysokość
                          // [160,160] -> trzy piętra
tier = 0;                 // które piętro renderować jako "panel" (0 = górne)
panel_dir = "width";      // [width, depth] – panel w kierunku szerokości (431) lub głębokości (420)
seam_gap = 4;             // nominalna szczelina między piętrami (kompensuje błąd wysokości kosza)

/* [Panel] */
panel_thickness = 4.0;   // grubość ścianki (mm)
frame_width     = 6.0;   // rama wokół ażuru (>= 5 mm)
corner_radius   = 3.0;   // zaokrąglenie narożników płyty
tolerance       = 0.3;   // luz technologiczny druku 3D (całkowity, na średnicy/szerokości)

/* [Hak górny – zatrzask na pręt brzegowy] */
hook_wall           = 2.2;  // grubość ścianki haka
hook_boss_thickness = 14;   // długość chwytu wzdłuż pręta (grubość zgrubienia w Z)
snap_interference   = 0.4;  // o ile wlot jest węższy od pręta
snap_land           = 0.6;  // płaska krawędź zęba zatrzasku
stop_leg_length     = 18;   // płaszczyzny oporowe poniżej pręta

/* [Siodełka na pręty pośrednie] */
lower_saddles          = true; // otwarte haki U bez wcisku na niższych prętach
saddle_boss_thickness  = 10;   // długość chwytu siodełka wzdłuż pręta
saddle_leg_length      = 12;   // długość ramion siodełka poniżej pręta
rod_slot_play          = 4;    // luz pionowy siodełka (kompensuje rozstaw prętów)
stiffening_bands       = true; // pełne poziome pasy przez ażur na wysokości siodełek
band_width             = 10;   // pełna szerokość pasa usztywniającego

/* [Zgrubienia haków] */
boss_flat = 6;    // pełna strefa zgrubienia przy krawędzi panelu (X)
boss_ramp = 1.0;  // nachylenie rampy: długość / przyrost grubości (1 = 45°)

/* [Nasadki "+"] */
cap_wall      = 2.0;   // ścianka ramion nasadki
cap_slot_depth = 16;   // promieniowa głębokość gniazda
cap_slot_h    = 18;    // wysokość gniazda (na ile wchodzi panel)
cap_web       = 2.5;   // grubość denka nasadki końcowej
lock_pin_d    = 3.0;   // poziomy kołek w gnieździe
lock_pin_off  = 6.0;   // położenie kołka od rdzenia nasadki (promieniowo)
lock_play     = 6.0;   // luz pionowy kołka w gnieździe panelu
lock_snap_interference = 0.4; // zwężenie szyjki zatrzasku względem kołka
lock_neck_len = 1.0;   // długość szyjki
lock_finger_w = 2.0;   // szerokość sprężystego palca
lock_relief_w = 1.5;   // szczelina odciążająca za palcem

/* [Ażur] */
pattern_style = "voronoi"; // [voronoi, hex, none]
cell_size     = 30;
strut_width   = 3.5;
cell_jitter   = 0.7;
hole_round    = 3.0;
pattern_seed  = 42;

/* [Render] */
part = "panel"; // [panel, end_cap, seam_cap, assembly]

/* [Hidden] */
$fn = 64;
eps = 0.05;

// =====================================================================
//  Wartości wyliczane
// =====================================================================
rod_r      = rod_diameter / 2;
hook_r_in  = rod_r + tolerance / 2;
hook_r_out = hook_r_in + hook_wall;
snap_gap   = rod_diameter - snap_interference;
snap_wrap  = 360 - 2 * asin(snap_gap / rod_diameter);

slot_w         = panel_thickness + tolerance;    // gniazdo nasadki
cap_core_r     = slot_w / 2 + cap_wall;          // połowa rdzenia nasadki
central_offset = cap_core_r + tolerance;         // oś kosza -> koniec panelu
basket_width   = basket_width_outer - rod_diameter;   // oś-oś prętów
basket_depth   = basket_depth_outer - rod_diameter;
function span_of(d) = d == "depth" ? basket_depth : basket_width;
function rod_x_of(d) = span_of(d) / 2 - central_offset;  // panel_width danego kierunku
// W modułach panelu: $rx = oś pręta, $bx = krawędź płyty (= wewn. płaszczyzna oporowa)

pin_slot_w   = lock_pin_d + tolerance;
pin_x        = lock_pin_off - tolerance;          // oś kołka we wsp. panelu
pin_r_world  = cap_core_r + lock_pin_off;
pin_h        = lock_play / 2 + pin_slot_w / 2 + lock_neck_len + 2.5; // środek gniazda od krawędzi
relief_depth = pin_h + lock_play / 2 + pin_slot_w / 2 + 2;

// --- piętra (wysokości w świecie mierzone od dna kosza) ---
rim_rod_z = basket_height_outer - rod_r;          // oś pręta brzegowego
top_z     = rim_rod_z + hook_r_out;               // górna krawędź górnego piętra
n_tiers   = len(tier_heights_top) + 1;
function cumsum(v, n) = n <= 0 ? 0 : v[n - 1] + cumsum(v, n - 1);
function tier_top_z(i) = top_z - cumsum(tier_heights_top, i) - i * seam_gap;
function tier_h(i)     = i < n_tiers - 1 ? tier_heights_top[i] : tier_top_z(i) - floor_z - cap_web;
function tier_bot_z(i) = tier_top_z(i) - tier_h(i);

rod_offsets = concat([0], [for (m = rod_spans_outer) m - rod_diameter]); // od osi brzegowego
rod_zs      = [for (o = rod_offsets) rim_rod_z - o];

// wysokości (we wsp. panelu) prętów obsługiwanych siodełkami
function saddle_ys(i) =
    let(H = tier_h(i), b = tier_bot_z(i),
        top_limit = (i == 0) ? H - 2 * hook_r_out - stop_leg_length - 2 : H)
    lower_saddles ? [for (k = [0 : len(rod_zs) - 1]) let(y = rod_zs[k] - b)
        if (len([for (n = saddle_rods) if (n == k + 1) n]) > 0 &&
            y - saddle_leg_length >= cap_web + 2 && y + rod_slot_play + hook_r_out <= top_limit) y] : [];

// zakresy Y zgrubień haków: [y0, y1, grubość]
function hook_spans(i) = concat(
    i == 0 ? [[tier_h(0) - hook_r_out - stop_leg_length, tier_h(0), hook_boss_thickness]] : [],
    [for (y = saddle_ys(i)) [y - saddle_leg_length, y + rod_slot_play + hook_r_out, saddle_boss_thickness]]);

// =====================================================================
//  Kontrola parametrów
// =====================================================================
assert(frame_width >= 5, "Rama musi mieć min. 5 mm");
assert(snap_gap < 2 * hook_r_in, "Wlot zatrzasku musi być węższy od gniazda");
assert(pin_x - pin_slot_w / 2 >= 2, "Za mało materiału przy końcu panelu");
assert(pin_x + pin_slot_w / 2 + lock_finger_w + lock_relief_w <= cap_slot_depth - tolerance - 1,
       "Zatrzask nasadki nie mieści się w gnieździe");
assert(relief_depth <= cap_slot_h - 1, "cap_slot_h za małe dla zatrzasku");
assert(seam_gap >= 1, "seam_gap za mały");
for (i = [0 : n_tiers - 1]) assert(tier_h(i) > 2 * cap_slot_h + 40, str("Piętro ", i, " za niskie"));
assert(tier >= 0 && tier < n_tiers, "Nie ma takiego piętra");
assert(panel_dir == "width" || panel_dir == "depth", "panel_dir: width | depth");

echo(str("Osie prętów: szerokość ", basket_width, " mm, głębokość ", basket_depth,
         " mm, wysokości osi prętów nad ref. = ", rod_zs));
echo(str("panel_width: width = ", rod_x_of("width"), " mm, depth = ", rod_x_of("depth"),
         " mm, opasanie pręta = ", snap_wrap, " deg"));
for (i = [0 : n_tiers - 1])
    echo(str("Piętro ", i, ": wysokość ", tier_h(i), " mm (od ", tier_bot_z(i), " do ",
             tier_top_z(i), " mm nad dnem), siodełka na Y = ", saddle_ys(i)));
echo(str("Druk: na każde piętro 2 x panel width + 2 x panel depth (razem ", 4 * n_tiers,
         "), 2 x end_cap, ", n_tiers - 1, " x seam_cap"));

// =====================================================================
//  panel_base() – płyta z ramą
// =====================================================================
module panel_base(i) {
    linear_extrude(height = panel_thickness)
        offset(r = corner_radius) offset(delta = -corner_radius)
            square([$bx, tier_h(i)]);
}

// =====================================================================
//  clip_hook() – zatrzask górny + siodełka (profile we wsp. osi pręta)
// =====================================================================
// --- zatrzask snap-fit (>180°) z płaszczyznami oporowymi ---
module snap_pos_2d() {
    circle(r = hook_r_out);
    translate([-hook_r_out - 3, 0]) square([hook_r_out + 3, hook_r_out]);           // bark
    translate([hook_r_in, -stop_leg_length]) square([hook_wall, stop_leg_length]);   // ramię zewn.
    translate([-hook_r_out, -stop_leg_length]) square([hook_wall, stop_leg_length]); // ramię wewn.
}
module snap_neg_2d() {
    y_t = -sqrt(hook_r_in * hook_r_in - (snap_gap / 2) * (snap_gap / 2));
    y_m = y_t - snap_land;
    c   = hook_r_in - snap_gap / 2;          // sfazowanie 45°
    circle(r = hook_r_in);
    polygon([[-snap_gap / 2, 0], [snap_gap / 2, 0], [snap_gap / 2, y_m],
             [hook_r_in, y_m - c], [hook_r_in, -stop_leg_length - 1],
             [-hook_r_in, -stop_leg_length - 1], [-hook_r_in, y_m - c], [-snap_gap / 2, y_m]]);
}

// --- siodełko: otwarty hak U bez wcisku, z luzem pionowym ---
module saddle_pos_2d() {
    p = rod_slot_play;
    translate([0, p]) circle(r = hook_r_out);
    translate([-hook_r_out - 3, 0]) square([hook_r_out + 3, p + hook_r_out]);
    translate([hook_r_in, -saddle_leg_length]) square([hook_wall, saddle_leg_length + p]);
    translate([-hook_r_out, -saddle_leg_length]) square([hook_wall, saddle_leg_length + p]);
}
module saddle_neg_2d() {
    p = rod_slot_play;
    L = saddle_leg_length;
    hull() {
        translate([0, p]) circle(r = hook_r_in);
        translate([-hook_r_in, -L - 1]) square([2 * hook_r_in, 0.01]);
    }
    // sfazowanie wejścia na ramieniu zewnętrznym
    polygon([[0, -L - 1], [hook_r_in + 1.2, -L - 1], [hook_r_in + 1.2, -L],
             [hook_r_in, -L + 1.2], [0, -L + 1.2]]);
}

// rampa przejścia z panelu w zgrubienie haka (druk bez podpór)
module boss_ramp_3d(y0, y1, th) {
    xb = $bx - boss_flat;
    xa = xb - (th - panel_thickness) * boss_ramp;
    hull() {
        translate([xa, y0, 0]) cube([eps, y1 - y0, panel_thickness]);
        translate([xb, y0, 0]) cube([boss_flat, y1 - y0, th]);
    }
}

module clip_hook(i) {
    H = tier_h(i);
    if (i == 0) {
        translate([$rx, H - hook_r_out, 0])
            linear_extrude(height = hook_boss_thickness) snap_pos_2d();
    }
    for (y = saddle_ys(i))
        translate([$rx, y, 0]) linear_extrude(height = saddle_boss_thickness) saddle_pos_2d();
    for (s = hook_spans(i)) boss_ramp_3d(s[0], s[1], s[2]);
}

module clip_hook_cut(i) {
    H = tier_h(i);
    hmax = max(hook_boss_thickness, saddle_boss_thickness) + 2 * eps;
    translate([0, 0, -eps]) {
        if (i == 0)
            translate([$rx, H - hook_r_out, 0]) linear_extrude(height = hmax) snap_neg_2d();
        for (y = saddle_ys(i))
            translate([$rx, y, 0]) linear_extrude(height = hmax) saddle_neg_2d();
    }
}

// =====================================================================
//  central_lock() – zatrzaski na kołki nasadek "+" (górny i dolny koniec)
//  Lokalnie: krawędź panelu na y=0, materiał w y<0.
//  Wlot z lejkiem -> szyjka węższa od kołka (klik) -> gniazdo wydłużone
//  o lock_play (kompensacja wysokości). Szczelina odciążająca tworzy
//  sprężysty palec.
// =====================================================================
module lock_slot_2d() {
    w   = pin_slot_w;
    n   = lock_pin_d - lock_snap_interference;
    ys0 = -(pin_h - lock_play / 2);           // koniec gniazda bliżej krawędzi
    ys1 = -(pin_h + lock_play / 2);           // koniec gniazda dalej od krawędzi
    yn  = ys0 + w / 2 + lock_neck_len;        // początek szyjki
    yc  = yn + (w - n) / 2;                   // koniec sfazowania przed szyjką
    translate([pin_x, 0]) {
        hull() { translate([0, ys0]) circle(d = w); translate([0, ys1]) circle(d = w); }
        translate([-n / 2, ys0]) square([n, yn - ys0]);
        polygon([[-n / 2, yn], [n / 2, yn], [w / 2, yc], [-w / 2, yc]]);
        translate([-w / 2, yc]) square([w, -yc + 1]);
        polygon([[-w / 2, -1.2], [w / 2, -1.2], [w / 2 + 1.2, 0], [w / 2 + 1.2, 1],
                 [-w / 2 - 1.2, 1], [-w / 2 - 1.2, 0]]);
    }
    rx = pin_x + w / 2 + lock_finger_w;
    hull() {
        translate([rx + lock_relief_w / 2, -relief_depth]) circle(d = lock_relief_w);
        translate([rx, 0]) square([lock_relief_w, 1]);
    }
}

module central_lock(i) {
    translate([0, 0, -eps]) linear_extrude(height = panel_thickness + 2 * eps) {
        translate([0, tier_h(i)]) lock_slot_2d();   // góra
        mirror([0, 1]) lock_slot_2d();             // dół
    }
}

// =====================================================================
//  Nasadki "+"
// =====================================================================
module cap_2d() {
    L = cap_core_r + cap_slot_depth;
    offset(r = 1) offset(delta = -1) union() {
        square([2 * L, 2 * cap_core_r], center = true);
        square([2 * cap_core_r, 2 * L], center = true);
    }
}
module cap_slots(z0, z1, chamfer_top, chamfer_bot) {
    c = 0.8;
    for (a = [0 : 90 : 270]) rotate([0, 0, a]) {
        translate([cap_core_r, -slot_w / 2, z0]) cube([cap_slot_depth + 1, slot_w, z1 - z0]);
        if (chamfer_top) hull() {
            translate([cap_core_r, -slot_w / 2 - c, z1 - eps]) cube([cap_slot_depth + 1, slot_w + 2 * c, eps]);
            translate([cap_core_r, -slot_w / 2, z1 - c - eps]) cube([cap_slot_depth + 1, slot_w, eps]);
        }
        if (chamfer_bot) hull() {
            translate([cap_core_r, -slot_w / 2 - c, z0]) cube([cap_slot_depth + 1, slot_w + 2 * c, eps]);
            translate([cap_core_r, -slot_w / 2, z0 + c]) cube([cap_slot_depth + 1, slot_w, eps]);
        }
    }
}
module cap_pins(zs) {
    for (a = [0 : 90 : 270], z = zs) rotate([0, 0, a])
        translate([pin_r_world, 0, z]) rotate([90, 0, 0])
            cylinder(d = lock_pin_d, h = slot_w + 2, center = true); // 1 mm w ściankach
}

// końcowa: denko na dole (druk denkiem do stołu), na górze kosza odwrócona
module end_cap() {
    h = cap_web + cap_slot_h;
    difference() {
        linear_extrude(height = h) cap_2d();
        cap_slots(cap_web, h + eps, true, false);
    }
    cap_pins([cap_web + pin_h]);
}

// łącznik pięter: gniazda z obu stron, szczelina seam_gap pośrodku
module seam_cap() {
    h = 2 * cap_slot_h + seam_gap;
    difference() {
        linear_extrude(height = h) cap_2d();
        cap_slots(-eps, h + eps, true, true);
    }
    cap_pins([h / 2 - seam_gap / 2 - pin_h, h / 2 + seam_gap / 2 + pin_h]);
}

// =====================================================================
//  voronoi_pattern() – ażur
//  Obszar = wnętrze ramy minus strefy zatrzasków, zgrubień i pasów
//  usztywniających, każda powiększona o frame_width.
// =====================================================================
module keepouts_2d(i) {
    H = tier_h(i);
    square([cap_slot_depth, cap_slot_h]);                                // zatrzask dolny
    translate([0, H - cap_slot_h]) square([cap_slot_depth, cap_slot_h]); // zatrzask górny
    for (s = hook_spans(i)) {
        xa = $bx - boss_flat - (s[2] - panel_thickness) * boss_ramp;
        translate([xa, s[0]]) square([$bx - xa, s[1] - s[0]]);
    }
}

// pasy usztywniające (bez dodatkowego offsetu – band_width to pełna szerokość pasa)
module bands_2d(i) {
    if (stiffening_bands)
        for (y = saddle_ys(i)) translate([0, y - band_width / 2]) square([$bx, band_width]);
}

module pattern_region_2d(i) {
    difference() {
        translate([frame_width, frame_width])
            square([$bx - 2 * frame_width, tier_h(i) - 2 * frame_width]);
        offset(delta = frame_width) keepouts_2d(i);
        bands_2d(i);
    }
}

module halfplane_2d(p, q, L) {
    d = q - p;
    translate((p + q) / 2) rotate(atan2(d[1], d[0])) translate([-L, -L / 2]) square([L, L]);
}

module voronoi_cell_2d(p, pts, R) {
    nb = [for (q = pts) if (norm(q - p) > 1e-6 && norm(q - p) < R) q];
    intersection() {
        translate(p - [R, R]) square(2 * R);
        intersection_for(q = nb) halfplane_2d(p, q, 2 * R);
    }
}

module voronoi_holes_2d(i) {
    x0 = frame_width; y0 = frame_width;
    W  = $bx - 2 * frame_width;
    H  = tier_h(i) - 2 * frame_width;
    nx = max(1, round(W / cell_size));
    ny = max(1, round(H / cell_size));
    sx = W / nx; sy = H / ny;
    rnd = rands(0, 1, (nx + 2) * (ny + 2) * 2, pattern_seed + i + ($dir == "depth" ? 100 : 0));
    pts = [for (a = [-1 : nx], b = [-1 : ny])
            let(k = 2 * ((a + 1) * (ny + 2) + (b + 1)))
            [x0 + (a + 0.5 + (rnd[k] - 0.5) * cell_jitter) * sx,
             y0 + (b + 0.5 + (rnd[k + 1] - 0.5) * cell_jitter) * sy]];
    R = 2.5 * max(sx, sy);
    for (p = pts)
        offset(r = hole_round) offset(delta = -hole_round)
            intersection() {
                pattern_region_2d(i);
                offset(delta = -strut_width / 2) voronoi_cell_2d(p, pts, R);
            }
}

module hex_holes_2d(i) {
    s  = cell_size;
    rc = (s - strut_width) / sqrt(3);
    py = s * sqrt(3) / 2;
    for (b = [-1 : ceil(tier_h(i) / py) + 1], a = [-1 : ceil($bx / s) + 1])
        offset(r = hole_round) offset(delta = -hole_round)
            intersection() {
                pattern_region_2d(i);
                translate([frame_width + a * s + (b % 2) * s / 2, frame_width + b * py])
                    rotate(30) circle(r = rc, $fn = 6);
            }
}

module voronoi_pattern(i) {
    if (pattern_style != "none")
        translate([0, 0, -eps]) linear_extrude(height = panel_thickness + 2 * eps)
            if (pattern_style == "hex") hex_holes_2d(i); else voronoi_holes_2d(i);
}

// =====================================================================
//  Złożenie
// =====================================================================
module separator_panel(i, d = "width") {
    $dir = d;
    $rx = rod_x_of(d);
    $bx = $rx - hook_r_in;
    difference() {
        union() { panel_base(i); clip_hook(i); }
        clip_hook_cut(i);
        central_lock(i);
        voronoi_pattern(i);
    }
}

module assembly() {
    for (i = [0 : n_tiers - 1], a = [0 : 90 : 270]) rotate([0, 0, a])
        color(i % 2 == 0 ? "SteelBlue" : "LightSkyBlue")
            translate([central_offset, panel_thickness / 2, tier_bot_z(i)])
                rotate([90, 0, 0]) separator_panel(i, a % 180 == 0 ? "width" : "depth");
    color("Orange") {
        translate([0, 0, tier_bot_z(n_tiers - 1) - cap_web]) end_cap();
        %translate([-260, -260, floor_z - 1]) cube([520, 520, 1]); // dno
        translate([0, 0, top_z + cap_web]) mirror([0, 0, 1]) end_cap();
        for (i = [0 : n_tiers - 2])
            translate([0, 0, tier_bot_z(i) - seam_gap / 2 - cap_slot_h]) seam_cap();
    }
    for (z = rod_zs, a = [0 : 90 : 270]) rotate([0, 0, a])
        %translate([span_of(a % 180 == 0 ? "width" : "depth") / 2, 0, z]) rotate([90, 0, 0])
            cylinder(d = rod_diameter, h = 80, center = true);
}

// =====================================================================
//  Render
//  panel    – piętro `tier`, kierunek `panel_dir`, płasko, zgrubieniami do góry (druk 2x każdy)
//  end_cap  – denkiem do stołu (druk 2x)
//  seam_cap – pionowo (druk 1x na każdy styk pięter)
//  assembly – podgląd w koszu
// =====================================================================
if (part == "panel")         separator_panel(tier, panel_dir);
else if (part == "end_cap")  end_cap();
else if (part == "seam_cap") seam_cap();
else if (part == "assembly") assembly();
