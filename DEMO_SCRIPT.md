# Holly Demo Script: A Day in the Life

## Scenario

You are a **portfolio analyst at a mid-market PE firm** like Oakley Capital. Your firm invests across Education, Technology, Consumer, and Business Services. One of your key portfolio holdings is **Time Out Group PLC** (ticker: TMO), listed on London's AIM market. Your firm holds a significant equity stake.

It's Monday morning. You have three things on your plate:

1. **Morning briefing** -- check the public markets and your portfolio company's share price
2. **Deep dive** -- the IC wants a volatility analysis on TMO ahead of a board call this afternoon
3. **Comparable analysis** -- position TMO against US-listed experiential companies for a quarterly investor letter

All of this would normally take most of the day across Bloomberg, SEC EDGAR, internal PDFs, and Excel. With Holly, you'll do it in **15 minutes from a single chat interface**.

---

## Setup

Open **Snowsight > AI & ML > Snowflake Intelligence** and select **Holly - FS Financial Agent**.

Holly has **9 tools** connected:

| Tool | Type | What it does |
|------|------|-------------|
| STOCK_PRICES | Cortex Analyst | S&P 500 daily OHLC prices (USD) |
| AIM_STOCK_PRICES | Cortex Analyst | London AIM daily prices (GBX) |
| SP500_COMPANIES | Cortex Analyst | S&P 500 company fundamentals |
| SEC_FILINGS_ANALYST | Cortex Analyst | SEC filing metadata & counts |
| TRANSCRIPTS_SEARCH | Cortex Search | Earnings calls & investor conferences |
| SEC_FILINGS_SEARCH | Cortex Search | 10-K, 10-Q, 8-K full text search |
| COMPANY_DOCS_SEARCH | Cortex Search | Time Out Group annual reports, interims, presentations |
| WEB_SEARCH | Built-in | Live web search for current news |
| DATA_TO_CHART | Built-in | Smooth charts from query results |

All data stays in Snowflake. The agent orchestrates across structured, semi-structured, and unstructured data in a single conversation.

---

## ACT 1: Morning Briefing (3 min)

*Context: You're at your desk with a coffee. First thing you check is the public markets.*

### Q1. US Market Overview

> **"Plot the share price of Microsoft, Amazon, Snowflake and Nvidia starting 20th Feb 2025 to 20th Feb 2026"**

**Talk track:** "I start every morning with a market snapshot. Holly generates SQL from my natural language question, queries our stock price database, and renders a smooth line chart -- all in one step. No Bloomberg terminal, no Excel pivot tables."

**What to point out:**
- Holly uses Cortex Analyst to auto-generate SQL against a semantic view
- The chart uses smooth monotone interpolation
- NVIDIA's growth trajectory vs the others

### Q2. Portfolio Company Check

> **"What is the latest share price of Time Out Group PLC?"**

**Talk track:** "Now I check our portfolio company. Time Out is listed on London's AIM market, not the NYSE, so the prices are in pence (GBX). Holly knows to route this to the AIM stock price tool, not the US tool -- even though 'TMO' is also Thermo Fisher Scientific on the NYSE. The orchestration handles this automatically."

**What to point out:**
- Different data source (AIM vs US markets) -- multi-tool routing
- Price returned in GBX with GBP conversion
- Holly correctly identifies TMO as Time Out Group, not Thermo Fisher

### Q3. Quick Fundamentals Check

> **"Are Nvidia, Microsoft, Amazon, Snowflake in the SP500"**

**Talk track:** "Quick check before the morning meeting -- are the stocks I'm watching in the index? Three of the four are. Snowflake isn't in the S&P 500. Holly generated SQL, queried the fundamentals table, and gave me a clean answer in seconds."

---

## ACT 2: Portfolio Deep Dive (5 min)

*Context: The Investment Committee wants an update on TMO ahead of a board call. They're concerned about the share price decline and want to understand what drove the key price moves.*

### Q4. 12-Month Price History

> **"Plot the Time Out Group share price over the last 12 months"**

**Talk track:** "Let's look at the full picture. TMO was trading around 34p a year ago and has come down significantly. The IC wants to know why. Holly plots the weekly average close price using our AIM stock price data, and we can immediately see the key inflection points."

