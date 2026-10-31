// =====================================================================
//  Obudowa RTL-SDR + uchwyt anteny ADS-B (PCB) na pionową rurkę fi 16.25
//  v2: zamykana, ażurowa (krata ukośna / skośne szczeliny), bez zaczepów
//  Materiał: ASA
//
//  Części:
//    base   – płyta tylna = kręgosłup (strain relief kabla, stoper gniazda,
//             prowadnice dongla, widełki anteny)
//    lid    – głęboka pokrywa z kratą na froncie i bokach
//    clip   – zatrzask C na rurkę (drukuj 2 szt.; górny montuje się odwrócony)
//    tripod – opcjonalnie: adapter z nakrętką 1/4"-20 zamiast zatrzasku
//
//  Śruby (5 szt.) wchodzą od tyłu: przez zatrzask/płytę tylną do słupków
//  w pokrywie. Te same śruby trzymają zatrzaski i zamykają obudowę.
//    fastener = "M4"    -> M4x20 + nakrętka M4 (gniazdo sześciokątne od frontu)
//    fastener = "wkret" -> wkręt 5x20 w otwór pilotowy
//
//  Układ współrzędnych (pozycja montażowa):
//    Z = w górę, Y = od rurki do przodu, X = w bok; tył płyty: y = 0
// =====================================================================

part      = "assembly"; // [assembly, exploded, base, lid, clip, tripod, print_all]
fastener  = "M4";       // [M4, wkret]
pattern   = "diamond";  // [diamond, slots]

$fn = 48;

// ---------- rurka ----------
pipe_d   = 16.25;

// ---------- dongle RTL-SDR (w obudowie, bez wtyku USB) ----------
dng_w    = 26.5;
dng_t    = 13.5;
dng_l    = 70;
dng_clr  = 0.4;
hs_protrude = 2;    // !!! ile radiatory wystają ponad obudowę dongla (strona pokrywy)
mcx_side = 1;       // +1 = MCX po prawej patrząc od frontu, -1 = po lewej
mcx_z    = 61;      // !!! od końca obudowy dongla przy USB do osi gniazda MCX
chan_h   = 12;      // wysokość bocznego kanału na wtyk kątowy (od płyty tylnej)

// ---------- gniazdo przedłużki USB-A ----------
fem_w    = 17;
fem_t    = 10;
fem_l    = 36;      // !!! długość plastikowej końcówki gniazda
fem_clr  = 0.3;
cable_d  = 4.5;
usb_gap  = 1.0;     // !!! szczelina gniazdo <-> obudowa dongla po wpięciu
plug_dy  = 0;
z_clr    = 1.0;

// ---------- antena PCB ----------
pcb_w    = 20;
pcb_l    = 180;
pcb_t    = 1.6;
pcb_slot = 1.8;
grip     = 25;
ant_gap  = 55;      // !!! od górnego końca dongla do dolnej krawędzi PCB

// ---------- obudowa ----------
t        = 4;       // płyta tylna
wall     = 2.2;     // ścianki boczne pokrywy
lid_t    = 2.4;     // front pokrywy
W        = 38;
W_top    = 16;
cable_zone = 30;
stop_t   = 3;
fork_w   = 2.5;
cap_len  = 12;      // strefa nad donglem (słupek górnej śruby)

// ---------- wzór ażuru ----------
pitch    = 9;       // raster kraty
web      = 2.0;     // szerokość żeberek
slot_sp  = 6;       // rozstaw skośnych szczelin

// ---------- zatrzaski ----------
clip_h    = 14;
clip_wall = 3;
clip_wrap = 235;
clip_clr  = 0.1;
pad_t     = 5;
hole_x    = 14;
hole_rows = [20, 40];   // dolny zatrzask: śruby na z=20, górny (odwrócony): z=40

// ---------- śruby ----------
screw_l  = 20;
head_d   = 10.2;    // łeb 9.5 + luz
cb_depth = 2.5;     // zagłębienie łba w zatrzasku
nut_af   = 7.4;     // M4 + luz
nut_h    = 3.4;
pilot_d  = 4.0;     // otwór pilotowy pod wkręt 5 mm

