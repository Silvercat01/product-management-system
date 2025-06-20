INSERT INTO r_ugyfel (ugyfel_id, nev, email) VALUES (1, 'Kovács Anna', 'kovacsanna03@example.com');
INSERT INTO r_ugyfel (ugyfel_id, nev, email) VALUES (2, 'Juhász Lilla', 'lilla.juhasz@example.com');
INSERT INTO r_ugyfel (ugyfel_id, nev, email) VALUES (3, 'Szabó Péter', 'szabopeti82@example.com');
INSERT INTO r_ugyfel (ugyfel_id, nev, email) VALUES (4, 'Nagy Balázs', 'balazs.nagy@example.com');

INSERT INTO r_raktar (raktar_id, nev, cim, kapacitas) VALUES (1, 'Soroksári raktár', 'Budapest XXIII', 100);
INSERT INTO r_raktar (raktar_id, nev, cim, kapacitas) VALUES (2, 'Budaörsi raktár', 'Budaörs', 80);
INSERT INTO r_raktar (raktar_id, nev, cim, kapacitas) VALUES (3, 'Csepeli raktár', 'Budapest XXI', 60);

INSERT INTO r_termek (termek_id, nev, ar, kategoria) VALUES (1, 'Dell Laptop', 370000, 'laptop');
INSERT INTO r_termek (termek_id, nev, ar, kategoria) VALUES (2, 'LG tv', 170000, 'tv');
INSERT INTO r_termek (termek_id, nev, ar, kategoria) VALUES (3, 'Sony tv', 150000, 'tv');
INSERT INTO r_termek (termek_id, nev, ar, kategoria) VALUES (4, 'Lenovo Laptop', 180000, 'laptop');
INSERT INTO r_termek (termek_id, nev, ar, kategoria) VALUES (5, 'Logitech egér', 6500, 'egér');
INSERT INTO r_termek (termek_id, nev, ar, kategoria) VALUES (6, 'Gembird egér', 1200, 'egér');

INSERT INTO r_rendeles (rendeles_id, ugyfel_id, rendeles_datum, szallitas_datum) VALUES (1, 1, DATE '2025-02-11', DATE '2025-02-16');
INSERT INTO r_rendeles (rendeles_id, ugyfel_id, rendeles_datum, szallitas_datum) VALUES (2, 3, DATE '2025-03-21', DATE '2025-03-23');
INSERT INTO r_rendeles (rendeles_id, ugyfel_id, rendeles_datum, szallitas_datum) VALUES (3, 4, DATE '2025-04-08', DATE '2025-04-19');

INSERT INTO r_rendeles_tetel (rendeles_id, termek_id, darabszam) VALUES (1, 2, 1);
INSERT INTO r_rendeles_tetel (rendeles_id, termek_id, darabszam) VALUES (1, 6, 2);
INSERT INTO r_rendeles_tetel (rendeles_id, termek_id, darabszam) VALUES (2, 1, 1);
INSERT INTO r_rendeles_tetel (rendeles_id, termek_id, darabszam) VALUES (3, 4, 1);

INSERT INTO r_kifizetes (rendeles_id, statusz) VALUES (1, 'Kifizetve');
INSERT INTO r_kifizetes (rendeles_id, statusz) VALUES (2, 'Kifizetve');
INSERT INTO r_kifizetes (rendeles_id, statusz) VALUES (3, 'Folyamatban');

INSERT INTO r_keszlet (raktar_id, termek_id, mennyiseg) VALUES (1, 1, 23);
INSERT INTO r_keszlet (raktar_id, termek_id, mennyiseg) VALUES (1, 2, 15);
INSERT INTO r_keszlet (raktar_id, termek_id, mennyiseg) VALUES (2, 3, 2);
INSERT INTO r_keszlet (raktar_id, termek_id, mennyiseg) VALUES (2, 1, 18);
INSERT INTO r_keszlet (raktar_id, termek_id, mennyiseg) VALUES (2, 4, 50);
INSERT INTO r_keszlet (raktar_id, termek_id, mennyiseg) VALUES (3, 5, 35);
INSERT INTO r_keszlet (raktar_id, termek_id, mennyiseg) VALUES (3, 6, 10);
