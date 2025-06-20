DROP TABLE r_keszlet;
DROP TABLE r_kifizetes;
DROP TABLE r_rendeles_tetel;
DROP TABLE r_rendeles;
DROP TABLE r_termek;
DROP TABLE r_ugyfel;
DROP TABLE r_raktar;

CREATE TABLE r_ugyfel (
    ugyfel_id       NUMBER PRIMARY KEY,
    nev             VARCHAR2(100),
    email           VARCHAR2(100)
);

CREATE TABLE r_raktar (
    raktar_id       NUMBER PRIMARY KEY,
    nev             VARCHAR2(100),
    cim             VARCHAR2(100),
    kapacitas       NUMBER
);

CREATE TABLE r_termek(
    termek_id       NUMBER PRIMARY KEY,
    nev             VARCHAR2(100),
    ar              NUMBER,
    kategoria       VARCHAR2(50)
);

CREATE TABLE r_rendeles(
    rendeles_id     NUMBER PRIMARY KEY,
    ugyfel_id       NUMBER,
    rendeles_datum  DATE,
    szallitas_datum DATE,
    FOREIGN KEY (ugyfel_id) REFERENCES r_ugyfel (ugyfel_id)
);

CREATE TABLE r_rendeles_tetel(
    rendeles_id     NUMBER,
    termek_id       NUMBER,
    darabszam       NUMBER,
    PRIMARY KEY (rendeles_id, termek_id),
    FOREIGN KEY (rendeles_id) REFERENCES r_rendeles (rendeles_id),
    FOREIGN KEY (termek_id) REFERENCES r_termek (termek_id)
);

CREATE TABLE r_kifizetes (
    rendeles_id     NUMBER PRIMARY KEY,
    statusz         VARCHAR2(50),
    FOREIGN KEY (rendeles_id) REFERENCES r_rendeles (rendeles_id)
);

CREATE TABLE r_keszlet(
    raktar_id       NUMBER,
    termek_id       NUMBER,
    mennyiseg       NUMBER,
    PRIMARY KEY (raktar_id, termek_id),
    FOREIGN KEY (raktar_id) REFERENCES r_raktar (raktar_id),
    FOREIGN KEY (termek_id) REFERENCES r_termek (termek_id)
);

CREATE SEQUENCE r_rendeles_seq START WITH 4 INCREMENT BY 1 NOCACHE NOCYCLE;
/