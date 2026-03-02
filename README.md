<div align="center">

<img src="images/holly.png" alt="Holly" width="200"/>

# 📊 Holly - Financial Research Assistant

**AI-Powered Stock Research with Snowflake Cortex**

[![Snowflake](https://img.shields.io/badge/Powered%20by-Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)](https://www.snowflake.com)
[![Cortex Agent](https://img.shields.io/badge/Cortex-Agent-00D4AA?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
[![Cortex Analyst](https://img.shields.io/badge/Cortex-Analyst-FF6B35?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
[![Cortex Search](https://img.shields.io/badge/Cortex-Search-9B59B6?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)

---

**Author:** Colm Moynihan | **Version:** 1.4 | **Updated:** March 2026

</div>

> ⚠️ **Disclaimer:** This is a custom demo for Financial Services clients. The code is provided under an open source license with no guarantee of maintenance, security updates, or support.

---

## 🎯 Overview

**Holly** is a self-service AI assistant that enables portfolio managers, analysts, and traders to perform comprehensive stock research using natural language.

### 📋 Use Case

You are a financial analyst in a hedge fund looking into AI Native Tech Stocks. You have 4 in mind: **SNOW**, **MSFT**, **AMZN**, and **NVDA**.

Because you know NVIDIA makes 90% of the GPUs for AI, you reckon this is worth investigating further. But you want to drill down on the **unstructured data** - 10-K, 8-K, 10-Q filings, investor call transcripts, and annual reports - to get a holistic view of the security based on all the data available, not just the fundamental data which is all structured.

<table>
<tr>
<td width="50%">

### ✨ Key Features

- 📈 **Stock Analysis** - Historical prices, OHLC data
- 💹 **Real-time Prices** - Live quotes via Yahoo Finance
- 🏢 **Company Research** - Full S&P 500 (503 companies)
- 📄 **SEC Filings** - 10-K, 10-Q, 8-K search
- 🎤 **Transcripts** - 60,000+ earnings calls

</td>
<td width="50%">

### 🏗️ Architecture

```
      ┌────────────────┐
      │  Agent Holly   │
      └───────┬────────┘
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
┌───────┐ ┌───────┐ ┌───────┐
│Search │ │Analyst│ │Yahoo  │
│SEC/TX │ │Prices │ │Finance│
└───────┘ └───────┘ └───────┘
```

</td>
</tr>
</table>

---

## 🚀 Quick Start

### 1️⃣ Prerequisites

- Snowflake account with ACCOUNTADMIN access
- Subscribe to **Snowflake Public Data (Free)** from Marketplace:
  - Go to: **Data Products > Marketplace**
  - Search: "Snowflake Public Data (Free)"
  - Click "Get" (completely free)
  - This provides: `SNOWFLAKE_PUBLIC_DATA_FREE.CYBERSYN`

### 2️⃣ Installation via Workspaces (Recommended)

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

### 3️⃣ Access Holly

Navigate to **AI & ML > Snowflake Intelligence** in Snowsight and select **Holly**.

---

## 🛠️ Tools

| Tool | Type | Description |
|------|------|-------------|
| **SEC_FILINGS_SEARCH** | Cortex Search | SEC EDGAR 10-K, 10-Q, 8-K filings |
| **TRANSCRIPTS_SEARCH** | Cortex Search | Earnings calls, investor conferences |
| **STOCK_PRICES** | Cortex Analyst | Historical price data (OHLC) |
| **SP500_COMPANIES** | Cortex Analyst | S&P 500 company fundamentals |

---

## 💹 Real-time Stock Prices (Yahoo Finance)

Holly includes an external function that fetches **real-time stock prices** from Yahoo Finance:

```sql
-- Get real-time quote for any ticker
SELECT COLM_DB.STRUCTURED.GET_STOCK_PRICE('NVDA');

-- Parse the response
SELECT 
    result:ticker::VARCHAR AS TICKER,
    result:price::FLOAT AS PRICE,
    result:previous_close::FLOAT AS PREVIOUS_CLOSE,
    result:currency::VARCHAR AS CURRENCY,
    result:exchange::VARCHAR AS EXCHANGE,
    result:market_state::VARCHAR AS MARKET_STATE,
    result:quote_date::VARCHAR AS QUOTE_DATE,
    result:quote_time::VARCHAR AS QUOTE_TIME
FROM (SELECT COLM_DB.STRUCTURED.GET_STOCK_PRICE('NVDA') AS result);
```

**Response fields:**
- `ticker` - Stock symbol
- `price` - Current/last traded price
- `previous_close` - Previous day's closing price
- `currency` - Trading currency (USD)
- `exchange` - Exchange name (NMS, NYSE, etc.)
- `market_state` - PRE, REGULAR, POST, CLOSED
- `quote_date` / `quote_time` - Timestamp of quote

---

## ⏰ Scheduled Data Refresh

Holly includes scheduled tasks that automatically keep data fresh:

| Task | Schedule | Description |
|------|----------|-------------|
| **REFRESH_SP500_WEEKLY** | Sundays 6 AM ET | Refreshes S&P 500 companies from Wikipedia |
| **REFRESH_TRANSCRIPTS_DAILY** | Daily 7 AM ET | Refreshes earnings transcripts from Cybersyn |

Cortex Search Services automatically detect changes and update their indexes.

```sql
-- Check task status
SHOW TASKS IN DATABASE COLM_DB;

-- View task history
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY()) 
WHERE DATABASE_NAME = 'COLM_DB' 
ORDER BY SCHEDULED_TIME DESC LIMIT 10;

-- Manually refresh S&P 500 data
CALL COLM_DB.STRUCTURED.REFRESH_SP500_COMPANIES();

-- Manually refresh transcripts
CALL COLM_DB.UNSTRUCTURED.REFRESH_PUBLIC_TRANSCRIPTS();
```

---

## 📁 Project Structure

```
holly/
├── 📄 README.md              # This file
├── 📄 INSTALL.sql            # Complete installation script
├── 📄 UNINSTALL.sql          # Complete uninstall script
├── 📄 DEMO_SCRIPT.md         # Demo walkthrough
├── 📂 cortex_agent/
│   ├── HOLLY.sql             # Agent definition
│   ├── YAHOO_FINANCE.sql     # Real-time stock price function
│   └── RAG_COMPONENTS.sql    # PDF document Q&A (optional)
├── 📂 cortex_analyst/
│   ├── STOCK_PRICE_TIMESERIES_SV.sql
│   └── SP500.sql
├── 📂 cortex_search/
│   └── EDGAR_FILINGS.sql
└── 📂 images/
    └── holly.png
```

---

## 💬 Sample Questions

| Query | Tool Used |
|-------|-----------|
| "Plot the share price of Microsoft, Amazon, Snowflake and Nvidia starting 20th Feb 2025 to 20th Feb 2026" | STOCK_PRICES |
| "Are Nvidia, Microsoft, Amazon, Snowflake in the SP500" | SP500_COMPANIES |
| "What are the latest public transcripts for NVIDIA" | TRANSCRIPTS_SEARCH |
| "Compare Nvidia's annual growth rate and Microsoft annual growth rate using the latest Annual reports" | SEC_FILINGS_SEARCH |
| "What is the latest 10-K for Nvidia from the EDGAR Filings" | SEC_FILINGS_SEARCH |
| "What is the latest share price of NVIDIA" | STOCK_PRICES |
| "Would you recommend buying Nvidia Stock at 195" | Multiple Tools |

---

## 📜 License

This project is proprietary software for demonstration purposes.

---

<div align="center">

**Built with ❄️ Snowflake Cortex**

*Data Source: Snowflake Marketplace (Cybersyn) + Yahoo Finance + Wikipedia*

</div>
