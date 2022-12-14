--TABLES
CREATE TABLE PERSON
(
    PERSON_ID INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    FIRSTNAME VARCHAR2(50),
    LASTNAME  VARCHAR2(50),
    CONSTRAINT PERSON_PK PRIMARY KEY (PERSON_ID)
        ENABLE
);

CREATE TABLE TRIP
(
    TRIP_ID   INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    NAME      VARCHAR2(100),
    COUNTRY   VARCHAR2(50),
    TRIP_DATE DATE,
    NO_PLACES INT,
    CONSTRAINT TRIP_PK PRIMARY KEY (TRIP_ID)
        ENABLE
);

CREATE TABLE RESERVATION
(
    RESERVATION_ID INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    TRIP_ID        INT,
    PERSON_ID      INT,
    STATUS         CHAR(1),
    CONSTRAINT RESERVATION_PK PRIMARY KEY (RESERVATION_ID)
        ENABLE
);

CREATE TABLE COUNTRY
(
    COUNTRY_ID INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    NAME       VARCHAR2(50),
    CONSTRAINT COUNTRY_PK PRIMARY KEY (COUNTRY_ID)
        ENABLE
);

CREATE TABLE RESERVATION_LOG
(
    LOG_ID         INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    RESERVATION_ID INT,
    CHANGE_DATE    DATE,
    STATUS         CHAR,
    CONSTRAINT RESERVATION_LOG_PK PRIMARY KEY (LOG_ID)
        ENABLE
);

ALTER TABLE TRIP
    ADD NO_AVAILABLE_PLACES INT;

-- FOREIGN KEYS
ALTER TABLE RESERVATION
    ADD CONSTRAINT RESERVATION_FK1 FOREIGN KEY
        (PERSON_ID) REFERENCES PERSON (PERSON_ID)
            ENABLE;

ALTER TABLE RESERVATION
    ADD CONSTRAINT RESERVATION_FK2 FOREIGN KEY
        (TRIP_ID) REFERENCES TRIP (TRIP_ID)
            ENABLE;

ALTER TABLE RESERVATION_LOG
    ADD CONSTRAINT RESERVATION_LOG_FK1 FOREIGN KEY
        (RESERVATION_ID) REFERENCES RESERVATION (RESERVATION_ID)
            ENABLE;

-- CHECKS
ALTER TABLE RESERVATION
    ADD CONSTRAINT RESERVATION_CHK1 CHECK
        (STATUS IN ('N', 'P', 'C'))
        ENABLE;

ALTER TABLE TRIP
    ADD CONSTRAINT TRIP_CHK1 CHECK
        (COUNTRY IN ('France', 'Spain', 'Germany', 'Poland'))
        ENABLE;

ALTER TABLE RESERVATION_LOG
    ADD CONSTRAINT RESERVATION_LOG_CHK1 CHECK
        (STATUS IN ('N', 'P', 'C'))
        ENABLE;

-- ADD COUNTRIES
INSERT INTO COUNTRY (NAME)
VALUES ('France');

INSERT INTO COUNTRY (NAME)
VALUES ('Spain');

INSERT INTO COUNTRY (NAME)
VALUES ('Germany');

INSERT INTO COUNTRY (NAME)
VALUES ('Poland');

-- ADD USERS
INSERT INTO PERSON (FIRSTNAME, LASTNAME)
VALUES ('Adam', 'Kowalski');

INSERT INTO PERSON (FIRSTNAME, LASTNAME)
VALUES ('Jan', 'Nowak');

INSERT INTO PERSON (FIRSTNAME, LASTNAME)
VALUES ('Arleta', 'Winnicka');

INSERT INTO PERSON (FIRSTNAME, LASTNAME)
VALUES ('Julia', 'Zawadzka');

INSERT INTO PERSON (FIRSTNAME, LASTNAME)
VALUES ('Mariusz', 'Kowalczyk');

INSERT INTO PERSON (FIRSTNAME, LASTNAME)
VALUES ('Igor', 'Brudny');

INSERT INTO PERSON (FIRSTNAME, LASTNAME)
VALUES ('Filip', 'Trochan');

INSERT INTO PERSON (FIRSTNAME, LASTNAME)
VALUES ('Anna', 'Borucka');

