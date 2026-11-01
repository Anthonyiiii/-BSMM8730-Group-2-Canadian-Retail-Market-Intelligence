#!/usr/bin/env python3
"""Rebuild/reconcile the ERD 1.0 snapshot from the three tracked cleaned CSVs."""
import argparse
import csv
from datetime import date
from decimal import Decimal, ROUND_HALF_UP
import getpass
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
KEYWORDS = ('competition', 'price', 'grocery', 'consumer', 'online')


def number(value, places):
    return None if not value.strip() else Decimal(value).quantize(Decimal(1).scaleb(-places))


def read_csv(path):
    with path.open(encoding='utf-8-sig', newline='') as stream:
        return list(csv.DictReader(stream))


def require(condition, message):
    if not condition:
        raise ValueError(message)


def prepare(root=ROOT):
    retail = read_csv(root / 'structured_data/retail_sales_clean.csv')
    econ = read_csv(root / 'semi_structured_data/economic_indicators_clean.csv')
    articles = read_csv(root / 'unstructured_data/web_articles_clean.csv')
    require(retail and econ and articles, 'A required dataset is empty')
    geo_levels = {}
    for row in retail:
        geo = row['geography'].strip()
        level = row['geography_level'].strip()
        require(geo and level, 'Missing geography or geography level')
        require(geo not in geo_levels or geo_levels[geo] == level, 'Conflicting geography levels')
        geo_levels[geo] = level
    require(all(r['geography'].strip() in geo_levels for r in econ), 'Unmapped economic geography')
    geos = {name: i for i, name in enumerate(sorted(geo_levels), 1)}
    industries = {key: i for i, key in enumerate(sorted({(r['industry'].strip(), r['naics_code'].strip()) for r in retail}), 1)}
    indicators = {name: i for i, name in enumerate(sorted({r['indicator'].strip() for r in econ}), 1)}
    plan = {}
    def add(table, columns, rows):
        plan[table] = (columns.split(), rows)
    add('geography_info', 'geography_id geography_name geography_level', [(i, name, geo_levels[name]) for name, i in geos.items()])
    add('industry_info', 'industry_id industry_name naics_code', [(i, name, code or None) for (name, code), i in industries.items()])
    add('indicator_info', 'indicator_id indicator_name', [(i, name) for name, i in indicators.items()])
    add('date_info', 'publication_date', [(d,) for d in sorted({date.fromisoformat(r['publication_date']) for r in articles})])
    add('keyword_info', 'keyword_id keyword_name', list(enumerate(KEYWORDS, 1)))
    sales = []
    natural_keys = set()
    for i, r in enumerate(retail, 1):
        d = date.fromisoformat(r['date'])
        require((int(r['year']), int(r['month'])) == (d.year, d.month), 'Retail date attributes disagree')
        key = (d, geos[r['geography'].strip()], industries[(r['industry'].strip(), r['naics_code'].strip())], r['sales_type'], r['adjustment'])
        require(key not in natural_keys, 'Duplicate retail business key')
        natural_keys.add(key)
        sales.append((i, d, key[1], r['dguid'], key[2], r['sales_type'], r['adjustment'], r['unit'], r['scalar_factor'], number(r['sales_value'], 2), r['status'], int(r['year']), int(r['month']), number(r['sales_millions'], 2), number(r['sales_billions'], 4)))
    add('retail_sales', 'sales_id date geography_id dguid industry_id sales_type adjustment unit scalar_factor sales_value status year month sales_millions sales_billions', sales)
    observations = []
    observation_keys = set()
    for r in econ:
        key = (r['source'], int(r['indicator_number']), r['geo_code'], r['reference_period'])
        require(key not in observation_keys, 'Duplicate economic observation key')
        observation_keys.add(key)
        level = number(r['numeric_value'], 4)
        require(bool(r['value_original'].strip()) or level is None, 'Absent economic level must remain NULL')
        observations.append((int(r['indicator_number']), indicators[r['indicator'].strip()], r['geo_code'], geos[r['geography'].strip()], r['value_original'], level, r['reference_period'], date.fromisoformat(r['release_date']), r['growth_rate'], number(r['growth_numeric'], 4), r['growth_details'], r['source']))
    add('economic_indicators', 'indicator_number indicator_id geo_code geography_id value_original numeric_value reference_period release_date growth_rate growth_numeric growth_details source', observations)
    content, metrics, frequencies = [], [], []
    ids, urls = set(), set()
    for r in articles:
        article_id, words = int(r['article_id']), int(r['word_count'])
        d = date.fromisoformat(r['publication_date'])
        require(article_id not in ids and r['source_url'] not in urls, 'Duplicate article ID or URL')
        ids.add(article_id); urls.add(r['source_url'])
        require(words > 0 and words == len(r['article_text'].split()), 'Article word count disagrees with text')
        require((int(r['year']), int(r['month'])) == (d.year, d.month), 'Article date attributes disagree')
        content.append((article_id, r['title'], d, r['source'], r['source_url'], words, r['article_text']))
        for keyword_id, name in enumerate(KEYWORDS, 1):
            count = int(r[name + '_mentions'])
            require(count >= 0, 'Negative keyword count')
            frequency = (Decimal(count) * 1000 / words).quantize(Decimal('.01'), rounding=ROUND_HALF_UP)
            require(frequency == number(r[name + '_per_1000_words'], 2), 'Source keyword frequency disagrees')
            metrics.append((article_id, keyword_id, count))
            frequencies.append((article_id, keyword_id, name, count, words, frequency))
    add('web_articles', 'article_id title publication_date source source_url word_count article_text', content)
    add('article_keyword_metrics', 'article_id keyword_id mention_count', metrics)
    return plan, frequencies


