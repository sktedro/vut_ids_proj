-- 2x join
-- 1x join 3 tables
-- 2x group by & agregačné funkcie
-- 1x exists
-- 1x IN (SELECT...

-- List all wardens in Leopoldov prison
SELECT "warden_name", "surname"
    FROM "warden" NATURAL JOIN "prison"
    WHERE "city" = 'Leopoldov' AND "zip" = 92041 AND "street" = 'Väzničné námestie' AND "street_number" = 10;

-- Count shifts in the database for each warden
SELECT "warden_name", "surname", COUNT(*) AS "shift_count"
    FROM "warden" NATURAL JOIN "oversees"
    GROUP BY "warden_name", "surname", "warden_id";

-- List all allergens of yeast ingredient
SELECT A."allergen_name" FROM "allergen" A
    RIGHT JOIN "ingredient_allergen" ON A."allergen_id" = "ingredient_allergen"."allergen_id"
    LEFT JOIN "ingredient" I ON "ingredient_allergen"."ingredient_id" = I."ingredient_id"
    WHERE I."ingredient_name" = 'yeast';

-- List how many customers do individual prisons have
SELECT "city", "street", "street_number", COUNT(*) AS "customer_count"
    FROM "prison" P JOIN "customer" ON P."prison_id" = "customer"."prison_id"
    GROUP BY P."prison_id", "city", "street", "street_number";

-- Count how many hours have individual wardens worked until now
SELECT "warden_name", "surname", SUM(EXTRACT(DAY FROM "hours_sum") * 24 + EXTRACT(HOUR FROM "hours_sum")) AS "hours_sum"
    FROM (SELECT W."warden_id", W."warden_name", W."surname", S."end_datetime" - S."start_datetime" AS "hours_sum"
        FROM "shift" S
            JOIN "oversees" O ON S."shift_id" = O."shift_id"
            JOIN "warden" W ON O."warden_id" = W."warden_id")
    GROUP BY "warden_id", "warden_name", "surname";

-- List all customers that have bought a kitchen knife
SELECT DISTINCT "customer_name", "surname"
    FROM "customer"
        WHERE EXISTS(
            SELECT *
                FROM "order" NATURAL JOIN "order_content" NATURAL JOIN "item"
                    WHERE "customer"."customer_id" = "order"."customer_id" AND "item_name" = 'knife'
            );

-- List all ingredients of garlic bread that are not in classic bread
SELECT "ingredient_name"
    FROM "pastry" NATURAL JOIN "pastry_ingredients" NATURAL JOIN "ingredient"
    WHERE "pastry_name" = 'garlic bread'
        AND "ingredient_name" NOT IN (
            SELECT "ingredient_name"
                FROM "pastry" NATURAL JOIN "pastry_ingredients" NATURAL JOIN "ingredient"
                WHERE "pastry_name" = 'classic bread'
            );
