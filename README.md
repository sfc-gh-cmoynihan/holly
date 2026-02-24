<div align="center">

# 📊 Holly - Financial Research Assistant

**AI-Powered Stock Research with Snowflake Cortex**

[![Snowflake](https://img.shields.io/badge/Powered%20by-Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)](https://www.snowflake.com)
[![Cortex Agent](https://img.shields.io/badge/Cortex-Agent-00D4AA?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
[![Cortex Analyst](https://img.shields.io/badge/Cortex-Analyst-FF6B35?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
[![Cortex Search](https://img.shields.io/badge/Cortex-Search-9B59B6?style=for-the-badge)](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)

---

**Author:** Colm Moynihan | **Version:** 1.1 | **Updated:** February 2026

</div>

> ⚠️ **Disclaimer:** This is a custom demo for Financial Services clients. The code is provided under an open source license with no guarantee of maintenance, security updates, or support.

---

## 🎯 Overview

**Holly** is a self-service AI assistant that enables portfolio managers, analysts, and traders to perform comprehensive stock research using natural language.

<table>
<tr>
<td width="50%">

### ✨ Key Features

- 📈 **Stock Analysis** - Historical prices, OHLC data
- 🏢 **Company Research** - S&P 500 fundamentals
- 📄 **SEC Filings** - 10-K, 10-Q, 8-K search
- 🎤 **Transcripts** - Earnings calls, conferences
- 🔍 **Expert Insights** - Third Bridge integration

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
| **PUBLIC_TRANSCRIPTS_SEARCH** | Cortex Search | Earnings calls, investor conferences |
| **TB_TRANSCRIPTS_SEARCH** | Cortex Search | Third Bridge expert transcripts |
| **STOCK_PRICES** | Cortex Analyst | Historical price data (OHLC) |
| **SP500_COMPANIES** | Cortex Analyst | Company fundamentals |

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
│   ├── EDGAR_FILINGS.sql
│   └── TRANSCRIPTS.sql
├── 📂 data/
│   └── SP500_COMPANIES.csv
└── 📄 DEMO_SCRIPT.md
```

---

## 💬 Sample Questions

| Query | Tool Used |
|-------|-----------|
| "What is Microsoft's stock price trend?" | STOCK_PRICES |
| "Find the top 5 companies by revenue growth" | SP500_COMPANIES |
| "What did Amazon announce in their latest 10-K?" | SEC_FILINGS_SEARCH |
| "Show me NVIDIA's fundamentals" | SP500_COMPANIES |
| "Search for transcripts about AI investments" | PUBLIC_TRANSCRIPTS_SEARCH |

---

## 📜 License

This project is proprietary software for demonstration purposes.

---

<div align="center">

**Built with ❄️ Snowflake Cortex**

*Data Source: Snowflake Marketplace (Cybersyn)*

</div>
