-- Authors: Dziyana Khrystsiuk (xkhrys00), Patrik Skaloš (xskalo01)

-- TODO pastry dimensions??
-- TODO orders: pastries not containing items are not possible at the moment

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
DROP TABLE "prison" CASCADE CONSTRAINTS;

-- Create new tables

CREATE TABLE "prison" (
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
    "prison_id" INT NOT NULL,
    CONSTRAINT "warden_prison_id_pk"
            FOREIGN KEY ("prison_id") REFERENCES "prison" ("id")
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
            ON DELETE CASCADE,
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
            CHECK (REGEXP_LIKE("phone_number", '^(\+\d{12})$')),
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
  "prison_id" INT NOT NULL,
  PRIMARY KEY ("smuggler_id", "prison_id"),
  CONSTRAINT "partnership_smuggler_id_pk"
          FOREIGN KEY ("smuggler_id") REFERENCES "smuggler" ("id")
          ON DELETE CASCADE,
  CONSTRAINT "partnership_prison_id_pk"
          FOREIGN KEY ("prison_id") REFERENCES "prison" ("id")
          ON DELETE CASCADE
);

CREATE TABLE "customer" (
    "id" INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(64) NOT NULL,
    "surname" VARCHAR(64) NOT NULL,
    "prison_id" INT,
    "cell_number" INT,
    "cell_type" VARCHAR(16),
    CONSTRAINT "customer_prison_id_pk"
            FOREIGN KEY ("prison_id") REFERENCES "prison" ("id")
            ON DELETE SET NULL
            -- the customer might be transferred to a different one
);

CREATE TABLE "order" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "order_datetime" TIMESTAMP(0) NOT NULL,
    "delivery_datetime" TIMESTAMP(0),
    "delivery_method" VARCHAR(64),
    "smuggler_id" INT,
    "customer_id" INT NOT NULL,
    CONSTRAINT "check_order_datetime"
            CHECK ("order_datetime" < "delivery_datetime"),
    CONSTRAINT "order_smuggler_id_pk"
            FOREIGN KEY ("smuggler_id") REFERENCES "smuggler" ("id")
            ON DELETE SET NULL,
    CONSTRAINT "order_customer_id_pk"
            FOREIGN KEY ("customer_id") REFERENCES "customer" ("id")
            ON DELETE CASCADE
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
    "wholesale_price" NUMBER(*, 2)
);

CREATE TABLE "order_content" (
    "order_id" INT NOT NULL,
    "pastry_id" INT NOT NULL,
    "item_id" INT DEFAULT NULL,
    "amount" INT NOT NULL,
    PRIMARY KEY ("order_id", "pastry_id", "item_id"),
    CONSTRAINT "order_content_order_id_fk"
		FOREIGN KEY ("order_id") REFERENCES "order" ("id")
		ON DELETE CASCADE,
	CONSTRAINT "order_content_pastry_id_fk"
		FOREIGN KEY ("pastry_id") REFERENCES "pastry" ("id")
		ON DELETE CASCADE,
	CONSTRAINT "order_content_item_id_fk"
		FOREIGN KEY ("item_id") REFERENCES "item" ("id")
		ON DELETE CASCADE
);

-- Insert some data

-- Insert some ingredients
INSERT INTO "ingredient" ("name", "current_amount", "unit", "wholesale_price")
        VALUES ('flour', '10', 'kg', '0.3');
INSERT INTO "ingredient" ("name", "current_amount", "unit", "wholesale_price")
        VALUES ('egg', '83', 'pcs', '0.05');
INSERT INTO "ingredient" ("name", "current_amount", "unit", "wholesale_price")
        VALUES ('yeast', '1283', 'g', '0.016');
INSERT INTO "ingredient" ("name", "current_amount", "unit", "wholesale_price")
        VALUES ('garlic', '300', 'g', '0.023');

-- Insert allergens
INSERT INTO "allergen" ("name", "description") VALUES ('gluten', '');
INSERT INTO "allergen" ("name", "description") VALUES ('eggs', '');
INSERT INTO "allergen" ("name", "description") VALUES ('lupin', '');
INSERT INTO "allergen" ("name", "description") VALUES ('milk', '');
INSERT INTO "allergen" ("name", "description") VALUES ('nuts', '');
INSERT INTO "allergen" ("name", "description") VALUES ('peanuts', '');
INSERT INTO "allergen" ("name", "description") VALUES ('soy', '');

-- Connect ingredients and allergens
INSERT INTO "ingredient_allergen" ("ingredient_id", "allergen_id")
        VALUES(1, 1); -- flour:gluten
INSERT INTO "ingredient_allergen" ("ingredient_id", "allergen_id")
        VALUES(1, 3); -- flout:lupin
INSERT INTO "ingredient_allergen" ("ingredient_id", "allergen_id")
        VALUES(2, 2); -- egg:eggs
INSERT INTO "ingredient_allergen" ("ingredient_id", "allergen_id")
        VALUES(3, 5); -- yeast:nuts
