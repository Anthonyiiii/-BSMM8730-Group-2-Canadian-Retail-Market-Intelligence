-- Exploratory query examples; Power BI implementation remains planned.
-- FR-03: national monthly retail trend, one industry and adjustment category.
SELECT r.date,r.sales_millions,r.status
FROM retail_sales r JOIN geography_info g USING(geography_id) JOIN industry_info i USING(industry_id)
WHERE g.geography_name='Canada' AND i.naics_code='44-45'
 AND r.sales_type='Total retail sales' AND r.adjustment='Unadjusted'
ORDER BY r.date;

-- FR-03: same-month province/territory comparison; excludes national/CMA rows.
SELECT g.geography_name,r.sales_millions,r.status
FROM retail_sales r JOIN geography_info g USING(geography_id) JOIN industry_info i USING(industry_id)
WHERE g.geography_level='Province/Territory' AND i.naics_code='44-45'
 AND r.date='2026-06-01' AND r.sales_type='Total retail sales' AND r.adjustment='Unadjusted'
ORDER BY r.sales_millions DESC;

-- E-commerce is national in this snapshot. Do not present provincial e-commerce.
SELECT r.date,
 MAX(CASE WHEN r.sales_type='Retail e-commerce sales' THEN r.sales_value END) AS ecommerce_thousands,
 MAX(CASE WHEN r.sales_type='Total retail sales' THEN r.sales_value END) AS total_thousands
FROM retail_sales r JOIN geography_info g USING(geography_id) JOIN industry_info i USING(industry_id)
WHERE g.geography_name='Canada' AND i.naics_code='44-45' AND r.adjustment='Unadjusted'
GROUP BY r.date ORDER BY r.date;

-- FR-04: retain the reporting period, release date, original units and growth basis.
SELECT i.indicator_name,g.geography_name,e.reference_period,e.release_date,
 e.value_original,e.numeric_value,e.growth_rate,e.growth_numeric,e.growth_details
FROM economic_indicators e JOIN geography_info g USING(geography_id) JOIN indicator_info i USING(indicator_id)
ORDER BY i.indicator_name,g.geography_name;

-- FR-05: article topic counts and frequencies; these are content signals.
SELECT a.article_id,a.title,a.publication_date,d.year,d.month,a.source,
 f.keyword_name,f.mention_count,f.per_1000_words
FROM web_articles a JOIN date_info d USING(publication_date)
JOIN article_keyword_frequencies f USING(article_id)
ORDER BY a.publication_date,a.article_id,f.keyword_id;
