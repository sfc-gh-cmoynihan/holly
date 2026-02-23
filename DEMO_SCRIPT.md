# Agent Holly - Demo Script

## 🎯 Demo Overview

This demo showcases Agent Holly as a self-service AI assistant for stock research and investment analysis. The demo takes approximately 15-20 minutes and covers key use cases for portfolio managers, analysts, and traders.

---

## 📋 Pre-Demo Checklist

- [ ] Holly agent deployed to `SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY`
- [ ] All underlying tables populated with data
- [ ] Cortex Search services are indexed and active
- [ ] Semantic views created and accessible
- [ ] User has access to Snowflake Intelligence

---

## 🎬 Demo Script

### Scene 1: Introduction (2 minutes)

**Talking Points:**
> "Meet Holly - your AI-powered research assistant for stock selection and investment analysis. Holly can search through SEC filings, expert transcripts, historical stock prices, and company fundamentals - all through natural conversation."

**Show:**
- Navigate to **AI & ML > Snowflake Intelligence**
- Select **Holly** agent
- Highlight the agent description

---

### Scene 2: Company Screening (3 minutes)

**Use Case:** Portfolio manager wants to find high-growth companies for a new fund.

**Demo Query:**
```
Show me the top 10 S&P 500 companies by revenue growth
```

**Expected Result:** Table showing companies ranked by revenue growth with sector, market cap, and other fundamentals.

**Follow-up Query:**
```
Of these, which ones are in the Technology sector?
```

**Talking Points:**
> "Holly uses Cortex Analyst to translate natural language into SQL, querying our semantic views. Notice how it understands the context from the previous question."

---

### Scene 3: Stock Price Analysis (3 minutes)

**Use Case:** Analyst wants to analyze recent price movements.

**Demo Query:**
```
What was Microsoft's closing price over the last 2 weeks?
```

**Expected Result:** Time series data showing MSFT closing prices.

**Follow-up Query:**
```
Compare this with Apple and Snowflake for the same period
```

**Talking Points:**
> "Holly is querying over 158 million stock price records. The semantic view understands ticker symbols, date ranges, and price variables like open, high, low, close."

---

### Scene 4: SEC Filing Research (4 minutes)

**Use Case:** Compliance officer needs to review recent company announcements.

**Demo Query:**
```
What has Amazon announced in their 10-K filings this year?
```

**Expected Result:** List of SEC filing excerpts with dates and key topics.

**Follow-up Query:**
```
Are there any risk factors mentioned related to AI?
```

**Talking Points:**
> "Holly uses Cortex Search with vector embeddings to find semantically relevant content across 380,000+ SEC filings. This isn't keyword search - it understands meaning and context."

---

### Scene 5: Expert Insights (3 minutes)

**Use Case:** Fund manager wants qualitative research on market trends.

**Demo Query:**
```
What are experts saying about NVIDIA and AI chip demand?
```

**Expected Result:** Relevant excerpts from Third Bridge expert transcripts.

**Follow-up Query:**
```
Find insights on competition from AMD or custom chips
```

**Talking Points:**
> "Third Bridge transcripts provide expert opinions that complement quantitative data. Holly can surface relevant insights that would take hours to find manually."

---

### Scene 6: Comprehensive Research (4 minutes)

**Use Case:** Investment committee needs a full research brief on a potential investment.

**Demo Query:**
```
Give me a comprehensive analysis of Snowflake Inc - include recent stock performance, company fundamentals, any SEC filings, and expert opinions
```

**Expected Result:** Multi-source response combining:
- Stock price trend from STOCK_PRICES
- Company metrics from SP500_COMPANIES  
- Recent filings from SEC_FILINGS_SEARCH
- Expert insights from TRANSCRIPTS_SEARCH

**Talking Points:**
> "This is where Holly shines - orchestrating across all four tools to deliver comprehensive research in seconds. What used to take an analyst hours is now instant."

---

### Scene 7: Architecture Deep Dive (Optional - 2 minutes)

**Show the underlying components:**

```sql
-- Show the agent definition
DESC AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY;

-- Show Cortex Search service status
SELECT * FROM COLM_DB.INFORMATION_SCHEMA.CORTEX_SEARCH_SERVICES;

-- Show semantic view definitions
SELECT * FROM COLM_DB.INFORMATION_SCHEMA.SEMANTIC_VIEWS;
```

**Talking Points:**
> "Under the hood, Holly is a Cortex Agent that orchestrates between Cortex Search for unstructured data and Cortex Analyst for structured data. Everything runs on Snowflake's secure, governed platform."

---

## 🎯 Key Value Props to Highlight

1. **Self-Service** - No SQL knowledge required
2. **Speed** - Research in seconds, not hours
3. **Comprehensive** - Combines multiple data sources
4. **Governed** - Full audit trail, role-based access
5. **Scalable** - Handles millions of records effortlessly

---

## ❓ Anticipated Questions

**Q: How accurate is the text-to-SQL?**
> A: Semantic views include verified queries and sample values that guide Cortex Analyst. Accuracy improves with well-defined semantic models.

**Q: Can we add our own data sources?**
> A: Absolutely. Add new Cortex Search services or semantic views and update the agent specification.

**Q: What about real-time data?**
> A: Data freshness depends on your pipeline. Stock prices can be updated daily or intraday. SEC filings are available within hours of publication.

**Q: How is this different from ChatGPT?**
> A: Holly queries YOUR data in YOUR Snowflake account with YOUR security policies. It's not sending data to external services.

---

## 🛠️ Troubleshooting

| Issue | Solution |
|-------|----------|
| Agent not responding | Check warehouse is running |
| "No results found" | Verify data is loaded in underlying tables |
| Slow responses | Increase warehouse size for complex queries |
| Permission denied | Verify user has USAGE on agent and underlying objects |

---

*Demo script for Agent Holly v1.0*
