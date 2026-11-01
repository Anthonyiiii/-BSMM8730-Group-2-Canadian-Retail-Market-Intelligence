# Database design - ERD 1.0

Nine base tables and seven foreign keys reproduce the submitted ERD. Data types are hidden in the figure and listed below. The frequency view is additional to the base tables.

## Keys and relationships

| Parent | Child foreign key | Line |
|---|---|---|
| `web_articles.article_id` | `article_keyword_metrics.article_id` | Solid (identifying) |
| `keyword_info.keyword_id` | `article_keyword_metrics.keyword_id` | Solid (identifying) |
| `geography_info.geography_id` | `economic_indicators.geography_id` | Dashed (non-identifying) |
| `indicator_info.indicator_id` | `economic_indicators.indicator_id` | Dashed (non-identifying) |
| `geography_info.geography_id` | `retail_sales.geography_id` | Dashed (non-identifying) |
| `industry_info.industry_id` | `retail_sales.industry_id` | Dashed (non-identifying) |
| `date_info.publication_date` | `web_articles.publication_date` | Dashed (non-identifying) |

`economic_indicators` has one composite PK: `(source, indicator_number, geo_code, reference_period)`. `article_keyword_metrics` has one composite PK: `(article_id, keyword_id)`; both columns also belong to FKs.

Every child FK is NOT NULL, so each child references exactly one parent. A geography may have no economic observations (nine metropolitan records currently have none). In Workbench, leave the geography parent mandatory and make the economic child optional to show 0..N. Reverse engineering may restore default Mandatory display settings; SQL FKs alone do not require a parent to have a child.

## Data dictionary

### article_keyword_frequencies

| Column | SQL type | Nullable | Key | Generated expression |
|---|---|---|---|---|
| `article_id` | `int` | NO | - | `` |
| `keyword_id` | `int` | NO | - | `` |
| `keyword_name` | `varchar(50)` | NO | - | `` |
| `mention_count` | `int` | NO | - | `` |
| `word_count` | `int` | NO | - | `` |
| `per_1000_words` | `decimal(10,2)` | YES | - | `` |
### article_keyword_metrics

| Column | SQL type | Nullable | Key | Generated expression |
|---|---|---|---|---|
| `article_id` | `int` | NO | PRI | `` |
| `keyword_id` | `int` | NO | PRI | `` |
| `mention_count` | `int` | NO | - | `` |
### date_info

| Column | SQL type | Nullable | Key | Generated expression |
|---|---|---|---|---|
| `publication_date` | `date` | NO | PRI | `` |
| `year` | `smallint` | YES | - | `year(`publication_date`)` |
| `month` | `tinyint` | YES | - | `month(`publication_date`)` |
| `quarter` | `tinyint` | YES | - | `quarter(`publication_date`)` |
### economic_indicators

| Column | SQL type | Nullable | Key | Generated expression |
|---|---|---|---|---|
| `indicator_number` | `int` | NO | PRI | `` |
| `indicator_id` | `int` | NO | MUL | `` |
| `geo_code` | `varchar(10)` | NO | PRI | `` |
| `geography_id` | `int` | NO | MUL | `` |
| `value_original` | `varchar(100)` | YES | - | `` |
| `numeric_value` | `decimal(18,4)` | YES | - | `` |
| `reference_period` | `varchar(50)` | NO | PRI | `` |
| `release_date` | `date` | NO | MUL | `` |
| `growth_rate` | `varchar(30)` | YES | - | `` |
| `growth_numeric` | `decimal(10,4)` | YES | - | `` |
| `growth_details` | `varchar(100)` | YES | - | `` |
| `source` | `varchar(20)` | NO | PRI | `` |
### geography_info

| Column | SQL type | Nullable | Key | Generated expression |
|---|---|---|---|---|
| `geography_id` | `int` | NO | PRI | `` |
| `geography_name` | `varchar(100)` | NO | UNI | `` |
| `geography_level` | `varchar(50)` | NO | MUL | `` |
### indicator_info

