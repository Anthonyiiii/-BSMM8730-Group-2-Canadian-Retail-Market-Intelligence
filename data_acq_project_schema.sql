CREATE DATABASE IF NOT EXISTS data_acq_project;

USE data_acq_project;


CREATE TABLE retail_sales (
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
    naics_code VARCHAR(20) NOT NULL
);


CREATE TABLE economic_indicators (
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
    )
);


CREATE TABLE web_articles (
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

    PRIMARY KEY (article_id)
);
