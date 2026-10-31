// ============================================================================
//  MASKOWNICA - prostopadłościan z trapezowym wycięciem i wzorem "jodełka"
// ============================================================================
//  Wszystkie wymiary w milimetrach [mm].
//
//  Układ współrzędnych:
//    X - szerokość  : 0 = lewa krawędź,   width  = prawa krawędź
//    Y - głębokość  : 0 = przód (lico z wzorem), depth = tył
//    Z - wysokość   : 0 = dół,            height = góra
//
//  Wzór: art-deco liść / jodełka - pionowy rdzeń i gęste, równoległe
//  ukośne żebra po obu stronach (jak na panelach ze zdjęcia).
//  Tryb "wypukly": wycinane jest tło, linie zostają wypukłe (jak na zdjęciu).
//  Tryb "rowki":   wycinane są same linie.
// ============================================================================

/* [Główne wymiary maskownicy] */
depth   = 20;    // głębokość
width   = 18.5;  // szerokość
height  = 205.5;   // wysokość

/* [Wycięcie (trapez) - prawy dolny róg] */
cut_start_z  = 23.5;  // wysokość, na której zaczyna się wycięcie (od dołu)
cut_edge_h   = 14.5;  // wysokość wycięcia na krawędzi prostopadłościanu
cut_in_width = 15;  // zasięg wycięcia w głąb od prawej krawędzi
cut_inner_h  = 13;  // wysokość wycięcia na końcu (w głębi), wyśrodkowana

/* [Wzór jodełka] */
wzor_wlaczony  = true;
wzor_tryb      = "wypukly";  // [wypukly, rowki]
wzor_glebokosc = 0.6;        // głębokość frezu
motyw_grubosc  = 1.2;        // grubość linii (żeber i rdzenia)
motyw_rozstaw  = 2.6;        // odstęp między żebrami (mierzony prostopadle)
motyw_kat      = 45;         // kąt żeber od poziomu [stopnie]
motyw_rdzen    = true;       // pionowa linia przez środek
motyw_kierunek = "naprzemian"; // [gora, dol, naprzemian]

/* [Wygięcie żeber (semilosowe)] */
seed           = 42;    // ziarno losowości - ten sam seed = ten sam wzór
zebra_wygiecie = 0.5;   // maks. ugięcie żebra w środku [mm] (0 = proste)
zebra_segmenty = 10;    // gładkość łuku (więcej = gładziej, wolniej)
zebra_symetria = true;  // lewa strona lustrzanym odbiciem prawej

/* [Układ: kafle i marginesy] */
kafel_wys          = 20;    // wysokość kafla (z przerwą)
kafel_odstep       = 1.5;   // pełna listwa między kaflami
wzor_margines_bok  = 1.75;  // margines lewo/prawo
wzor_margines_gora = 9.5;     // margines od góry
wzor_odstep_trapez = 2;     // margines od górnej krawędzi trapezu

/* [Ustawienia ogólne] */
$fn = 64;

// ---------------------------------------------------------------------------
//  Geometria wycięcia (trapez)
// ---------------------------------------------------------------------------
cut_center    = cut_start_z + cut_edge_h / 2;
cut_edge_bot  = cut_start_z;
cut_edge_top  = cut_start_z + cut_edge_h;
cut_inner_bot = cut_center - cut_inner_h / 2;
cut_inner_top = cut_center + cut_inner_h / 2;

x_right = width;
x_inner = width - cut_in_width;

trapez_points = [
    [x_inner, cut_inner_bot],
    [x_right, cut_edge_bot],
    [x_right, cut_edge_top],
    [x_inner, cut_inner_top],
];

eps = 1;

// ---------------------------------------------------------------------------
//  Obszar wzoru i kafle (kafle wyśrodkowane w pionie)
// ---------------------------------------------------------------------------
wzor_x0   = wzor_margines_bok;
wzor_z0   = cut_edge_top + wzor_odstep_trapez;
wzor_szer = width  - 2 * wzor_margines_bok;
wzor_wys  = height - wzor_z0 - wzor_margines_gora;

kafel_h      = kafel_wys - kafel_odstep;                       // wysokość motywu
kafel_liczba = max(1, floor((wzor_wys + kafel_odstep) / kafel_wys));
kafel_offset = (wzor_wys - (kafel_liczba * kafel_wys - kafel_odstep)) / 2;

