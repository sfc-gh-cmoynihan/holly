# Agent Holly - Snowflake Assets

This repository contains all the assets used by the Agent Holly Cortex Agent for financial research and analysis.

## Repository Structure

```
holly/
├── cortex_agent/              # Cortex Agent definition
│   └── HOLLY.sql              # Holly agent DDL
├── cortex_analyst/            # Semantic Views (Cortex Analyst)
│   ├── STOCK_PRICE_TIMESERIES_SV.sql
│   └── SP500.sql
├── cortex_search/             # Cortex Search Service definitions
│   ├── EDGAR_FILINGS.sql      # SEC filings search service
│   └── TRANSCRIPTS.sql        # Expert transcripts search service
├── data/                      # Table DDL and sample data
│   ├── STRUCTURED_SP500_COMPANIES.sql
│   ├── STRUCTURED_STOCK_PRICE_TIMESERIES.sql
│   ├── SEMI_STRUCTURED_EDGAR_FILINGS.sql
│   ├── UNSTRUCTURED_TB_TRANSCRIPTS.sql
│   ├── UNSTRUCTURED_DOCS_CHUNKS_TABLE.sql
│   └── SP500_COMPANIES.csv    # Sample company data
└── README.md
```

## Cortex Agent: HOLLY

**Location:** `SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY`

Holly is a financial research assistant that orchestrates across multiple data sources:

### Tools

| Tool | Type | Description |
|------|------|-------------|
| SEC_FILINGS_SEARCH | Cortex Search | Search SEC EDGAR filings (10-K, 10-Q, 8-K) |
| TRANSCRIPTS_SEARCH | Cortex Search | Search Third Bridge expert transcripts |
| STOCK_PRICES | Cortex Analyst | Query historical stock price data (158M+ rows) |
| SP500_COMPANIES | Cortex Analyst | Query S&P 500 company fundamentals |

### Sample Questions

- "What did Amazon announce in their latest 10-K filing?"
- "Find expert insights on cloud computing trends"
- "Show me Microsoft's stock price trend for the last 30 days"
- "Which S&P 500 companies have the highest revenue growth?"
- "Compare EBITDA for tech companies in the S&P 500"

## Database: COLM_DB

### Schemas and Tables

| Schema | Table | Row Count | Description |
|--------|-------|-----------|-------------|
| STRUCTURED | STOCK_PRICE_TIMESERIES | 158,604,608 | Historical stock prices with daily OHLC data |
| STRUCTURED | SP500_COMPANIES | 502 | S&P 500 company information and financials |
| SEMI_STRUCTURED | EDGAR_FILINGS | 379,661 | SEC EDGAR filings text data |
| UNSTRUCTURED | TB_TRANSCRIPTS | 118 | Third Bridge expert interview transcripts |
| UNSTRUCTURED | DOCS_CHUNKS_TABLE | 460 | Document chunks for RAG (Snowflake 10-Q) |

### Cortex Search Services

1. **TRANSCRIPTS** (`COLM_DB.UNSTRUCTURED.TRANSCRIPTS`)
   - Search column: TITLE
   - Attributes: TITLE, AGENDA, CONTENT_TYPE, TARGET_COMPANIES, STARTS_AT, TRANSCRIPT_URL, RELEVANT_COMPANIES
   - Source: TB_TRANSCRIPTS table
   - Embedding model: snowflake-arctic-embed-l-v2.0

2. **EDGAR_FILINGS** (`COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS`)
   - Search column: COMPANY_NAME
   - Attributes: COMPANY_NAME, ANNOUNCEMENT_TYPE, FILED_DATE, FISCAL_PERIOD, FISCAL_YEAR, ITEM_NUMBER, ITEM_TITLE
   - Source: EDGAR_FILINGS table
   - Embedding model: snowflake-arctic-embed-l-v2.0

### Semantic Views (Cortex Analyst)

1. **STOCK_PRICE_TIMESERIES_SV** (`COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV`)
   - Facts: VALUE
   - Dimensions: ASSET_CLASS, PRIMARY_EXCHANGE_CODE, PRIMARY_EXCHANGE_NAME, TICKER, VARIABLE, VARIABLE_NAME, DATE, EVENT_TIMESTAMP_UTC
   - Filters: major_tech_stocks (AMZN, MSFT, SNOW)

2. **SP500** (`COLM_DB.STRUCTURED.SP500`)
   - Facts: CURRENTPRICE, REVENUEGROWTH
   - Dimensions: CITY, COUNTRY, EBITDA, EXCHANGE, FULLTIMEEMPLOYEES, INDUSTRY, LONGBUSINESSSUMMARY, LONGNAME, MARKETCAP, SECTOR, SHORTNAME, STATE, SYMBOL, WEIGHT
   - Verified queries included for common analytical questions

## Data Sources

- **Stock Prices**: Daily OHLC data from multiple exchanges
- **Company Data**: S&P 500 constituent information
- **SEC Filings**: EDGAR filings including 10-K, 10-Q reports
- **Expert Transcripts**: Third Bridge expert interviews on technology, finance, and other sectors
- **Documents**: Snowflake Q3 2026 10-Q filing (chunked for RAG)

## Deployment

To recreate these assets in Snowflake:

1. Create the database and schemas:
```sql
CREATE DATABASE IF NOT EXISTS COLM_DB;
CREATE SCHEMA IF NOT EXISTS COLM_DB.STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.SEMI_STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.UNSTRUCTURED;
```

2. Run the DDL files in `data/` to create tables

3. Load data into tables (sample CSV provided for SP500_COMPANIES)

4. Create Cortex Search services using files in `cortex_search/`

5. Create Semantic Views using files in `cortex_analyst/`

6. Create the Holly Cortex Agent:
```sql
-- Run cortex_agent/HOLLY.sql
```

## Notes

- Large tables (STOCK_PRICE_TIMESERIES, EDGAR_FILINGS) data not included due to size
- Sample data provided for SP500_COMPANIES (top companies by weight)
- Semantic view extensions contain sample values and verified queries for Cortex Analyst
- Holly agent requires access to Snowflake Intelligence (AI & ML > Snowflake Intelligence)
