-- =========================================================
-- BSMM8730 Group 2
-- Canadian Retail Market Intelligence
-- MySQL Data Import Script
-- =========================================================

USE data_acq_project;

-- =========================================================
-- 1. STRUCTURED DATA
-- Statistics Canada Retail Sales
-- =========================================================

LOAD DATA LOCAL INFILE
'data/processed/retail_sales_clean.csv'
INTO TABLE retail_sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    date,
    geography,
    dguid,
    industry,
    sales_type,
    adjustment,
    unit,
    scalar_factor,
    sales_value,
    status,
    year,
    month,
    sales_millions,
    sales_billions,
    geography_level,
    naics_code
);


-- =========================================================
-- 2. SEMI-STRUCTURED DATA
-- Statistics Canada Economic Indicators JSON
-- =========================================================

LOAD DATA LOCAL INFILE
'data/processed/economic_indicators_clean.csv'
INTO TABLE economic_indicators
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    indicator_number,
    indicator,
    geo_code,
    geography,
    value_original,
    numeric_value,
    reference_period,
    release_date,
    growth_rate,
    growth_numeric,
    growth_details,
    source
);


-- =========================================================
-- 3. UNSTRUCTURED DATA
-- Competition Bureau Web Scraping
-- =========================================================

LOAD DATA LOCAL INFILE
'data/processed/web_articles_clean.csv'
INTO TABLE web_articles
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    article_id,
    title,
    publication_date,
    year,
    month,
    source,
    source_url,
    word_count,
    competition_mentions,
    price_mentions,
    grocery_mentions,
    consumer_mentions,
    online_mentions,
    competition_per_1000_words,
    price_per_1000_words,
    grocery_per_1000_words,
    consumer_per_1000_words,
    online_per_1000_words,
    article_text
);


-- =========================================================
-- 4. DATA IMPORT VALIDATION
-- =========================================================

SELECT
    'Structured' AS data_type,
    COUNT(*) AS total_rows
FROM retail_sales

UNION ALL

SELECT
    'Semi-structured',
    COUNT(*)
FROM economic_indicators

UNION ALL

SELECT
    'Unstructured',
    COUNT(*)
FROM web_articles;


-- =========================================================
-- 5. EXPECTED RESULTS
-- Structured:       69,115 rows
-- Semi-structured:      38 rows
-- Unstructured:          7 rows
-- Total:            69,160 rows
-- =========================================================