INSERT INTO "ingredient_allergen" ("ingredient_id", "allergen_id")
        VALUES(3, 6); -- yeast:peanuts
INSERT INTO "ingredient_allergen" ("ingredient_id", "allergen_id")
        VALUES(3, 7); -- yeast:soy

-- Insert some pastries
INSERT INTO "pastry" ("name", "type", "weight")
        VALUES ('classic bread', 'bread', '1000');
INSERT INTO "pastry" ("name", "type", "weight")
        VALUES ('garlic bread', 'bread', '500');

-- Connect pastries to ingredients
INSERT INTO "pastry_ingredients" ("pastry_id", "ingredient_id")
        VALUES(1, 1); -- classic_bread:flour
INSERT INTO "pastry_ingredients" ("pastry_id", "ingredient_id")
        VALUES(1, 2); -- classic_bread:egg
INSERT INTO "pastry_ingredients" ("pastry_id", "ingredient_id")
        VALUES(1, 3); -- classic_bread:yeast
INSERT INTO "pastry_ingredients" ("pastry_id", "ingredient_id")
        VALUES(2, 1); -- garlic_bread:flour
INSERT INTO "pastry_ingredients" ("pastry_id", "ingredient_id")
        VALUES(2, 2); -- garlic_bread:egg
INSERT INTO "pastry_ingredients" ("pastry_id", "ingredient_id")
        VALUES(2, 3); -- garlic_bread:yeast
INSERT INTO "pastry_ingredients" ("pastry_id", "ingredient_id")
        VALUES(2, 4); -- garlic_bread:garlic

-- Insert some items that can be baked into a pastry
INSERT INTO "item" ("name", "description", "width", "length", "height", "wholesale_price")
        VALUES('knife', 'kitchen knife', 18, 200, 24, 40);
INSERT INTO "item" ("name", "description", "width", "length", "height", "wholesale_price")
        VALUES('wrench', 'M8 stainless steel metric wrench', 8, 122, 40, 24);
INSERT INTO "item" ("name", "description", "width", "length", "height", "wholesale_price")
        VALUES('scalpel', 'carbonated steel with anti-slip handle', 10, 100, 10, 18);
INSERT INTO "item" ("name", "description", "width", "length", "height", "wholesale_price")
        VALUES('screwdriver', 'phillips screwdriver #4', 28, 155, 28, 42);

-- Initialize two prisons
INSERT INTO "prison" ("region", "city", "zip", "street", "street_number")
        VALUES ('Trnavský kraj', 'Leopoldov', '92041', 'Väzničné námestie', '10');
INSERT INTO "prison" ("city", "zip", "street", "street_number")
        VALUES ('Košice', '04020', 'Lunícka', '9');

-- Initialize some wardens
INSERT INTO "warden" ("name", "surname", "prison_id")
        VALUES ('John', 'Eyeless', 1); -- John at Leopoldov
INSERT INTO "warden" ("name", "surname", "prison_id")
        VALUES ('Bob', 'Guard', 1); -- Bob at Leopoldov
INSERT INTO "warden" ("name", "surname", "prison_id")
        VALUES ('Natalie', 'Harsh', 2); -- Natalie at Košice

-- Initialize some smugglers
INSERT INTO "smuggler" ("name", "surname", "phone_number", "birth_number")
        VALUES ('Sam', 'Sneaky', '+421944333666', 9410166606);
INSERT INTO "smuggler" ("name", "surname", "phone_number", "iban", "birth_number")
        VALUES ('Jack', 'Quiet', '+420111222333', 'CZ3601000000000123456789', 9801041444);
INSERT INTO "smuggler" ("name", "surname", "phone_number", "birth_number")
        VALUES ('Mary', 'Persuasive', '+421944444555', 8803036606);

-- Connect smugglers to prisons (partnership)
INSERT INTO "partnership" ("smuggler_id", "prison_id")
        VALUES (1, 1); -- Sam Sneaky at Leopoldov
INSERT INTO "partnership" ("smuggler_id", "prison_id")
        VALUES (1, 2); -- Sam Sneaky at Košice
INSERT INTO "partnership" ("smuggler_id", "prison_id")
        VALUES (2, 1); -- Jack Quiet at Leopoldov
INSERT INTO "partnership" ("smuggler_id", "prison_id")
        VALUES (3, 2); -- Mary Persuasive at Košice

-- Connect smugglers to wardens (agreement)
INSERT INTO "agreement" ("smuggler_id", "warden_id")
        VALUES (1, 1); -- Sam with John
INSERT INTO "agreement" ("smuggler_id", "warden_id")
        VALUES (1, 3); -- Sam with Natalie
INSERT INTO "agreement" ("smuggler_id", "warden_id")
        VALUES (2, 2); -- Jack with Bob
INSERT INTO "agreement" ("smuggler_id", "warden_id")
        VALUES (3, 3); -- Mary with Natalie

-- Create some shifts
-- Leopoldov: 8h blocks starting at 6AM
INSERT INTO "shift" ("start_datetime", "end_datetime")
        VALUES(TIMESTAMP '2020-04-01 06:00:00', TIMESTAMP '2020-04-01 14:00:00');
