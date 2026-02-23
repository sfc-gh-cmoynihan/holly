# 🤖 Agent Holly - AI-Powered Stock Research Assistant

**Author:** Colm Moynihan  
**Date:** 23rd February 2026  
**Version:** 1.0

> **Disclaimer:** This is a custom demo of an AI-powered financial research agent built for use by Financial Services clients. The code here is not supported and is provided under an open source license. It is released with this source code publicly available, but with no guarantee of maintenance, security updates, bug fixes, or customer support from the original developer.

---

![Powered by Snowflake](https://img.shields.io/badge/Powered%20by-Snowflake-29B5E8?style=flat&logo=snowflake)
![Cortex Agent](https://img.shields.io/badge/Cortex-Agent-00D4AA?style=flat)
![Cortex Analyst](https://img.shields.io/badge/Cortex-Analyst-FF6B35?style=flat)
![Cortex Search](https://img.shields.io/badge/Cortex-Search-9B59B6?style=flat)

## 📊 Overview

**Agent Holly** is a self-service AI assistant that enables portfolio managers, analysts, and traders to perform comprehensive stock research using natural language. Built on Snowflake's Cortex platform, Holly orchestrates across multiple data sources to deliver actionable investment insights.

### Business Value

- **Self-Service Research** - Democratize access to financial data without SQL knowledge
- **Faster Decision Making** - Get answers in seconds, not hours
- **Comprehensive Analysis** - Combine quantitative data with qualitative insights
- **Reduced Operational Risk** - Consistent, auditable research process

## 🏗️ Architecture

```
                         ┌──────────────────────────┐
                         │      Agent Holly         │
                         │  (Cortex Agent)          │
                         └────────────┬─────────────┘
                                      │
            ┌─────────────────────────┼─────────────────────────┐
            │                         │                         │
            ▼                         ▼                         ▼
┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│  Cortex Search    │    │  Cortex Analyst   │    │  Cortex Analyst   │
│                   │    │                   │    │                   │
│ • SEC Filings     │    │ • Stock Prices    │    │ • S&P 500 Data    │
│ • Expert Insights │    │ • 158M+ Records   │    │ • Fundamentals    │
└───────────────────┘    └───────────────────┘    └───────────────────┘
         │                         │                         │
         ▼                         ▼                         ▼
┌───────────────────┐    ┌───────────────────┐    ┌───────────────────┐
│  EDGAR_FILINGS    │    │ STOCK_PRICE_      │    │  SP500_COMPANIES  │
│  TB_TRANSCRIPTS   │    │ TIMESERIES        │    │                   │
└───────────────────┘    └───────────────────┘    └───────────────────┘
```

## 🛠️ Tools & Capabilities

| Tool | Type | Data Source | Use Cases |
|------|------|-------------|-----------|
| **SEC_FILINGS_SEARCH** | Cortex Search | SEC EDGAR (379K filings) | Company announcements, 10-K/10-Q analysis, regulatory disclosures |
| **TRANSCRIPTS_SEARCH** | Cortex Search | Third Bridge (118 transcripts) | Expert opinions, market commentary, qualitative research |
| **STOCK_PRICES** | Cortex Analyst | 158M+ price records | Historical prices, OHLC analysis, returns calculations |
| **SP500_COMPANIES** | Cortex Analyst | 502 companies | Fundamentals, sector analysis, company screening |

## 📁 Repository Structure

```
holly/
├── cortex_agent/              # Cortex Agent definition
│   └── HOLLY.sql              # Agent DDL with tool configuration
├── cortex_analyst/            # Semantic Views for text-to-SQL
│   ├── STOCK_PRICE_TIMESERIES_SV.sql
│   └── SP500.sql
├── cortex_search/             # Cortex Search Service definitions
│   ├── EDGAR_FILINGS.sql      # SEC filings search service
│   └── TRANSCRIPTS.sql        # Expert transcripts search service
├── data/                      # Table DDL and sample data
│   ├── SEMI_STRUCTURED_EDGAR_FILINGS.sql
│   ├── STRUCTURED_SP500_COMPANIES.sql
│   ├── STRUCTURED_STOCK_PRICE_TIMESERIES.sql
│   ├── UNSTRUCTURED_TB_TRANSCRIPTS.sql
│   ├── UNSTRUCTURED_DOCS_CHUNKS_TABLE.sql
│   └── SP500_COMPANIES.csv
├── DEMO_SCRIPT.md             # Demo walkthrough guide
└── README.md
```

## 🚀 Deployment

### Prerequisites

- Snowflake account with ACCOUNTADMIN access
- Access to `SNOWFLAKE_PUBLIC_DATA_PAID` for SEC filings data
- Access to Third Bridge data (for transcripts)

### Step 1: Create Database and Schemas

```sql
CREATE DATABASE IF NOT EXISTS COLM_DB;
CREATE SCHEMA IF NOT EXISTS COLM_DB.STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.SEMI_STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.UNSTRUCTURED;
```

### Step 2: Create Tables

```sql
-- Run DDL files from data/ folder
!source data/STRUCTURED_SP500_COMPANIES.sql
!source data/STRUCTURED_STOCK_PRICE_TIMESERIES.sql
!source data/SEMI_STRUCTURED_EDGAR_FILINGS.sql
!source data/UNSTRUCTURED_TB_TRANSCRIPTS.sql
```

### Step 3: Create Cortex Search Services

```sql
!source cortex_search/EDGAR_FILINGS.sql
!source cortex_search/TRANSCRIPTS.sql
```

### Step 4: Create Semantic Views

```sql
!source cortex_analyst/STOCK_PRICE_TIMESERIES_SV.sql
!source cortex_analyst/SP500.sql
```

### Step 5: Deploy Holly Agent

```sql
!source cortex_agent/HOLLY.sql
```

### Step 6: Access Holly

Navigate to **AI & ML > Snowflake Intelligence** in Snowsight to interact with Holly.

## 💬 Sample Conversations

### Stock Analysis
```
User: "What is Microsoft's stock price trend over the last 30 days?"
Holly: [Queries STOCK_PRICES tool, returns price chart and analysis]
```

### Company Research
```
User: "Find the top 5 S&P 500 companies by revenue growth"
Holly: [Queries SP500_COMPANIES tool, returns ranked list with metrics]
```

### SEC Filing Search
```
User: "What did Amazon announce in their latest 10-K filing?"
Holly: [Searches EDGAR_FILINGS, returns key announcements and excerpts]
```

### Expert Insights
```
User: "What are experts saying about AI infrastructure investments?"
Holly: [Searches TRANSCRIPTS, returns relevant expert opinions]
```

### Multi-Source Research
```
User: "Give me a comprehensive view of NVIDIA - recent filings, stock performance, and analyst opinions"
Holly: [Combines all four tools for complete analysis]
```

## 📊 Data Sources

| Source | Description | Records | Update Frequency |
|--------|-------------|---------|------------------|
| **Stock Prices** | Daily OHLC data from multiple exchanges | 158,604,608 | Daily |
| **S&P 500 Companies** | Fundamentals and company profiles | 502 | Quarterly |
| **SEC EDGAR Filings** | 10-K, 10-Q, 8-K reports from 2025+ | 379,661 | Daily |
| **Third Bridge Transcripts** | Expert interview transcripts | 118 | Weekly |

## 🔒 Security & Access

Holly operates within Snowflake's security model:
- Uses caller's role and warehouse for all queries
- Respects row-level security and masking policies
- Full audit trail via Snowflake's query history

## 📝 Notes

- Large datasets (stock prices, SEC filings) are sourced from Snowflake Marketplace
- Sample data provided for SP500_COMPANIES for quick setup
- Semantic views include verified queries for common analytical patterns
- Agent requires Snowflake Intelligence access (AI & ML menu)

---

*Built with Snowflake Cortex - Powering the AI Data Cloud*
