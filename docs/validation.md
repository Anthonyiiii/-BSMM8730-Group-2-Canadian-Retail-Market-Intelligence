# ERD 1.0 rebuild validation

Validated on 2026-11-01 using Python 3.9, mysql-connector-python 9.4.0 and an isolated MySQL 8.3.0 server. The temporary server had a separate data directory, used a local socket with networking disabled, and did not operate on the existing Workbench database.

## Results

- Clean DDL creation succeeded: nine base tables, nine primary keys, seven foreign keys and one derived view.
- Source checks passed for all three tracked cleaned CSV files.
- First import committed successfully. Every imported field was reconciled against its transformed CSV value, including article LONGTEXT and decimal values.
- Counts: retail 69,115; economic 38; articles 7; geographies 23; industries 30; indicators 5; dates 6; keywords 5; article-keyword metrics 35.
- All six generated date rows matched their year/month/quarter values. No unmatched article dates were found.
- Two absent economic level values remained SQL NULL. Original growth text, numeric growth and growth_details were preserved.
- All 35 derived article keyword frequencies matched the original cleaned CSV to two decimal places; zero-count rows were retained.
- Repeating the import on the unchanged populated database performed read-only reconciliation, with no duplicate inserts or overwritten records.
- A deliberate change to one keyword count caused a repeated import to reject the differing populated target without overwriting it. The test-only change was then restored.
- A forced CHECK-constraint failure at the final junction-table import rolled back all rows in all nine tables, including the 69,115 previously inserted retail rows within the transaction.
- Three source-quality tests passed: missing-level/zero-count/full-text preservation, duplicate retail business-key rejection, and article-frequency inconsistency rejection.
- All five example queries in sql/analysis_queries.sql executed successfully.
- git diff --check passed.

## Reproduction

Follow the fresh-database commands in the root README, then run:

```bash
python -m unittest discover -s tests -v
python scripts/import_data.py --database YOUR_REBUILD_DATABASE --user YOUR_USER --validate-only
mysql -u YOUR_USER -p YOUR_REBUILD_DATABASE < sql/validation.sql
mysql -u YOUR_USER -p YOUR_REBUILD_DATABASE < sql/analysis_queries.sql
```

These checks establish snapshot loading and query execution. They do not establish that all upstream scraped text is free of repeated webpage content, that source dates were manually verified, that Power BI is implemented, or that formal performance targets have been met.
