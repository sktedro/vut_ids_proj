-- Authors: Dziyana Khrystsiuk (xkhrys00), Patrik Skaloš (xskalo01)


-- TODO Clear old table data if there is any

DROP TABLE "ingredient_allergen";
DROP TABLE "pastry_ingredients";
DROP TABLE "order_content";
DROP TABLE "allergen";
DROP TABLE "ingredient";
DROP TABLE "pastry";
DROP TABLE "order";
DROP TABLE "item";
DROP TABLE "shift";

-- Create new tables

CREATE TABLE "shift" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "start_datetime" TIMESTAMP(0) NOT NULL,
    "end_datetime" TIMESTAMP(0) NOT NULL,
    CONSTRAINT "check_shift_datetime" CHECK ("end_datetime" > "start_datetime")
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

CREATE TABLE "order"(
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY
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
    "unit" VARCHAR(3) NOT NULL
            CHECK("unit" IN ('pcs', 'g', 'kg', 'l', 'ml')),
    "purchase_price" NUMBER(*,2) NOT NULL
);

CREATE TABLE "allergen" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR2(2048)
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

