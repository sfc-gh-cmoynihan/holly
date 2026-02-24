# Holly - Financial Research Assistant

**Author:** Colm Moynihan  
**Date:** 23rd February 2026  
**Version:** 1.0

> **Disclaimer:** This is a custom demo of an AI-powered financial research agent built for Financial Services clients. The code is provided under an open source license with no guarantee of maintenance, security updates, bug fixes, or customer support.

---

## Overview

**Holly** is a self-service AI assistant that enables portfolio managers, analysts, and traders to perform comprehensive stock research using natural language. Built on Snowflake's Cortex platform, Holly orchestrates across multiple data sources to deliver actionable investment insights.

### Business Value

- **Self-Service Research** - Democratize access to financial data without SQL knowledge
- **Faster Decision Making** - Get answers in seconds, not hours
- **Comprehensive Analysis** - Combine quantitative data with qualitative insights
- **Reduced Operational Risk** - Consistent, auditable research process

## Architecture

```
                         ┌──────────────────────────┐
                         │      Agent Holly         │
                         │    (Cortex Agent)        │
                         └────────────┬─────────────┘
                                      │
            ┌─────────────────────────┼─────────────────────────┐
            │                         │                         │
            ▼                         ▼                         ▼
┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│  Cortex Search    │    │  Cortex Analyst   │    │  Cortex Analyst   │
│                   │    │                   │    │                   │
│ • SEC Filings     │    │ • Stock Prices    │    │ • S&P 500 Data    │
│ • Transcripts     │    │ • Historical Data │    │ • Fundamentals    │
└───────────────────┘    └───────────────────┘    └───────────────────┘
```

## Tools & Capabilities

| Tool | Type | Data Source | Use Cases |
|------|------|-------------|-----------|
| **SEC_FILINGS_SEARCH** | Cortex Search | SEC EDGAR | Company announcements, 10-K/10-Q analysis, regulatory disclosures |
| **PUBLIC_TRANSCRIPTS_SEARCH** | Cortex Search | Cybersyn (S&P 500 + SNOW) | Public earnings calls, investor conferences |
| **TB_TRANSCRIPTS_SEARCH** | Cortex Search | Third Bridge | Expert opinions, market commentary, qualitative research |
| **STOCK_PRICES** | Cortex Analyst | Stock Price Timeseries | Historical prices, OHLC analysis, returns calculations |
| **SP500_COMPANIES** | Cortex Analyst | 502 companies | Fundamentals, sector analysis, company screening |

## Repository Structure

```
holly/
├── cortex_agent/
│   └── HOLLY.sql              # Agent DDL with tool configuration
├── cortex_analyst/
│   ├── STOCK_PRICE_TIMESERIES_SV.sql
│   ├── STOCK_PRICE_TIMESERIES_IT_SV.sql
│   └── SP500.sql
├── cortex_search/
│   ├── EDGAR_FILINGS.sql
│   └── TRANSCRIPTS.sql
├── data/
│   ├── SEMI_STRUCTURED_EDGAR_FILINGS.sql
│   ├── STRUCTURED_SP500_COMPANIES.sql
│   ├── STRUCTURED_STOCK_PRICE_TIMESERIES.sql
│   ├── UNSTRUCTURED_TB_TRANSCRIPTS.sql
│   ├── UNSTRUCTURED_DOCS_CHUNKS_TABLE.sql
│   └── SP500_COMPANIES.csv
├── INSTALL.sql                # Complete installation script
├── DEMO_SCRIPT.md
└── README.md
```

## Deployment

### Prerequisites

- Snowflake account with ACCOUNTADMIN access
- Access to `SNOWFLAKE_PUBLIC_DATA_PAID` for SEC filings and stock data
- Access to Third Bridge data (optional, for private transcripts)

### Quick Install

Run the complete installation script:

```sql
!source INSTALL.sql
```

### Manual Installation

1. **Create Database and Schemas**
```sql
CREATE DATABASE IF NOT EXISTS COLM_DB;
CREATE SCHEMA IF NOT EXISTS COLM_DB.STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.SEMI_STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.UNSTRUCTURED;
```

2. **Run DDL files from data/ folder**
3. **Create Cortex Search Services**
4. **Create Semantic Views**
5. **Deploy Holly Agent**

### Access Holly

Navigate to **AI & ML > Snowflake Intelligence** in Snowsight to interact with Holly.

## Sample Conversations

**Stock Analysis**
```
User: "What is Microsoft's stock price trend over the last 30 days?"
Holly: [Queries STOCK_PRICES, returns price analysis]
```

**Company Research**
```
User: "Find the top 5 S&P 500 companies by revenue growth"
Holly: [Queries SP500_COMPANIES, returns ranked list]
```

**SEC Filing Search**
```
User: "What did Amazon announce in their latest 10-K filing?"
Holly: [Searches SEC_FILINGS, returns key announcements]
```

**Multi-Source Research**
```
User: "Give me a comprehensive view of NVIDIA"
Holly: [Combines all tools for complete analysis]
```

## Security & Access

Holly operates within Snowflake's security model:
- Uses caller's role and warehouse for all queries
- Respects row-level security and masking policies
- Full audit trail via Snowflake's query history

---

*Built with Snowflake Cortex*