INSERT INTO PERSON (FIRSTNAME, LASTNAME)
VALUES ('Cezary', 'Czarnecki');

INSERT INTO PERSON (FIRSTNAME, LASTNAME)
VALUES ('Oliwia', 'Mickiewicz');

-- ADD TRIPS
INSERT INTO TRIP (NAME, COUNTRY, TRIP_DATE, NO_PLACES)
VALUES ('Trip to Paris', 'France', TO_DATE('2021-09-03', 'YYYY-MM-DD'), 3);

INSERT INTO TRIP (NAME, COUNTRY, TRIP_DATE, NO_PLACES)
VALUES ('Trip to Barcelona', 'Spain', TO_DATE('2022-12-04', 'YYYY-MM-DD'), 2);

INSERT INTO TRIP (NAME, COUNTRY, TRIP_DATE, NO_PLACES)
VALUES ('Trip to Berlin', 'Germany', TO_DATE('2023-02-02', 'YYYY-MM-DD'), 1);

INSERT INTO TRIP (NAME, COUNTRY, TRIP_DATE, NO_PLACES)
VALUES ('Trip to Cracow', 'Poland', TO_DATE('2022-10-05', 'YYYY-MM-DD'), 2);

-- ADD RESERVATIONS
INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
VALUES (1, 1, 'N');

INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
VALUES (1, 2, 'P');

INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
VALUES (1, 3, 'C');

INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
VALUES (2, 4, 'C');

INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
VALUES (2, 5, 'N');

INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
VALUES (3, 6, 'P');

INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
VALUES (3, 7, 'C');

INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
VALUES (4, 8, 'N');

INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
VALUES (4, 9, 'N');

INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
VALUES (4, 10, 'C');

-- VIEWS
CREATE OR REPLACE VIEW V_RESERVATIONS AS
SELECT c.NAME           AS country,
       t.TRIP_DATE      AS trip_date,
       t.NAME           AS trip_name,
       p.FIRSTNAME      AS firstname,
       p.LASTNAME       AS lastname,
       r.RESERVATION_ID AS reservation_id,
       r.STATUS         AS status
FROM RESERVATION r
         JOIN TRIP t ON
    r.TRIP_ID = t.TRIP_ID
         JOIN PERSON p ON
    r.PERSON_ID = p.PERSON_ID
         JOIN COUNTRY c on
    c.NAME = t.COUNTRY;

CREATE OR REPLACE VIEW V_RESERVATIONS_COUNT AS
SELECT t.COUNTRY AS country, COUNT(r.TRIP_ID) AS reservations
FROM TRIP t
         JOIN RESERVATION r on t.TRIP_ID = r.TRIP_ID
WHERE r.STATUS != 'C'
GROUP BY t.COUNTRY;

CREATE OR REPLACE VIEW V_TRIPS AS
SELECT c.NAME                                   AS country,
       t.TRIP_ID                                AS trip_id,
       t.TRIP_DATE                              AS trip_date,
       t.NAME                                   AS trip_name,
       t.NO_PLACES                              AS no_places,
       (NO_PLACES - (SELECT reservations
                     FROM V_RESERVATIONS_COUNT v
                     WHERE v.country = c.NAME)) AS no_available_places
FROM TRIP T
         JOIN COUNTRY c on c.NAME = t.COUNTRY;

CREATE OR REPLACE VIEW V_TRIPS_2 AS
SELECT c.NAME                AS country,
       t.TRIP_ID             AS trip_id,
       t.TRIP_DATE           AS trip_date,
       t.NAME                AS trip_name,
       t.NO_PLACES           AS no_places,
       t.NO_AVAILABLE_PLACES AS no_available_places
FROM TRIP T
         JOIN COUNTRY c on c.NAME = t.COUNTRY;


CREATE OR REPLACE VIEW V_AVAILABLE_TRIPS AS
SELECT *
FROM V_TRIPS
WHERE NO_AVAILABLE_PLACES > 0
  AND TRIP_DATE > CURRENT_DATE;

-- PROCEDURES
CREATE TYPE TRIP_PARTICIPANT AS OBJECT
(
    country_name   VARCHAR2(25),
    trip_date      DATE,
    trip_name      VARCHAR2(50),
    first_name     VARCHAR2(25),
    last_name      VARCHAR2(25),
    reservation_id INT,
    status         CHAR(1)
);

