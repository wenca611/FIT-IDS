-- IDS 2018/2019 ------------------
-- PROJEKT - POSLEDNI CAST
-- xvorli01, xpastu02

-- UPRAVA FORMATU CASU--

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS';
ALTER SESSION SET time_zone = 'CET';

-- VYTVORENI SEKVENCI --

DROP SEQUENCE SQ_Zamestnanec;
DROP SEQUENCE SQ_Rezervace;
DROP SEQUENCE SQ_Objednavka;
DROP SEQUENCE SQ_Zaznam_o_platbe;
DROP SEQUENCE SQ_Stul;

CREATE SEQUENCE SQ_Zamestnanec			  START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SQ_Rezervace			    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SQ_Objednavka			    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SQ_Zaznam_o_platbe		START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SQ_Stul           		START WITH 1 INCREMENT BY 1;

-- VYTVORENI INDEXU

-- explicitní vytvoření alespoň jednoho indexu tak, aby pomohl optimalizovat zpracování dotazů, přičemž musí být uveden
-- také příslušný dotaz, na který má index vliv, a v dokumentaci popsán způsob využití indexu v tomto dotazy

DROP INDEX Testovaci_index;

CREATE INDEX Testovaci_index ON Zamestnanec (Prijmeni);

-- VYTVORENI TABULEK --

DROP TABLE Zamestnanec CASCADE CONSTRAINTS;
DROP TABLE Rezervace CASCADE CONSTRAINTS;
DROP TABLE Objednavka CASCADE CONSTRAINTS;
DROP TABLE Polozka_objednavky CASCADE CONSTRAINTS;
DROP TABLE Surovina CASCADE CONSTRAINTS;
DROP TABLE Stul CASCADE CONSTRAINTS;
DROP TABLE Zaznam_o_platbe CASCADE CONSTRAINTS;
DROP TABLE Sprava_rezervace CASCADE CONSTRAINTS;
DROP TABLE Rezervovany_stul CASCADE CONSTRAINTS;
DROP TABLE Stul_objednavky CASCADE CONSTRAINTS;
DROP TABLE Sprava_objednavky CASCADE CONSTRAINTS;
DROP TABLE Obsahuje CASCADE CONSTRAINTS;
DROP TABLE Obsah_objednavky CASCADE CONSTRAINTS;

CREATE TABLE Zamestnanec (
  Cislo_zamestnance   INTEGER         NOT NULL,
  Jmeno               VARCHAR(40)     NOT NULL CHECK(LENGTH(TRIM(Jmeno))>=2),
  Prijmeni            VARCHAR(40)     NOT NULL CHECK(LENGTH(TRIM(Prijmeni))>=2),
  Rodne_cislo         VARCHAR(11)     NOT NULL CHECK(MOD(CAST(REPLACE(Rodne_cislo, '/', '') AS INTEGER), 11 ) = 0) UNIQUE,
  Telefon             VARCHAR(13)     UNIQUE,
  Adresa              VARCHAR(100)
);

CREATE TABLE Rezervace (
  ID_rezervace        INTEGER         DEFAULT SQ_Rezervace.nextval  NOT NULL,
  Pocet_osob          INTEGER         CHECK(Pocet_osob<500) NOT NULL,
  Datum_cas           DATE            NOT NULL,
  Jmeno               VARCHAR(40)     NOT NULL CHECK(LENGTH(TRIM(Jmeno))>=2)
);

CREATE TABLE Objednavka (
  ID_objednavky       INTEGER         DEFAULT SQ_Objednavka.nextval  NOT NULL,
  Stav                CHAR(1)         DEFAULT 'P' NOT NULL CHECK(Stav='D' OR Stav='Z' OR Stav='P'), -- D=Dokoncena, Z=Zrusena, P=Probihajici
  ID_rezervace        INTEGER UNIQUE
);

CREATE TABLE Polozka_objednavky (
  Nazev_polozky       VARCHAR(100)    NOT NULL,
  Cena                DECIMAL(7,2)    NOT NULL CHECK(Cena>0),
  Porce               INTEGER         NOT NULL,
  Druh                CHAR(1)         NOT NULL CHECK (Druh='P' OR Druh='J') -- J=Jidlo, P=Piti
);

CREATE TABLE Surovina (
  Nazev_suroviny      VARCHAR(100)    NOT NULL,
  Cena                DECIMAL(7,2)    NOT NULL CHECK(Cena>0),
  Puvod               VARCHAR(100),
  Alergeny            VARCHAR(100)
);

CREATE TABLE Stul (
  Cislo_stolu         INTEGER         DEFAULT SQ_Stul.nextval  NOT NULL,
  Pocet_mist          INTEGER         NOT NULL CHECK(Pocet_mist>0 AND Pocet_mist<=10),
  Mistnost            VARCHAR(30)     NOT NULL CHECK(LENGTH(TRIM(Mistnost))>=1)
);

