// ============================================================================
//  MASKOWNICA - prostopadłościan z trapezowym wycięciem i frezowanym wzorem
// ============================================================================
//  Wszystkie wymiary w milimetrach [mm].
//
//  Układ współrzędnych:
//    X - szerokość  : 0 = lewa krawędź,   width  = prawa krawędź
//    Y - głębokość  : 0 = przód (lico z wzorem), depth = tył
//    Z - wysokość   : 0 = dół,            height = góra
//
//  Wycięcie (trapez) leży w prawym dolnym rogu i przechodzi NA WYLOT
//  przez całą głębokość.
//
//  Wzór (frez) jest wcinany tylko na przednim licu (y = 0) na niską
//  głębokość. To powtarzalny kafelek z marginesem od krawędzi.
//  Losowość steruje parametr `seed` - ten sam seed = ten sam wzór.
// ============================================================================

/* [Główne wymiary maskownicy] */
depth   = 20;    // głębokość
width   = 18.5;  // szerokość
height  = 200;   // wysokość

/* [Wycięcie (trapez) - prawy dolny róg] */
cut_start_z  = 32;  // wysokość, na której zaczyna się wycięcie (od dołu)
cut_edge_h   = 14;  // wysokość wycięcia na krawędzi prostopadłościanu
cut_in_width = 15;  // zasięg wycięcia w głąb od prawej krawędzi
cut_inner_h  = 13;  // wysokość wycięcia na końcu (w głębi), wyśrodkowana

/* [Wzór (frez) na przednim licu] */
wzor_wlaczony   = true;      // wyłącz/włącz frez
wzor_typ        = "rowki";   // [rowki, kafel, motyw, organiczne]
seed            = 42;        // ziarno losowości
wzor_glebokosc  = 0.4;       // głębokość frezu (odejmowana warstwa)
wzor_min_szer   = 1.0;       // min. szerokość linii (>= dysza to bezpieczne)
wzor_max_szer   = 3.0;       // maks. szerokość linii
wzor_rowki_n    = 4;         // liczba rowków w poziomym rzędzie (typ "rowki")
wzor_odstep_min = 0.8;       // min. odstęp między rowkami

/* [Motyw geometryczny (typ "motyw")] */
motyw_zebra   = 4;    // liczba par żeber (gałęzi) w kafelku
motyw_grubosc = 1.6;  // grubość linii motywu

/* [Układ wzoru: kafel i marginesy] */
kafel_wys           = 12;      // wysokość jednego kafelka
kafel_odstep        = 1.5;     // przerwa między kaflami (0 = ciągłe)
kafel_wariacja      = "seed";  // [seed, lustro, brak]
wzor_margines_bok   = 1.75;    // margines lewo/prawo
wzor_margines_gora  = 4;       // margines od góry
wzor_odstep_trapez  = 2;       // margines mierzony od górnej krawędzi wycięcia trapezu

/* [Ustawienia ogólne] */
$fn = 64;

// ---------------------------------------------------------------------------
//  Geometria wycięcia (trapez) - wyliczana z parametrów
// ---------------------------------------------------------------------------
cut_center    = cut_start_z + cut_edge_h / 2;   // pionowy środek wycięcia
cut_edge_bot  = cut_start_z;                    // dolna krawędź na krawędzi bryły
cut_edge_top  = cut_start_z + cut_edge_h;       // górna krawędź na krawędzi bryły
cut_inner_bot = cut_center - cut_inner_h / 2;   // dolna krawędź w głębi
cut_inner_top = cut_center + cut_inner_h / 2;   // górna krawędź w głębi

x_right = width;                 // prawa krawędź prostopadłościanu
x_inner = width - cut_in_width;  // krawędź wycięcia w głębi bryły

// Narożniki trapezu, patrząc na ścianę 18.5 x 200 mm:
//   [w głębi - dół] -> [na krawędzi - dół] -> [na krawędzi - góra] -> [w głębi - góra]
trapez_points = [
    [x_inner, cut_inner_bot],
    [x_right, cut_edge_bot],
    [x_right, cut_edge_top],
    [x_inner, cut_inner_top],
];

