-- ERD 1.0: run in a NEW, empty database selected by the client.
-- This file intentionally fails on existing tables; it is not an in-place migration.
-- MySQL 8.0.16+; validated on MySQL 8.3. Never run historical SQL File 6 wholesale.
CREATE TABLE geography_info (
 geography_id INT AUTO_INCREMENT PRIMARY KEY,
 geography_name VARCHAR(100) NOT NULL UNIQUE,
 geography_level VARCHAR(50) NOT NULL,
 INDEX idx_geography_level (geography_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE industry_info (
 industry_id INT AUTO_INCREMENT PRIMARY KEY,
 industry_name VARCHAR(255) NOT NULL,
 naics_code VARCHAR(20),
 UNIQUE KEY unique_industry (industry_name,naics_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE indicator_info (
 indicator_id INT AUTO_INCREMENT PRIMARY KEY,
 indicator_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE retail_sales (
    sales_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    geography_id INT NOT NULL,
    dguid VARCHAR(50) NOT NULL,
    industry_id INT NOT NULL,
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
    CONSTRAINT unique_retail_record UNIQUE
        (date, geography_id, industry_id, sales_type, adjustment),
    INDEX idx_retail_date (date),
    INDEX idx_retail_geography (geography_id),
    INDEX idx_retail_industry (industry_id),
    INDEX idx_retail_sales_type (sales_type),
    CONSTRAINT fk_retail_geography_normalized FOREIGN KEY (geography_id)
        REFERENCES geography_info(geography_id),
    CONSTRAINT fk_retail_industry_normalized FOREIGN KEY (industry_id)
        REFERENCES industry_info(industry_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE economic_indicators (
    indicator_number INT NOT NULL,
    indicator_id INT NOT NULL,
    geo_code VARCHAR(10) NOT NULL,
    geography_id INT NOT NULL,
    value_original VARCHAR(100),
    numeric_value DECIMAL(18,4),
    reference_period VARCHAR(50) NOT NULL,
    release_date DATE NOT NULL,
    growth_rate VARCHAR(30),
    growth_numeric DECIMAL(10,4),
    growth_details VARCHAR(100),
    source VARCHAR(20) NOT NULL,
    PRIMARY KEY (source, indicator_number, geo_code, reference_period),
    INDEX idx_economic_indicator (indicator_id),
    INDEX idx_economic_geography (geography_id),
    INDEX idx_economic_release_date (release_date),
    INDEX idx_economic_geo_code (geo_code),
    CONSTRAINT fk_economic_geography_normalized FOREIGN KEY (geography_id)
        REFERENCES geography_info(geography_id),
    CONSTRAINT fk_economic_indicator_normalized FOREIGN KEY (indicator_id)
        REFERENCES indicator_info(indicator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE date_info (
 publication_date DATE PRIMARY KEY,
 year SMALLINT GENERATED ALWAYS AS (YEAR(publication_date)) STORED,
 month TINYINT GENERATED ALWAYS AS (MONTH(publication_date)) STORED,
 quarter TINYINT GENERATED ALWAYS AS (QUARTER(publication_date)) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE web_articles (
    article_id INT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    publication_date DATE NOT NULL,
    source VARCHAR(150) NOT NULL,
    source_url VARCHAR(500) NOT NULL,
    word_count INT NOT NULL,
    article_text LONGTEXT,
    UNIQUE KEY unique_article_url (source_url),
    INDEX idx_web_publication_date (publication_date),
    INDEX idx_web_source (source),
    CONSTRAINT chk_article_word_count_positive CHECK (word_count>0),
    CONSTRAINT fk_article_publication_date_observed FOREIGN KEY (publication_date)
        REFERENCES date_info(publication_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE keyword_info (
    keyword_id INT AUTO_INCREMENT PRIMARY KEY,
    keyword_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE article_keyword_metrics (
    article_id INT NOT NULL,
    keyword_id INT NOT NULL,
    mention_count INT NOT NULL,
    PRIMARY KEY (article_id,keyword_id),
    INDEX idx_article_keyword_keyword (keyword_id),
    CONSTRAINT chk_article_keyword_count CHECK (mention_count>=0),
    CONSTRAINT fk_article_keyword_article FOREIGN KEY (article_id)
        REFERENCES web_articles(article_id),
    CONSTRAINT fk_article_keyword_keyword FOREIGN KEY (keyword_id)
        REFERENCES keyword_info(keyword_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE VIEW article_keyword_frequencies AS
SELECT m.article_id,m.keyword_id,k.keyword_name,m.mention_count,a.word_count,
       CAST(ROUND(m.mention_count*1000.0/NULLIF(a.word_count,0),2) AS DECIMAL(10,2)) AS per_1000_words
FROM article_keyword_metrics m
JOIN web_articles a ON a.article_id=m.article_id
JOIN keyword_info k ON k.keyword_id=m.keyword_id;
