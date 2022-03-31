-- Authors: Dziyana Khrystsiuk (xkhrys00), Patrik Skaloš (xskalo01)

-- Clear old table data if there is any

DROP TABLE "customer";
DROP TABLE "employment";
DROP TABLE "agreement";
DROP TABLE "smuggler";
DROP TABLE "oversees";
DROP TABLE "warden";
DROP TABLE "jail";
DROP TABLE "shift";

-- Create new tables

CREATE TABLE "shift" (
    "id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    "start_datetime" TIMESTAMP(0) NOT NULL,
    "end_datetime" TIMESTAMP(0) NOT NULL,
    CONSTRAINT "check_shift_datetime" CHECK ("end_datetime" > "start_datetime")
);

CREATE TABLE "jail" (
    "id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    "region" VARCHAR(64),
    "city" VARCHAR(64),
    "zip" NUMBER(5, 0),
    "street" VARCHAR(64),
    "street_number" INT NOT NULL
);

CREATE TABLE "warden" (
    "id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(64) NOT NULL,
    "surname" VARCHAR(64) NOT NULL,
    "jail_id" INT NOT NULL,
    CONSTRAINT "warden_jail_id_pk"
            FOREIGN KEY ("jail_id") REFERENCES "jail" ("id")
            ON DELETE CASCADE
);

CREATE TABLE "oversees" (
    "warden_id" INT NOT NULL,
    "shift_id" INT NOT NULL,
    PRIMARY KEY ("warden_id", "shift_id"),
    CONSTRAINT "oversees_warden_id_pk"
            FOREIGN KEY ("warden_id") REFERENCES "warden" ("id")
            ON DELETE SET NULL,
    CONSTRAINT "oversees_shift_id_pk"
            FOREIGN KEY ("shift_id") REFERENCES "shift" ("id")
            ON DELETE CASCADE
);

CREATE TABLE "smuggler" (
    "id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(64) NOT NULL,
    "surname" VARCHAR(64) NOT NULL,
    "phone_number" VARCHAR(13) NOT NULL,
    "iban" VARCHAR2(34),
    "birth_number" NUMBER(10, 0) NOT NULL,
    CONSTRAINT "phone_number_check"
            CHECK (REGEXP_LIKE("phone_number", '^+\d{12}$')),
    CONSTRAINT "iban_length_check"
            CHECK (LENGTH("iban") = '34')
);

CREATE TABLE "agreement" (
     "smuggler_id" INT NOT NULL,
     "warden_id" INT NOT NULL,
     PRIMARY KEY ("smuggler_id", "warden_id"),
     CONSTRAINT "agreement_smuggler_id_pk"
             FOREIGN KEY ("smuggler_id") REFERENCES "smuggler" ("id")
             ON DELETE SET NULL,
     CONSTRAINT "agreement_warden_id_pk"
             FOREIGN KEY ("warden_id") REFERENCES "warden" ("id")
             ON DELETE CASCADE
);

CREATE TABLE "employment" (
  "smuggler_id" INT NOT NULL,
  "jail_id" INT NOT NULL,
  PRIMARY KEY ("smuggler_id", "jail_id"),
  CONSTRAINT "employment_smuggler_id_pk"
          FOREIGN KEY ("smuggler_id") REFERENCES "smuggler" ("id")
          ON DELETE SET NULL,
  CONSTRAINT "employment_jail_id_pk"
          FOREIGN KEY ("jail_id") REFERENCES "jail" ("id")
          ON DELETE CASCADE
);

CREATE TABLE "customer" (
    "id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(64) NOT NULL,
    "surname" VARCHAR(64) NOT NULL,
    "jail_id" INT,
    "cell_number" INT,
    "cell_type" VARCHAR(16),
    CONSTRAINT "customer_jail_id_pk"
            FOREIGN KEY ("jail_id") REFERENCES "jail" ("id")
            ON DELETE CASCADE
);

-- Insert some data

-- INSERT INTO "smuggler" ("name", "surname", "phone_number", "iban", "birth_number")
--     VALUES ('patrik', 'skalos', '+421944306657', 'SK1235421', 1010567890);