CREATE TYPE TRIP_PARTICIPANT_TABLE AS TABLE OF TRIP_PARTICIPANT;

CREATE OR REPLACE FUNCTION TRIP_PARTICIPANTS(TRIP_ID IN TRIP.TRIP_ID % TYPE)
    RETURN TRIP_PARTICIPANT_TABLE AS
    RESULT TRIP_PARTICIPANT_TABLE;
    VALID  INT;

BEGIN
    SELECT COUNT(*)
    INTO VALID
    FROM TRIP t
    WHERE t.TRIP_ID = TRIP_PARTICIPANTS.TRIP_ID;

    IF
        VALID = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid trip_id');
    END IF;

    SELECT TRIP_PARTICIPANT(
                   t.COUNTRY,
                   t.TRIP_DATE,
                   t.NAME,
                   p.FIRSTNAME,
                   p.LASTNAME,
                   r.RESERVATION_ID,
                   r.STATUS
               ) BULK COLLECT
    INTO RESULT
    FROM RESERVATION r
             JOIN PERSON p on p.PERSON_ID = r.PERSON_ID
             JOIN TRIP t on t.TRIP_ID = r.TRIP_ID
             JOIN COUNTRY c on c.NAME = t.COUNTRY
    WHERE t.TRIP_ID = TRIP_PARTICIPANTS.TRIP_ID;

    RETURN RESULT;
END;

SELECT *
FROM TRIP_PARTICIPANTS(1);

CREATE TYPE PERSON_RESERVATION AS OBJECT
(
    country_name   VARCHAR2(25),
    trip_date      DATE,
    trip_name      VARCHAR2(50),
    first_name     VARCHAR2(25),
    last_name      VARCHAR2(25),
    reservation_id INT,
    status         CHAR(1)
);

CREATE TYPE PERSON_RESERVATION_TABLE AS TABLE OF PERSON_RESERVATION;

CREATE OR REPLACE FUNCTION PERSON_RESERVATIONS(PERSON_ID IN PERSON.PERSON_ID % TYPE)
    RETURN PERSON_RESERVATION_TABLE AS
    RESULT PERSON_RESERVATION_TABLE;
    VALID  INT;

BEGIN
    SELECT COUNT(*)
    INTO VALID
    FROM PERSON p
    WHERE p.PERSON_ID = PERSON_RESERVATIONS.PERSON_ID;

    IF
        VALID = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid person_id');
    END IF;

    SELECT PERSON_RESERVATION(
                   t.COUNTRY,
                   t.TRIP_DATE,
                   t.NAME,
                   p.FIRSTNAME,
                   p.LASTNAME,
                   r.RESERVATION_ID,
                   r.STATUS) BULK COLLECT
    INTO RESULT
    FROM RESERVATION r
             JOIN PERSON p on p.PERSON_ID = r.PERSON_ID
             JOIN TRIP t on t.TRIP_ID = r.TRIP_ID
             JOIN COUNTRY c on c.NAME = t.COUNTRY
    WHERE p.PERSON_ID = PERSON_RESERVATIONS.PERSON_ID;

    RETURN RESULT;
END;

SELECT *
FROM PERSON_RESERVATIONS(1);

CREATE TYPE AVAILABLE_TRIP AS OBJECT
(
    country_name        VARCHAR2(25),
    trip_date           DATE,
    trip_name           VARCHAR2(50),
    no_available_places INT
);

CREATE TYPE AVAILABLE_TRIPS_TABLE AS TABLE OF AVAILABLE_TRIP;

CREATE OR REPLACE FUNCTION AVAILABLE_TRIPS(COUNTRY_NAME IN TRIP.COUNTRY % TYPE, DATE_FROM IN TRIP.TRIP_DATE % TYPE,
                                           DATE_TO IN TRIP.TRIP_DATE % TYPE)
    RETURN AVAILABLE_TRIPS_TABLE AS
    RESULT AVAILABLE_TRIPS_TABLE;
    VAR_NUMBER INT;

