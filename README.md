# Canadian Retail Market Intelligence
### BSMM 8730 – Data Acquisition and Management | Group 2
University of Windsor

## Project Overview

This project analyzes Canadian retail market trends to support data-driven business decisions.

It combines structured, semi-structured, and unstructured data to investigate regional retail performance, industry trends, e-commerce activity, economic conditions, and grocery market competition.

## Data Sources

| Data Type | Source | Description | Records |
|---|---|---|---:|
| Structured | Statistics Canada | Monthly retail sales by province and industry | 69,115 |
| Semi-structured | Statistics Canada | Economic indicators (JSON) | 38 |
| Unstructured | Competition Bureau Canada | Web-scraped grocery competition articles | 7 |

### Data Preparation

- **Structured:** Cleaned retail sales CSV data using Python and Pandas.
- **Semi-structured:** Parsed and flattened JSON data containing economic indicators.
- **Unstructured:** Used Requests and BeautifulSoup for web scraping, text cleaning, and keyword frequency analysis.

## Project Workflow

Data Acquisition → Data Cleaning & Wrangling → MySQL Database → Data Validation → Data Integration → SQL Analysis → Power BI

## Database Implementation

A MySQL database named `data_acq_project` has been created with three tables:

| Table | Records |
|---|---:|
| `retail_sales` | 69,115 |
| `economic_indicators` | 38 |
| `web_articles` | 7 |
| **Total** | **69,160** |

Database scripts are available in the `sql/` directory:

- `data_acq_project_schema.sql` – Database tables, keys, and indexes.
- `import_data.sql` – Import scripts for the three cleaned datasets.

All three datasets have been successfully imported into MySQL.

## Repository Structure

- `structured_data/` – Retail sales data and processing files
- `semi_structured_data/` – Economic indicators and JSON processing
- `unstructured_data/` – Web scraping and text processing
- `sql/` – Database schema and SQL scripts

## Tools and Technologies

- **Python / Pandas:** Data acquisition, cleaning, and transformation
- **Requests / BeautifulSoup:** Web scraping
- **MySQL / SQL:** Database management and analysis
- **Power BI:** Data visualization (planned)
- **GitHub:** Version control and collaboration

## Project Progress

| Phase | Status |
|---|---|
| Data Acquisition | Completed |
| Data Cleaning & Wrangling | Initial processing completed |
| Web Scraping | Completed |
| MySQL Database Implementation | Completed |
| Data Validation | In Progress |
| Data Integration | Planned |
| SQL Analysis | Planned |
| Power BI Dashboard | Planned |

## Team Members

- **Quan Yuan** – Data Analysis Lead
- **Jiya Kiran Khadgi** – Business Analysis & Documentation Lead
- **Santiago Pinzon Niño** – Data Management & Database Lead

## Data Sources and References

- Statistics Canada – Monthly Retail Trade Sales (Table 20-10-0056-01)
- Statistics Canada – Economic Indicators JSON
- Competition Bureau Canada – Grocery Competition Market Studies
