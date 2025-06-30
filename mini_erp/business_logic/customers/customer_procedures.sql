-- ügyfelek, akik több mint 30 napja inaktívak
CREATE OR REPLACE PROCEDURE inaktiv_ugyfelek
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('inaktív ügyfelek:');

    FOR rec IN (
        SELECT u.ugyfel_id, u.nev
        FROM r_ugyfel u
        WHERE NOT EXISTS (
            SELECT 1
            FROM r_rendeles r
            JOIN r_kifizetes k ON r.rendeles_id = k.rendeles_id
            WHERE r.ugyfel_id = u.ugyfel_id
            AND (
                r.rendeles_datum >= SYSDATE - 30
                OR (k.datum IS NOT NULL AND k.datum >= SYSDATE - 30)
            )
        )
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('id: ' || rec.ugyfel_id || ', név: ' || rec.nev);
    END LOOP;
    
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('hiba  történt: ' || SQLERRM);
    RAISE;
END;