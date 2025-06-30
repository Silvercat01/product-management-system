-- hány db van a megadott termékből összesen a raktárakban?
CREATE OR REPLACE FUNCTION termekdb (p_termek_azon IN NUMBER)
RETURN NUMBER
IS
    v_letezik NUMBER;
    v_osszes NUMBER;
BEGIN
    -- létezik-e ilyen termék
    SELECT COUNT(*)
    INTO v_letezik
    FROM r_termek
    WHERE termek_id = p_termek_azon;
    
    IF v_letezik = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nincs ilyen termék az adatbázisban.');
    END IF;
    
    -- hány ilyen termék van készleten?
    SELECT NVL(SUM(mennyiseg),0)
    INTO v_osszes
    FROM r_keszlet
    WHERE termek_id = p_termek_azon;
    
    RETURN v_osszes;
    
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('hiba  történt: ' || SQLERRM);
    RAISE;
END;
/

-- hány termék van a megadott raktárban?
CREATE OR REPLACE FUNCTION raktarban_levok_szama (p_raktar_azon IN NUMBER)
RETURN NUMBER
IS
    v_van_ilyen_raktar NUMBER;
    v_osszes NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_van_ilyen_raktar
    FROM r_raktar
    WHERE p_raktar_azon = raktar_id;
    
    IF v_van_ilyen_raktar = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'nincs ilyen raktár');
    END IF;
    
    SELECT NVL(SUM(mennyiseg),0)
    INTO v_osszes
    FROM r_keszlet
    WHERE p_raktar_azon = raktar_id;
    
    return v_osszes;
    
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('hiba  történt: ' || SQLERRM);
    RAISE;
END;
/

-- a megadott raktár kihasználtsága százalékosan
CREATE OR REPLACE FUNCTION raktar_kihasznaltsag (p_raktar_azon IN NUMBER)
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
    WHERE raktar_id = p_raktar_azon;
    
    FOR rec IN (
        SELECT mennyiseg
        FROM r_keszlet
        WHERE raktar_id = p_raktar_azon
    ) LOOP
        v_osszes_termek := v_osszes_termek + rec.mennyiseg;
    END LOOP;
    
    v_kihasznaltsag := ROUND((v_osszes_termek / v_kapacitas) * 100, 2);
    RETURN v_kihasznaltsag;
    
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('hiba  történt: ' || SQLERRM);
    RAISE;
END;
/