// ---------------------------------------------------------------------------
//  Motyw
// ---------------------------------------------------------------------------
module gruba_linia(p1, p2, w) {
    hull() {
        translate(p1) circle(d = w, $fn = 16);
        translate(p2) circle(d = w, $fn = 16);
    }
}

// Ugięcie ograniczone tak, żeby sąsiednie żebra się nie zlewały
amp_eff = min(zebra_wygiecie, (motyw_rozstaw - motyw_grubosc) / 2);

function tile_seed(t) = seed + t * 7919;

// Ugięcia kolejnych żeber: płynna fala + odrobina szumu,
// dzięki temu sąsiednie żebra wyginają się podobnie (wzór "płynie").
function ugiecia(n, s) =
    let(r  = rands(0, 1, n + 4, s),
        f  = 15 + 30 * r[0],     // jak szybko zmienia się ugięcie [°/żebro]
        ph = 360 * r[1])         // faza
    [for (k = [0 : n]) amp_eff * (0.75 * sin(f * k + ph) + 0.25 * (2 * r[k + 3] - 1))];

// Skos łuku (gdzie wypada najmocniejsze ugięcie) - stały w obrębie kafla
function skos_luku(s) = 0.7 + 0.7 * rands(0, 1, 1, s + 3)[0];

// Wygięte żebro: łuk od p1 do p2, ugięcie b prostopadle do linii,
// zerowe przy rdzeniu (czyste połączenie).
module zebro(p1, p2, b, skos, g) {
    d   = p2 - p1;
    nrm = [-d[1], d[0]] / norm(d);
    pts = [for (i = [0 : zebra_segmenty])
              let(u = i / zebra_segmenty)
              p1 + d * u + nrm * b * sin(180 * pow(u, skos))];
    for (i = [0 : zebra_segmenty - 1])
        gruba_linia(pts[i], pts[i + 1], g);
}

// Linie jodełki w prostokącie W x H (żebra rosną w górę od rdzenia)
module jodelka_linie(W, H, t) {
    cx   = W / 2;
    g    = motyw_grubosc;
    tg   = tan(motyw_kat);
    dx   = cx + g;                         // wyjście poza krawędź (czyste końce)
    step = motyw_rozstaw / cos(motyw_kat); // pionowy skok żeber
    n    = ceil((H + dx * tg) / step) + 1;

    s    = tile_seed(t);
    bP   = ugiecia(n, s);
    bL   = zebra_symetria ? bP : ugiecia(n, s + 101);
    skP  = skos_luku(s);
    skL  = zebra_symetria ? skP : skos_luku(s + 101);

    if (motyw_rdzen)
        translate([cx - g / 2, -g]) square([g, H + 2 * g]);

    for (k = [0 : n]) {
        y0 = -dx * tg + k * step;
        zebro([cx, y0], [cx + dx, y0 + dx * tg],  bP[k], skP, g);  // prawa
        zebro([cx, y0], [cx - dx, y0 + dx * tg], -bL[k], skL, g);  // lewa (lustro)
    }
}

// Kierunek kafla t (do góry / do dołu / naprzemiennie)
module jodelka_kafel(t) {
    w_dol = (motyw_kierunek == "dol") ||
            (motyw_kierunek == "naprzemian" && t % 2 == 1);
    if (w_dol)
        translate([0, kafel_h]) mirror([0, 1]) jodelka_linie(wzor_szer, kafel_h, t);
    else
        jodelka_linie(wzor_szer, kafel_h, t);
}

// Kształt do wycięcia w jednym kaflu
module kafel_ciecie(t) {
    if (wzor_tryb == "rowki")
        intersection() {
            square([wzor_szer, kafel_h]);
            jodelka_kafel(t);
        }
    else // "wypukly" - wycinamy tło, linie zostają
        difference() {
            square([wzor_szer, kafel_h]);
            jodelka_kafel(t);
        }
}

module wzor_2d() {
    translate([wzor_x0, wzor_z0 + kafel_offset])
        for (t = [0 : kafel_liczba - 1])
            translate([0, t * kafel_wys]) kafel_ciecie(t);
}

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
        cube([width, depth, height]);
        
        translate([width-10, 0, height-8.5])
        cube([10,depth+2*eps,8.5]);

        translate([0, depth + eps, 0])
            rotate([90, 0, 0])
                linear_extrude(height = depth + 2 * eps)
                    polygon(points = trapez_points);

        frezy();
    }
}

maskownica();