BEGIN
    SELECT COUNT(*)
    INTO VAR_NUMBER
    FROM V_TRIPS t
    WHERE t.NO_AVAILABLE_PLACES > 0
      AND DATE_FROM < t.TRIP_DATE
      AND DATE_TO > t.TRIP_DATE
      AND COUNTRY_NAME = t.COUNTRY;

    IF
        VAR_NUMBER = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'No trips found');
    END IF;

    SELECT AVAILABLE_TRIP(
                   t.COUNTRY,
                   t.TRIP_DATE,
                   t.TRIP_NAME,
                   t.NO_AVAILABLE_PLACES) BULK COLLECT
    INTO RESULT
    FROM V_TRIPS t
    WHERE t.COUNTRY = AVAILABLE_TRIPS.COUNTRY_NAME;

    RETURN RESULT;
END;

CREATE OR REPLACE FUNCTION AVAILABLE_TRIPS_2(COUNTRY_NAME IN TRIP.COUNTRY % TYPE, DATE_FROM IN TRIP.TRIP_DATE % TYPE,
                                           DATE_TO IN TRIP.TRIP_DATE % TYPE)
    RETURN AVAILABLE_TRIPS_TABLE AS
    RESULT AVAILABLE_TRIPS_TABLE;
    VAR_NUMBER INT;

BEGIN
    SELECT COUNT(*)
    INTO VAR_NUMBER
    FROM V_TRIPS_2 t
    WHERE t.NO_AVAILABLE_PLACES > 0
      AND DATE_FROM < t.TRIP_DATE
      AND DATE_TO > t.TRIP_DATE
      AND COUNTRY_NAME = t.COUNTRY;

    IF
        VAR_NUMBER = 0
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'No trips found');
    END IF;

    SELECT AVAILABLE_TRIP(
                   t.COUNTRY,
                   t.TRIP_DATE,
                   t.TRIP_NAME,
                   t.NO_AVAILABLE_PLACES) BULK COLLECT
    INTO RESULT
    FROM V_TRIPS_2 t
    WHERE t.COUNTRY = AVAILABLE_TRIPS.COUNTRY_NAME;

    RETURN RESULT;
END;

SELECT *
FROM AVAILABLE_TRIPS('France', 2020 - 09 - 03, 2023 - 09 - 03);

CREATE OR REPLACE PROCEDURE ADD_RESERVATION(TRIP_ID IN TRIP.TRIP_ID % TYPE, PERSON_ID IN PERSON.PERSON_ID % TYPE) IS

    VALID_PERSON       INT;
    VALID_TRIP         INT;
    NEW_RESERVATION_ID INT;

BEGIN
    SELECT COUNT(*)
    INTO VALID_PERSON
    FROM PERSON p
    WHERE ADD_RESERVATION.PERSON_ID = P.PERSON_ID;

    IF
        VALID_PERSON != 1
    THEN
        raise_application_error(-20001, 'Invalid person');
    END IF;

    SELECT COUNT(*)
    INTO VALID_TRIP
    FROM V_TRIPS t
    WHERE ADD_RESERVATION.TRIP_ID = t.TRIP_ID
      AND t.NO_AVAILABLE_PLACES > 0
      AND t.TRIP_DATE > CURRENT_DATE;

    IF
        VALID_TRIP != 1
    THEN
        raise_application_error(-20001, 'Invalid trip');
    END IF;

    INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
    VALUES (ADD_RESERVATION.TRIP_ID,
            ADD_RESERVATION.PERSON_ID,
            'N')
    RETURNING RESERVATION_ID
        INTO NEW_RESERVATION_ID;

    INSERT INTO RESERVATION_LOG (RESERVATION_ID, CHANGE_DATE, STATUS)
    VALUES (NEW_RESERVATION_ID, CURRENT_DATE, 'N');

END;

CREATE OR REPLACE PROCEDURE MODIFY_RESERVATION_STATUS(RESERVATION_ID IN RESERVATION.RESERVATION_ID % TYPE,
                                                      STATUS IN RESERVATION.STATUS % TYPE) IS
    VALID_RESERVATION_ID INT;
    AVAILABLE_PLACES     INT;

