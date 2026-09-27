/* ============================================================
   INDIA MACROECONOMIC ANALYSIS
   Step 2: Data Cleaning and Quality Checks
   ============================================================
   Checks completeness per indicator, confirms the real
   coverage window for government debt, tests for duplicate
   year + indicator combinations, and uses a LEFT JOIN to keep
   every year visible even where no measurement exists.
   ============================================================ */

USE INDIA_MACRO;

-- ------------------------------------------------------------
-- Check A: how complete is each indicator?
-- ------------------------------------------------------------

SELECT
    indi.indicator_name,
    COUNT(*) AS total_rows,
    COUNT(FCM.value) AS non_null_rows,
    COUNT(*) - COUNT(FCM.value) AS missing
FROM Fact_india_macro AS FCM
LEFT JOIN dim_indicator AS indi
    ON FCM.indicator_code = indi.indicator_code
GROUP BY indi.indicator_name, indi.unit
ORDER BY missing DESC;

-- ------------------------------------------------------------
-- Check B: what years does government debt actually cover?
-- ------------------------------------------------------------

(SELECT 'Earliest year' AS period, YEAR
FROM fact_india_macro
WHERE indicator_code = 'GOVT_DEBT_PCT_GDP'
    AND value IS NOT NULL
ORDER BY YEAR
LIMIT 1)
UNION
(SELECT 'latest year' AS period, YEAR
FROM fact_india_macro
WHERE indicator_code = 'GOVT_DEBT_PCT_GDP'
    AND value IS NOT NULL
ORDER BY YEAR DESC
LIMIT 1);

-- ------------------------------------------------------------
-- Check C: are there any duplicate year + indicator rows?
-- ------------------------------------------------------------

SELECT year, indicator_code, COUNT(*)
FROM fact_india_macro
GROUP BY year, indicator_code
HAVING COUNT(*) > 1;

-- Expect zero rows returned.

-- ------------------------------------------------------------
-- Check D: keep every year visible with a LEFT JOIN
-- ------------------------------------------------------------

SELECT y.Year, FCM.value
FROM dim_year AS Y
LEFT JOIN fact_india_macro AS FCM
    ON Y.year = FCM.year
    AND indicator_code = 'GOVT_DEBT_PCT_GDP'
ORDER BY year;

-- A plain JOIN would only return the years that have data;
-- LEFT JOIN keeps all 63 years and shows NULL where missing.
