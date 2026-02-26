<div align="center">

<img src="images/holly.png" alt="Holly" width="200"/>

# 📊 Holly - Financial Research Assistant

**AI-Powered Stock Research with Snowflake Cortex**

[![Snowflake](https://img.shields.io/badge/Powered%20by-Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)](https://www.snowflake.com)
[![Cortex Agent](https://img.shields.io/badge/Cortex-Agent-00D4AA?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
[![Cortex Analyst](https://img.shields.io/badge/Cortex-Analyst-FF6B35?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
[![Cortex Search](https://img.shields.io/badge/Cortex-Search-9B59B6?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)

---

**Author:** Colm Moynihan | **Version:** 1.2 | **Updated:** February 2026

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
- 🏢 **Company Research** - S&P 500 fundamentals
- 📄 **SEC Filings** - 10-K, 10-Q, 8-K search
- 🎤 **Transcripts** - Earnings calls, conferences

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
│Search │ │Analyst│ │Analyst│
│SEC/TX │ │Prices │ │S&P500 │
└───────┘ └───────┘ └───────┘
```

</td>
</tr>
</table>

---

## 🚀 Quick Start

### 1️⃣ Prerequisites

- Snowflake account with ACCOUNTADMIN access
- Subscribe to **Cybersyn Financial & Economic Essentials** from Marketplace:
  - Go to: Data Products > Marketplace
  - Search: "Cybersyn Financial & Economic Essentials"
  - Click "Get" (free tier available)

### 2️⃣ Installation

```sql
-- Copy and paste INSTALL.sql into a Snowflake worksheet and run
-- Estimated runtime: 5-10 minutes
```

### 3️⃣ Access Holly

Navigate to **AI & ML > Snowflake Intelligence** in Snowsight.

---

## 🛠️ Tools

| Tool | Type | Description |
|------|------|-------------|
| **SEC_FILINGS_SEARCH** | Cortex Search | SEC EDGAR 10-K, 10-Q, 8-K filings |
| **TRANSCRIPTS_SEARCH** | Cortex Search | Earnings calls, investor conferences |
| **STOCK_PRICES** | Cortex Analyst | Historical price data (OHLC) |
| **SP500_COMPANIES** | Cortex Analyst | Company fundamentals |

---

## Scheduled Data Refresh

Holly includes a scheduled task that automatically keeps data fresh:

| Task | Schedule | Description |
|------|----------|-------------|
| **DAILY_DATA_REFRESH** | 6:00 AM GMT daily | Refreshes EDGAR_FILINGS and PUBLIC_TRANSCRIPTS from Cybersyn |

The task performs incremental MERGE operations to add new SEC filings and earnings transcripts. Cortex Search Services automatically detect changes and update their indexes.

```sql
-- Check task status
SHOW TASKS LIKE 'DAILY_DATA_REFRESH' IN SCHEMA COLM_DB.STRUCTURED;

-- View task history
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(TASK_NAME => 'DAILY_DATA_REFRESH')) ORDER BY SCHEDULED_TIME DESC LIMIT 10;
```

---

## 📁 Project Structure

```
holly/
├── 📄 README.md              # This file
├── 📄 INSTALL.sql            # Complete installation script
├── 📂 cortex_agent/
│   └── HOLLY.sql             # Agent definition
├── 📂 cortex_analyst/
│   ├── STOCK_PRICE_TIMESERIES_SV.sql
│   └── SP500.sql
├── 📂 cortex_search/
│   └── EDGAR_FILINGS.sql
├── 📂 tasks/
│   └── DAILY_DATA_REFRESH.sql  # Scheduled data refresh task
├── 📂 data/
│   └── SP500_COMPANIES.csv
├── 📂 images/
│   └── holly.png
└── 📄 DEMO_SCRIPT.md
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

*Data Source: Snowflake Marketplace (Cybersyn)*

</div>
