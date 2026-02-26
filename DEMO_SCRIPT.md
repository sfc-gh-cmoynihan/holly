# Holly Demo Script

## Use Case

You are a financial analyst in a hedge fund looking into AI Native Tech Stocks. You have 4 in mind: **SNOW**, **MSFT**, **AMZN**, and **NVDA**.

Because you know NVIDIA makes 90% of the GPUs for AI, you reckon this is worth investigating further. But you want to drill down on the unstructured data - 10-K, 8-K, 10-Q filings, investor call transcripts, and annual reports - to get a holistic view of the security based on all the data available, not just the fundamental data which is all structured.

## Introduction

What I'm going to show you here is an AI for BI agent. This agent is called Holly, and it's really easy to build - fast, easy, and secure.

We sourced all the data from the Snowflake Marketplace - EDGAR filings, stock price series, public company transcripts, and the S&P 500 index. We've loaded them into our Snowflake data lake.

## Agent Overview

This is Holly - it's under **AI & ML > Snowflake Intelligence** in Snowsight. It has four tools connected:

| Tool | Type | Purpose |
|------|------|---------|
| TRANSCRIPTS_SEARCH | Cortex Search | Earnings calls, investor conferences |
| SEC_FILINGS_SEARCH | Cortex Search | 10-K, 10-Q, 8-K filings |
| STOCK_PRICES | Cortex Analyst | Historical OHLC price data |
| SP500_COMPANIES | Cortex Analyst | Company fundamentals |

Holly also has access to a **real-time stock price function** via Yahoo Finance for live market quotes.

## Demo Questions

### 1. Plot Share Prices

> "Plot the share price of Microsoft, Amazon, Snowflake and Nvidia starting 20th Feb 2025 to 20th Feb 2026"

You'll see the output - Microsoft tracks up and down, NVIDIA started the year at $139 and is now around $186, which looks like an interesting buy.

### 2. S&P 500 Check

> "Are Nvidia, Microsoft, Amazon, Snowflake in the SP500"

Holly automatically generates SQL from natural language. Of the four stocks, 3 are in the S&P - Microsoft, Amazon, NVIDIA. Snowflake is not in the S&P 500.

### 3. Latest Transcripts

> "What are the latest public transcripts for NVIDIA"

The last public transcript shows total revenue for the quarter was $46 billion with 56% growth - really good numbers.

### 4. SEC Filings

> "What is the latest 10-K for Nvidia from the EDGAR Filings"

Holly searches SEC EDGAR filings and returns the comprehensive annual report data.

### 5. Company Comparison

> "Compare Nvidia's annual growth rate and Microsoft annual growth rate using the latest Annual reports using a table format for all the key metrics"

You can do cross-comparison - Microsoft has larger total revenue, but NVIDIA's got $130 billion with 114% growth.

### 6. Latest Share Price

> "What is the latest share price of NVIDIA"

Holly queries the historical stock price data to show the most recent closing price from the database.

### 7. Investment Research

> "Would you recommend buying Nvidia Stock at 195"

Holly doesn't give investment advice (which is correct), but provides the current price, summary, and historical trends to inform your decision.

## Real-time Stock Prices (Bonus)

You can also get **live stock prices** directly from Yahoo Finance:

```sql
-- Get real-time NVIDIA quote
SELECT COLM_DB.STRUCTURED.GET_STOCK_PRICE('NVDA');

-- Formatted output
SELECT 
    result:ticker::VARCHAR AS TICKER,
    result:price::FLOAT AS PRICE,
    result:previous_close::FLOAT AS PREVIOUS_CLOSE,
    result:market_state::VARCHAR AS MARKET_STATE,
    result:quote_date::VARCHAR AS QUOTE_DATE
FROM (SELECT COLM_DB.STRUCTURED.GET_STOCK_PRICE('NVDA') AS result);
```

This returns real-time data including:
- Current price
- Previous close
- Market state (PRE, REGULAR, POST, CLOSED)
- Quote timestamp

## Summary

In this demo we:

- Plotted historical share prices for multiple stocks
- Checked S&P 500 membership
- Searched public earnings transcripts
- Retrieved SEC 10-K filings
- Compared annual reports across companies
- Accessed real-time stock prices via Yahoo Finance
- Ran everything through Snowflake Intelligence

This is how easy it is to build an AI for BI agent with Snowflake Cortex.
