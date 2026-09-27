# India Macroeconomic Analysis — SQL Project

A dimensional data model and analysis of India's macroeconomic indicators (1960–2022), built in MySQL, using data sourced from Kaggle / World Bank development indicators.

## What this project does

Nine raw CSV files covering India's GDP, GNI, inflation, government debt and manufacturing output were cleaned and restructured into a proper relational model — one fact table and three dimension tables — then analysed using joins, aggregate functions, subqueries, and ranking logic.

## Data model

```
dim_year ────────┐
                  │ year
                  ▼
dim_indicator ──► fact_india_macro
     │ indicator_code
     │ category_code
     ▼
dim_category
```

| Table | Type | Rows | Description |
|---|---|---|---|
| `fact_india_macro` | Fact | 567 | One row per year per indicator |
| `dim_indicator` | Dimension | 9 | Indicator name, unit, category |
| `dim_category` | Dimension | 4 | Indicator groupings (National Accounts, Prices, Fiscal, Sector) |
| `dim_year` | Dimension | 63 | Year, decade, policy era, crisis flag |

## Files in this repository

| File | What it covers |
|---|---|
| `01_schema_setup.sql` | Database and table creation, foreign keys, load verification |
| `02_data_cleaning.sql` | Completeness checks, coverage checks, duplicate checks, LEFT JOIN checks |
| `03_metrics_analysis.sql` | The wide view (long → wide format) and six metrics: era/category averages, YoY change with moving average and running total, decade rankings, inflation-band segmentation, above-average years, and a three-era comparison |
| `README.md` | This file |

## How to run

1. Run `01_schema_setup.sql` in MySQL Workbench to create the database and tables.
2. Import the four CSV files using the Table Data Import Wizard, in this order: `dim_category` → `dim_indicator` → `dim_year` → `fact_india_macro`.
3. Run `02_data_cleaning.sql` to reproduce the data quality checks.
4. Run `03_metrics_analysis.sql` to build the analytical view and run the metrics.

## Data quality notes

A few issues were found and handled during cleaning:
- Some source files used inconsistent or transposed column labelling across related indicators, which required cross-checking values before trusting a column name.
- Government debt data has genuine gaps — several years show no recorded value rather than a true zero, and these were kept as NULL rather than treated as 0.
- Duplicate-row checks were run on the fact table to confirm no year + indicator combination was loaded more than once.

## What this project demonstrates

- Designing a dimensional (fact/dimension) model from flat source files
- Writing and enforcing primary and foreign key relationships
- Data quality auditing: completeness checks, coverage checks, duplicate detection
- Reshaping data from long to wide format using conditional aggregation
- Multi-table joins across fact and dimension tables
- Window functions (`LAG`, `DENSE_RANK`, moving/running aggregates), subqueries, and `CASE`-based segmentation

## Limitations

This dataset covers one country on an annual basis, so it is suited to demonstrating SQL modelling and analysis technique rather than to statistical inference. Any figures derived from it should be treated as illustrative unless verified against the original source files.