eps = 1;  // zapas booleowski, żeby cięcia były czyste

// ---------------------------------------------------------------------------
//  Geometria wzoru - obszar roboczy, kafel, seed
// ---------------------------------------------------------------------------
wzor_x0   = wzor_margines_bok;                      // lewa krawędź wzoru
wzor_z0   = cut_edge_top + wzor_odstep_trapez;      // dolna krawędź wzoru - liczona OD TRAPEZU
wzor_szer = width  - 2 * wzor_margines_bok;         // szerokość obszaru wzoru
wzor_wys  = height - wzor_z0 - wzor_margines_gora;  // wysokość obszaru wzoru

kafel_pitch   = kafel_wys;              // odstęp między kaflami (co ile się powtarza)
kafel_motif_h = kafel_wys - kafel_odstep;// realna wysokość motywu w kafelku
kafel_liczba  = max(1, floor(wzor_wys / kafel_pitch)); // ile kafli się zmieści

// Seed zależny od numeru kafelka: przy "seed" każdy kafelek inny, inaczej stały.
function tile_seed(t) = (kafel_wariacja == "seed") ? seed + t * 7919 : seed;

// Suma listy do indeksu i (rekurencyjnie).
function lsum(v, i) = (i < 0) ? 0 : v[i] + lsum(v, i - 1);

// Średnia ruchoma w oknie +/-rad - wygładza przebieg linii.
function avgk(v, i, rad) =
    let(lo = max(0, i - rad), hi = min(len(v) - 1, i + rad))
    lsum([for (j = [lo : hi]) v[j]], hi - lo) / (hi - lo + 1);

// Spacer losowy z powrotem do środka (random walk) - zwraca listę współrzędnych Y.
function _walk(n, r, center, retain, scale, i = 0, y = 0, acc = []) =
    i > n
        ? acc
        : let(yy = center + (y - center) * retain + (r[i] - 0.5) * scale)
          _walk(n, r, center, retain, scale, i + 1, yy, concat(acc, [yy]));

// ---------------------------------------------------------------------------
//  Motywy kafelka (rysowane w 2D w lokalnych współrzędnych kafelka)
// ---------------------------------------------------------------------------
// Gruba linia (2D) między punktami - zaokrąglone końce, do rysowania motywów.
module gruba_linia(p1, p2, w) {
    hull() {
        translate(p1) circle(d = w, $fn = 16);
        translate(p2) circle(d = w, $fn = 16);
    }
}

// "rowki" - pionowe żłobki o losowej (ale stałej na wysokości) grubości
module kafelek_rowki(t) {
    col = wzor_szer / wzor_rowki_n;
    w   = rands(wzor_min_szer, wzor_max_szer, wzor_rowki_n, tile_seed(t));
    for (i = [0 : wzor_rowki_n - 1]) {
        bw = min(w[i], col - wzor_odstep_min);   // nie przekracza kolumny
        xc = (i + 0.5) * col;                    // środek kolumny
        translate([xc - bw / 2, 0])
            square([bw, kafel_motif_h]);
    }
}

// "kafel" - falista linia o zmieniającej się grubości
module kafelek_fala(t) {
    r     = rands(0, 1, 3, tile_seed(t));
    freq  = 1 + floor(r[0] * 3);                     // 1..3 półfale w kafelku
    amp   = kafel_motif_h * 0.28 * (0.6 + 0.4 * r[1]); // amplituda fali
    ph    = r[2] * 360;                              // przesunięcie fazy
    steps = 48;
    for (i = [0 : steps]) {
        u = i / steps;
        x = u * wzor_szer;
        y = kafel_motif_h / 2 + amp * sin(180 * freq * u + ph);
        w = wzor_min_szer
          + (wzor_max_szer - wzor_min_szer) * (0.5 + 0.5 * sin(360 * u + ph * 0.5));
        translate([x, y]) circle(d = w, $fn = 20);
    }
}

