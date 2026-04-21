<div align="center">

<img src="images/holly.png" alt="Holly" width="200"/>

# Holly - Financial Research Assistant

**AI-Powered Stock Research with Snowflake Cortex**

[![Snowflake](https://img.shields.io/badge/Powered%20by-Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)](https://www.snowflake.com)
[![Cortex Agent](https://img.shields.io/badge/Cortex-Agent-00D4AA?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
[![Cortex Analyst](https://img.shields.io/badge/Cortex-Analyst-FF6B35?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
[![Cortex Search](https://img.shields.io/badge/Cortex-Search-9B59B6?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)
[![MCP Server](https://img.shields.io/badge/MCP-Server-E91E63?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents/mcp-server)
[![Trial Compatible](https://img.shields.io/badge/Trial-Compatible-00C853?style=for-the-badge)](https://signup.snowflake.com/)

---

**Author:** Colm Moynihan | **Version:** 3.1 | **Updated:** 21 April 2026

</div>

> **Disclaimer:** This is a custom demo for Financial Services clients. The code is provided under an open source license with no guarantee of maintenance, security updates, or support.

---

## Overview

**Holly** is a self-service AI assistant that enables portfolio managers, analysts, and traders to perform comprehensive stock research using natural language. It combines US market data, London AIM market data, SEC filings, earnings transcripts, and internal company documents in a single conversational interface.

### Use Case

You are a **portfolio analyst at a mid-market PE firm**. Your firm holds a significant equity stake in **Time Out Group PLC** (ticker: TMO), listed on London's AIM market. You need to:

- Monitor US and UK stock markets from a single interface
- Analyse Time Out Group's share price, financial reports, and strategy
- Benchmark TMO against US-listed comparables (Airbnb, Live Nation)
- Search SEC filings and earnings transcripts for competitive intelligence
- Correlate price movements with company announcements from PDF reports

All of this would normally take most of the day across Bloomberg, SEC EDGAR, internal PDFs, and Excel. With Holly, you do it in **15 minutes from a single chat interface**.

<table>
<tr>
<td width="50%">

### Key Features

- **US Stock Analysis** - S&P 500 daily OHLC prices, smooth charts
- **UK AIM Market** - Time Out Group daily prices (GBX) since 2016
- **Company Documents** - Time Out Group annual reports, interims, presentations (PDF search)
- **S&P 500 Fundamentals** - Sector, industry, headquarters, CIK
- **SEC Filings** - 10-K, 10-Q, 8-K content search & analytics
- **Earnings Transcripts** - S&P 500 earnings calls & conferences
- **Web Search** - Live news & market updates
- **Charting** - Smooth interpolated line charts
- **MCP Server** - Connect via Cursor, Claude Desktop, or any MCP client

</td>
<td width="50%">

### Architecture

```
          ┌──────────────────┐
          │   Agent Holly     │
          │  (claude-opus-4-6) │
          └────────┬─────────┘
                   │
   ┌──────┬──────┬┴┬──────┬──────┬──────┐
   ▼      ▼      ▼ ▼      ▼      ▼      ▼
┌──────┐┌──────┐┌──────┐┌──────┐┌──────┐┌─────┐
│Search││Search││Search││Anlyst││Anlyst││Anlyst│
│ SEC  ││ TX   ││ Docs ││US Px ││AIM Px││SP500│
└──────┘└──────┘└──────┘└──────┘└──────┘└─────┘
   ▲                              ▲
   │      ┌──────┐┌──────┐┌─────┐│
   │      │Anlyst││ Web  ││Chart││
   │      │ SEC  ││ Srch ││     ││
   │      └──────┘└──────┘└─────┘│
   │                              │
   └── 3 Cortex Search ──────────┘
   └── 4 Cortex Analyst ─────────┘
   └── 2 Built-in ───────────────┘
```

</td>
</tr>
</table>

---

## Quick Start

### 1. Prerequisites

- Snowflake account with ACCOUNTADMIN access (Works with Trial Accounts)
- Subscribe to **Cybersyn Financial & Economic Essentials** from Marketplace:
  - Go to: **Data Products > Marketplace**
  - Search: "Cybersyn Financial & Economic Essentials"
  - Click "Get" (free trial available)
  - This provides: `SNOWFLAKE_PUBLIC_DATA_PAID`
  - **Schema Note:** Non-trial accounts use `CYBERSYN` schema; trial accounts use `PUBLIC_DATA`. The INSTALL.sql defaults to `CYBERSYN` — find-and-replace with `PUBLIC_DATA` if on a trial account.

### 2. Installation via Workspaces (Recommended)

#### Option A: If Git Integration Already Exists

1. **Open Workspaces** in Snowsight:
   - Navigate to **Projects > Workspaces**
   - Click **+ Workspace** (top right)

2. **Connect to Git Repository**:
   - Select **Create Workspace from Git Repository**
   - Enter repository URL: `https://github.com/sfc-gh-cmoynihan/holly`
   - Click **Create**

3. **Run Installation Script**:
   - Open `INSTALL.sql` from the file explorer
   - Click **Run All** or press `Ctrl+Enter` / `Cmd+Enter`
   - Estimated runtime: 5-10 minutes

#### Option B: Create Git Integration First (If Required)

If you see "No API integration available", run this SQL first:

```sql
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE API INTEGRATION GITHUB_INTEGRATION
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-cmoynihan')
    ENABLED = TRUE;

GRANT USAGE ON INTEGRATION GITHUB_INTEGRATION TO ROLE ACCOUNTADMIN;
```

Then follow Option A above.

#### Option C: Manual Installation (No Git Required)

1. Open the installation script directly: [INSTALL.sql](https://github.com/sfc-gh-cmoynihan/holly/blob/main/INSTALL.sql)
2. Click **Raw** to view the raw SQL
3. Copy all the SQL content
4. Paste into a new Snowflake worksheet
5. Click **Run All**

### 3. Additional Data Setup

The main `INSTALL.sql` creates all US market data, SEC filings, transcripts, company document search (PDF RAG pipeline), and the agent automatically. Two additional steps require manual action:

#### AIM Stock Prices (Time Out Group)

The INSTALL.sql creates the empty `AIM_STOCK_PRICES` table. Load data via the Python script:

```bash
SNOWFLAKE_CONNECTION_NAME=<your_connection> python scripts/load_aim_stock_prices.py
```

This populates `COLM_DB.STRUCTURED.AIM_STOCK_PRICES` with ~2,300 daily records from June 2016 to present.

#### Company Documents (Time Out Group PDFs)

The INSTALL.sql creates the stage, chunks table, PDF chunker function, and Cortex Search service. You need to upload PDFs **before** running the INSTALL.sql INSERT step (7.3.5):

```sql
PUT file:///path/to/time_out_group_plc_ar25_final_online.pdf @COLM_DB.UNSTRUCTURED.COMPANY_ANNOUNCEMENTS AUTO_COMPRESS=FALSE;
PUT file:///path/to/time_out_group_plc_interim_results_31_03_2026.pdf @COLM_DB.UNSTRUCTURED.COMPANY_ANNOUNCEMENTS AUTO_COMPRESS=FALSE;
PUT file:///path/to/time_out_group_plc_half_year_2026_presentation.pdf @COLM_DB.UNSTRUCTURED.COMPANY_ANNOUNCEMENTS AUTO_COMPRESS=FALSE;
```

The PDF chunker (`PDF_TEXT_CHUNKER`) uses PyPDF2 to extract and chunk text, then the chunks are indexed by the `COMPANY_DOCS_SEARCH` Cortex Search service.

### 4. Access Holly

Navigate to **AI & ML > Snowflake Intelligence** in Snowsight and select **Holly - FS Financial Agent**.

---

## Tools

| Tool | Type | Description |
|------|------|-------------|
| **STOCK_PRICES** | Cortex Analyst | S&P 500 daily OHLC prices (USD) |
| **AIM_STOCK_PRICES** | Cortex Analyst | London AIM daily prices for Time Out Group (GBX) |
| **SP500_COMPANIES** | Cortex Analyst | S&P 500 company fundamentals (sector, industry, HQ) |
| **SEC_FILINGS_ANALYST** | Cortex Analyst | SEC filing metadata counts & aggregations |
| **TRANSCRIPTS_SEARCH** | Cortex Search | Earnings calls & investor conferences |
| **SEC_FILINGS_SEARCH** | Cortex Search | 10-K, 10-Q, 8-K full text search |
| **COMPANY_DOCS_SEARCH** | Cortex Search | Time Out Group annual reports, interims, presentations |
| **WEB_SEARCH** | Built-in | Live web search for current news |
| **DATA_TO_CHART** | Built-in | Smooth interpolated line charts and visualizations |

---

## Project Structure

```
holly/
├── README.md                              # This file
├── INSTALL.sql                            # Complete installation script
├── UNINSTALL.sql                          # Complete uninstall script
├── DEMO_SCRIPT.md                         # Demo walkthrough (11 questions, all 9 tools)
├── cortex_agent/
│   ├── HOLLY.sql                          # Agent definition (9 tools, v3 orchestration)
│   ├── MCP_SERVER.sql                     # MCP Server setup for Cursor/Claude Desktop
│   ├── YAHOO_FINANCE.sql                  # Real-time stock price UDF (standalone)
│   └── RAG_COMPONENTS.sql                 # PDF document Q&A (standalone version, now integrated in INSTALL.sql)
├── cortex_analyst/
│   ├── STOCK_PRICE_TIMESERIES_SV.sql      # US stock price semantic view with VQRs
│   ├── AIM_STOCK_PRICES_SV.sql            # London AIM stock price semantic view with VQRs
│   └── SP500.sql                          # S&P 500 semantic view
├── cortex_search/
│   └── EDGAR_FILINGS.sql                  # SEC filings search service
├── semantic_views/
│   └── edgar_filings_sv.yaml              # EDGAR filings semantic view (YAML)
├── scripts/
│   └── load_aim_stock_prices.py           # AIM stock price data loader (Yahoo Finance)
├── tasks/
│   └── DAILY_DATA_REFRESH.sql             # Daily data refresh task
├── data/
│   └── SP500_COMPANIES.csv                # S&P 500 companies data
├── images/
│   └── holly.png                          # Holly avatar
└── stock_price_forecast.ipynb             # Stock price forecasting notebook
```

---

## MCP Server

Holly can be accessed from external MCP clients (Cursor, Claude Desktop, etc.) via a Snowflake-managed MCP Server.

See [`cortex_agent/MCP_SERVER.sql`](cortex_agent/MCP_SERVER.sql) for setup instructions including:
- `CREATE MCP SERVER` with `CORTEX_AGENT_RUN` tool type
- PAT-based authentication configuration
- Client config for `~/.cursor/mcp.json` and Claude Desktop

---

## Sample Questions

| Query | Tools Used |
|-------|-----------|
| "Plot the share price of Microsoft, Amazon, Snowflake and Nvidia starting 20th Feb 2025 to 20th Feb 2026" | STOCK_PRICES + DATA_TO_CHART |
| "Are Nvidia, Microsoft, Amazon, Snowflake in the SP500" | SP500_COMPANIES |
| "What are the latest public transcripts for NVIDIA" | TRANSCRIPTS_SEARCH |
| "Compare Nvidia's annual growth rate and Microsoft annual growth rate using the latest Annual reports" | SEC_FILINGS_SEARCH |
| "What is the latest share price of Time Out Group PLC?" | AIM_STOCK_PRICES |
| "Plot the Time Out Group share price over the last 12 months" | AIM_STOCK_PRICES + DATA_TO_CHART |
| "Show the biggest daily price drops for Time Out Group and explain what caused them" | AIM_STOCK_PRICES + COMPANY_DOCS_SEARCH |
| "What was Time Out Group's revenue in FY25 and how did it break down between Markets and Media?" | COMPANY_DOCS_SEARCH |
| "What caused the £35m impairment charge in Time Out Group's FY25 annual report?" | COMPANY_DOCS_SEARCH |
| "How many Time Out Markets are currently open worldwide and which new markets are in the pipeline?" | COMPANY_DOCS_SEARCH |
| "Explain the December 2025 share placing - how much was raised and from whom?" | COMPANY_DOCS_SEARCH |
| "What were Time Out Group's H1 FY26 interim results - revenue, EBITDA and key highlights?" | COMPANY_DOCS_SEARCH |
| "Plot the share price of Time Out Group over the last 12 months against Airbnb and Live Nation" | AIM_STOCK_PRICES + STOCK_PRICES + DATA_TO_CHART |
| "What is the latest news on Time Out Group?" | WEB_SEARCH |

---

## Data Sources

| Source | Type | Coverage |
|--------|------|----------|
| **Cybersyn Financial & Economic Essentials** | Marketplace | S&P 500 stock prices, SEC filings, earnings transcripts |
| **Yahoo Finance** | Script (`load_aim_stock_prices.py`) | Time Out Group AIM prices (daily OHLC since June 2016) |
| **Company PDFs** | Snowflake Stage | Time Out Group annual report FY25, interim results H1 FY26, half year presentation |

---

## License

This project is proprietary software for demonstration purposes.

---

<div align="center">

**Built with Snowflake Cortex**

*Data Sources: Snowflake Marketplace (Cybersyn), Yahoo Finance, Time Out Group PLC*

---

### Trial Account Compatible

This demo works on **Snowflake Trial Accounts** with no external access integrations required. All data comes from Snowflake Marketplace.

</div>
