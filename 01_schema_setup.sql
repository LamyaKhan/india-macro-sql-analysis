/* ============================================================
   INDIA MACROECONOMIC ANALYSIS
   Step 1: Schema and Table Setup
   ============================================================
   Creates the INDIA_MACRO database with one fact table and
   three dimension tables, then verifies the row counts after
   loading the four CSV files (dim_category, dim_indicator,
   dim_year, fact_india_macro) via MySQL Workbench's Table
   Data Import Wizard.
   ============================================================ */

DROP DATABASE IF EXISTS INDIA_MACRO;

CREATE DATABASE INDIA_MACRO;

USE INDIA_MACRO;

-- ------------------------------------------------------------
-- Create the four tables
-- ------------------------------------------------------------

CREATE TABLE dim_category
        (category_code VARCHAR(5) PRIMARY KEY,
        category_name VARCHAR(20),
        category_description VARCHAR(100));

CREATE TABLE dim_indicator
     (indicator_code VARCHAR(20) PRIMARY KEY,
     indicator_name VARCHAR(50),
     unit VARCHAR(30),
	 source_file VARCHAR (50),
     category_code VARCHAR(5),
       FOREIGN KEY (category_code) REFERENCES dim_category(category_code));

CREATE TABLE dim_year
    (year INT PRIMARY KEY,
    decade VARCHAR(5),
    five_year_period VARCHAR(10),
    policy_era VARCHAR(40),
    crisis_period VARCHAR(30));

CREATE TABLE fact_india_macro
    (fact_id INT PRIMARY KEY,
    year INT,
      FOREIGN KEY (year) REFERENCES dim_year(year),
	indicator_code VARCHAR(20),
       FOREIGN KEY(indicator_code) REFERENCES dim_indicator(indicator_code),
	value decimal(8,2) null
    );

-- ------------------------------------------------------------
-- Import order (via Table Data Import Wizard):
--   1. dim_category.csv
--   2. dim_indicator.csv
--   3. dim_year.csv
--   4. fact_india_macro.csv
-- Dimension tables must load before the fact table, since the
-- fact table's foreign keys reference them.
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- Verify the load
-- ------------------------------------------------------------

SELECT
    'fact_india_macro' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(value) AS non_null_values,
    COUNT(*) - COUNT(value) AS null_values
FROM fact_india_macro

UNION ALL

SELECT
    'dim_category',
    COUNT(*),
    COUNT(category_code),
    COUNT(*) - COUNT(category_code)
FROM dim_category

UNION ALL

SELECT
    'dim_indicator',
    COUNT(*),
    COUNT(indicator_code),
    COUNT(*) - COUNT(indicator_code)
FROM dim_indicator

UNION ALL

SELECT
    'dim_year',
    COUNT(*),
    COUNT(year),
    COUNT(*) - COUNT(year)
FROM dim_year;

-- Expected: fact_india_macro = 567 rows (528 non-null, 39 null)
--           dim_year = 63 | dim_indicator = 9 | dim_category = 4
