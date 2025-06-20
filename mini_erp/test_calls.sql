SET SERVEROUTPUT ON;

-- hány db van a megadott termékből összesen a raktárakban?
BEGIN
    DBMS_OUTPUT.PUT_LINE(termekdb(2) || 'db van készleten a termékből');
END;
/

-- hány termék van a megadott raktárban?
DECLARE
    v_raktar_nev r_raktar.nev%TYPE;
BEGIN
    SELECT nev
    INTO v_raktar_nev
    FROM r_raktar
    WHERE raktar_id = 1;
    
    DBMS_OUTPUT.PUT_LINE('a(z) ' || v_raktar_nev || 'ban/ben ' || raktarban_levok_szama(1) || 'db termék van');
END;
/

-- egy rendelés árának kiszámítása
BEGIN
    DBMS_OUTPUT.PUT_LINE('az 1 ID-val rendelkező rendelés összege: ' || rendeles_ar(1));
END;
/

-- a megadott raktár kihasználtsága százalékosan
DECLARE
    v_raktar_nev r_raktar.nev%TYPE;
BEGIN
    SELECT nev
    INTO v_raktar_nev
    FROM r_raktar
    WHERE raktar_id = 2;
    
    DBMS_OUTPUT.PUT_LINE(v_raktar_nev || ' kihasználtsága: ' || raktar_kihasznaltsag(2) || '%');
END;
/

-- legnépszerűbb (legtöbbször rendelt) termék
BEGIN
    DBMS_OUTPUT.PUT_LINE('a legnépszerűbb termék ID-ja: ' || legnepszerubb_termek);
END;

-- új rendelés létrehozása
DECLARE
    v_uj_rendeles_id NUMBER;
BEGIN
    uj_rendeles(3, DATE '2025-05-20', DATE '2025-05-25', v_uj_rendeles_id);
END;
/

-- a megadott rendelés státuszának frissítése
BEGIN
    rendeles_frissites(3);
END;
/

-- a raktár(ak) kiírása ahol a készlet a kapacitás 10%-a alatt van
BEGIN
    keves_termek_figyeles;
END;
/

-- adott termék áthelyezése egy raktárból egy másikba
BEGIN
    termek_athelyezes(1, 17, 1, 2);
END;
/