def reconcile(cursor, plan, frequencies):
    """Compare every imported value, including long text, with the prepared CSV rows."""
    for table, (columns, expected) in plan.items():
        cursor.execute('SELECT ' + ','.join('`'+c+'`' for c in columns) + ' FROM `' + table + '`')
        actual = cursor.fetchall()
        require(len(actual) == len(expected) and set(actual) == set(expected), 'Row reconciliation failed: ' + table)
    cursor.execute('SELECT publication_date,year,month,quarter FROM date_info')
    for d, y, m, q in cursor.fetchall():
        require((y, m, q) == (d.year, d.month, (d.month-1)//3+1), 'Generated date attribute mismatch')
    cursor.execute('SELECT article_id,keyword_id,keyword_name,mention_count,word_count,per_1000_words FROM article_keyword_frequencies')
    require(set(cursor.fetchall()) == set(frequencies), 'Frequency view reconciliation failed')
    cursor.execute("SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND REFERENCED_TABLE_NAME IS NOT NULL")
    require(cursor.fetchone()[0] == 7, 'Expected seven FK relationships')
    cursor.execute("SELECT REFERENCED_COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='web_articles' AND COLUMN_NAME='publication_date' AND REFERENCED_TABLE_NAME='date_info'")
    require(cursor.fetchall() == [('publication_date',)], 'Article date FK target mismatch')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--database', required=True, help='Explicit target database; create it separately with the DDL')
    parser.add_argument('--user', default=os.getenv('MYSQL_USER', getpass.getuser()))
    parser.add_argument('--host', default=os.getenv('MYSQL_HOST', '127.0.0.1'))
    parser.add_argument('--port', default=3306, type=int)
    parser.add_argument('--socket', help='Optional local Unix socket')
    parser.add_argument('--check-csv', action='store_true', help='Validate CSVs only; no database connection')
    parser.add_argument('--validate-only', action='store_true', help='Read-only reconciliation against a populated target')
    args = parser.parse_args()
    plan, frequencies = prepare()
    counts = {t: len(rows) for t, (_, rows) in plan.items()}
    print(json.dumps({'expected_rows': counts}, indent=2))
    if args.check_csv:
        return
    import mysql.connector
    password = os.getenv('MYSQL_PASSWORD')
    if password is None:
        password = getpass.getpass('MySQL password (not stored): ')
    config = dict(user=args.user, password=password, database=args.database, host=args.host, port=args.port, charset='utf8mb4', autocommit=False)
    if args.socket:
        config['unix_socket'] = args.socket
    connection = mysql.connector.connect(**config)
    try:
        cursor = connection.cursor()
        # Serialise this importer for the selected database; never touch another schema.
        cursor.execute('SELECT GET_LOCK(%s, 10)', ('bsmm8730:'+args.database,))
        require(cursor.fetchone()[0] == 1, 'Another import is active')
        cursor.execute('SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_TYPE=\'BASE TABLE\'')
        require({r[0] for r in cursor.fetchall()} == set(plan), 'Target must contain exactly the ERD 1.0 base tables; use a fresh rebuild database')
        populated = False
        for table in plan:
            cursor.execute('SELECT COUNT(*) FROM `'+table+'`')
            populated |= cursor.fetchone()[0] > 0
        if populated or args.validate_only:
            reconcile(cursor, plan, frequencies)
            print('PASS: all source rows, generated dates and frequencies match; no writes performed.')
            return
        for table, (columns, rows) in plan.items():
            sql = 'INSERT INTO `'+table+'` ('+','.join('`'+c+'`' for c in columns)+') VALUES ('+','.join(['%s']*len(columns))+')'
            for start in range(0, len(rows), 1000):
                cursor.executemany(sql, rows[start:start+1000])
        reconcile(cursor, plan, frequencies)
        connection.commit()
        print('PASS: atomic import committed; all source rows, dates and frequencies reconciled.')
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()  # Releases the advisory lock, including on failure.


if __name__ == '__main__':
    main()
