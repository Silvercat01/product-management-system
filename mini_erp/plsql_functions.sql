-- hány db van a megadott termékből összesen a raktárakban?
SET SERVEROUTPUT ON;
CREATE OR REPLACE FUNCTION termekdb (termek_azon IN NUMBER)
RETURN NUMBER
IS
    v_letezik NUMBER;
    v_osszes NUMBER;
BEGIN
    -- létezik-e ilyen termék
    SELECT COUNT(*)
    INTO v_letezik
    FROM r_termek
    WHERE termek_id = termek_azon;
    
    IF v_letezik = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nincs ilyen termék az adatbázisban.');
    END IF;
    
    -- hány ilyen termék van készleten?
    SELECT NVL(SUM(mennyiseg),0)
    INTO v_osszes
    FROM r_keszlet
    WHERE termek_id = termek_azon;
    
    RETURN v_osszes;
END;
/

-- hány termék van a megadott raktárban?
CREATE OR REPLACE FUNCTION raktarban_levok_szama (raktar_azon IN NUMBER)
RETURN NUMBER
IS
    v_van_ilyen_raktar NUMBER;
    v_osszes NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_van_ilyen_raktar
    FROM r_raktar
    WHERE raktar_azon = raktar_id;
    
    IF v_van_ilyen_raktar = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'nincs ilyen raktár');
    END IF;
    
    SELECT NVL(SUM(mennyiseg),0)
    INTO v_osszes
    FROM r_keszlet
    WHERE raktar_azon = raktar_id;
    
    return v_osszes;
END;
/

-- egy rendelés árának kiszámítása
CREATE OR REPLACE FUNCTION rendeles_ar (rendeles_azon IN NUMBER)
RETURN NUMBER
IS
    v_osszeg NUMBER;
    v_termek_ar NUMBER;
BEGIN
    v_osszeg := 0;
    FOR rec IN (
        SELECT termek_id, darabszam
        FROM r_rendeles_tetel
        WHERE rendeles_id = rendeles_azon
    ) LOOP
        SELECT ar
        INTO v_termek_ar
        FROM r_termek
        WHERE termek_id = rec.termek_id;
        v_osszeg := v_osszeg + v_termek_ar * rec.darabszam;
    END LOOP;
    RETURN v_osszeg;
END;
/

-- a megadott raktár kihasználtsága százalékosan
CREATE OR REPLACE FUNCTION raktar_kihasznaltsag (raktar_azon IN NUMBER)
RETURN NUMBER
IS
    v_kapacitas r_raktar.kapacitas%TYPE;
    v_osszes_termek NUMBER;
    v_kihasznaltsag NUMBER;
BEGIN
    v_osszes_termek := 0;

    SELECT kapacitas
    INTO v_kapacitas
    FROM r_raktar
    WHERE raktar_id = raktar_azon;
    
    FOR rec IN (
        SELECT mennyiseg
        FROM r_keszlet
        WHERE raktar_id = raktar_azon
    ) LOOP
        v_osszes_termek := v_osszes_termek + rec.mennyiseg;
    END LOOP;
    
    v_kihasznaltsag := ROUND((v_osszes_termek / v_kapacitas) * 100, 2);
    RETURN v_kihasznaltsag;
END;
/

-- legnépszerűbb (legtöbbször rendelt) termék
CREATE OR REPLACE FUNCTION legnepszerubb_termek
RETURN NUMBER
IS
    v_termek_id NUMBER;
BEGIN
    SELECT termek_id
    INTO v_termek_id
    FROM (
        SELECT termek_id, SUM(darabszam) AS osszes
        FROM r_rendeles_tetel
        GROUP BY termek_id
        ORDER BY osszes DESC
    )
    FETCH FIRST 1 ROW ONLY;
    RETURN v_termek_id;
END;
/