BEGIN
    IF
                STATUS != 'N'
            AND STATUS != 'C'
            AND STATUS != 'P' THEN
        RAISE_APPLICATION_ERROR
            (-20001, 'Invalid status; status must be either NEW (N), PAID (P) or CANCELED (C)');
    END IF;

    SELECT COUNT(*)
    INTO VALID_RESERVATION_ID
    FROM V_RESERVATIONS r
    WHERE MODIFY_RESERVATION_STATUS.RESERVATION_ID = r.RESERVATION_ID;

    IF
        VALID_RESERVATION_ID != 1
    THEN
        raise_application_error(-20001, 'Invalid reservation_id');
    END IF;

    SELECT NO_AVAILABLE_PLACES
    INTO AVAILABLE_PLACES
    FROM V_TRIPS t
    WHERE t.TRIP_ID =
          (SELECT TRIP_ID
           FROM RESERVATION R
           WHERE R.RESERVATION_ID = MODIFY_RESERVATION_STATUS.RESERVATION_ID);

    IF
                AVAILABLE_PLACES < 1
            AND STATUS = 'N'
            AND STATUS = 'P'
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'No places are available for that trip');
    END IF;

    UPDATE RESERVATION r
    SET STATUS = MODIFY_RESERVATION_STATUS.STATUS
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS.RESERVATION_ID;

    INSERT INTO RESERVATION_LOG (RESERVATION_ID, CHANGE_DATE, STATUS)
    VALUES (MODIFY_RESERVATION_STATUS.RESERVATION_ID,
            CURRENT_DATE,
            MODIFY_RESERVATION_STATUS.STATUS);
END;

CREATE OR REPLACE PROCEDURE MODIFY_NO_PLACES(
    TRIP_ID IN TRIP.TRIP_ID % TYPE, NEW_NO_PLACES IN TRIP.NO_PLACES % TYPE) IS

    TRIP_EXISTS           INT;
    EXISTING_RESERVATIONS INT;

BEGIN
    SELECT COUNT(*)
    INTO TRIP_EXISTS
    FROM TRIP t
    WHERE t.TRIP_ID = MODIFY_NO_PLACES.TRIP_ID;

    IF
        TRIP_EXISTS != 1 THEN
        raise_application_error(-20001, 'Invalid trip_id');
    END IF;

    SELECT COUNT(*)
    INTO EXISTING_RESERVATIONS
    FROM RESERVATION r
    WHERE r.TRIP_ID = MODIFY_NO_PLACES.TRIP_ID
      AND r.STATUS IN ('P', 'N');

    IF
        EXISTING_RESERVATIONS > MODIFY_NO_PLACES.NEW_NO_PLACES
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'Places for existing reservations can not be changed');
    END IF;

    UPDATE TRIP t
    SET NO_PLACES = MODIFY_NO_PLACES.NEW_NO_PLACES
    WHERE t.TRIP_ID = MODIFY_NO_PLACES.TRIP_ID;
END;

CREATE OR UPDATE PROCEDURE COUNT_NO_PLACES(
    TRIP_ID IN TRIP.TRIP_ID % TYPE, COUNTRY IN TRIP.COUNTRY % TYPE) IS
    NO_PLACES INT;
BEGIN
    FOR TRIP IN (SELECT * FROM TRIP)
        LOOP
            SELECT v.RESERVATIONS
            INTO NO_PLACES
            FROM V_RESERVATIONS_COUNT v
            WHERE v.COUNTRY = COUNT_NO_PLACES.COUNTRY;

            UPDATE TRIP t
            SET t.NO_AVAILABLE_PLACES = NO_PLACES
            WHERE t.TRIP_ID = COUNT_NO_PLACES.TRIP_ID;

        END LOOP;
END;

CREATE OR REPLACE PROCEDURE ADD_RESERVATION_2(TRIP_ID IN TRIP.TRIP_ID % TYPE, PERSON_ID IN PERSON.PERSON_ID % TYPE) IS

    VALID_PERSON       INT;
    VALID_TRIP         INT;
    NEW_RESERVATION_ID INT;