// =====================================================================
//  Wyliczenia
// =====================================================================
m_clear = fastener == "M4" ? 4.5 : 5.3;
D       = dng_t + max(hs_protrude, 0) + 0.3;   // głębokość wnętrza
y_in    = t + D;
y_front = y_in + lid_t;
Wi      = W/2 - wall;
y_c     = t + dng_t/2;
fem_ped = dng_t/2 - fem_t/2 + plug_dy;
z_stop0 = cable_zone;
z_fem0  = z_stop0 + stop_t;
z_fem1  = z_fem0 + fem_l;
z_d0    = z_fem1 + usb_gap;
z_d1    = z_d0 + dng_l;
z_cap0  = z_d1 + z_clr;
z_end   = z_cap0 + cap_len;
z_mcx   = z_d0 + mcx_z;
z_p     = z_d1 + ant_gap;
H       = z_p + grip;
z_tap1  = z_end + 15;
dng_in  = dng_w/2 + dng_clr;
fem_in  = fem_w/2 + fem_clr;
ph      = clip_h + 12;                 // wysokość płytki zatrzasku
top_z   = z_cap0 + 5.5;

// [x, z, koniec śruby w Y]
clip_end = -pad_t + cb_depth + screw_l;
holes = concat(
  [for (z = hole_rows, s = [-1, 1]) [s*hole_x, z, clip_end]],
  [[0, top_z, screw_l]]
);

echo(str("H kręgosłupa = ", H, " mm, obudowa ", W, " x ", y_front, " x ", z_end, " mm"));
for (h = holes) {
  if (h[2] > y_front - 0.3) echo(str("UWAGA: śruba na z=", h[1], " wystaje z frontu"));
  if (fastener == "M4" && h[2] - 0.3 - nut_h < t + 0.5)
    echo(str("UWAGA: za krótka śruba na z=", h[1]));
}
if (z_p < z_end + 15) echo("UWAGA: ant_gap za mały, PCB nachodzi na obudowę");

// =====================================================================
//  Pomocnicze
// =====================================================================
module xz(th, y0=0) translate([0, y0+th, 0]) rotate([90,0,0]) linear_extrude(th) children();
// 2D w (y,z), wyciągnięte w X od x0
module yz(th, x0=0) translate([x0, 0, 0]) rotate([90,0,90]) linear_extrude(th) children();

module rrect(x0, x1, z0, z1, r=3)
  translate([x0+r, z0+r]) offset(r) square([x1-x0-2*r, z1-z0-2*r]);

module wedge(a, r=60) {
  a0 = 270 - a/2; a1 = 270 + a/2;
  polygon(concat([[0,0]], [for (i=[0:24]) let(q=a0+(a1-a0)*i/24) [r*cos(q), r*sin(q)]]));
}

module diamonds(u0, u1, v0, v1) {
  a = pitch/2 - web*0.7071;
  for (i = [floor(u0/pitch)-1 : ceil(u1/pitch)+1],
       j = [floor(v0/pitch)-1 : ceil(v1/pitch)+1], o = [0, 0.5])
    translate([(i+o)*pitch, (j+o)*pitch]) rotate(45) square(a*sqrt(2), center=true);
}
module slots(u0, u1, v0, v1) {
  ws = slot_sp - web*sqrt(2);
  for (c = [floor((u0-v1)/slot_sp)-1 : ceil((u1-v0)/slot_sp)+1]) let(k = c*slot_sp)
    polygon([[k+v0-20, v0-20], [k+ws+v0-20, v0-20], [k+ws+v1+20, v1+20], [k+v1+20, v1+20]]);
}
module lattice(u0, u1, v0, v1) {
  intersection() {
    translate([u0, v0]) square([u1-u0, v1-v0]);
    if (pattern == "slots") slots(u0, u1, v0, v1); else diamonds(u0, u1, v0, v1);
  }
}

