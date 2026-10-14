// ============================================================================
//  MASKOWNICA - prostopadłościan z trapezowym wycięciem w prawym dolnym rogu
// ============================================================================
//  Wszystkie wymiary w milimetrach [mm].
//
//  Układ współrzędnych:
//    X - szerokość   : 0 = lewa krawędź,   width  = prawa krawędź
//    Y - głębokość   : 0 = przód,          depth  = tył
//    Z - wysokość    : 0 = dół,            height = góra
//
//  Wycięcie (trapez) leży w prawym dolnym rogu i przechodzi NA WYLOT
//  przez całą głębokość. Jest wyśrodkowane pionowo:
//    - na krawędzi bryły (x = width) ma wysokość `cut_edge_h`,
//    - w głębi (x = width - cut_in_width) ma wysokość `cut_inner_h`.
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

/* [Ustawienia ogólne] */
$fn = 64;

// ---------------------------------------------------------------------------
//  Geometria wycięcia (wyliczana z powyższych parametrów - nie zmieniaj ręcznie)
// ---------------------------------------------------------------------------
// Środek wycięcia na krawędzi bryły oraz pionowe granice na krawędzi i w głębi.
cut_center    = cut_start_z + cut_edge_h / 2;   // pionowy środek wycięcia
cut_edge_bot  = cut_start_z;                    // dolna krawędź na krawędzi bryły
cut_edge_top  = cut_start_z + cut_edge_h;       // górna krawędź na krawędzi bryły
cut_inner_bot = cut_center - cut_inner_h / 2;   // dolna krawędź w głębi (wyśrodkowana)
cut_inner_top = cut_center + cut_inner_h / 2;   // górna krawędź w głębi (wyśrodkowana)

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

// Zapas tak, aby wycięcie na pewno przebiło bryłę na wylot (bez artefaktów).
eps = 1;

// ---------------------------------------------------------------------------
//  Bryła
// ---------------------------------------------------------------------------
module maskownica() {
    difference() {
        // Prostopadłościan bazowy
        cube([width, depth, height]);

        // Trapezowe wycięcie na wylot przez całą głębokość.
        // rotate([90,0,0]) obraca wyciągnięty profil (w płaszczyźnie XZ)
        // tak, że wyciągnięcie biegnie wzdłuż osi Y; translate ustawia je
        // w zakresie od -eps do depth+eps, czyli z zapasem po obu stronach.
        translate([0, depth + eps, 0])
            rotate([90, 0, 0])
                linear_extrude(height = depth + 2 * eps)
                    polygon(points = trapez_points);
    }
}

maskownica();