CREATE TABLE Zaznam_o_platbe (
  ID_Platby           INTEGER         DEFAULT SQ_Zaznam_o_platbe.nextval  NOT NULL,
  Datum_cas           DATE            NOT NULL,
  Druh_platby         CHAR(1)         CHECK(Druh_platby ='K' OR Druh_platby ='H' OR Druh_platby ='S'), -- K=Platebni karta, H=Hotovost, S=Stravenky
  Celkova_cena        DECIMAL(9,2)    NOT NULL CHECK(Celkova_cena>0),
  ID_Objednavky       INTEGER NOT NULL UNIQUE,
  Cislo_zamestnance   INTEGER NOT NULL
);

-- VYTVORENI TABULEK RELACE --

CREATE TABLE Sprava_rezervace (
  Cislo_zamestnance   INTEGER NOT NULL,
  ID_rezervace        INTEGER
);

CREATE TABLE Rezervovany_stul (
  Cislo_stolu         INTEGER,
  ID_rezervace        INTEGER
);

CREATE TABLE Stul_objednavky (
  Cislo_stolu         INTEGER,
  ID_objednavky       INTEGER
);

CREATE TABLE Sprava_objednavky (
  Cislo_zamestnance   INTEGER NOT NULL,
  ID_objednavky       INTEGER
);

CREATE TABLE Obsahuje (
  Nazev_suroviny   VARCHAR(100),
  Nazev_polozky    VARCHAR(100)
);

CREATE TABLE Obsah_objednavky (
  ID_objednavky     INTEGER,
  Nazev_polozky     VARCHAR(100)
);

-- PRIMARNI KLICE --

ALTER TABLE Zamestnanec ADD CONSTRAINT PK_Zamestnanec PRIMARY KEY (Cislo_zamestnance);
ALTER TABLE Rezervace ADD CONSTRAINT PK_Rezervace PRIMARY KEY (ID_rezervace);
ALTER TABLE Objednavka ADD CONSTRAINT PK_Objednavka PRIMARY KEY (ID_objednavky);
ALTER TABLE Polozka_objednavky ADD CONSTRAINT PK_Polozka PRIMARY KEY (Nazev_polozky);
ALTER TABLE Surovina ADD CONSTRAINT PK_Surovina PRIMARY KEY (Nazev_suroviny);
ALTER TABLE Stul ADD CONSTRAINT PK_Stul PRIMARY KEY (Cislo_stolu);
ALTER TABLE Zaznam_o_platbe ADD CONSTRAINT PK_Platba PRIMARY KEY (ID_Platby);

ALTER TABLE Sprava_rezervace ADD CONSTRAINT PK_Sprava_rezervace PRIMARY KEY (Cislo_zamestnance,ID_rezervace);
ALTER TABLE Rezervovany_stul ADD CONSTRAINT PK_Rezervovany_stul PRIMARY KEY (Cislo_stolu,ID_rezervace);
ALTER TABLE Stul_objednavky ADD CONSTRAINT PK_Stul_objednavky PRIMARY KEY (Cislo_stolu,ID_objednavky);
ALTER TABLE Sprava_objednavky ADD CONSTRAINT PK_Sprava_objednavky PRIMARY KEY (Cislo_zamestnance,ID_objednavky);
ALTER TABLE Obsahuje ADD CONSTRAINT PK_Obsahuje PRIMARY KEY (Nazev_suroviny,Nazev_polozky);
ALTER TABLE Obsah_objednavky ADD CONSTRAINT PK_Obsah_objednavky PRIMARY KEY (ID_objednavky,NAzev_polozky);

-- CIZI KLICE --

ALTER TABLE Objednavka ADD CONSTRAINT FK_O_Platba FOREIGN KEY (ID_rezervace) REFERENCES Rezervace(ID_rezervace);

ALTER TABLE Zaznam_o_platbe ADD CONSTRAINT FK_Z_Objednavka FOREIGN KEY (ID_Objednavky) REFERENCES Objednavka(ID_objednavky);
ALTER TABLE Zaznam_o_platbe ADD CONSTRAINT FK_Z_Zamestnanec FOREIGN KEY (Cislo_zamestnance) REFERENCES Zamestnanec(Cislo_zamestnance);

ALTER TABLE Sprava_rezervace ADD CONSTRAINT FK_VR_Zamestnanec FOREIGN KEY (Cislo_zamestnance) REFERENCES Zamestnanec(Cislo_zamestnance);
ALTER TABLE Sprava_rezervace ADD CONSTRAINT FK_VR_Rezervace FOREIGN KEY (ID_rezervace) REFERENCES Rezervace(ID_rezervace);

