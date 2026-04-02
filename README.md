<div align="center">

<img src="images/holly.png" alt="Holly" width="200"/>

# Holly - Financial Research Assistant

**AI-Powered Stock Research with Snowflake Cortex**

[![Snowflake](https://img.shields.io/badge/Powered%20by-Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)](https://www.snowflake.com)
[![Cortex Agent](https://img.shields.io/badge/Cortex-Agent-00D4AA?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
[![Cortex Analyst](https://img.shields.io/badge/Cortex-Analyst-FF6B35?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
[![Cortex Search](https://img.shields.io/badge/Cortex-Search-9B59B6?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)
[![Trial Compatible](https://img.shields.io/badge/Trial-Compatible-00C853?style=for-the-badge)](https://signup.snowflake.com/)

---

**Author:** Colm Moynihan | **Version:** 2.0 | **Updated:** April 2026

</div>

> **Disclaimer:** This is a custom demo for Financial Services clients. The code is provided under an open source license with no guarantee of maintenance, security updates, or support.

---

## Overview

**Holly** is a self-service AI assistant that enables portfolio managers, analysts, and traders to perform comprehensive stock research using natural language.

### Use Case

You are a financial analyst in a hedge fund looking into AI Native Tech Stocks. You have 4 in mind: **SNOW**, **MSFT**, **AMZN**, and **NVDA**.

Because you know NVIDIA makes 90% of the GPUs for AI, you reckon this is worth investigating further. But you want to drill down on the **unstructured data** - 10-K, 8-K, 10-Q filings, investor call transcripts, and annual reports - to get a holistic view of the security based on all the data available, not just the fundamental data which is all structured.

<table>
<tr>
<td width="50%">

### Key Features

- Stock Analysis - Historical prices, OHLC data, smooth charts
- Company Research - S&P 500 companies
- SEC Filings - 10-K, 10-Q, 8-K search & analytics
- Transcripts - Earnings calls & investor conferences
- Web Search - Live news & market updates
- Charting - Smooth interpolated line charts

</td>
<td width="50%">

### Architecture

```
         ┌─────────────────┐
         │   Agent Holly    │
         └────────┬────────┘
                  │
   ┌──────┬──────┼──────┬──────┬──────┐
   ▼      ▼      ▼      ▼      ▼      ▼
┌──────┐┌──────┐┌──────┐┌──────┐┌─────┐┌─────┐
│Search││Search││Anlyst││Anlyst││ Web ││Chart│
│ SEC  ││ TX   ││Prices││SP500 ││Srch ││     │
└──────┘└──────┘└──────┘└──────┘└─────┘└─────┘
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
  - This provides: `SNOWFLAKE_PUBLIC_DATA_PAID.PUBLIC_DATA`

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
-- Run as ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- Create API integration for GitHub
CREATE OR REPLACE API INTEGRATION GITHUB_INTEGRATION
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-cmoynihan')
    ENABLED = TRUE;

-- Grant usage to your role
GRANT USAGE ON INTEGRATION GITHUB_INTEGRATION TO ROLE ACCOUNTADMIN;
```

Then follow Option A above.

#### Option C: Manual Installation (No Git Required)

1. Open the installation script directly: [INSTALL.sql](https://github.com/sfc-gh-cmoynihan/holly/blob/main/INSTALL.sql)
2. Click **Raw** to view the raw SQL
3. Copy all the SQL content
4. Paste into a new Snowflake worksheet
5. Click **Run All**

### 3. Access Holly

Navigate to **AI & ML > Snowflake Intelligence** in Snowsight and select **Holly - FS Financial Agent**.

---

## Tools

| Tool | Type | Description |
|------|------|-------------|
| **TRANSCRIPTS_SEARCH** | Cortex Search | Earnings calls, investor conferences from S&P 500 companies |
| **SEC_FILINGS_SEARCH** | Cortex Search | SEC EDGAR 10-K, 10-Q, 8-K filings content search |
| **STOCK_PRICES** | Cortex Analyst | Historical stock price data with smooth weekly aggregation |
| **SP500_COMPANIES** | Cortex Analyst | S&P 500 company fundamentals (sector, industry, HQ) |
| **SEC_FILINGS_ANALYST** | Cortex Analyst | SEC filing metadata counts & aggregations |
| **WEB_SEARCH** | Built-in | Current news, market updates, recent events |
| **DATA_TO_CHART** | Built-in | Smooth interpolated line charts and visualizations |

---

## Project Structure

```
holly/
├── README.md                              # This file
├── INSTALL.sql                            # Complete installation script
├── UNINSTALL.sql                          # Complete uninstall script
├── DEMO_SCRIPT.md                         # Demo walkthrough
├── cortex_agent/
│   ├── HOLLY.sql                          # Agent definition (7 tools)
│   ├── YAHOO_FINANCE.sql                  # Real-time stock price UDF (standalone)
│   └── RAG_COMPONENTS.sql                 # PDF document Q&A (optional)
├── cortex_analyst/
│   ├── STOCK_PRICE_TIMESERIES_SV.sql      # Stock price semantic view with VQRs
│   └── SP500.sql                          # S&P 500 semantic view
├── cortex_search/
│   └── EDGAR_FILINGS.sql                  # SEC filings search service
├── semantic_views/
│   └── edgar_filings_sv.yaml              # EDGAR filings semantic view (YAML)
├── tasks/
│   └── DAILY_DATA_REFRESH.sql             # Daily data refresh task
├── data/
│   └── SP500_COMPANIES.csv                # S&P 500 companies data
└── images/
    └── holly.png                          # Holly avatar
```

---

## Sample Questions

| Query | Tool Used |
|-------|-----------|
| "Plot the share price of Microsoft, Amazon, Snowflake and Nvidia starting 20th Feb 2025 to 20th Feb 2026" | STOCK_PRICES + DATA_TO_CHART |
| "Are Nvidia, Microsoft, Amazon, Snowflake in the SP500" | SP500_COMPANIES |
| "What are the latest public transcripts for NVIDIA" | TRANSCRIPTS_SEARCH |
| "Compare Nvidia's annual growth rate and Microsoft annual growth rate using the latest Annual reports" | SEC_FILINGS_SEARCH |
| "What is the latest 10-K for Nvidia from the EDGAR Filings" | SEC_FILINGS_SEARCH |
| "What is the latest share price of NVIDIA" | STOCK_PRICES |
| "Would you recommend buying Nvidia Stock at 195" | Multiple Tools |
| "What is the latest news on NVIDIA" | WEB_SEARCH |

---

## License

This project is proprietary software for demonstration purposes.

---

<div align="center">

**Built with Snowflake Cortex**

*Data Source: Snowflake Marketplace (Cybersyn)*

---

### Trial Account Compatible

This demo works on **Snowflake Trial Accounts** with no external access integrations required. All data comes from Snowflake Marketplace.

</div>
