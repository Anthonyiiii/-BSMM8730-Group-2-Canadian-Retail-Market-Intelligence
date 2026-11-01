-- Read-only snapshot checks. Select your rebuild database before running.
SELECT table_name,actual_rows,expected_rows,IF(actual_rows=expected_rows,'PASS','REVIEW') result
FROM (
 SELECT 'retail_sales' table_name,COUNT(*) actual_rows,69115 expected_rows FROM retail_sales
 UNION ALL SELECT 'economic_indicators',COUNT(*),38 FROM economic_indicators
 UNION ALL SELECT 'web_articles',COUNT(*),7 FROM web_articles
 UNION ALL SELECT 'geography_info',COUNT(*),23 FROM geography_info
 UNION ALL SELECT 'industry_info',COUNT(*),30 FROM industry_info
 UNION ALL SELECT 'indicator_info',COUNT(*),5 FROM indicator_info
 UNION ALL SELECT 'date_info',COUNT(*),6 FROM date_info
 UNION ALL SELECT 'keyword_info',COUNT(*),5 FROM keyword_info
 UNION ALL SELECT 'article_keyword_metrics',COUNT(*),35 FROM article_keyword_metrics
) counts;
SELECT COUNT(*) AS missing_article_dates FROM web_articles a LEFT JOIN date_info d USING(publication_date) WHERE d.publication_date IS NULL;
SELECT COUNT(*) AS economic_null_levels FROM economic_indicators WHERE numeric_value IS NULL; -- 2, not zero-filled
SELECT COUNT(*) AS date_attribute_errors FROM date_info WHERE year<>YEAR(publication_date) OR month<>MONTH(publication_date) OR quarter<>QUARTER(publication_date);
SELECT COUNT(*) AS active_foreign_keys FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND REFERENCED_TABLE_NAME IS NOT NULL; -- 7
SELECT COUNT(*) AS frequency_rows FROM article_keyword_frequencies; -- 35 including zero counts
-- Full row-by-row source reconciliation: scripts/import_data.py --validate-only