ALTER TABLE Rezervovany_stul ADD CONSTRAINT FK_RS_Rezervace FOREIGN KEY (ID_rezervace) REFERENCES Rezervace(ID_rezervace);
ALTER TABLE Rezervovany_stul ADD CONSTRAINT FK_RS_Stul FOREIGN KEY (Cislo_stolu) REFERENCES Stul(Cislo_stolu);

ALTER TABLE Stul_objednavky ADD CONSTRAINT FK_SO_Objednavka FOREIGN KEY (ID_objednavky) REFERENCES Objednavka(ID_objednavky);
ALTER TABLE Stul_objednavky ADD CONSTRAINT FK_SO_Stul FOREIGN KEY (Cislo_stolu) REFERENCES Stul(Cislo_stolu);

ALTER TABLE Sprava_objednavky ADD CONSTRAINT FK_VO_Objednavka FOREIGN KEY (ID_objednavky) REFERENCES Objednavka(ID_objednavky);
ALTER TABLE Sprava_objednavky ADD CONSTRAINT FK_VO_Zamestnanec FOREIGN KEY (Cislo_zamestnance) REFERENCES Zamestnanec(Cislo_zamestnance);

ALTER TABLE Obsahuje ADD CONSTRAINT FK_OB_Surovina FOREIGN KEY (Nazev_suroviny) REFERENCES Surovina(Nazev_suroviny);
ALTER TABLE Obsahuje ADD CONSTRAINT FK_OB_Polozka FOREIGN KEY (Nazev_polozky) REFERENCES Polozka_objednavky(Nazev_polozky);

ALTER TABLE Obsah_objednavky ADD CONSTRAINT FK_OO_Objednavka FOREIGN KEY (ID_objednavky) REFERENCES Objednavka(ID_objednavky);
ALTER TABLE Obsah_objednavky ADD CONSTRAINT FK_OO_Polozka FOREIGN KEY (Nazev_polozky) REFERENCES Polozka_objednavky(Nazev_polozky);

-- TRIGGERY

-- Automaticky vygeneruje cas a datum vlozeni zaznamu o platbe
CREATE OR REPLACE TRIGGER Zaznam_o_platbe_cas
BEFORE INSERT
ON Zaznam_o_platbe
FOR EACH ROW
BEGIN
  :NEW.Datum_cas := (sysdate);
END;

-- Automaticky generuje PK_Cislo_zamestnance
CREATE OR REPLACE TRIGGER Generate_PK
BEFORE INSERT
ON Zamestnanec
FOR EACH ROW
BEGIN
	IF (:NEW.Cislo_zamestnance IS NULL)
	THEN
		:new.Cislo_zamestnance := SQ_Zamestnanec.nextval;
	END IF;
END;

-- PROCEDURY

-- vytvoření alespoň dvou netriviálních uložených procedur vč. jejich předvedení, ve kterých se musí (dohromady) vyskytovat
-- alespoň jednou kurzor, ošetření výjimek a použití proměnné s datovým typem odkazujícím se na řádek či typ sloupce tabulky
-- (table_name.column_name%TYPE nebo table_name%ROWTYPE)

CREATE OR REPLACE PROCEDURE nazev_procedury IS
BEGIN

END;

EXECUTE nazev_procedury;

CREATE OR REPLACE PROCEDURE nazev_procedury2 IS
BEGIN

END;

EXECUTE nazev_procedury2;


-- OPRAVNENI PRO PRISTUP (SELECT * from xvorli01.zamestnanec@orclpdb.gort.fit.vutbr.cz)

GRANT ALL ON Objednavka             TO xpastu02;
GRANT ALL ON Obsah_objednavky       TO xpastu02;
GRANT ALL ON Obsahuje               TO xpastu02;
GRANT ALL ON Polozka_objednavky			TO xpastu02;
GRANT ALL ON Rezervace              TO xpastu02;
GRANT ALL ON Rezervovany_stul       TO xpastu02;
GRANT ALL ON Sprava_objednavky			TO xpastu02;
GRANT ALL ON Sprava_rezervace       TO xpastu02;
GRANT ALL ON Stul				            TO xpastu02;
GRANT ALL ON Stul_objednavky				TO xpastu02;
GRANT ALL ON Surovina			          TO xpastu02;
GRANT ALL ON Zamestnanec				    TO xpastu02;
GRANT ALL ON Zaznam_o_platbe				TO xpastu02;

GRANT EXECUTE ON nazev_procedury		TO xpastu02;
GRANT EXECUTE ON nazev_procedury2		TO xpastu02;

GRANT CREATE MATERIALIZED VIEW      TO xpastu02;

-- MATERIALIZOVANY POHLED

