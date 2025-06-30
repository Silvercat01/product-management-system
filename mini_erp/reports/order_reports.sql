-- rendelések kilistázása
SELECT u.nev, r.rendeles_datum, k.statusz
FROM r_ugyfel u
JOIN r_rendeles r ON u.ugyfel_id = r.ugyfel_id
JOIN r_kifizetes k ON k.rendeles_id = r.rendeles_id
ORDER BY u.nev ASC, r.rendeles_datum ASC;