INSERT INTO "shift" ("start_datetime", "end_datetime")
        VALUES(TIMESTAMP '2020-04-01 22:00:00', TIMESTAMP '2020-04-02 06:00:00');
INSERT INTO "shift" ("start_datetime", "end_datetime")
        VALUES(TIMESTAMP '2020-04-02 06:00:00', TIMESTAMP '2020-04-02 14:00:00');
INSERT INTO "shift" ("start_datetime", "end_datetime")
        VALUES(TIMESTAMP '2020-04-02 22:00:00', TIMESTAMP '2020-04-03 06:00:00');
-- Košice: 8h blocks starting at 4AM
INSERT INTO "shift" ("start_datetime", "end_datetime")
        VALUES(TIMESTAMP '2020-04-01 12:00:00', TIMESTAMP '2020-04-01 20:00:00');
INSERT INTO "shift" ("start_datetime", "end_datetime")
        VALUES(TIMESTAMP '2020-04-03 12:00:00', TIMESTAMP '2020-04-03 20:00:00');

-- Connect wardens to shifts
-- John: every day at 6AM
INSERT INTO "oversees" ("warden_id", "shift_id")
        VALUES(1, 1);
INSERT INTO "oversees" ("warden_id", "shift_id")
        VALUES(1, 3);
-- Bob: every day at 10PM
INSERT INTO "oversees" ("warden_id", "shift_id")
        VALUES(2, 2);
INSERT INTO "oversees" ("warden_id", "shift_id")
        VALUES(2, 4);
-- Natalie: every other day at 12PM (noon)
INSERT INTO "oversees" ("warden_id", "shift_id")
        VALUES(3, 5);
INSERT INTO "oversees" ("warden_id", "shift_id")
        VALUES(3, 6);

-- Initialize some customers
INSERT INTO "customer" ("name", "surname", "prison_id", "cell_number", "cell_type")
        VALUES('James', 'Junkie', 1, 42, 'general'); -- James at Leopoldov #42
INSERT INTO "customer" ("name", "surname", "prison_id", "cell_number", "cell_type")
        VALUES('Michael', 'Robber', 1, 169, 'general'); -- Michael at Leopoldov #169
INSERT INTO "customer" ("name", "surname", "prison_id", "cell_number", "cell_type")
        VALUES('Richard', 'Kidnapper', 1, 4, 'solitary'); -- Richard at Leopoldov #4
INSERT INTO "customer" ("name", "surname", "prison_id", "cell_number", "cell_type")
        VALUES('Elizabeth', 'Kill', 2, 1173, 'general'); -- Elizabeth at Košice #1173
INSERT INTO "customer" ("name", "surname", "prison_id", "cell_number", "cell_type")
        VALUES('Susan', 'Innocent', 2, 17, 'protective'); --  Susan at Košice #17

-- Create some orders
INSERT INTO "order" ("order_datetime", "delivery_datetime", "delivery_method",
                "smuggler_id", "customer_id")
        VALUES (TIMESTAMP '2020-04-01 17:34:02', TIMESTAMP '2020-04-02 08:24:00',
                'delivery by warden', 1, 1);
        -- James at Leopoldov, delivered by smuggler Sam and warden John
INSERT INTO "order" ("order_datetime", "delivery_datetime", "delivery_method",
                 "smuggler_id", "customer_id")
        VALUES (TIMESTAMP '2020-04-01 21:12:39', TIMESTAMP '2020-04-03 15:15:00',
                'delivery by warden', 3, 5);
        -- Susan at Košice, delivered by smuggler Sam and warden Natalie
INSERT INTO "order" ("order_datetime", "customer_id")
        VALUES (TIMESTAMP '2020-04-01 21:12:39', 3);
        -- Richard at Košice, delivery not yet planned

/* TODO
-- Add contents of an order to an order
INSERT INTO "order_content" ("order_id", "pastry_id", "item_id", "amount")
        VALUES(1, 1, 1, 1);
INSERT INTO "order_content" ("order_id", "pastry_id", "item_id", "amount")
        VALUES(1, 2, 2, 1);
INSERT INTO "order_content" ("order_id", "pastry_id", "amount")
        VALUES(1, 2, 1);
        -- James at Leopoldov orders classic bread with knife inside and two
        -- garlic breads, one with a wrench, one empty
INSERT INTO "order_content" ("order_id", "pastry_id", "amount")
        VALUES(2, 2, 2);
        -- Susan at Košice orders two garlic breads, no items
INSERT INTO "order_content" ("order_id", "pastry_id", "item_id", "amount")
        VALUES(3, 1, 4, 1);
INSERT INTO "order_content" ("order_id", "pastry_id", "item_id", "amount")
        VALUES(3, 2, 3, 1);
INSERT INTO "order_content" ("order_id", "pastry_id", "amount")
        VALUES(3, 2, 3);
        -- Richard at Košice orders classic bread with a screwdriver inside and
        -- four garlic breads, one with scalpel inside, three empty
*/