-- vytvořen alespoň jeden materializovaný pohled patřící druhému členu týmu a používající tabulky definované prvním
-- členem týmu (nutno mít již definována přístupová práva), vč. SQL příkazů/dotazů ukazujících, jak materializovaný pohled funguje

CREATE MATERIALIZED VIEW Testovaci_view
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
DISABLE QUERY REWRITE
AS
SELECT * FROM xvorli01.zamestnanec@orclpdb.gort.fit.vutbr.cz;

DROP MATERIALIZED VIEW Testovaci_view;

-- NAPLNENI TABULKY ZAMESTNANCI DATY --

INSERT INTO Zamestnanec (Jmeno, Prijmeni, Rodne_cislo, Adresa, Telefon)
VALUES ('Joe','Appleseed','330099/7722','Nova 3, 78301 Olomouc','+420777444555');

INSERT INTO Zamestnanec (Jmeno, Prijmeni, Rodne_cislo, Adresa, Telefon)
VALUES ('Clara','Smith','110000/0000','Stara 4, 78301 Olomouc','+420786333111');

INSERT INTO Zamestnanec (Jmeno, Prijmeni, Rodne_cislo, Adresa, Telefon)
VALUES ('Nina','Roberts','222222/2222','Rychla 5, 77890 Praha','+420321444666');

INSERT INTO Zamestnanec (Jmeno, Prijmeni, Rodne_cislo, Adresa, Telefon)
VALUES ('Siobhan','Willow-Dunham','000000/0000','Generala Marseilla Shermana 513/47, 77890 Praha','+420371494666');

INSERT INTO Zamestnanec (Jmeno, Prijmeni, Rodne_cislo, Adresa, Telefon)
VALUES ('Kylie','Jenner','333333/3333','Miloslava Slovaka 76, 77890 Praha','+420321944866');

INSERT INTO Zamestnanec (Jmeno, Prijmeni, Rodne_cislo, Adresa, Telefon)
VALUES ('Mark','Ronson','222222/0000','Kulata 5, 78301 Olomouc','+420787654111');

INSERT INTO Zamestnanec (Jmeno, Prijmeni, Rodne_cislo, Adresa, Telefon)
VALUES ('Nina','Dobrev','555555/0000','Pomala 987/09, 77890 Praha','+420320938966');

INSERT INTO Zamestnanec (Jmeno, Prijmeni, Rodne_cislo, Adresa, Telefon)
VALUES ('Reese','Spark','333333/0000','Lesni 12, 77890 Praha','+420371492266');

INSERT INTO Zamestnanec (Jmeno, Prijmeni, Rodne_cislo, Adresa, Telefon)
VALUES ('Khloe','Karn','444444/0000','Novakova 23, 77890 Praha','+420326588066');

INSERT INTO Zamestnanec (Jmeno, Prijmeni, Rodne_cislo, Adresa, Telefon)
VALUES ('Mary','Smith','666666/0000','Novakova 23, 77890 Praha','+420326588011');

-- NAPLNENI TABULKY REZERVACE DATY --

INSERT INTO Rezervace (Pocet_osob, Datum_cas, Jmeno)
VALUES ('4','09.04.2019 12:30','George Simson');

INSERT INTO Rezervace (Pocet_osob, Datum_cas, Jmeno)
VALUES ('6','14.06.2019 15:00','Sienna Wall');

INSERT INTO Rezervace (Pocet_osob, Datum_cas, Jmeno)
VALUES ('3','01.05.2020 12:15','John Melton');

INSERT INTO Rezervace (Pocet_osob, Datum_cas, Jmeno)
VALUES ('20','18.03.2018 10:30','Jeremy Smith');

INSERT INTO Rezervace (Pocet_osob, Datum_cas, Jmeno)
VALUES ('2','23.05.2019 17:15','Josh Burn');

INSERT INTO Rezervace (Pocet_osob, Datum_cas, Jmeno)
VALUES ('3','08.04.2019 09:30','Liam Williams');

INSERT INTO Rezervace (Pocet_osob, Datum_cas, Jmeno)
VALUES ('10','15.06.2019 15:55','Sienna Drake');

INSERT INTO Rezervace (Pocet_osob, Datum_cas, Jmeno)
VALUES ('25','04.04.2020 10:05','Camilla John');

INSERT INTO Rezervace (Pocet_osob, Datum_cas, Jmeno)
VALUES ('1','13.03.2007 12:30','Jeremy Musk');

INSERT INTO Rezervace (Pocet_osob, Datum_cas, Jmeno)
VALUES ('7','15.04.2007 14:15','Mia Wolt');

-- NAPLNENI TABULKY POLOZKY OBJEDNAVKY DATY --

INSERT INTO Polozka_objednavky (Nazev_polozky, Cena, Porce, Druh)
VALUES ('Hraskova polevka','39','300','J');

