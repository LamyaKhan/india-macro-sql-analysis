/* ============================================================
   INDIA MACROECONOMIC ANALYSIS
   Step 3: Build the Wide View and Calculate Metrics
   ============================================================
   Converts the long-format fact table into one row per year,
   then builds six metrics: era/category averages, YoY change
   with moving average and running total, decade rankings,
   inflation-band segmentation, above-average years, and a
   three-era comparison.
   ============================================================ */

USE INDIA_MACRO;

-- ------------------------------------------------------------
-- Convert from long to wide format (one row per year)
-- ------------------------------------------------------------

DROP VIEW IF EXISTS v_india_macro_wide;

CREATE VIEW v_india_macro_wide AS
SELECT
    FIM.YEAR,

    MAX(DY.decade) AS decade,
    MAX(DY.policy_era) AS policy_era,
    MAX(DY.crisis_period) AS crisis_period,

    MAX(CASE
        WHEN FIM.indicator_code = 'gdp_usd_bn'
        THEN FIM.value
    END) AS gdp_usd_bn,

    MAX(CASE
        WHEN FIM.indicator_code = 'gdp_growth_pct'
        THEN FIM.value
    END) AS gdp_growth_pct,

    MAX(CASE
        WHEN FIM.indicator_code = 'gdp_per_capita_usd'
        THEN FIM.value
    END) AS gdp_per_capita_usd,

    MAX(CASE
        WHEN FIM.indicator_code = 'gni_usd_bn'
        THEN FIM.value
    END) AS gni_usd_bn,

    MAX(CASE
        WHEN FIM.indicator_code = 'inflation_pct'
        THEN FIM.value
    END) AS inflation_pct,

    MAX(CASE
        WHEN FIM.indicator_code = 'govt_debt_pct_gdp'
        THEN FIM.value
    END) AS govt_debt_pct_gdp,

    MAX(CASE
        WHEN FIM.indicator_code = 'mfg_output_usd_bn'
        THEN FIM.value
    END) AS mfg_output_usd_bn,

    MAX(CASE
        WHEN FIM.indicator_code = 'mfg_pct_gdp'
        THEN FIM.value
    END) AS mfg_pct_gdp

FROM fact_india_macro AS FIM

LEFT JOIN dim_year AS DY
    ON FIM.YEAR = DY.year

GROUP BY FIM.YEAR;

SELECT * FROM v_india_macro_wide;


-- ------------------------------------------------------------
-- Metric 1 — Average value by era and category
-- (three-table join: fact -> dim_indicator -> dim_category,
--  and fact -> dim_year)
-- ------------------------------------------------------------

SELECT DY.policy_era,
    DC.category_name,
    DI.indicator_name,
    AVG(VALUE) AS Average_value
FROM fact_india_macro AS FIC
LEFT JOIN dim_indicator AS DI
    ON FIC.indicator_code = DI.indicator_code
LEFT JOIN dim_year AS DY
    ON FIC.year = DY.year
LEFT JOIN dim_category AS DC
    ON DI.category_code = DC.category_code
GROUP BY policy_era, category_name, indicator_name;


-- ------------------------------------------------------------
-- Metric 2 — Year-on-year change, 5-year moving average,
-- running total
-- ------------------------------------------------------------

SELECT year,
    LAG(gdp_usd_bn) OVER (
        ORDER BY year) AS previous_gdp,

    gdp_usd_bn - LAG(gdp_usd_bn) OVER (
        ORDER BY year) AS change_gdp,

    AVG(inflation_pct) OVER(
        ORDER BY year
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS inflation_5yr_avg,

    SUM(gdp_growth_pct) OVER(
                ORDER BY year
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_sum_growth

FROM v_india_macro_wide;


-- ------------------------------------------------------------
-- Metric 3 — Rank the best growth years inside each decade
-- ------------------------------------------------------------

SELECT *
FROM (
    SELECT
        year,
        gdp_growth_pct,
        decade,
        DENSE_RANK() OVER (
            PARTITION BY decade
            ORDER BY gdp_growth_pct DESC
        ) AS decade_rank
    FROM v_india_macro_wide
    WHERE gdp_growth_pct IS NOT NULL
) AS ranked
WHERE decade_rank IN (1, 2, 3)
ORDER BY decade, decade_rank;


-- ------------------------------------------------------------
-- Metric 4 — Segment years by inflation band
-- ------------------------------------------------------------

SELECT
    COUNT(YEAR) AS number_of_years,
    AVG(gdp_growth_pct) AS average_growth,
    CASE
        WHEN inflation_pct < 4 THEN 'Low'
        WHEN inflation_pct >= 4 AND inflation_pct < 8 THEN 'Moderate'
        ELSE 'High'
    END AS inflation_band

FROM v_india_macro_wide

WHERE inflation_pct IS NOT NULL
  AND gdp_growth_pct IS NOT NULL

GROUP BY
    CASE
        WHEN inflation_pct < 4 THEN 'Low'
        WHEN inflation_pct >= 4 AND inflation_pct < 8 THEN 'Moderate'
        ELSE 'High'
    END
HAVING COUNT(YEAR) >= 3

ORDER BY average_growth DESC;


-- ------------------------------------------------------------
-- Metric 5 — Years that beat the long-run average
-- ------------------------------------------------------------

SELECT year, overall_avg, gdp_growth_pct
FROM (
    SELECT AVG(gdp_growth_pct) OVER() AS overall_avg, year, gdp_growth_pct
    FROM v_india_macro_wide) AS Averaget
WHERE gdp_growth_pct > overall_avg
ORDER BY gdp_growth_pct DESC;


-- ------------------------------------------------------------
-- Metric 6 — Compare the three policy eras
-- ------------------------------------------------------------

SELECT policy_era, COUNT(year), AVG(gdp_growth_pct),
    AVG(inflation_pct), AVG(mfg_pct_gdp)
FROM v_india_macro_wide
GROUP BY policy_era
ORDER BY MIN(year);
