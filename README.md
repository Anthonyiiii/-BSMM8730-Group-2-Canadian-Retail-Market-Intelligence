# -BSMM8730-Canadian-Retail-Market-Intelligence
# BSMM 8730 Group Project - Canadian Retail Market Intelligence
## Project Overview

This project analyzes Canadian retail market trends to support business decision-making. The analysis combines structured, semi-structured, and unstructured data from Statistics Canada and the Competition Bureau Canada.

The project focuses on regional retail performance, industry trends, e-commerce activity, and relevant economic indicators across Canada.

## Data Sources

### Structured Data

Statistics Canada retail trade data (Table 20-10-0056-01) is used to analyze retail sales by geography, industry, sales type, and time period.

### Semi-Structured Data

Statistics Canada Economic Indicators JSON data is used to provide additional economic context, including:

- Average weekly earnings

- Employment level

- Unemployment rate

- Consumer Price Index (CPI)

- Real GDP by expenditure

The nested JSON data is flattened, cleaned, and transformed using Python.

### Unstructured Data

Competition Bureau Canada grocery competition webpages are collected through web scraping using Python Requests and BeautifulSoup.

Article text and metadata are cleaned and transformed into analytical features such as publication date, word count, and keyword frequencies.

## Data Processing Workflow

Raw Data → Data Acquisition → Data Cleaning & Wrangling → Data Integration → MySQL → Data Analysis → Power BI

Python is used primarily for data acquisition, cleaning, transformation, and web scraping. MySQL will be used to store the final relational schema and support analytical queries. Power BI will be used for visualization and dashboard development.

## Repository Structure

- `structured_data/` – Statistics Canada retail sales data and processing files

- `semi_structured_data/` – Statistics Canada JSON economic indicator data and processing files

- `unstructured_data/` – Web scraping scripts and processed Competition Bureau data

## Team Members

- Quan Yuan – Data Analysis Lead

- Jiya Kiran Khadgi – Business Analysis & Documentation Lead

- Santiago Pinzon Niño – Data Management & Database Lead

## Course

BSMM 8730 – Data Acquisition and Management  

University of Windsor