INSERT INTO Polozka_objednavky (Nazev_polozky, Cena, Porce, Druh)
VALUES ('Malinova limonada','59,50','400','P');

INSERT INTO Polozka_objednavky (Nazev_polozky, Cena, Porce, Druh)
VALUES ('Zeleninove rizoto s kousky marinovaneho tofu','119','500','J');

INSERT INTO Polozka_objednavky (Nazev_polozky, Cena, Porce, Druh)
VALUES ('Perliva voda','10','250','P');

INSERT INTO Polozka_objednavky (Nazev_polozky, Cena, Porce, Druh)
VALUES ('Veganske lasagne','129,90','250','J');

INSERT INTO Polozka_objednavky (Nazev_polozky, Cena, Porce, Druh)
VALUES ('Vegetariansky hemenex','79','490','J');

INSERT INTO Polozka_objednavky (Nazev_polozky, Cena, Porce, Druh)
VALUES ('Cafe Latte s veganskym mlekem','89,9','150','J');

INSERT INTO Polozka_objednavky (Nazev_polozky, Cena, Porce, Druh)
VALUES ('Vegansky dortik','100,5','230','J');

INSERT INTO Polozka_objednavky (Nazev_polozky, Cena, Porce, Druh)
VALUES ('Vegansky hamburger','200','700','J');

-- NAPLNENI TABULKY OBJEDNAVKY DATY --

INSERT INTO Objednavka (Stav, ID_rezervace)
VALUES ('Z',3);

INSERT INTO Objednavka (Stav, ID_rezervace)
VALUES ('P',1);

INSERT INTO Objednavka (Stav)
VALUES ('D');

INSERT INTO Objednavka (Stav)
VALUES ('D');

INSERT INTO Objednavka (Stav)
VALUES ('D');

INSERT INTO Objednavka (Stav)
VALUES ('P');

INSERT INTO Objednavka (Stav)
VALUES ('Z');

INSERT INTO Objednavka (Stav, ID_rezervace)
VALUES ('D',2);

INSERT INTO Objednavka (Stav, ID_rezervace)
VALUES ('P',4);

INSERT INTO Objednavka (Stav, ID_rezervace)
VALUES ('Z',5);

INSERT INTO Objednavka (Stav, ID_rezervace)
VALUES ('P',6);

INSERT INTO Objednavka (Stav, ID_rezervace)
VALUES ('P',7);

INSERT INTO Objednavka (Stav)
VALUES ('P');

-- NAPLNENI TABULKY SUROVINY DATY --

INSERT INTO Surovina (Nazev_suroviny, Cena, Puvod, Alergeny)
VALUES ('Tofu marinovane','20','USA','1,5,9');

INSERT INTO Surovina (Nazev_suroviny, Cena, Puvod, Alergeny)
VALUES ('Brambory 1Kg','30','Ceska republika','');

INSERT INTO Surovina (Nazev_suroviny, Cena, Puvod, Alergeny)
VALUES ('Soja','250,90','Kolumbie','2,3');

INSERT INTO Surovina (Nazev_suroviny, Cena, Puvod, Alergeny)
VALUES ('Gouda','79,9','Rakousko','4,3,1');

INSERT INTO Surovina (Nazev_suroviny, Cena, Puvod, Alergeny)
VALUES ('Sojove mleko','43','USA','1,5,9');

INSERT INTO Surovina (Nazev_suroviny, Cena, Puvod, Alergeny)
VALUES ('Mrkev 1Kg','25,9','Slovensko','2');

INSERT INTO Surovina (Nazev_suroviny, Cena, Puvod, Alergeny)
VALUES ('Cocka','12,90','Madarsko','');

INSERT INTO Surovina (Nazev_suroviny, Cena, Puvod, Alergeny)
VALUES ('Vege syr','86,9','Nemecko','4,9');


-- NAPLNENI TABULKY OBSAHUJE --

INSERT INTO Obsahuje (Nazev_suroviny, Nazev_polozky)
VALUES ('Brambory 1Kg','Perliva voda');

INSERT INTO Obsahuje (Nazev_suroviny, Nazev_polozky)
VALUES ('Cocka','Veganske lasagne');

INSERT INTO Obsahuje (Nazev_suroviny, Nazev_polozky)
VALUES ('Soja','Hraskova polevka');

INSERT INTO Obsahuje (Nazev_suroviny, Nazev_polozky)
VALUES ('Sojove mleko','Vegetariansky hemenex');

INSERT INTO Obsahuje (Nazev_suroviny, Nazev_polozky)
VALUES ('Tofu marinovane','Vegansky hamburger');

INSERT INTO Obsahuje (Nazev_suroviny, Nazev_polozky)
VALUES ('Sojove mleko','Malinova limonada');