**What to point out:**
- Weekly aggregation for smooth visualization over 12 months
- Clear downtrend visible -- multiple step-downs
- Sets up the volatility question next

### Q5. Volatility Analysis

> **"Show the biggest daily price drops for Time Out Group in the last 12 months and explain what company announcements caused them"**

**Talk track:** "This is where it gets powerful. Holly uses *two tools simultaneously* -- it queries the AIM stock prices to find the biggest daily drops, then searches our internal company documents to explain what caused them. The 18th December 2025 drop of nearly 24% was the big one. Holly correlates the price move with content from the annual report -- media revenue declining 26%, adjusted EBITDA swing. This would have taken an analyst an hour to piece together manually."

**What to point out:**
- Multi-tool orchestration: AIM_STOCK_PRICES + COMPANY_DOCS_SEARCH in a single query
- LAG() window function generated automatically for % change calculation
- Document search finds the relevant financial content from PDFs uploaded to a Snowflake stage
- No manual SQL, no switching between Bloomberg and your document store

### Q6. Revenue Deep Dive

> **"What was Time Out Group's revenue in FY25 and how did it break down between Markets and Media?"**

**Talk track:** "Let me drill into the financials. Holly searches the annual report PDF we uploaded and pulls out the exact revenue figures with the Markets vs Media breakdown. Markets revenue was up but Media revenue was down 26%. All of this comes from unstructured PDFs that we processed with Cortex -- the agent is extracting structured financial data from a 120-page annual report."

**What to point out:**
- Cortex Search over chunked PDF documents
- Source attribution -- Holly references which document the data came from
- Structured financial data extracted from unstructured annual reports
- Markets vs Media breakdown shows the business model pivot

### Q7. Impairment & Strategic Context

> **"What caused the £35m impairment charge in Time Out Group's FY25 annual report?"**

**Talk track:** "This is the kind of deep-dive question that would normally send an analyst searching through footnotes and appendices. Holly finds the impairment details in the annual report -- goodwill write-downs, the strategic rationale, and what it means for the balance sheet. This is buried deep in the report and Holly surfaces it in seconds."

**What to point out:**
- Deep document search -- finding specific financial events in dense PDF content
- Holly explains the context, not just the number
- This is the kind of question that tests whether your RAG pipeline actually works on real financial documents

---

## ACT 3: Comparable Analysis (5 min)

*Context: You're preparing a section of the quarterly investor letter comparing TMO's performance against US-listed experiential companies.*

### Q8. Cross-Market Comparison

> **"Plot the share price of Time Out Group over the last 12 months against Airbnb and Live Nation"**

**Talk track:** "Now I need to benchmark TMO against comparable US-listed experiential companies. Airbnb for the travel/hospitality platform angle, Live Nation for the venues and experiential entertainment. This is a *cross-market comparison* -- TMO is priced in pence on AIM, these two are priced in dollars on NYSE/NASDAQ. Holly queries both the AIM and US stock price tools, and the agent combines them for comparison. This normally requires pulling data from two different terminals and normalizing in Excel."

**What to point out:**
- Three different companies across two different markets (AIM + US)
- Holly orchestrates across two separate Cortex Analyst tools in one question
- Charting tool renders the comparison

### Q9. Competitor Intelligence

> **"What are the latest public transcripts for Live Nation?"**

**Talk track:** "I want to see what Live Nation management is saying about the experiential economy. Holly searches the public transcripts database -- these are earnings calls and investor conferences from S&P 500 companies. I can see what the Q4 call said about concert demand, venue expansion, and consumer spending trends. This is competitive intelligence for my investor letter."

**What to point out:**
- Cortex Search over earnings call transcripts
- Can search by company name or ticker
- Full transcript text available, not just summaries

### Q10. SEC Filing Cross-Reference

> **"Compare Nvidia's annual growth rate and Microsoft annual growth rate using the latest Annual reports using a table format for all the key metrics"**

**Talk track:** "While I'm at it, let me pull a comparison for another section of the letter on our tech watchlist. Holly searches the 10-K filings for both companies and presents a side-by-side table. NVIDIA's growth rate is extraordinary -- 114% revenue growth -- but Microsoft has the larger absolute revenue base. This is SEC filing data, not a third-party summary."

