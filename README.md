# Holly - Financial Research Assistant

A self-service AI assistant for stock research built on Snowflake Cortex.

## Quick Start

### Prerequisites

1. Snowflake account with ACCOUNTADMIN access
2. Subscribe to **Cybersyn Financial & Economic Essentials** from the Marketplace:
   - Go to: Data Products > Marketplace
   - Search: "Cybersyn Financial & Economic Essentials"
   - Click "Get" (free tier available)

### Installation

Run the complete installation script in a Snowflake worksheet:

```sql
-- Copy and paste the contents of INSTALL.sql into a Snowflake worksheet and run
```

**Estimated runtime:** 5-10 minutes

### Access Holly

Navigate to **AI & ML > Snowflake Intelligence** in Snowsight.

## Architecture

```
                    ┌────────────────────┐
                    │   Agent Holly      │
                    └─────────┬──────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ Cortex Search │    │Cortex Analyst │    │Cortex Analyst │
│               │    │               │    │               │
│ • SEC Filings │    │ • Stock Prices│    │ • S&P 500     │
│ • Transcripts │    │               │    │   Companies   │
└───────────────┘    └───────────────┘    └───────────────┘
```

## Tools

| Tool | Type | Description |
|------|------|-------------|
| SEC_FILINGS_SEARCH | Cortex Search | SEC EDGAR 10-K, 10-Q, 8-K filings |
| PUBLIC_TRANSCRIPTS_SEARCH | Cortex Search | Earnings calls, investor conferences |
| TB_TRANSCRIPTS_SEARCH | Cortex Search | Third Bridge expert transcripts |
| STOCK_PRICES | Cortex Analyst | Historical price data (OHLC) |
| SP500_COMPANIES | Cortex Analyst | Company fundamentals |

## Project Structure

```
holly/
├── INSTALL.sql           # Complete installation script
├── cortex_agent/
│   └── HOLLY.sql         # Agent definition
├── cortex_analyst/
│   ├── STOCK_PRICE_TIMESERIES_SV.sql
│   └── SP500.sql
├── cortex_search/
│   ├── EDGAR_FILINGS.sql
│   └── TRANSCRIPTS.sql
├── data/
│   └── SP500_COMPANIES.csv
├── DEMO_SCRIPT.md
└── README.md
```

## Sample Questions

- "What is Microsoft's stock price trend over the last 30 days?"
- "Find the top 5 companies by revenue growth"
- "What did Amazon announce in their latest 10-K?"
- "Show me NVIDIA's fundamentals"
- "Search for transcripts about AI investments"

---

**Author:** Colm Moynihan | **Version:** 1.1 | **Date:** February 2026