// =====================================================================
//  Geometria wspólna
// =====================================================================
module lid2d()   rrect(-W/2, W/2, 0, z_end, 4);
module inner2d() rrect(-Wi, Wi, wall, z_end - wall, 2);
module rim2d()   difference() { offset(-0.3) inner2d(); offset(-1.5) inner2d(); }

// słupki pokrywy (footprint XZ)
module pillar2d(h) {
  if (h[0] == 0) translate([-5.5, z_cap0]) square([11, cap_len - wall + 0.5]);
  else let(s = sign(h[0]))
    translate([s > 0 ? 9.7 : -Wi-0.5, h[1]-5.5]) square([Wi + 0.5 - 9.7, 11]);
}
module dng_ribs2d()
  for (s=[-1,1], z=[z_d0+6, z_d1-24]) translate([s*11.5-1, z]) square([2, 8]);
module fem_ribs2d()
  for (s=[-1,1], z=[z_fem0+3, z_fem1-11]) translate([s*4-1, z]) square([2, 8]);

// kanał na kątowy wtyk MCX i pigtail (w górę, przez górną ściankę)
module mcx_channel() {
  x0 = mcx_side > 0 ? dng_w/2 - 0.5 : -W/2 - 1;
  translate([x0, t - 1, z_mcx - 5]) cube([W/2 + 1 - dng_w/2 + 0.5, chan_h + 1, z_end - z_mcx + 6]);
}
// wycięcie na kabel USB w dolnej ściance
module cable_notch() {
  translate([-(cable_d/2+0.3), t - 1, -1]) cube([cable_d+0.6, y_c + cable_d/2 - t + 1, wall + 3]);
}

// =====================================================================
//  BASE
// =====================================================================
module base_outline2d() {
  offset(4) offset(-4) union() {
    translate([-W/2, 0]) square([W, z_end]);
    hull() {
      translate([-W/2, z_end-1]) square([W, 1]);
      translate([-W_top/2, z_tap1]) square([W_top, 1]);
    }
    translate([-W_top/2, z_tap1]) square([W_top, H - z_tap1]);
  }
}
tie_z = z_p + grip/2;
tie_x = pcb_slot/2 + fork_w + 1.8;

module base() {
  difference() {
    union() {
      xz(t) difference() {
        base_outline2d();
        lattice(-9.5, 9.5, z_d0 + 5, z_d1 - 5);
        lattice(-W_top/2 + 3, W_top/2 - 3, z_tap1 + 3, z_p - 8);
      }
      // obrzeże centrujące pokrywę
      xz(1.5, t - 0.01) rim2d();

      // kabel: podest + słupki S
      translate([-4, t-0.01, 0]) cube([8, y_c - cable_d/2 - t, z_stop0]);
      for (p = [[3.2, 8], [-3.2, 16], [3.2, 24]])
        translate([p[0], t-0.01, p[1]]) rotate([-90,0,0]) cylinder(d=5, h=y_c + cable_d/2 + 1.5 - t);

      // stoper gniazda
      translate([-9.4, t-0.01, z_stop0]) cube([18.8, fem_ped + fem_t, stop_t]);
      // podest + niskie prowadnice gniazda
      if (fem_ped > 0) translate([-fem_in, t-0.01, z_fem0]) cube([2*fem_in, fem_ped, fem_l]);
      for (s=[-1,1]) translate([s > 0 ? fem_in : -9.4, t-0.01, z_fem0]) cube([9.4 - fem_in, fem_ped + 2, fem_l]);

      // niskie prowadnice dongla
      for (s=[-1,1]) translate([s > 0 ? dng_in : -dng_in-1.2, t-0.01, z_d0+2]) cube([1.2, 2, dng_l-4]);

      // widełki PCB
      for (s=[-1,1]) mirror([s<0?1:0,0,0])
        translate([pcb_slot/2, t-0.01, z_p-3]) cube([fork_w, pcb_w, H-(z_p-3)]);
      translate([-pcb_slot/2-0.01, t-0.01, z_p-3]) cube([pcb_slot+0.02, 4, 3]);
    }
    translate([-(cable_d/2+0.3), y_c - cable_d/2 - 0.3, z_stop0-1]) cube([cable_d+0.6, 20, stop_t+2]);
    mcx_channel();
    cable_notch();
    for (h = holes) translate([h[0], -1, h[1]]) rotate([-90,0,0]) cylinder(d=m_clear, h=t+2);
    for (s=[-1,1]) translate([s*tie_x - 1.2, -1, tie_z-2.5]) cube([2.4, t+2, 5]);
  }
}

