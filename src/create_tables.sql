-- Authors: Dziyana Khrystsiuk (xkhrys00), Patrik Skaloš (xskalo01)


-- TODO Clear old table data if there is any


-- Create new tables

CREATE TABLE "shift" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "start_datetime" TIMESTAMP(0) NOT NULL,
    "end_datetime" TIMESTAMP(0) NOT NULL,
    CONSTRAINT "check_shift_datetime" CHECK ("end_datetime" > "start_datetime")
);