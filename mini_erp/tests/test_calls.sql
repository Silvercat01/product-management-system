SET SERVEROUTPUT ON;

-- hány db van a megadott termékből összesen a raktárakban?
BEGIN
    DBMS_OUTPUT.PUT_LINE(termekdb(3) || 'db van készleten a termékből');
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
/

-- rendelések, ahol a rendelési és szállítási idő között több mint 7 nap telt el
DECLARE
    v_kurzor SYS_REFCURSOR;
    v_rendeles_id NUMBER;
    v_rendeles_datum DATE;
    v_szallitas_datum DATE;
BEGIN
    v_kurzor := kesedelmes_rendelesek;
    DBMS_OUTPUT.PUT_LINE('késedelmes rendelések:');
    LOOP
        FETCH v_kurzor INTO v_rendeles_id, v_rendeles_datum, v_szallitas_datum;
        EXIT WHEN v_kurzor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('rendelés ID: ' || v_rendeles_id || ', rendelési dátum: ' || v_rendeles_datum || ', szállítási dátum: ' || v_szallitas_datum);
    END LOOP;
    CLOSE v_kurzor;
END;
/

-- új rendelés és rendelés tételek létrehozása
DECLARE
    v_rendeles_id NUMBER;
BEGIN
    uj_rendeles(3, SYSDATE, v_rendeles_id);
    uj_tetel(v_rendeles_id, 2, 1);
    uj_tetel(v_rendeles_id, 3, 1);
END;
/

-- szállítási dátum hozzáadása egy rendeléshez
BEGIN
    szallitasi_datum(16, SYSDATE);
END;
/

-- a megadott rendelés kifizetési információinak frissítése
BEGIN
    rendeles_frissites(16, SYSDATE);
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

-- ügyfelek, akik több mint 30 napja inaktívak
BEGIN
    inaktiv_ugyfelek;
END;
/