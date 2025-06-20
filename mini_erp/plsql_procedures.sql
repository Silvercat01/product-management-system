-- új rendelés létrehozása
CREATE OR REPLACE PROCEDURE uj_rendeles (
    p_ugyfel_id IN NUMBER,
    p_rendeles_datum IN DATE,
    p_szallitas_datum IN DATE,
    p_rendeles_id OUT NUMBER
)
IS
    v_ugyfel_db NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_ugyfel_db
    FROM r_ugyfel
    WHERE ugyfel_id = p_ugyfel_id;
    
    -- ellenőrzések
    IF v_ugyfel_db = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'nem létezik ilyen ügyfél');
    END IF;
    
    IF p_rendeles_datum > p_szallitas_datum THEN
        RAISE_APPLICATION_ERROR(-20001, 'a szállítási dátum nem lehet hamarabb mint a rendelési dátum');
    END IF;
    
    -- beszúrás
    INSERT INTO r_rendeles (rendeles_id, ugyfel_id, rendeles_datum, szallitas_datum)
    VALUES (r_rendeles_seq.NEXTVAL, p_ugyfel_id, p_rendeles_datum, p_szallitas_datum)
    RETURNING rendeles_id INTO p_rendeles_id;
    
    DBMS_OUTPUT.PUT_LINE('új rendelés ID:' || p_rendeles_id);
    
    COMMIT;
    
    -- hibakezelés
    EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('hiba  történt: ' || SQLERRM);
        RAISE;
END uj_rendeles;
/

-- a megadott rendelés státuszának frissítése
CREATE OR REPLACE PROCEDURE rendeles_frissites(rendeles_azon IN NUMBER)
IS
    v_rendeles_db NUMBER;
    v_statusz r_kifizetes.statusz%TYPE;
BEGIN
    -- létezik-e a rendelés
    SELECT COUNT(*)
    INTO v_rendeles_db
    FROM r_kifizetes
    WHERE rendeles_id = rendeles_azon;
    
    IF v_rendeles_db = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'nincs ilyen ID-val rendelkező rendelés');
    END IF;

    -- státusz átállítása
    SELECT statusz
    INTO v_statusz
    FROM r_kifizetes
    WHERE rendeles_id = rendeles_azon;
    
    IF v_statusz = 'Kifizetve' THEN
        DBMS_OUTPUT.PUT_LINE('a rendelés már kifizetésre került');
    ELSIF v_statusz = 'Folyamatban' THEN
        UPDATE r_kifizetes
        SET r_kifizetes.statusz = 'Kifizetve';
        DBMS_OUTPUT.PUT_LINE('a rendelés státusza átállítva a következőre: "Kifizetve"');
        COMMIT;
    ELSE DBMS_OUTPUT.PUT_LINE('ismeretlen rendelés státusz');
    END IF;
END rendeles_frissites;
/

-- a raktár(ak) kiírása ahol a készlet a kapacitás 10%-a alatt van
CREATE OR REPLACE PROCEDURE keves_termek_figyeles
IS
    v_kapacitas_minimum NUMBER;
    v_osszes NUMBER;
BEGIN
    FOR rec IN (
        SELECT kapacitas, raktar_id
        FROM r_raktar
    ) LOOP
        v_kapacitas_minimum := rec.kapacitas * 0.1;
        SELECT SUM(mennyiseg)
        INTO v_osszes
        FROM r_keszlet
        WHERE raktar_id = rec.raktar_id;
        
        IF v_osszes < v_kapacitas_minimum THEN
            DBMS_OUTPUT.PUT_LINE('a(z) alábbi ID-val rendelkező raktárban alacsony a készlet: ' || rec.raktar_id);
        END IF;
    END LOOP;
END keves_termek_figyeles;
/

-- adott termék áthelyezése egy raktárból egy másikba
CREATE OR REPLACE PROCEDURE termek_athelyezes (p_termek_azon IN NUMBER, p_mennyiseg IN NUMBER, p_raktar1_azon IN NUMBER, p_raktar2_azon IN NUMBER)
IS
    v_termek_db NUMBER;
    v_raktar1_db NUMBER;
    v_raktar2_db NUMBER;
    v_raktar1_id NUMBER;
    v_raktar2_id NUMBER;
    v_mennyiseg NUMBER;
    v_mennyiseg_celraktar NUMBER;
    v_mennyiseg_forrasraktar NUMBER;
