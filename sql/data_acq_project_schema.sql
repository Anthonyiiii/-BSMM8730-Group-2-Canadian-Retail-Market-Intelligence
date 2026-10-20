CREATE DATABASE IF NOT EXISTS data_acq_project
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE data_acq_project;


-- =========================================================
-- TABLE 1: STRUCTURED DATA
-- Statistics Canada Retail Sales
-- =========================================================

CREATE TABLE IF NOT EXISTS retail_sales (

    sales_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    date DATE NOT NULL,

    geography VARCHAR(100) NOT NULL,

    dguid VARCHAR(50) NOT NULL,

    industry VARCHAR(255) NOT NULL,

    sales_type VARCHAR(100) NOT NULL,

    adjustment VARCHAR(50) NOT NULL,

    unit VARCHAR(50) NOT NULL,

    scalar_factor VARCHAR(50) NOT NULL,

    sales_value DECIMAL(15,2),

    status VARCHAR(50),

    year INT,

    month TINYINT,

    sales_millions DECIMAL(15,2),

    sales_billions DECIMAL(15,4),

    geography_level VARCHAR(50) NOT NULL,

    naics_code VARCHAR(20) NOT NULL,

    CONSTRAINT unique_retail_record
    UNIQUE (
        date,
        geography,
        industry,
        sales_type,
        adjustment
    ),

    INDEX idx_retail_date (date),

    INDEX idx_retail_geography (geography),

    INDEX idx_retail_industry (naics_code),

    INDEX idx_retail_sales_type (sales_type),

    INDEX idx_retail_geography_level (geography_level)

) ENGINE = InnoDB
DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;



-- =========================================================
-- TABLE 2: SEMI-STRUCTURED DATA
-- Statistics Canada Economic Indicators JSON
-- =========================================================

CREATE TABLE IF NOT EXISTS economic_indicators (

    indicator_number INT NOT NULL,

    indicator VARCHAR(100) NOT NULL,

    geo_code VARCHAR(10) NOT NULL,

    geography VARCHAR(100) NOT NULL,

    value_original VARCHAR(100),

    numeric_value DECIMAL(18,4),

    reference_period VARCHAR(50) NOT NULL,

    release_date DATE NOT NULL,

    growth_rate VARCHAR(30),

    growth_numeric DECIMAL(10,4),

    growth_details VARCHAR(100),

    source VARCHAR(20) NOT NULL,

    PRIMARY KEY (
        source,
        indicator_number,
        geo_code,
        reference_period
    ),

    INDEX idx_economic_indicator (indicator),

    INDEX idx_economic_geography (geography),

    INDEX idx_economic_release_date (release_date),

    INDEX idx_economic_geo_code (geo_code)

) ENGINE = InnoDB
DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;



-- =========================================================
-- TABLE 3: UNSTRUCTURED DATA
-- Competition Bureau Web Scraping
-- =========================================================

CREATE TABLE IF NOT EXISTS web_articles (

    article_id INT NOT NULL,

    title VARCHAR(500) NOT NULL,

    publication_date DATE NOT NULL,

    year INT NOT NULL,

    month TINYINT NOT NULL,

    source VARCHAR(150) NOT NULL,

    source_url VARCHAR(500) NOT NULL,

    word_count INT,

    competition_mentions INT,

    price_mentions INT,

    grocery_mentions INT,

    consumer_mentions INT,

    online_mentions INT,

    competition_per_1000_words DECIMAL(10,2),

    price_per_1000_words DECIMAL(10,2),

    grocery_per_1000_words DECIMAL(10,2),

    consumer_per_1000_words DECIMAL(10,2),

    online_per_1000_words DECIMAL(10,2),

    article_text LONGTEXT,

    PRIMARY KEY (article_id),

    UNIQUE KEY unique_article_url (source_url),

    INDEX idx_web_publication_date (publication_date),

    INDEX idx_web_year (year),

    INDEX idx_web_source (source)

) ENGINE = InnoDB
DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;



-- =========================================================
-- DATABASE VALIDATION
-- =========================================================

SHOW TABLES;


-- Check structured data table

DESCRIBE retail_sales;


-- Check semi-structured data table

DESCRIBE economic_indicators;


-- Check unstructured data table

DESCRIBE web_articles;


-- Check primary keys and indexes

SHOW INDEX FROM retail_sales;

SHOW INDEX FROM economic_indicators;

SHOW INDEX FROM web_articles;


-- =========================================================
-- ROW COUNT VALIDATION
-- Run these queries after importing the CSV files
-- =========================================================

SELECT COUNT(*) AS retail_sales_rows
FROM retail_sales;


SELECT COUNT(*) AS economic_indicators_rows
FROM economic_indicators;


SELECT COUNT(*) AS web_articles_rows
FROM web_articles;
