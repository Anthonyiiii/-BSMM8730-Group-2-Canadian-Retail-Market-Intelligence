# Requirements and implementation status

The supplied PDFs are preserved as authored. This mapping explains how the repository implements the current nine-table design; it does not revise the approved requirements.

| Requirement | Implementation evidence | Remaining work |
|---|---|---|
| FR-01 Store prepared datasets | Current DDL and transactional importer; three source datasets populate nine related tables | No claim that every reference/junction row corresponds to one CSV row |
| FR-02 Validate stored data | Full row reconciliation, generated-date and frequency comparisons; validation.sql | Extend snapshot checks when source data changes |
| FR-03 Retrieve/filter retail | analysis_queries.sql: monthly national and same-month provincial examples | Final business questions and benchmark timings |
| FR-04 Analyze economic indicators | Query retains geographic scope, source period, original/numeric measures and growth basis | Historical comparisons need additional compatible observations |
| FR-05 Analyze articles | Keyword junction table and derived frequency view; title/source/date retrieval | Review repeated scraped sections and date extraction before wider interpretation |
| FR-06 Present market trends | Query outputs can be exported/connected to Power BI | Dashboards and value reconciliation remain planned |
| NFR-01 Integrity | Nine PKs, seven FKs, retail business-key uniqueness, unique article URLs and nonnegative metric counts | Parent minimum participation in ERD is a business rule, not an SQL FK guarantee |
| NFR-02 Quality | NULL economic levels preserved, CSV date/metric checks, row reconciliation | Source collection limitations remain documented |
| NFR-03 Security | Prompted/environment credentials; no credentials in added code | Configure access on each actual deployment |
| NFR-04 Performance | Date/geography/industry indexes; batch import | Formal benchmarks and dashboard responsiveness not yet assessed |
| NFR-05 Reliability | Repeat import is read-only when snapshot matches; failures roll back | Changed snapshots use a separate rebuild database |
| NFR-06 Maintainability | Relative paths, documented schema/import and tests | Existing exploratory notebooks retain original local paths |
| NFR-07 Compliance | Original source files and per-article URLs retained | Team must verify source-use requirements for subsequent collection |

## Document clarifications for the next revision

1. The row-count criteria in the requirements and Design sections 2.3/4.4 apply directly to the three source-level tables. Reference and junction counts are derived (e.g. seven articles generate 35 article-keyword rows).
2. Design section 7.2 describes calculating frequency. The cleaned CSV retains frequency as preparation evidence; MySQL stores mention counts and calculates frequency in a view. The importer requires positive word counts and rejects invalid articles instead of treating division by zero as meaningful zero frequency.
3. The date table contains observed publication dates, with generated year/month/quarter. It is not linked to retail dates in ERD 1.0.
4. Shared geography keys do not establish comparable reporting periods or units. Articles have no source-defined record-level mapping to individual retail/economic observations.
5. The supplied dashboard layouts are a design, not evidence of a deployed Power BI dashboard.
