# Holly - Demo Script

## Overview

Demo of Holly as a self-service AI assistant for stock research. Duration: 10-15 minutes.

---

## Pre-Demo Checklist

- [ ] Run `INSTALL.sql` successfully
- [ ] Verify Cortex Search services are indexed: `SHOW CORTEX SEARCH SERVICES IN DATABASE COLM_DB;`
- [ ] Access Snowflake Intelligence: AI & ML > Snowflake Intelligence

---

## Demo Scenes

### 1. Introduction (2 min)

> "Meet Holly - your AI research assistant for stock analysis. Holly searches SEC filings, transcripts, stock prices, and company fundamentals through natural conversation."

**Navigate to:** AI & ML > Snowflake Intelligence > Holly

---

### 2. Company Screening (3 min)

**Query:**
```
Show me the top 5 companies by revenue growth
```

**Follow-up:**
```
Which of these are in the Technology sector?
```

> "Holly uses Cortex Analyst to translate questions into SQL against our semantic views."

---

### 3. Stock Price Analysis (3 min)

**Query:**
```
What was Microsoft's closing price over the last 2 weeks?
```

**Follow-up:**
```
Compare this with Apple and Snowflake
```

> "Holly queries millions of stock price records. The semantic view understands tickers, dates, and OHLC variables."

---

### 4. SEC Filing Research (3 min)

**Query:**
```
What has NVIDIA announced in SEC filings this year?
```

**Follow-up:**
```
Are there any risk factors about AI competition?
```

> "Holly uses Cortex Search with vector embeddings to find semantically relevant content across SEC filings."

---

### 5. Comprehensive Research (3 min)

**Query:**
```
Give me a complete analysis of Snowflake Inc - stock performance, fundamentals, SEC filings, and transcripts
```

> "Holly orchestrates across all 5 tools to deliver comprehensive research in seconds."

---

## Tools Reference

| Tool | Type | Use For |
|------|------|---------|
| SEC_FILINGS_SEARCH | Cortex Search | 10-K, 10-Q, 8-K filings |
| PUBLIC_TRANSCRIPTS_SEARCH | Cortex Search | Earnings calls, conferences |
| TB_TRANSCRIPTS_SEARCH | Cortex Search | Third Bridge expert transcripts |
| STOCK_PRICES | Cortex Analyst | Historical OHLC prices |
| SP500_COMPANIES | Cortex Analyst | Company fundamentals |

---

## Key Value Props

1. **Self-Service** - No SQL required
2. **Speed** - Research in seconds
3. **Comprehensive** - Multiple data sources
4. **Governed** - Runs on your Snowflake account

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No response | Check warehouse is running |
| No results | Verify tables have data |
| Permission denied | Grant USAGE on agent |

---

*Holly v1.1*
