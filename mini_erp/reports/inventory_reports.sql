-- raktárak és a benne található termékek darabszáma
SELECT r.nev, SUM(k.mennyiseg) AS osszes
FROM r_raktar r
JOIN r_keszlet k ON r.raktar_id = k.raktar_id
GROUP BY r.nev
ORDER BY r.nev ASC;

-- termékek, amiket még egyszer sem rendeltek
SELECT t.termek_id, t.nev
FROM r_termek t
WHERE NOT EXISTS (
    SELECT 1
    FROM r_rendeles_tetel rt
    WHERE t.termek_id = rt.termek_id
);

-- a 3 leggyakrabban rendelt termék
SELECT rt.termek_id, t.nev, COUNT(*) AS db
FROM r_rendeles_tetel rt
JOIN r_termek t ON rt.termek_id = t.termek_id
GROUP BY rt.termek_id, t.nev
ORDER BY db DESC
FETCH FIRST 3 ROWS ONLY;

-- raktárak, ahol átlagon aluli a készletmennyiség
SELECT r.raktar_id, r.nev, SUM(k.mennyiseg) AS keszlet_mennyiseg
FROM r_raktar r
JOIN r_keszlet k ON r.raktar_id = k.raktar_id
GROUP BY r.raktar_id, r.nev
HAVING SUM(k.mennyiseg) < (
    SELECT AVG(keszlet_mennyiseg) AS atlag
    FROM (
        SELECT SUM(mennyiseg) AS keszlet_mennyiseg
        FROM r_keszlet
        GROUP BY raktar_id
    )
);