INSERT INTO Obsahuje (Nazev_suroviny, Nazev_polozky)
VALUES ('Vege syr','Vegansky dortik');

INSERT INTO Obsahuje (Nazev_suroviny, Nazev_polozky)
VALUES ('Gouda','Veganske lasagne');

-- NAPLNENI TABULKY STUL DATY --

INSERT INTO Stul (Pocet_mist, Mistnost)
VALUES ('4','Hlavni mistnost');

INSERT INTO Stul (Pocet_mist, Mistnost)
VALUES ('1','Hlavni mistnost');

INSERT INTO Stul (Pocet_mist, Mistnost)
VALUES ('3','Hlavni mistnost');

INSERT INTO Stul (Pocet_mist, Mistnost)
VALUES ('2','Terasa');

INSERT INTO Stul (Pocet_mist, Mistnost)
VALUES ('2','Terasa');

INSERT INTO Stul (Pocet_mist, Mistnost)
VALUES ('2','Terasa');

INSERT INTO Stul (Pocet_mist, Mistnost)
VALUES ('2','Terasa');

INSERT INTO Stul (Pocet_mist, Mistnost)
VALUES ('2','Terasa');

INSERT INTO Stul (Pocet_mist, Mistnost)
VALUES ('2','Terasa');

-- NAPLNENI TABULKY ZAZNAM O PLATBE DATY --

INSERT INTO Zaznam_o_platbe (Druh_platby, Celkova_cena, Cislo_zamestnance, ID_Objednavky)
VALUES ('K','99,90','1','7');

INSERT INTO Zaznam_o_platbe (Druh_platby, Celkova_cena, Cislo_zamestnance, ID_Objednavky)
VALUES ('H','335,54','2','6');

INSERT INTO Zaznam_o_platbe (Druh_platby, Celkova_cena, Cislo_zamestnance, ID_Objednavky)
VALUES ('S','59','3','5');

INSERT INTO Zaznam_o_platbe (Druh_platby, Celkova_cena, Cislo_zamestnance, ID_Objednavky)
VALUES ('H','119','7','1');

INSERT INTO Zaznam_o_platbe (Druh_platby, Celkova_cena, Cislo_zamestnance, ID_Objednavky)
VALUES ('K','109','7','4');

INSERT INTO Zaznam_o_platbe (Druh_platby, Celkova_cena, Cislo_zamestnance, ID_Objednavky)
VALUES ('H','66,8','8','3');

INSERT INTO Zaznam_o_platbe (Druh_platby, Celkova_cena, Cislo_zamestnance, ID_Objednavky)
VALUES ('K','218','1','9');

INSERT INTO Zaznam_o_platbe (Druh_platby, Celkova_cena, Cislo_zamestnance, ID_Objednavky)
VALUES ('S','74','5','2');

-- NAPLNENI TABULKY OBSAH OBJEDNAVKY --

INSERT INTO Obsah_objednavky (ID_Objednavky, Nazev_polozky)
VALUES ('1','Malinova limonada');

INSERT INTO Obsah_objednavky (ID_Objednavky, Nazev_polozky)
VALUES ('2','Perliva voda');

INSERT INTO Obsah_objednavky (ID_Objednavky, Nazev_polozky)
VALUES ('3','Veganske lasagne');

INSERT INTO Obsah_objednavky (ID_Objednavky, Nazev_polozky)
VALUES ('4','Vegansky hamburger');

INSERT INTO Obsah_objednavky (ID_Objednavky, Nazev_polozky)
VALUES ('1','Vegansky dortik');

INSERT INTO Obsah_objednavky (ID_Objednavky, Nazev_polozky)
VALUES ('5','Vegetariansky hemenex');

INSERT INTO Obsah_objednavky (ID_Objednavky, Nazev_polozky)
VALUES ('3','Hraskova polevka');

INSERT INTO Obsah_objednavky (ID_Objednavky, Nazev_polozky)
VALUES ('5','Perliva voda');

INSERT INTO Obsah_objednavky (ID_Objednavky, Nazev_polozky)
VALUES ('13','Cafe Latte s veganskym mlekem');

-- NAPLNENI TABULKY STUL_OBJEDNAVKY --

INSERT INTO Stul_objednavky (Cislo_stolu, ID_objednavky)
VALUES ('3','1');

INSERT INTO Stul_objednavky (Cislo_stolu, ID_objednavky)
VALUES ('1','1');

INSERT INTO Stul_objednavky (Cislo_stolu, ID_objednavky)
VALUES ('3','5');

INSERT INTO Stul_objednavky (Cislo_stolu, ID_objednavky)
VALUES ('2','1');

INSERT INTO Stul_objednavky (Cislo_stolu, ID_objednavky)
VALUES ('5','4');

INSERT INTO Stul_objednavky (Cislo_stolu, ID_objednavky)
VALUES ('2','5');

