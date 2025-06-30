-- új rendelés létrehozása
CREATE OR REPLACE PROCEDURE uj_rendeles (
    p_ugyfel_id IN NUMBER,
    p_rendeles_datum IN DATE,
    p_rendeles_id OUT NUMBER
)
IS
    v_ugyfel_db NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_ugyfel_db
    FROM r_ugyfel
    WHERE ugyfel_id = p_ugyfel_id;
    
    -- létezik-e ilyen ügyfél
    IF v_ugyfel_db = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'nem létezik ilyen ügyfél');
    END IF;
    
    -- beszúrás az r_rendeles táblába
    INSERT INTO r_rendeles (rendeles_id, ugyfel_id, rendeles_datum)
    VALUES (r_rendeles_seq.NEXTVAL, p_ugyfel_id, p_rendeles_datum)
    RETURNING rendeles_id INTO p_rendeles_id;
    
    -- beszúrás az r_kifizetes táblába
    INSERT INTO r_kifizetes (rendeles_id) VALUES (p_rendeles_id);
    
    DBMS_OUTPUT.PUT_LINE('új rendelés ID:' || p_rendeles_id);
    
    COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('hiba  történt: ' || SQLERRM);
        RAISE;
        ROLLBACK;
END uj_rendeles;
/

-- új rendelés tétel létrehozása egy rendeléshez
CREATE OR REPLACE PROCEDURE uj_tetel (p_rendeles_id IN NUMBER, p_termek_id IN NUMBER, p_darabszam IN NUMBER)
IS
    v_rendeles_db NUMBER;
    v_termek_db NUMBER;
    v_elerheto NUMBER;
    v_maradek NUMBER := p_darabszam;
    v_levonando NUMBER;
BEGIN
    -- van-e ilyen rendelés
    SELECT COUNT(*)
    INTO v_rendeles_db
    FROM r_rendeles
    WHERE rendeles_id = p_rendeles_id;
    
    IF v_rendeles_db < 1 THEN
    RAISE_APPLICATION_ERROR(-20001, 'nincs ilyen rendelés');
    END IF;
    
    -- van-e ilyen termék
    SELECT COUNT(*)
    INTO v_termek_db
    FROM r_termek
    WHERE termek_id = p_termek_id;
    
    IF v_termek_db < 1 THEN
    RAISE_APPLICATION_ERROR(-20001, 'nincs ilyen termék');
    END IF;
    
    -- darabszám
    IF p_darabszam < 1 THEN
    RAISE_APPLICATION_ERROR(-20002, 'a darabszámnak 1-nél nagyobbnak kell lennie');
    END IF;
    
    -- elegendő készlet ellenőrzése
    SELECT NVL(SUM(mennyiseg), 0)
    INTO v_elerheto
    FROM r_keszlet
    WHERE termek_id = p_termek_id;
    
    IF termekdb(p_termek_id) < p_darabszam THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nincs elegendő készlet: csak ' || termekdb(p_termek_id) || ' db elérhető.');
    END IF;
    
    -- új rendeléstétel beszúrása
    INSERT INTO r_rendeles_tetel (rendeles_id, termek_id, darabszam) VALUES (p_rendeles_id, p_termek_id, p_darabszam);
    
    -- készlet csökkentése
    FOR rec IN (
        SELECT raktar_id, mennyiseg
        FROM r_keszlet
        WHERE termek_id = p_termek_id
        ORDER BY mennyiseg DESC
    ) LOOP
        EXIT WHEN v_maradek = 0;
        
        -- ha legalább annyi készlet van egy raktárban amennyi kell, levonjuk a kellő mennyiséget
        IF rec.mennyiseg >= v_maradek THEN
            v_levonando := v_maradek;
            UPDATE r_keszlet
            SET mennyiseg = mennyiseg - v_levonando
            WHERE raktar_id = rec.raktar_id AND termek_id = p_termek_id;
            v_maradek := 0;
        -- egyébként csak annyit vonunk le, amennyi rendelkezésre áll, majd megyünk a következő raktárra
        ELSE
            v_levonando := rec.mennyiseg;
            UPDATE r_keszlet
            SET mennyiseg = mennyiseg - v_levonando
            WHERE raktar_id = rec.raktar_id AND termek_id = p_termek_id;
            v_maradek := v_maradek - v_levonando;
        END IF;
    END LOOP;
    
    -- ahol 1 alá csökkenne a darabszám, ott töröljük a termék sorát a készlet táblából
    DELETE FROM r_keszlet WHERE mennyiseg < 1;
    
    DBMS_OUTPUT.PUT_LINE('rendelés tétel (' || p_termek_id || ') hozzáadva');
    
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('hiba történt: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
/

-- szállítási dátum hozzáadása egy rendeléshez
CREATE OR REPLACE PROCEDURE szallitasi_datum (p_rendeles_id IN NUMBER, p_szallitasi_datum IN DATE)
IS
    v_rendeles_db NUMBER;
    v_rendeles_datum DATE;
    v_szallitas_datum DATE;
BEGIN
    -- létezik-e ilyen rendelés
    SELECT COUNT(*)
    INTO v_rendeles_db
    FROM r_rendeles
    WHERE rendeles_id = p_rendeles_id;
    
    IF v_rendeles_db < 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'nincs ilyen rendelés');
    END IF;
    
    -- szállítási dátum ellenőrzése
    SELECT rendeles_datum
    INTO v_rendeles_datum
    FROM r_rendeles
    WHERE rendeles_id = p_rendeles_id;
    
    IF p_szallitasi_datum < v_rendeles_datum THEN
        RAISE_APPLICATION_ERROR(-20002, 'a szállítási dátum nem lehet hamarabb mint a rendelési dátum');
    END IF;
    
    -- szállítási dátum beállítása ha NULL
    SELECT szallitas_datum
    INTO v_szallitas_datum
    FROM r_rendeles
    WHERE rendeles_id = p_rendeles_id;
    
    IF v_szallitas_datum IS NULL THEN
        UPDATE r_rendeles
        SET szallitas_datum = p_szallitasi_datum
        WHERE rendeles_id = p_rendeles_id;
        DBMS_OUTPUT.PUT_LINE('szállítási dátum beállítva a rendeléshez');
    ELSE
        DBMS_OUTPUT.PUT_LINE('szállítási dátum már beállításra került a rendeléshez');
    END IF;
    
    COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('hiba történt: ' || SQLERRM);
        RAISE;
        ROLLBACK;