BEGIN
    -- létezik-e a termék
    SELECT COUNT(*)
    INTO v_termek_db
    FROM r_termek
    WHERE termek_id = p_termek_azon;
    
    IF v_termek_db = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'nincs ilyen termék');
    END IF;

    -- létezik-e az egyik raktár
    SELECT COUNT(*)
    INTO v_raktar1_db
    FROM r_raktar
    WHERE raktar_id = p_raktar1_azon;
    
    IF v_raktar1_db = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'nem létezik a küldő raktár');
    END IF;
    
    -- létezik-e a másik raktár
    SELECT COUNT(*)
    INTO v_raktar2_db
    FROM r_raktar
    WHERE raktar_id = p_raktar2_azon;
    
    IF v_raktar2_db = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'nem létezik a fogadó raktár');
    END IF;
    
    -- nem ugyanaz-e a két raktár
    SELECT raktar_id
    INTO v_raktar1_id
    FROM r_raktar
    WHERE raktar_id = p_raktar1_azon;
    
    SELECT raktar_id
    INTO v_raktar2_id
    FROM r_raktar
    WHERE raktar_id = p_raktar2_azon;
    
    IF v_raktar1_id = v_raktar2_id THEN
        RAISE_APPLICATION_ERROR(-20001, 'a két raktár nem lehet ugyanaz');
    END IF;
    
    -- van-e elegendő mennyiség a termékből
    SELECT mennyiseg
    INTO v_mennyiseg
    FROM r_keszlet
    WHERE raktar_id = p_raktar1_azon AND termek_id = p_termek_azon;
    
    IF v_mennyiseg < p_mennyiseg OR v_mennyiseg IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'nincs elegendő mennyiség a termékből, kért mennyiség: ' || p_mennyiseg || ', rendelkezésre álló mennyiség: ' || v_mennyiseg);
    END IF;
    
    -- ha már van ilyen termék a célraktárban, akkor a mennyiséget növeljük
    SELECT mennyiseg
    INTO v_mennyiseg_celraktar
    FROM r_keszlet
    WHERE raktar_id = p_raktar2_azon AND termek_id = p_termek_azon;
    
    IF v_mennyiseg_celraktar IS NOT NULL THEN
        UPDATE r_keszlet
        SET mennyiseg = v_mennyiseg_celraktar + p_mennyiseg
        WHERE raktar_id = p_raktar2_azon AND termek_id = p_termek_azon;
        DBMS_OUTPUT.PUT_LINE('a célraktárban már volt ilyen termék, a mennyisége frissítésre került');
    -- ha nincs még ilyen termék a célraktárban, akkor hozzáadjuk a terméket
    ELSE
        INSERT INTO r_keszlet (raktar_id, termek_id, mennyiseg) VALUES (p_raktar2_azon, p_termek_azon, p_mennyiseg);
        DBMS_OUTPUT.PUT_LINE('a célraktárban még nem volt ilyen termék, a termék hozzáadásra került');
    END IF;
    
    -- kivonjuk a mennyiséget forrásraktárból
    SELECT mennyiseg
    INTO v_mennyiseg_forrasraktar
    FROM r_keszlet
    WHERE raktar_id = p_raktar1_azon AND termek_id = p_termek_azon;

    UPDATE r_keszlet
    SET mennyiseg = v_mennyiseg_forrasraktar - p_mennyiseg
    WHERE raktar_id = p_raktar1_azon AND termek_id = p_termek_azon;
    DBMS_OUTPUT.PUT_LINE('a forrásraktárból levonásra került a mennyiség');
    
    -- ha a mennyiség így 0 lesz vagy az alá menne, kitöröljük az adott sort
    DELETE FROM r_keszlet
    WHERE raktar_id = p_raktar1_azon AND termek_id = p_termek_azon AND mennyiseg < 1;
    
    COMMIT;
END termek_athelyezes;
/