INSERT INTO Stul_objednavky (Cislo_stolu, ID_objednavky)
VALUES ('1','3');

INSERT INTO Stul_objednavky (Cislo_stolu, ID_objednavky)
VALUES ('4','7');

INSERT INTO Stul_objednavky (Cislo_stolu, ID_objednavky)
VALUES ('7','1');

-- NAPLNENI TABULKY REZERVOVANY_STUL --

INSERT INTO Rezervovany_stul (Cislo_stolu, ID_rezervace)
VALUES ('1','1');

INSERT INTO Rezervovany_stul (Cislo_stolu, ID_rezervace)
VALUES ('2','1');

INSERT INTO Rezervovany_stul (Cislo_stolu, ID_rezervace)
VALUES ('3','1');

INSERT INTO Rezervovany_stul (Cislo_stolu, ID_rezervace)
VALUES ('3','3');

INSERT INTO Rezervovany_stul (Cislo_stolu, ID_rezervace)
VALUES ('1','4');

INSERT INTO Rezervovany_stul (Cislo_stolu, ID_rezervace)
VALUES ('5','6');

INSERT INTO Rezervovany_stul (Cislo_stolu, ID_rezervace)
VALUES ('7','3');

-- NAPLNENI TABULKY VYTVORENI_OBJEDNAVKY --

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('7','1');

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('3','2');

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('2','3');

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('7','4');

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('7','5');

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('5','6');

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('1','7');

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('2','8');

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('3','9');

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('4','10');

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('6',11);

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('3','12');

INSERT INTO Sprava_objednavky (Cislo_zamestnance, ID_objednavky)
VALUES ('9','13');

-- NAPLNENI TABULKY VYTVORENI_REZERVACE --

INSERT INTO Sprava_rezervace (Cislo_zamestnance, ID_rezervace)
VALUES ('7','1');

INSERT INTO Sprava_rezervace (Cislo_zamestnance, ID_rezervace)
VALUES ('1','2');

INSERT INTO Sprava_rezervace (Cislo_zamestnance, ID_rezervace)
VALUES ('4','3');

INSERT INTO Sprava_rezervace (Cislo_zamestnance, ID_rezervace)
VALUES ('9','4');

INSERT INTO Sprava_rezervace (Cislo_zamestnance, ID_rezervace)
VALUES ('4','5');

INSERT INTO Sprava_rezervace (Cislo_zamestnance, ID_rezervace)
VALUES ('2','6');

INSERT INTO Sprava_rezervace (Cislo_zamestnance, ID_rezervace)
VALUES ('5','7');

INSERT INTO Sprava_rezervace (Cislo_zamestnance, ID_rezervace)
VALUES ('9','8');

INSERT INTO Sprava_rezervace (Cislo_zamestnance, ID_rezervace)
VALUES ('5','9');

INSERT INTO Sprava_rezervace (Cislo_zamestnance, ID_rezervace)
VALUES ('9','10');

-- SELECT DOTAZY --

-- Zobrazi suroviny drazsi nez 50Kc, serazeno od nejlevnejsi --
SELECT Nazev_suroviny,Cena FROM Surovina
WHERE Cena > 50
ORDER BY Cena ASC;

-- Zobrazi vyber jidel z polozek objednavky, jejichz porce je vetsi nebo rovna 200g --
SELECT Nazev_polozky,Porce FROM Polozka_objednavky
WHERE Druh='J' AND Porce >= 200
ORDER BY Nazev_polozky DESC;

-- Zobrazi pocet surovin polozek objednavky --
SELECT Obsahuje.Nazev_polozky, Count(Surovina.Nazev_suroviny) FROM Obsahuje
INNER JOIN Surovina
ON Obsahuje.Nazev_suroviny = Surovina.Nazev_suroviny
GROUP BY Nazev_polozky;

-- Zobrazi objednavky, ktere maji presne 2 polozky --
SELECT Obsah_objednavky.ID_objednavky, Count(Polozka_objednavky.Nazev_polozky) AS Pocet_polozek FROM Obsah_objednavky
LEFT JOIN Polozka_objednavky
ON Obsah_objednavky.Nazev_polozky = Polozka_objednavky.Nazev_polozky
GROUP BY Obsah_objednavky.ID_objednavky
HAVING Count(Polozka_objednavky.Nazev_polozky) = 2;

-- Zobrazi objednavky, ktere obsahuji piti --
SELECT Obsah_objednavky.ID_objednavky FROM Obsah_objednavky
LEFT JOIN Polozka_objednavky
ON Obsah_objednavky.Nazev_polozky = Polozka_objednavky.Nazev_polozky
WHERE Polozka_objednavky.Druh = 'P'
GROUP BY Obsah_objednavky.ID_objednavky
ORDER BY Obsah_objednavky.ID_objednavky DESC;

