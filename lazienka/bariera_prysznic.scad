// =====================================================================
//  Korek narożny pod drzwi prysznicowe – bryła + 2 regulowane wycięcia
//  Układ: A = (0,0) kąt prosty, AB wzdłuż X, AC wzdłuż Y, Z w górę
// =====================================================================

// ---------------- BRYŁA ----------------
a = 25;   // długość krawędzi AB (oś X) [mm]
b = 20;   // długość krawędzi AC (oś Y) [mm]
H = 13;    // wysokość nad krawędzią AB [mm]

// ---------------- PODGLĄD ----------------
pokaz_wyciecia = true;  // true = wycięcia podświetlone na różowo w podglądzie (F5)
                        // w renderze (F6) i eksporcie STL podświetlenie znika
luz = 0.2;              // tolerancja dodawana do szerokości i długości wycięć [mm]

// ---------------- WYCIĘCIE 1: szyba wchodząca od góry ----------------
w1_wlaczone = true;
w1_poz   = [7, 0, 1.6];      // [x, y, z] dolnego narożnika wycięcia
                            //   x = odległość od krawędzi AC
                            //   z = dno szczeliny (H - z = głębokość wejścia szyby)
w1_wym   = [7.8, b , 20];  // [grubość szyby, długość, wysokość]
                            //   długość i wysokość celowo "na zapas" poza bryłę
w1_obrot = 0;               // obrót wokół osi Z względem narożnika [°]

// -- wyciecie 3 na koło
w3_wlaczone = true;
w3_poz   = [0, 0, 5.5];      // [x, y, z] dolnego narożnika wycięcia
                            //   x = odległość od krawędzi AC
                            //   z = dno szczeliny (H - z = głębokość wejścia szyby)
w3_wym   = [7.8, b, 20];  // [grubość szyby, długość, wysokość]
                            //   długość i wysokość celowo "na zapas" poza bryłę
w3_obrot = 0;               // obrót wokół osi Z względem narożnika [°]


// ---------------- NADLOZENIA ----------------

// n1 - wydluzenie do srodka wneki
n1_wlaczone = true;
n1_poz   = [0, 0, 0];      // [x, y, z] dolnego narożnika wycięcia
                            //   x = odległość od krawędzi AC
                            //   z = dno szczeliny (H - z = głębokość wejścia szyby)
n1_wym   = [a, b, H];  // [grubość szyby, długość, wysokość]
                            //   długość i wysokość celowo "na zapas" poza bryłę
n1_obrot = 0;               // obrót wokół osi Z względem narożnika [°]


// =====================================================================

// Prostopadłościan powiększony o luz w X i Y (symetrycznie), bez zmiany Z
module wyciecie(poz, wym, obrot) {
    translate(poz)
        rotate([0, 0, obrot])
            translate([-luz/2, -luz/2, 0])
                cube(wym + [luz, luz, 0]);
}

module wyciecia() {
    if (w1_wlaczone) wyciecie(w1_poz, w1_wym, w1_obrot);
    if (w3_wlaczone) wyciecie(w3_poz, w3_wym, w3_obrot);
}



// ---------------- ODBICIE LUSTRZANE ----------------
lustro     = true;      // true = odbij całość (bryłę razem z wycięciami)
lustro_os  = [1, 0, 0]; // [1,0,0] = lewo-prawo (odbicie względem płaszczyzny YZ)
                        // [0,1,0] = przód-tył (względem płaszczyzny XZ)

module calosc() {
    union() {
    difference() {
        if (n1_wlaczone) wyciecie(n1_poz, n1_wym, n1_obrot);

        if (pokaz_wyciecia) #wyciecia();
        else                 wyciecia();
    }

    }
}

if (lustro) mirror(lustro_os) calosc();
else        calosc();
