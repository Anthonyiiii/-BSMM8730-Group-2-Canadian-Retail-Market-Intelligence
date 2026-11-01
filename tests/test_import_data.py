"""Source checks for data loss risks introduced by the ERD 1.0 transformation."""
import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('loader',ROOT/'scripts/import_data.py')
loader=importlib.util.module_from_spec(spec);spec.loader.exec_module(loader)

class ImportTests(unittest.TestCase):
    def test_missing_levels_zero_keyword_counts_and_full_article_text(self):
        plan, frequencies=loader.prepare()
        self.assertEqual(sum(r[5] is None for r in plan['economic_indicators'][1]),2)
        self.assertEqual(len(plan['article_keyword_metrics'][1]),35)
        self.assertTrue(any(r[2]==0 for r in plan['article_keyword_metrics'][1]))
        self.assertEqual(len(plan['date_info'][1]),6)
        source=loader.read_csv(ROOT/'unstructured_data/web_articles_clean.csv')
        self.assertEqual([r[6] for r in plan['web_articles'][1]],[r['article_text'] for r in source])
        self.assertEqual(len(frequencies),35)

    def test_duplicate_business_key_rejected_before_connecting(self):
        original=loader.read_csv
        def changed(path):
            rows=original(path)
            return rows+[dict(rows[0])] if path.name=='retail_sales_clean.csv' else rows
        with patch.object(loader,'read_csv',side_effect=changed):
            with self.assertRaisesRegex(ValueError,'Duplicate retail business key'):loader.prepare()

    def test_inconsistent_article_frequency_rejected(self):
        original=loader.read_csv
        def changed(path):
            rows=original(path)
            if path.name=='web_articles_clean.csv':rows[0]['competition_per_1000_words']='999'
            return rows
        with patch.object(loader,'read_csv',side_effect=changed):
            with self.assertRaisesRegex(ValueError,'frequency disagrees'):loader.prepare()

if __name__=='__main__':unittest.main()
