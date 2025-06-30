-- egy rendelés árának kiszámítása
CREATE OR REPLACE FUNCTION rendeles_ar (p_rendeles_azon IN NUMBER)
RETURN NUMBER
IS
    v_osszeg NUMBER;
    v_termek_ar NUMBER;
BEGIN
    v_osszeg := 0;
    FOR rec IN (
        SELECT termek_id, darabszam
        FROM r_rendeles_tetel
        WHERE rendeles_id = p_rendeles_azon
    ) LOOP
        SELECT ar
        INTO v_termek_ar
        FROM r_termek
        WHERE termek_id = rec.termek_id;
        v_osszeg := v_osszeg + v_termek_ar * rec.darabszam;
    END LOOP;
    
    RETURN v_osszeg;
    
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('hiba  történt: ' || SQLERRM);
    RAISE;
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
    
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('hiba  történt: ' || SQLERRM);
    RAISE;
END;
/

-- rendelések, ahol a rendelési és szállítási idő között több mint 7 nap telt el
CREATE OR REPLACE FUNCTION kesedelmes_rendelesek
RETURN SYS_REFCURSOR
IS
    c_kesedelmesek SYS_REFCURSOR;
BEGIN
    OPEN c_kesedelmesek FOR
        SELECT rendeles_id, rendeles_datum, szallitas_datum
        FROM r_rendeles
        WHERE szallitas_datum - rendeles_datum > 7;
    RETURN c_kesedelmesek;
    
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('hiba  történt: ' || SQLERRM);
    RAISE;
END;
/