BEGIN
    SELECT COUNT(*)
    INTO VALID_PERSON
    FROM PERSON p
    WHERE ADD_RESERVATION_2.PERSON_ID = P.PERSON_ID;

    IF
        VALID_PERSON != 1
    THEN
        raise_application_error(-20001, 'Invalid person');
    END IF;

    SELECT COUNT(*)
    INTO VALID_TRIP
    FROM TRIP t
    WHERE ADD_RESERVATION_2.TRIP_ID = t.TRIP_ID
      AND t.NO_AVAILABLE_PLACES > 0
      AND t.TRIP_DATE > CURRENT_DATE;

    IF
        VALID_TRIP != 1
    THEN
        raise_application_error(-20001, 'Invalid trip');
    END IF;

    INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
    VALUES (ADD_RESERVATION_2.TRIP_ID,
            ADD_RESERVATION_2.PERSON_ID,
            'N')
    RETURNING RESERVATION_ID
        INTO NEW_RESERVATION_ID;

    UPDATE TRIP t
    SET t.NO_AVAILABLE_PLACES = t.NO_AVAILABLE_PLACES - 1
    WHERE t.TRIP_ID = ADD_RESERVATION_2.TRIP_ID;

    INSERT INTO RESERVATION_LOG (RESERVATION_ID, CHANGE_DATE, STATUS)
    VALUES (NEW_RESERVATION_ID, CURRENT_DATE, 'N');

END;

CREATE OR REPLACE PROCEDURE MODIFY_RESERVATION_STATUS_2(RESERVATION_ID IN RESERVATION.RESERVATION_ID % TYPE,
                                                        STATUS IN RESERVATION.STATUS % TYPE) IS
    VALID_RESERVATION_ID INT;
    AVAILABLE_PLACES     INT;
    START_STATUS         CHAR(1);
    VAR_TRIP_ID          INT;

BEGIN
    IF
                STATUS != 'N'
            AND STATUS != 'C'
            AND STATUS != 'P' THEN
        RAISE_APPLICATION_ERROR
            (-20001, 'Invalid status; status must be either NEW (N), PAID (P) or CANCELED (C)');
    END IF;

    SELECT COUNT(*)
    INTO VALID_RESERVATION_ID
    FROM V_RESERVATIONS r
    WHERE MODIFY_RESERVATION_STATUS_2.RESERVATION_ID = r.RESERVATION_ID;

    SELECT STATUS
    INTO START_STATUS
    FROM RESERVATION r
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_2.RESERVATION_ID;

    SELECT TRIP_ID
    INTO VAR_TRIP_ID
    FROM RESERVATION R
    WHERE R.RESERVATION_ID = MODIFY_RESERVATION_STATUS_2.RESERVATION_ID;

    IF
        VALID_RESERVATION_ID != 1
    THEN
        raise_application_error(-20001, 'Invalid reservation_id');
    END IF;

    SELECT NO_AVAILABLE_PLACES
    INTO AVAILABLE_PLACES
    FROM TRIP t
    WHERE t.TRIP_ID = VAR_TRIP_ID;
    IF AVAILABLE_PLACES < 1
        AND STATUS = 'N'
        AND STATUS = 'P'
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'No places are available for that trip');
    END IF;

    UPDATE RESERVATION r
    SET STATUS = MODIFY_RESERVATION_STATUS_2.STATUS
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_2.RESERVATION_ID;;

    IF START_STATUS = 'C' THEN
        UPDATE TRIP t
        SET t.NO_AVAILABLE_PLACES = t.NO_AVAILABLE_PLACES + 1
        WHERE t.TRIP_ID = VAR_TRIP_ID;
    ELSE
        UPDATE TRIP t
        SET t.NO_AVAILABLE_PLACES = t.NO_AVAILABLE_PLACES - 1
        WHERE t.TRIP_ID = VAR_TRIP_ID;
    END IF;

    INSERT INTO RESERVATION_LOG (RESERVATION_ID, CHANGE_DATE, STATUS)
    VALUES (MODIFY_RESERVATION_STATUS_2.RESERVATION_ID,
            CURRENT_DATE,
            MODIFY_RESERVATION_STATUS_2.STATUS);
END;

-- TRIGGERS
CREATE OR REPLACE TRIGGER RESERVATION_LOG_TRIGGER
    AFTER INSERT OR UPDATE
    ON RESERVATION
    FOR EACH ROW
BEGIN
    INSERT INTO RESERVATION_LOG
        (RESERVATION_ID, CHANGE_DATE, STATUS)
    VALUES (:NEW.RESERVATION_ID, CURRENT_DATE, :NEW.STATUS);
END;