| Column | SQL type | Nullable | Key | Generated expression |
|---|---|---|---|---|
| `indicator_id` | `int` | NO | PRI | `` |
| `indicator_name` | `varchar(100)` | NO | UNI | `` |
### industry_info

| Column | SQL type | Nullable | Key | Generated expression |
|---|---|---|---|---|
| `industry_id` | `int` | NO | PRI | `` |
| `industry_name` | `varchar(255)` | NO | MUL | `` |
| `naics_code` | `varchar(20)` | YES | - | `` |
### keyword_info

| Column | SQL type | Nullable | Key | Generated expression |
|---|---|---|---|---|
| `keyword_id` | `int` | NO | PRI | `` |
| `keyword_name` | `varchar(50)` | NO | UNI | `` |
### retail_sales

| Column | SQL type | Nullable | Key | Generated expression |
|---|---|---|---|---|
| `sales_id` | `bigint` | NO | PRI | `` |
| `date` | `date` | NO | MUL | `` |
| `geography_id` | `int` | NO | MUL | `` |
| `dguid` | `varchar(50)` | NO | - | `` |
| `industry_id` | `int` | NO | MUL | `` |
| `sales_type` | `varchar(100)` | NO | MUL | `` |
| `adjustment` | `varchar(50)` | NO | - | `` |
| `unit` | `varchar(50)` | NO | - | `` |
| `scalar_factor` | `varchar(50)` | NO | - | `` |
| `sales_value` | `decimal(15,2)` | YES | - | `` |
| `status` | `varchar(50)` | YES | - | `` |
| `year` | `int` | YES | - | `` |
| `month` | `tinyint` | YES | - | `` |
| `sales_millions` | `decimal(15,2)` | YES | - | `` |
| `sales_billions` | `decimal(15,4)` | YES | - | `` |
### web_articles

| Column | SQL type | Nullable | Key | Generated expression |
|---|---|---|---|---|
| `article_id` | `int` | NO | PRI | `` |
| `title` | `varchar(500)` | NO | - | `` |
| `publication_date` | `date` | NO | MUL | `` |
| `source` | `varchar(150)` | NO | MUL | `` |
| `source_url` | `varchar(500)` | NO | UNI | `` |
| `word_count` | `int` | NO | - | `` |
| `article_text` | `longtext` | YES | - | `` |

## Data meaning and retained fields

- `retail_sales`: one date/geography/industry/sales-type/adjustment combination, with a surrogate sales_id and a unique business key. Source sales values are in the unit/scalar recorded on the row. Retained year/month and sales_millions/sales_billions are analytical conveniences; this is selective normalization, not a claim that every table is in 3NF.
- `economic_indicators`: one source/indicator-number/geographic-code/reference-period observation. Original text and numeric fields serve different purposes. Missing CPI/GDP levels remain NULL; zero is not substituted. `growth_details` preserves monthly/12-month/quarterly comparison basis, while growth_rate retains % or pts unit labels.
- `date_info`: six distinct observed article publication dates, not a continuous calendar. Its year/month/quarter are stored generated columns. Retail year/month stay in retail_sales, and no retail-to-date_info FK is implied.
- `article_keyword_metrics`: each article has a record for each of the five selected keywords, including zero mentions. The view calculates ROUND(mention_count * 1000 / word_count, 2). Positive word counts are required.
- `geography_info`: national, provincial/territorial and metropolitan reporting areas share one key space. Current City/CMA labels are retained; more precise CMA/CMA-part categories and parent province relationships are deferred. Use geographic-level filters to prevent overlapping totals.
- `dguid` remains in retail_sales in this version. It identifies a source geography/boundary vintage, not a reporting month. No unreviewed DGUID relocation has been included.
- Article text provides context. There is no verified article-to-sales observation FK. Align reporting periods, geography, industry and measurement definitions before cross-source comparisons. The economic snapshot is limited and should not be treated as a historical series.

## Rebuild versus existing Workbench database

The repository DDL is a clean creation script. It contains no backup tables, historical ALTER/RENAME sequences, DROP DATABASE, or automatic migration of an existing instance. Rebuild into a new database and compare it before deciding how to adopt it locally. The supplied ERD image and project PDFs are preserved unchanged.
