// =====================================================================
//  Korek narożny pod drzwi prysznicowe – bryła + 2 regulowane wycięcia
//  Układ: A = (0,0) kąt prosty, AB wzdłuż X, AC wzdłuż Y, Z w górę
// =====================================================================

// ---------------- BRYŁA ----------------
a = 41;   // długość krawędzi AB (oś X) [mm]
b = 120;   // długość krawędzi AC (oś Y) [mm]
H = 13;    // wysokość nad krawędzią AB [mm]
g = 10;   // dlugosc korka

// ---------------- PODGLĄD ----------------
pokaz_wyciecia = true;  // true = wycięcia podświetlone na różowo w podglądzie (F5)
                        // w renderze (F6) i eksporcie STL podświetlenie znika
luz = 0.2;              // tolerancja dodawana do szerokości i długości wycięć [mm]

// ---------------- WYCIĘCIE 1: szyba wchodząca od góry ----------------
w1_wlaczone = true;
w1_poz   = [7, -1-g, 1.6];      // [x, y, z] dolnego narożnika wycięcia
                            //   x = odległość od krawędzi AC
                            //   z = dno szczeliny (H - z = głębokość wejścia szyby)
w1_wym   = [7.8, b + 2+g, 20];  // [grubość szyby, długość, wysokość]
                            //   długość i wysokość celowo "na zapas" poza bryłę
w1_obrot = 0;               // obrót wokół osi Z względem narożnika [°]

// ---------------- WYCIĘCIE 2: od krawędzi AB ----------------
// Wcięcie typu "U" wchodzące od krawędzi AB (y = 0) w głąb bryły.
w2_wlaczone = true;
w2_poz   = [25, -1-g, -1];    // [x, y, z] dolnego narożnika wycięcia
                            //   y = -1, żeby wycięcie wychodziło poza krawędź
w2_wym   = [20, 15+g, H + 2];   // [szerokość, głębokość w bryłę + 1, wysokość]
                            //   wysokość H+2 = przelotowo; zmniejsz dla wcięcia częściowego
w2_obrot = 0;               // obrót wokół osi Z względem narożnika [°]

// -- wyciecie 3 na koło
w3_wlaczone = true;
w3_poz   = [0, 0-g, 5.5];      // [x, y, z] dolnego narożnika wycięcia
                            //   x = odległość od krawędzi AC
                            //   z = dno szczeliny (H - z = głębokość wejścia szyby)
w3_wym   = [7.8, b + 2+g, 20];  // [grubość szyby, długość, wysokość]
                            //   długość i wysokość celowo "na zapas" poza bryłę
w3_obrot = 0;               // obrót wokół osi Z względem narożnika [°]


// w4 - sciecie z przodu
w4_wlaczone = true;
w4_poz   = [0, b-20, -1];    // [x, y, z] dolnego narożnika wycięcia
                            //   y = -1, żeby wycięcie wychodziło poza krawędź
w4_wym   = [20, 20, H + 2];   // [szerokość, głębokość w bryłę + 1, wysokość]
                            //   wysokość H+2 = przelotowo; zmniejsz dla wcięcia częściowego
w4_obrot = 0;               // obrót wokół osi Z względem narożnika [°]


// ---------------- NADLOZENIA ----------------

// n1 - wydluzenie do srodka wneki
n1_wlaczone = true;
n1_poz   = [0, 0-g, 0];      // [x, y, z] dolnego narożnika wycięcia
                            //   x = odległość od krawędzi AC
                            //   z = dno szczeliny (H - z = głębokość wejścia szyby)
n1_wym   = [a, g, H];  // [grubość szyby, długość, wysokość]
                            //   długość i wysokość celowo "na zapas" poza bryłę
n1_obrot = 0;               // obrót wokół osi Z względem narożnika [°]

// --------------- ZACZEP ---------------------

z_wlaczone = true;
z_wym      = [23.1, 11.5, 3.5];   // [X, Y, Z] prostopadłościanu [mm]
z_cyl_d    = 6.6;             // średnica cylindra [mm]
z_cyl_l    = 3.6;             // o ile cylinder wystaje ponad prostopadłościan [mm]
z_cyl_poz  = [4.9, 5.0];        // [x, y] środka cylindra na górnej ścianie
                            //   (domyślnie środek ściany 10 x 10)
z_fazka    = 0.8;           // fazka na końcu cylindra, ułatwia wejście (0 = brak)
z_fn       = 48;            // gładkość cylindra

// Umieszczenie w docelowym modelu
z_poz      = [38, 1+1.7, 8+2+3.16];     // [x, y, z] przesunięcie całego zaczepu
z_obrot    = [0, 180, 0];     // [x, y, z] obrót całego zaczepu [°]

// =====================================================================

module bryla() {
    polyhedron(
        points = [[0,0,0], [a,0,0], [0,b,0], [0,0,H], [a,0,H]],
        faces  = [[0,1,2], [0,3,4,1], [0,2,3], [1,4,2], [3,2,4]]
    );
}

// Prostopadłościan powiększony o luz w X i Y (symetrycznie), bez zmiany Z
module wyciecie(poz, wym, obrot) {
    translate(poz)
        rotate([0, 0, obrot])
            translate([-luz/2, -luz/2, 0])
                cube(wym + [luz, luz, 0]);
}

module wyciecia() {
    if (w1_wlaczone) wyciecie(w1_poz, w1_wym, w1_obrot);
    if (w2_wlaczone) wyciecie(w2_poz, w2_wym, w2_obrot);
    if (w3_wlaczone) wyciecie(w3_poz, w3_wym, w3_obrot);
    if (w4_wlaczone) wyciecie(w4_poz, w4_wym, w4_obrot);
}

module zaczep(wym = z_wym, d = z_cyl_d, l = z_cyl_l,
              cpoz = z_cyl_poz, fazka = z_fazka) {
    e = 0.01;  // zakładka, żeby bryły się na pewno połączyły
    union() {
        cube(wym);
        translate([cpoz[0], cpoz[1], wym[2] - e]) {
            cylinder(d = d, h = l - fazka + e, $fn = z_fn);
            if (fazka > 0)
                translate([0, 0, l - fazka])
                    cylinder(d1 = d, d2 = d - 2 * fazka, h = fazka + e, $fn = z_fn);
        }
    }
}


// ---------------- ODBICIE LUSTRZANE ----------------
lustro     = true;      // true = odbij całość (bryłę razem z wycięciami)
lustro_os  = [1, 0, 0]; // [1,0,0] = lewo-prawo (odbicie względem płaszczyzny YZ)
                        // [0,1,0] = przód-tył (względem płaszczyzny XZ)

module calosc() {
    union() {
    difference() {
        union() {
            bryla();
            if (n1_wlaczone) wyciecie(n1_poz, n1_wym, n1_obrot);
            
        }
        if (pokaz_wyciecia) #wyciecia();
        else                 wyciecia();
    }
    if (z_wlaczone) translate(z_poz) rotate(z_obrot) zaczep();
    }
}

if (lustro) mirror(lustro_os) calosc();
else        calosc();