CREATE OR REPLACE TRIGGER RESERVATION_DELETE_TRIGGER
    BEFORE DELETE
    ON RESERVATION
    FOR EACH ROW
BEGIN
    RAISE_APPLICATION_ERROR(-20000, 'Reservation can not be deleted');
END;

CREATE OR REPLACE PROCEDURE ADD_RESERVATION_3(TRIP_ID IN TRIP.TRIP_ID % TYPE, PERSON_ID IN PERSON.PERSON_ID % TYPE) IS

    VALID_PERSON       INT;
    VALID_TRIP         INT;
    NEW_RESERVATION_ID INT;

BEGIN
    SELECT COUNT(*)
    INTO VALID_PERSON
    FROM PERSON p
    WHERE ADD_RESERVATION_3.PERSON_ID = P.PERSON_ID;

    IF
        VALID_PERSON != 1
    THEN
        raise_application_error(-20001, 'Invalid person');
    END IF;

    SELECT COUNT(*)
    INTO VALID_TRIP
    FROM TRIP t
    WHERE ADD_RESERVATION_3.TRIP_ID = t.TRIP_ID
      AND t.NO_AVAILABLE_PLACES > 0
      AND t.TRIP_DATE > CURRENT_DATE;

    IF
        VALID_TRIP != 1
    THEN
        raise_application_error(-20001, 'Invalid trip');
    END IF;

    INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
    VALUES (ADD_RESERVATION_3.TRIP_ID,
            ADD_RESERVATION_3.PERSON_ID,
            'N')
    RETURNING RESERVATION_ID
        INTO NEW_RESERVATION_ID;

    UPDATE TRIP t
    SET t.NO_AVAILABLE_PLACES = t.NO_AVAILABLE_PLACES - 1
    WHERE t.TRIP_ID = ADD_RESERVATION_3.TRIP_ID;
END;

CREATE OR REPLACE PROCEDURE MODIFY_RESERVATION_STATUS_3(RESERVATION_ID IN RESERVATION.RESERVATION_ID % TYPE,
                                                        STATUS IN RESERVATION.STATUS % TYPE) IS
    VALID_RESERVATION_ID INT;
    AVAILABLE_PLACES     INT;
    START_STATUS         CHAR(1);
    VAR_TRIP_ID          INT;

BEGIN
    IF
                STATUS != 'N'
            AND STATUS != 'C'
            AND STATUS != 'P' THEN
        RAISE_APPLICATION_ERROR
            (-20001, 'Invalid status; status must be either NEW (N), PAID (P) or CANCELED (C)');
    END IF;

    SELECT COUNT(*)
    INTO VALID_RESERVATION_ID
    FROM V_RESERVATIONS r
    WHERE MODIFY_RESERVATION_STATUS_3.RESERVATION_ID = r.RESERVATION_ID;

    SELECT STATUS
    INTO START_STATUS
    FROM RESERVATION r
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_3.RESERVATION_ID;

    SELECT TRIP_ID
    INTO VAR_TRIP_ID
    FROM RESERVATION R
    WHERE R.RESERVATION_ID = MODIFY_RESERVATION_STATUS_3.RESERVATION_ID;

    IF
        VALID_RESERVATION_ID != 1
    THEN
        raise_application_error(-20001, 'Invalid reservation_id');
    END IF;

    SELECT NO_AVAILABLE_PLACES
    INTO AVAILABLE_PLACES
    FROM TRIP t
    WHERE t.TRIP_ID = VAR_TRIP_ID;
    IF AVAILABLE_PLACES < 1
        AND STATUS = 'N'
        AND STATUS = 'P'
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'No places are available for that trip');
    END IF;

    UPDATE RESERVATION r
    SET STATUS = MODIFY_RESERVATION_STATUS_3.STATUS
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_3.RESERVATION_ID;;

    IF START_STATUS = 'C' THEN
        UPDATE TRIP t
        SET t.NO_AVAILABLE_PLACES = t.NO_AVAILABLE_PLACES + 1
        WHERE t.TRIP_ID = VAR_TRIP_ID;
    ELSE
        UPDATE TRIP t
        SET t.NO_AVAILABLE_PLACES = t.NO_AVAILABLE_PLACES - 1
        WHERE t.TRIP_ID = VAR_TRIP_ID;
    END IF;