-- Zobrazi rezervace spravovane zamestnancem se jmenem zacinajicim na K --
SELECT Zamestnanec.Jmeno, Sprava_rezervace.ID_rezervace FROM Sprava_rezervace
LEFT JOIN Zamestnanec
ON Sprava_rezervace.Cislo_zamestnance = Zamestnanec.Cislo_zamestnance
WHERE Zamestnanec.Jmeno LIKE 'K%';

-- Zobrazi prijmeni zamestnance, ktery spravoval rezervaci pro vice nez 5 osob --
SELECT Zamestnanec.Prijmeni, Rezervace.Pocet_osob FROM Sprava_rezervace
LEFT JOIN Zamestnanec
ON Sprava_rezervace.Cislo_zamestnance = Zamestnanec.Cislo_zamestnance
RIGHT JOIN Rezervace
ON Rezervace.ID_rezervace = Sprava_rezervace.ID_rezervace
WHERE Pocet_osob > 5;

-- Zobrazi zamestnance, ktery spravoval existujici zaznam o platbe s celkovou cenou vetsi nez 200Kc --
SELECT DISTINCT Zamestnanec.Jmeno FROM Zamestnanec
WHERE EXISTS (SELECT * FROM Zaznam_o_platbe WHERE Zamestnanec.Cislo_zamestnance = Zaznam_o_platbe.Cislo_zamestnance AND Celkova_cena > 200);

-- Zobrazi objednavky, jejichz polozky maji v nazvu 'veg' --
SELECT obsah_objednavky.ID_objednavky FROM Obsah_objednavky
WHERE Nazev_polozky IN (SELECT Nazev_polozky FROM Polozka_objednavky WHERE LOWER(Obsah_objednavky.Nazev_polozky) LIKE '%veg%');

-- Zobrazi objednavky, ktere obsahuji alespon jednu surovinu drazsi nez 50Kc --
SELECT DISTINCT Obsah_objednavky.ID_objednavky FROM Obsah_objednavky
WHERE EXISTS (SELECT Nazev_polozky FROM Polozka_objednavky WHERE Obsah_objednavky.Nazev_polozky = Polozka_objednavky.Nazev_polozky AND
EXISTS (SELECT * FROM Obsahuje WHERE  Obsahuje.Nazev_polozky = Polozka_objednavky.Nazev_polozky AND
EXISTS (SELECT Surovina.Cena FROM Surovina WHERE Surovina.Nazev_suroviny = Obsahuje.Nazev_suroviny AND Cena > 50 )));


-- přičemž v dokumentaci musí být srozumitelně popsáno, jak proběhne dle toho
-- výpisu plánu provedení dotazu, vč. objasnění použitých prostředků pro jeho urychlení (např. použití indexu, druhu spojení,
-- atp.), a dále musí být navrnut způsob, jak konkrétně by bylo možné dotaz dále urychlit (např. zavedením nového indexu),
-- navržený způsob proveden (např. vytvořen index), zopakován EXPLAIN PLAN a jeho výsledek porovnán s výsledkem před provedením navrženého způsobu urychlení

-- EXPLAIN PLAN

-- Postup zobrazeni prijmeni zamestnancu a rezervaci pro vice nez 5 osob --
EXPLAIN PLAN FOR
SELECT Zamestnanec.Prijmeni, Rezervace.Pocet_osob FROM Sprava_rezervace
LEFT JOIN Zamestnanec
ON Sprava_rezervace.Cislo_zamestnance = Zamestnanec.Cislo_zamestnance
RIGHT JOIN Rezervace
ON Rezervace.ID_rezervace = Sprava_rezervace.ID_rezervace
WHERE Pocet_osob > 5
GROUP BY Zamestnanec.Prijmeni,Rezervace.Pocet_osob;
SELECT * FROM TABLE(DBMS_XPLAN.display);

-- Postup zobrazeni objednavek, ktere obsahuji alespon jednu surovinu drazsi nez 50Kc --
EXPLAIN PLAN FOR
SELECT DISTINCT Obsah_objednavky.ID_objednavky FROM Obsah_objednavky
WHERE EXISTS (SELECT Nazev_polozky FROM Polozka_objednavky WHERE Obsah_objednavky.Nazev_polozky = Polozka_objednavky.Nazev_polozky AND
EXISTS (SELECT * FROM Obsahuje WHERE  Obsahuje.Nazev_polozky = Polozka_objednavky.Nazev_polozky AND
EXISTS (SELECT Surovina.Cena FROM Surovina WHERE Surovina.Nazev_suroviny = Obsahuje.Nazev_suroviny AND Cena > 50 )));
SELECT * FROM TABLE(DBMS_XPLAN.display);

COMMIT;
