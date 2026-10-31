// ==========================================
// Prawidłowa ścianka z wzorem plastra miodu (Honeycomb Wall)
// ==========================================

// --- PARAMETRY KONFIGURACYJNE ---
width = 210;         // Szerokość ścianki (w mm)
length = 230;        // Długość / wysokość ścianki (w mm)
thickness = 5;       // Grubość całej ścianki (w mm)

hex_size = 15;       // Średnica oczka (rozmiar heksagonu - odległość między przeciwległymi ściankami, w mm)
wall_thickness = 5;  // Grubość ścianek pomiędzy heksagonami oraz ramki (w mm)

// Rozdzielczość renderowania heksagonów (dokładnie 6 ścian)
$fn = 6;

// --- GŁÓWNY MODUŁ ---
module honeycomb_wall() {
difference() {
// 1. Zewnętrzna pełna bryła (płyta)
cube([width, length, thickness]);

    // 2. Wycięcie siatki heksagonów
    // Przesuwamy o grubość ścianki/ramki, aby zachować solidną obwódkę wokół
    translate([wall_thickness, wall_thickness, -1])
        honeycomb_grid(
            width - (2 * wall_thickness), 
            length - (2 * wall_thickness), 
            thickness + 2, 
            hex_size, 
            wall_thickness
        );
}


}

// --- MODUŁ SIATKI HEKSAGONALNEJ ---
module honeycomb_grid(w, l, h, size, w_thick) {
// W matematyce heksagonów foremnych (flat-to-flat = size):
// Promień koła opisanego na heksagonie (r) wynosi: (size / 2) / cos(30°) = size / sqrt(3)
// Odstępy między środkami w układzie plastra miodu:
// dx = size + w_thick (w przybliżeniu dla prawidłowego spasowania ścianek)

// Obliczamy dokładne przesunięcia dla heksagonów wyrównanych płaskimi bokami do góry:
radius = (size / 2) / cos(30);

dx = size + w_thick;
dy = (size * 0.866) + (w_thick * 0.866); // 0.866 to sqrt(3)/2

// Iteracja po siatce 2D
for (y = [radius : dy : l + radius]) {
    row_index = round(y / dy);
    x_offset = (row_index % 2 == 0) ? 0 : (dx / 2);
    
    for (x = [radius + x_offset : dx : w + radius]) {
        // Generujemy pojedynczy otwór heksagonalny
        // Obrót o 30 stopni ustawia heksagon płaskimi bokami pionowo/poziomo,
        // co ułatwia zachowanie stałej grubości ścianek w siatce.
        translate([x, y, 0])
            rotate([0, 0, 30])
                cylinder(h = h, r = radius, center = false);
    }
}


}

// Wywołanie głównego modelu
honeycomb_wall();