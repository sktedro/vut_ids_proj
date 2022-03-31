-- Authors: Dziyana Khrystsiuk (xkhrys00), Patrik Skaloš (xskalo01)

-- TODO:
-- What to do with attributes which cannot be null (NOT NULL) but we want to
-- keep their parent table when references get deleted (ON DELETE SET NULL)?

-- Clear old table data if there is any

DROP TABLE "order_content";
DROP TABLE "item";
DROP TABLE "ingredient_allergen";
DROP TABLE "allergen";
DROP TABLE "pastry_ingredients";
DROP TABLE "ingredient";
DROP TABLE "pastry";
DROP TABLE "order";
DROP TABLE "customer";
DROP TABLE "partnership";
DROP TABLE "agreement";
DROP TABLE "smuggler" CASCADE CONSTRAINTS;
DROP TABLE "oversees";
DROP TABLE "shift";
DROP TABLE "warden";
DROP TABLE "jail" CASCADE CONSTRAINTS;

-- Create new tables

CREATE TABLE "jail" (
    "id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    "region" VARCHAR(64),
    "city" VARCHAR(64) NOT NULL,
    "zip" NUMBER(5, 0) NOT NULL,
    "street" VARCHAR(64) NOT NULL,
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

CREATE TABLE "shift" (
    "id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    "start_datetime" TIMESTAMP(0) NOT NULL,
    "end_datetime" TIMESTAMP(0) NOT NULL,
    CONSTRAINT "check_shift_datetime"
            CHECK ("start_datetime" < "end_datetime")
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
    "iban" VARCHAR2(34), -- We don't need his IBAN if he doesn't want to get paid
    "birth_number" NUMBER(10, 0) NOT NULL,
    CONSTRAINT "phone_number_check"
            CHECK (REGEXP_LIKE("phone_number", '^+\d{12}$')),
    CONSTRAINT "iban_length_check"
            CHECK (REGEXP_LIKE("iban", '^[A-Z]{2}\d+$') AND LENGTH("iban") <= 34)
);

CREATE TABLE "agreement" (
     "smuggler_id" INT NOT NULL,
     "warden_id" INT NOT NULL,
     PRIMARY KEY ("smuggler_id", "warden_id"),
     CONSTRAINT "agreement_smuggler_id_pk"
             FOREIGN KEY ("smuggler_id") REFERENCES "smuggler" ("id")
             ON DELETE CASCADE,
     CONSTRAINT "agreement_warden_id_pk"
             FOREIGN KEY ("warden_id") REFERENCES "warden" ("id")
             ON DELETE CASCADE
);

CREATE TABLE "partnership" (
  "smuggler_id" INT NOT NULL,
  "jail_id" INT NOT NULL,
  PRIMARY KEY ("smuggler_id", "jail_id"),
  CONSTRAINT "partnership_smuggler_id_pk"
          FOREIGN KEY ("smuggler_id") REFERENCES "smuggler" ("id")
          ON DELETE CASCADE,
  CONSTRAINT "partnership_jail_id_pk"
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
            ON DELETE SET NULL
            -- the customer might be transferred to a different one
);

CREATE TABLE "order" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "order_datetime" TIMESTAMP(0) NOT NULL,
    "delivery_datetime" TIMESTAMP(0),
    "delivery_method" VARCHAR(64),
    "smuggler_id" INT NOT NULL,
    "customer_id" INT NOT NULL,
    CONSTRAINT "check_order_datetime"
            CHECK ("order_datetime" < "delivery_datetime"),
    CONSTRAINT "order_smuggler_id_pk"
            FOREIGN KEY ("smuggler_id") REFERENCES "smuggler" ("id")
            ON DELETE SET NULL,
    CONSTRAINT "order_customer_id_pk"
            FOREIGN KEY ("customer_id") REFERENCES "customer" ("id")
            ON DELETE SET NULL
);

CREATE TABLE "pastry" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "type" VARCHAR(64) NOT NULL,
    "weight" INT NOT NULL
);

CREATE TABLE "ingredient" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "current_amount" INT NOT NULL,
    "unit" VARCHAR(4) NOT NULL
            CHECK("unit" IN ('pcs', 'g', 'kg', 'ml', 'l', 'mm', 'm', 'mm^2', 'm^2')),
    "wholesale_price" NUMBER(*, 4) NOT NULL
);

CREATE TABLE "pastry_ingredients" (
    "pastry_id" INT NOT NULL,
    "ingredient_id" INT NOT NULL,
    PRIMARY KEY ("pastry_id","ingredient_id"),
    CONSTRAINT "pastry_ingredients_ingredient_id_fk"
            FOREIGN KEY ("ingredient_id") REFERENCES "ingredient" ("id")
            ON DELETE CASCADE,
    CONSTRAINT "pastry_ingredients_pastry_id_fk"
            FOREIGN KEY ("pastry_id") REFERENCES "pastry" ("id")
            ON DELETE CASCADE
);

CREATE TABLE "allergen" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR2(2048)
);

CREATE TABLE "ingredient_allergen" (
    "ingredient_id" INT NOT NULL,
    "allergen_id" INT NOT NULL,
    PRIMARY KEY ("allergen_id","ingredient_id"),
    CONSTRAINT "ingredients_allergen_ingredient_id_fk"
            FOREIGN KEY ("ingredient_id") REFERENCES "ingredient" ("id")
            ON DELETE CASCADE,
    CONSTRAINT "ingredients_allergen_pastry_id_fk"
            FOREIGN KEY ("allergen_id") REFERENCES "allergen" ("id")
            ON DELETE CASCADE
);

CREATE TABLE "item" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR2(2048),
    "width" INT NOT NULL,
    "length" INT NOT NULL,
    "height" INT NOT NULL,
    "price" NUMBER(*,2)
);

CREATE TABLE "order_content" (
    "order_id" INT NOT NULL,
    "pastry_id" INT NOT NULL,
    "item_id" INT DEFAULT NULL,
    PRIMARY KEY ("order_id", "pastry_id", "item_id"),
    CONSTRAINT "order_content_order_id_fk"
		FOREIGN KEY ("order_id") REFERENCES "order" ("id")
		ON DELETE CASCADE,
	CONSTRAINT "order_content_pastry_id_fk"
		FOREIGN KEY ("pastry_id") REFERENCES "pastry" ("id")
		ON DELETE SET NULL,
	CONSTRAINT "order_content_item_id_fk"
		FOREIGN KEY ("item_id") REFERENCES "item" ("id")
		ON DELETE SET NULL
);

-- Insert some data

-- INSERT INTO "smuggler" ("name", "surname", "phone_number", "iban", "birth_number")
--     VALUES ('patrik', 'skalos', '+421944306657', 'SK1235421', 1010567890);
