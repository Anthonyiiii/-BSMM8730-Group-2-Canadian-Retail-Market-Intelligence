-- ERD 1.0 import entry point has moved to scripts/import_data.py.
-- The three original CSV layouts no longer map directly to the nine base tables.
-- From the repository root, after creating an empty schema with the DDL:
-- python scripts/import_data.py --database data_acq_project_rebuild --user YOUR_USER
-- This importer loads reference/date tables first, expands five keyword counts
-- per article, handles quoted multiline CSV text, and preserves missing levels
-- as NULL. It performs full row reconciliation before committing.
-- Do not reuse the old LOAD DATA statements against this schema.
SELECT 'Run scripts/import_data.py from the repository root; see README.md' AS next_step;