// =====================================================================
//  LID
// =====================================================================
module lid_body() {
  difference() {
    hull() {
      xz(y_front - t - 1.5, t) lid2d();
      xz(0.01, y_front - 0.01) offset(-1.5) lid2d();
    }
    xz(y_in - t + 1, t - 1) inner2d();
  }
  // słupki
  xz(y_in - t + 0.5, t) for (h = holes) pillar2d(h);
  // dociski dongla i gniazda
  rib_d = y_in - (t + dng_t + 0.1);
  if (rib_d > 0.4) xz(rib_d + 0.5, t + dng_t + 0.1) dng_ribs2d();
  rib_f = y_in - (t + fem_ped + fem_t + 0.1);
  if (rib_f > 0.4) xz(rib_f + 0.5, t + fem_ped + fem_t + 0.1) fem_ribs2d();
}

module front_keepout2d() {
  for (h = holes) offset(1.5) pillar2d(h);
  offset(1.2) dng_ribs2d();
  offset(1.2) fem_ribs2d();
}
module side_keepout2d(s) {
  // w (y,z)
  for (h = holes) if (sign(h[0]) == s) translate([0, h[1]-7]) square([50, 14]);
  if (s == mcx_side) translate([0, z_mcx - 7]) square([50, 200]);
}

module lid() {
  difference() {
    lid_body();
    // front
    xz(lid_t + 2, y_in - 1) difference() {
      lattice(-Wi + 1, Wi - 1, wall + 1.5, z_end - wall - 1.5);
      front_keepout2d();
    }
    // boki
    for (s=[-1,1]) yz(wall + 2, s > 0 ? Wi - 0.5 : -W/2 - 1.5) difference() {
      lattice(t + 3, y_in - 1.2, wall + 2, z_end - wall - 2);
      side_keepout2d(s);
    }
    mcx_channel();
    cable_notch();
    xz(1.8, t - 1) offset(0.25) rim2d();
    // śruby
    for (h = holes) {
      if (fastener == "M4") {
        translate([h[0], -1, h[1]]) rotate([-90,0,0]) cylinder(d=m_clear, h=y_front+2);
        nb = h[2] - 0.3 - nut_h;
        translate([h[0], nb, h[1]]) rotate([-90,0,0]) rotate([0,0,30])
          cylinder(d=nut_af/cos(30), h=y_front - nb + 1, $fn=6);
      } else {
        translate([h[0], -1, h[1]]) rotate([-90,0,0]) cylinder(d=pilot_d, h=min(h[2] + 2, y_front - 1) + 1);
      }
    }
  }
}

// =====================================================================
//  Zatrzask C (drukować w tej orientacji: oś rurki pionowo)
//  dolny: pierścień na dole; górny: ten sam detal obrócony do góry nogami
// =====================================================================
module clip() {
  ri = (pipe_d + clip_clr)/2;
  ro = ri + clip_wall;
  yc = -pad_t - ri - 0.5;
  op = 360 - clip_wrap;
  difference() {
    union() {
      translate([-W/2, -pad_t, 0]) cube([W, pad_t, ph]);
      hull() {
        translate([-9, -pad_t-0.01, 0]) cube([18, 0.02, clip_h]);
        translate([0, yc, 0]) cylinder(r=ro, h=clip_h);
      }
    }
    translate([0, yc, -1]) cylinder(r=ri, h=clip_h+2, $fn=128);
    translate([0, yc, -1]) linear_extrude(clip_h+2) wedge(op);
    translate([0, yc, -1]) linear_extrude(clip_h+2) intersection() {
      wedge(op + 40);
      difference() { circle(60); circle(ri + clip_wall*0.45); }
    }
    for (s=[-1,1]) translate([s*hole_x, 0, clip_h + 6]) rotate([90,0,0]) {
      cylinder(d=m_clear, h=50, center=true);
      translate([0,0,pad_t-cb_depth]) cylinder(d=head_d, h=40);
    }
  }
}