END;

CREATE OR REPLACE TRIGGER NO_AVAILABLE_PLACES_TRIGGER
    AFTER UPDATE
    ON RESERVATION
    FOR EACH ROW
BEGIN
    UPDATE TRIP t
    SET t.NO_AVAILABLE_PLACES = t.NO_AVAILABLE_PLACES - 1
    WHERE t.TRIP_ID = :NEW.TRIP_ID;
END;

CREATE OR REPLACE TRIGGER CHANGE_NO_AVAILABLE_PLACES_TRIGGER
    AFTER INSERT OR UPDATE
    ON TRIP
    FOR EACH ROW
BEGIN
    UPDATE TRIP t
    SET t.NO_AVAILABLE_PLACES = t.NO_AVAILABLE_PLACES - (:OLD.NO_PLACES - :NEW.NO_PLACES)
    WHERE t.TRIP_ID = :NEW.TRIP_ID;
END;

CREATE OR REPLACE PROCEDURE ADD_RESERVATION_4(TRIP_ID IN TRIP.TRIP_ID % TYPE, PERSON_ID IN PERSON.PERSON_ID % TYPE) IS

    VALID_PERSON       INT;
    VALID_TRIP         INT;
    NEW_RESERVATION_ID INT;

BEGIN
    SELECT COUNT(*)
    INTO VALID_PERSON
    FROM PERSON p
    WHERE ADD_RESERVATION_4.PERSON_ID = P.PERSON_ID;

    IF
        VALID_PERSON != 1
    THEN
        raise_application_error(-20001, 'Invalid person');
    END IF;

    SELECT COUNT(*)
    INTO VALID_TRIP
    FROM TRIP t
    WHERE ADD_RESERVATION_4.TRIP_ID = t.TRIP_ID
      AND t.NO_AVAILABLE_PLACES > 0
      AND t.TRIP_DATE > CURRENT_DATE;

    IF
        VALID_TRIP != 1
    THEN
        raise_application_error(-20001, 'Invalid trip');
    END IF;

    INSERT INTO RESERVATION(TRIP_ID, PERSON_ID, STATUS)
    VALUES (ADD_RESERVATION_4.TRIP_ID,
            ADD_RESERVATION_4.PERSON_ID,
            'N')
    RETURNING RESERVATION_ID
        INTO NEW_RESERVATION_ID;
END;

CREATE OR REPLACE PROCEDURE MODIFY_RESERVATION_STATUS_4(RESERVATION_ID IN RESERVATION.RESERVATION_ID % TYPE,
                                                        STATUS IN RESERVATION.STATUS % TYPE) IS
    VALID_RESERVATION_ID INT;
    AVAILABLE_PLACES     INT;
    START_STATUS         CHAR(1);
    VAR_TRIP_ID          INT;

BEGIN
    IF
                STATUS != 'N'
            AND STATUS != 'C'
            AND STATUS != 'P' THEN
        RAISE_APPLICATION_ERROR
            (-20001, 'Invalid status; status must be either NEW (N), PAID (P) or CANCELED (C)');
    END IF;

    SELECT COUNT(*)
    INTO VALID_RESERVATION_ID
    FROM V_RESERVATIONS r
    WHERE MODIFY_RESERVATION_STATUS_4.RESERVATION_ID = r.RESERVATION_ID;

    SELECT STATUS
    INTO START_STATUS
    FROM RESERVATION r
    WHERE r.RESERVATION_ID = MODIFY_RESERVATION_STATUS_4.RESERVATION_ID;

    SELECT TRIP_ID
    INTO VAR_TRIP_ID
    FROM RESERVATION R
    WHERE R.RESERVATION_ID = MODIFY_RESERVATION_STATUS_4.RESERVATION_ID;

    IF
        VALID_RESERVATION_ID != 1
    THEN
        raise_application_error(-20001, 'Invalid reservation_id');
    END IF;

    SELECT NO_AVAILABLE_PLACES
    INTO AVAILABLE_PLACES
    FROM TRIP t
    WHERE t.TRIP_ID = VAR_TRIP_ID;
    IF AVAILABLE_PLACES < 1
        AND STATUS = 'N'
        AND STATUS = 'P'
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'No places are available for that trip');
    END IF;
END;