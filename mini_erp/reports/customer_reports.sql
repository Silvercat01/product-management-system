-- vevők és hány különböző terméket rendeltek eddig
SELECT u.ugyfel_id, u.nev, COUNT(DISTINCT rt.termek_id) AS kulonbozo_db
FROM r_ugyfel u
JOIN r_rendeles r ON u.ugyfel_id = r.ugyfel_id
JOIN r_rendeles_tetel rt ON r.rendeles_id = rt.rendeles_id
GROUP BY u.ugyfel_id, u.nev
ORDER BY u.nev ASC, kulonbozo_db ASC;