**What to point out:**
- Cross-company analysis from SEC filings
- Table format with key metrics
- Holly cites the filing source

### Q11. Live Market Check

> **"What is the latest news on Time Out Group?"**

**Talk track:** "Finally, before I write up the investor letter, let me check if there's any breaking news. Holly's web search tool goes out to the live internet. This combines our internal data with external real-time information -- so the analyst never needs to leave the platform."

**What to point out:**
- Web search is a built-in tool -- no API keys to configure
- Complements the internal data sources
- Holly attributes sources with links

---

## Closing (1 min)

**Talk track:**

"So in 15 minutes, from a single chat interface, we've done what would normally take most of the morning:

- **Checked the public markets** with live stock charts
- **Monitored our portfolio company** across a completely different exchange
- **Analysed price volatility** and correlated it with company announcements from PDF reports
- **Dug into revenue and strategy** from unstructured annual report documents
- **Benchmarked against US-listed comparables** across two different markets
- **Reviewed competitor earnings transcripts** and SEC filings
- **Checked live news** without leaving the platform

Holly has 9 tools -- 3 Cortex Search services, 4 Cortex Analyst semantic views, web search, and charting. All the data stays in Snowflake. The governance, access control, and audit trail are all native. This isn't a prototype -- it's a production-ready analyst workstation built on Snowflake Intelligence.

The entire agent was built with a single SQL statement. No infrastructure. No API plumbing. Just `CREATE AGENT` and you're done."

---

## Quick Reference: All Demo Questions

| # | Question | Tools Used | Time |
|---|----------|-----------|------|
| 1 | Plot the share price of Microsoft, Amazon, Snowflake and Nvidia starting 20th Feb 2025 to 20th Feb 2026 | STOCK_PRICES, DATA_TO_CHART | Act 1 |
| 2 | What is the latest share price of Time Out Group PLC? | AIM_STOCK_PRICES | Act 1 |
| 3 | Are Nvidia, Microsoft, Amazon, Snowflake in the SP500 | SP500_COMPANIES | Act 1 |
| 4 | Plot the Time Out Group share price over the last 12 months | AIM_STOCK_PRICES, DATA_TO_CHART | Act 2 |
| 5 | Show the biggest daily price drops for Time Out Group in the last 12 months and explain what company announcements caused them | AIM_STOCK_PRICES, COMPANY_DOCS_SEARCH | Act 2 |
| 6 | What was Time Out Group's revenue in FY25 and how did it break down between Markets and Media? | COMPANY_DOCS_SEARCH | Act 2 |
| 7 | What caused the £35m impairment charge in Time Out Group's FY25 annual report? | COMPANY_DOCS_SEARCH | Act 2 |
| 8 | Plot the share price of Time Out Group over the last 12 months against Airbnb and Live Nation | AIM_STOCK_PRICES, STOCK_PRICES, DATA_TO_CHART | Act 3 |
| 9 | What are the latest public transcripts for Live Nation? | TRANSCRIPTS_SEARCH | Act 3 |
| 10 | Compare Nvidia's annual growth rate and Microsoft annual growth rate using the latest Annual reports using a table format for all the key metrics | SEC_FILINGS_SEARCH | Act 3 |
| 11 | What is the latest news on Time Out Group? | WEB_SEARCH | Act 3 |

**Tools exercised:** All 9 tools across 11 questions. Every tool is hit at least once.

---

## Tips for Presenters

- **Don't rush Q5** -- the multi-tool volatility analysis is the showstopper. Let the audience see Holly pull price data AND document content in one answer.
- **Q8 is the architecture moment** -- cross-market comparison (AIM + US) demonstrates why multi-tool orchestration matters.
- **Pause after Q2** to explain the TMO ticker disambiguation -- same ticker, different exchanges, correct routing.
- **If time is short**, cut Q3 (SP500 check) and Q10 (NVDA vs MSFT comparison) -- they're strong but not essential to the narrative.
- **If you have extra time**, add: "How many Time Out Markets are currently open worldwide and which new markets are in the pipeline?" after Q7 -- it pulls a rich answer from the annual report about management agreements and new market openings.
