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

## Demo Questions

### 1. Plot Share Prices

> "Plot the share price of Amazon, Microsoft, Snowflake and NVIDIA for the last year"

You'll see the output - Microsoft tracks up and down, NVIDIA started the year at $139 and is now around $186, which looks like an interesting buy.

### 2. S&P 500 Check

> "Which of these four stocks are in the S&P 500: MSFT, Snowflake, NVIDIA, and Amazon?"

Holly automatically generates SQL from natural language. Of the four stocks, 3 are in the S&P - Microsoft, Amazon, NVIDIA. Snowflake is not in the S&P 500.

### 3. Latest Transcripts

> "Give me the latest public transcripts of NVIDIA"

The last public transcript shows total revenue for the quarter was $46 billion with 56% growth - really good numbers.

### 4. SEC Filings

> "Give me the latest 10-K for NVIDIA"

Holly searches SEC EDGAR filings and returns the comprehensive annual report data.

### 5. Annual Report Summary

> "Please summarize the latest annual report of NVIDIA"

Holly uses Cortex Search to find the filing and summarizes: 114% year-over-year growth, $130 billion revenue, large-scale production of the Blackwell architecture, launched the GeForce RTX50 series GPU.

### 6. Company Comparison

> "Compare Microsoft's annual growth versus NVIDIA using the latest annual reports"

You can do cross-comparison - Microsoft has larger total revenue, but NVIDIA's got $130 billion with 114% growth.

### 7. Investment Research

> "Would you recommend buying NVIDIA at $191?"

Holly doesn't give investment advice (which is correct), but provides the current price, summary, and historical trends to inform your decision.

## Summary

In this demo we:

- Plotted historical share prices for multiple stocks
- Checked S&P 500 membership
- Searched public earnings transcripts
- Retrieved SEC 10-K filings
- Summarized and compared annual reports
- Ran everything through Snowflake Intelligence

This is how easy it is to build an AI for BI agent with Snowflake Cortex.