END;
/

-- a megadott rendelés kifizetési információinak frissítése
CREATE OR REPLACE PROCEDURE rendeles_frissites(p_rendeles_id IN NUMBER, p_datum DATE)
IS
    v_rendeles_db NUMBER;
    v_rendeles_datum DATE;
    v_statusz r_kifizetes.statusz%TYPE;
    v_kifizetes_datum DATE;
    v_osszeg NUMBER;
    v_uj_osszeg NUMBER;
BEGIN
    -- létezik-e a rendelés
    SELECT COUNT(*)
    INTO v_rendeles_db
    FROM r_kifizetes
    WHERE rendeles_id = p_rendeles_id;
    
    IF v_rendeles_db = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'nincs ilyen rendelés');
    END IF;

    -- dátum ellenőrzése
    SELECT rendeles_datum
    INTO v_rendeles_datum
    FROM r_rendeles
    WHERE rendeles_id = p_rendeles_id;
    
    IF p_datum < v_rendeles_datum THEN
        RAISE_APPLICATION_ERROR(-20002, 'a kifizetés dátuma nem lehet hamarabb mint a rendelés dátuma');
    END IF;
    
    -- státusz átállítása
    SELECT statusz
    INTO v_statusz
    FROM r_kifizetes
    WHERE rendeles_id = p_rendeles_id;
    
    IF v_statusz = 'Kifizetve' THEN
        DBMS_OUTPUT.PUT_LINE('a rendelés már kifizetésre került');
    ELSIF v_statusz = 'Folyamatban' THEN
        UPDATE r_kifizetes
        SET statusz = 'Kifizetve'
        WHERE rendeles_id = p_rendeles_id;
        DBMS_OUTPUT.PUT_LINE('a rendelés státusza átállítva a következőre: "Kifizetve"');
        COMMIT;
    ELSE DBMS_OUTPUT.PUT_LINE('ismeretlen rendelés státusz');
    END IF;
    
    -- fizetési dátum beállítása
    SELECT datum
    INTO v_kifizetes_datum
    FROM r_kifizetes
    WHERE rendeles_id = p_rendeles_id;
    
    IF v_kifizetes_datum IS NULL THEN
        UPDATE r_kifizetes
        SET datum = p_datum
        WHERE rendeles_id = p_rendeles_id;
        DBMS_OUTPUT.PUT_LINE('kifizetési dátum beállítva a következőre: ' || TO_CHAR(p_datum, 'YYYY-MM-DD'));
    ELSE
        DBMS_OUTPUT.PUT_LINE('a kifizetési dátum már beállításra került:  ' || TO_CHAR(v_kifizetes_datum, 'YYYY-MM-DD'));
    END IF;
    
    -- összeg beállítása
    SELECT osszeg
    INTO v_osszeg
    FROM r_kifizetes
    WHERE rendeles_id = p_rendeles_id;
    
    IF v_osszeg IS NULL THEN
        v_uj_osszeg := rendeles_ar(p_rendeles_id);

        UPDATE r_kifizetes
        SET osszeg = v_uj_osszeg
        WHERE rendeles_id = p_rendeles_id;

        DBMS_OUTPUT.PUT_LINE('a rendelés összege beállítva a következőre: ' || v_uj_osszeg);
    ELSE
        DBMS_OUTPUT.PUT_LINE('a rendelés összege már beállításra került: ' || v_osszeg);
    END IF;

    COMMIT;
    
    EXCEPTION
        WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('hiba  történt: ' || SQLERRM);
        RAISE;
        ROLLBACK;
END;
/