// =====================================================================
//  Adapter 1/4"-20 (zamiast zatrzasku)
// =====================================================================
module tripod() {
  naf = 11.4; nh = 5.9; bolt = 6.8; bd = 10;
  difference() {
    union() {
      translate([-W/2, -pad_t, 0]) cube([W, pad_t, ph]);
      hull() {
        translate([-10, -pad_t-0.01, 0]) cube([20, 0.02, clip_h]);
        translate([-8.5, -pad_t-bd, 0]) cube([17, bd, clip_h]);
      }
    }
    hull() for (z=[clip_h/2, -2]) translate([0, -pad_t-bd/2, z]) rotate([90,0,0]) rotate([0,0,30])
      cylinder(d=naf/cos(30), h=nh, center=true, $fn=6);
    translate([0, 0, clip_h/2]) rotate([90,0,0]) cylinder(d=bolt, h=50, center=true);
    for (s=[-1,1]) translate([s*hole_x, 0, clip_h + 6]) rotate([90,0,0]) {
      cylinder(d=m_clear, h=50, center=true);
      translate([0,0,pad_t-cb_depth]) cylinder(d=head_d, h=40);
    }
  }
}

// =====================================================================
//  Podgląd
// =====================================================================
module clips_placed() {
  translate([0, 0, hole_rows[0] - (clip_h + 6)]) clip();
  translate([0, 0, hole_rows[1] + (clip_h + 6)]) mirror([0,0,1]) clip();
}

module ghosts() {
  ri = (pipe_d + clip_clr)/2;
  yc = -pad_t - ri - 0.5;
  zb = hole_rows[1] + clip_h + 6 + 15;
  color("silver", 0.5) {
    translate([0, yc, -60]) cylinder(d=pipe_d, h=zb+60);
    translate([0, yc, zb]) rotate([90,0,0]) cylinder(d=pipe_d, h=120);
  }
  color("black")   translate([-dng_w/2, t, z_d0]) cube([dng_w, dng_t, dng_l]);
  color("dimgray") translate([-fem_w/2, t+fem_ped, z_fem0]) cube([fem_w, fem_t, fem_l]);
  color("dimgray") translate([0, y_c, -60]) cylinder(d=cable_d, h=60+z_fem0);
  color("green")   translate([-pcb_t/2, t, z_p]) cube([pcb_t, pcb_w, pcb_l]);
  color("gold")    translate([0, t+pcb_w/2, z_p-14]) cylinder(d=8, h=14);
  color("gold")    translate([mcx_side*(dng_w/2), y_c, z_mcx]) rotate([0, mcx_side*90, 0]) cylinder(d=5, h=6);
}

module assembly(ex=0) {
  color("orange") base();
  color("darkorange") translate([0, ex, 0]) lid();
  color("tomato") translate([0, -ex*0.6, 0]) clips_placed();
  if (ex == 0) ghosts();
}

module print_all() {
  translate([0, H, 0]) rotate([90,0,0]) base();
  translate([W + 8, z_end, y_front]) rotate([-90,0,0]) lid();
  for (i=[0:1]) translate([2*W + 18, 20 + i*40, 0]) clip();
  translate([2*W + 18, 110, 0]) tripod();
}

if      (part == "assembly")  assembly();
else if (part == "exploded")  assembly(30);
else if (part == "base")      rotate([90,0,0]) base();
else if (part == "lid")       translate([0,0,y_front]) rotate([-90,0,0]) lid();
else if (part == "clip")      clip();
else if (part == "tripod")    tripod();
else if (part == "print_all") print_all();