// "organiczne" - nieregularna linia (random walk) o płynnie zmiennej grubości
module kafelek_organiczne(t) {
    n      = 72;
    center = kafel_motif_h / 2;
    r      = rands(0, 1, n + 1, tile_seed(t));
    raw    = _walk(n, r, center, 0.85, kafel_motif_h * 0.13, 0, center, []);
    ys     = [for (i = [0 : n]) avgk(raw, i, 3)];        // wygładzony przebieg
    wp     = rands(0, 1, 3, tile_seed(t) + 11);          // parametry grubości
    for (i = [0 : n]) {
        u = i / n;
        x = u * wzor_szer;
        w = wzor_min_szer
          + (wzor_max_szer - wzor_min_szer)
            * (0.5 + 0.5 * sin(360 * (0.7 + wp[0]) * u + wp[1] * 360));
        translate([x, ys[i]]) circle(d = w, $fn = 20);
    }
}

// "motyw" - geometryczny liść/pióro: rdzeń + symetryczne żebra (jak na obrazku)
module kafelek_motyw(t) {
    W  = wzor_szer;
    H  = kafel_motif_h;
    p  = rands(0, 1, 2, tile_seed(t));
    n  = motyw_zebra + floor(p[0] * 2);   // liczba par żeber (lekka wariacja)
    wl = motyw_grubosc;
    cx = W / 2;

    // rdzeń (pionowa linia przez środek)
    gruba_linia([cx, 0], [cx, H], wl);

    // żebra: od rdzenia ku krawędziom, symetrycznie, w górę
    for (i = [0 : n - 1]) {
        y0 = i / n * H;
        y1 = (i + 1) / n * H;
        gruba_linia([cx, y0], [0, y1], wl);
        gruba_linia([cx, y0], [W, y1], wl);
    }
}

// Wybór motywu wg parametru `wzor_typ`
module kafelek(t) {
    if      (wzor_typ == "rowki")       kafelek_rowki(t);
    else if (wzor_typ == "kafel")       kafelek_fala(t);
    else if (wzor_typ == "motyw")       kafelek_motyw(t);
    else if (wzor_typ == "organiczne")  kafelek_organiczne(t);
    else                                kafelek_rowki(t);
}

// Rysowanie kafelka z wariacją: przy "lustro" co drugi kafelek jest odbity
module tile_draw(t) {
    if (kafel_wariacja == "lustro" && (t % 2) == 1)
        translate([wzor_szer, 0]) scale([-1, 1]) kafelek(t);
    else
        kafelek(t);
}

// Wszystkie kafelki jeden nad drugim
module wzor_wypelnienie() {
    for (t = [0 : kafel_liczba - 1])
        translate([0, t * kafel_pitch])
            tile_draw(t);
}

// Wzór przycięty do obszaru roboczego (marginesy)
module wzor_2d() {
    intersection() {
        translate([wzor_x0, wzor_z0]) square([wzor_szer, wzor_wys]);
        translate([wzor_x0, wzor_z0]) wzor_wypelnienie();
    }
}

// Frez: płytkie wycięcie wzoru w przednim licu (y = 0)
module frezy() {
    if (wzor_wlaczony)
        translate([0, wzor_glebokosc, 0])
            rotate([90, 0, 0])
                linear_extrude(height = wzor_glebokosc + eps)
                    wzor_2d();
}

// ---------------------------------------------------------------------------
//  Bryła
// ---------------------------------------------------------------------------
module maskownica() {
    difference() {
        // Prostopadłościan bazowy
        cube([width, depth, height]);

        // Trapezowe wycięcie na wylot przez całą głębokość
        translate([0, depth + eps, 0])
            rotate([90, 0, 0])
                linear_extrude(height = depth + 2 * eps)
                    polygon(points = trapez_points);

        // Płytki wzór (frez) na licu
        frezy();
    }
}

maskownica();
