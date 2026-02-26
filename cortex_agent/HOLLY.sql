CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY
  COMMENT = 'Financial research assistant for SEC filings, transcripts, stock prices, and company data'
  PROFILE = '{"display_name": "Holly - Financial Research Assistant", "avatar": "📊", "color": "#1E88E5"}'
  FROM SPECIFICATION $$
models:
  orchestration: claude-4-sonnet

instructions:
  orchestration: |
    You are Holly, a financial research assistant. Route each query to the appropriate tool:
    
    **TRANSCRIPTS**: For earnings calls, investor conferences, or company event transcripts from S&P 500 companies, use TRANSCRIPTS_SEARCH.
    
    **HISTORICAL PRICES**: For historical stock price analysis, OHLC data, or price trends, use STOCK_PRICES.
    
    **COMPANY FUNDAMENTALS**: For S&P 500 company data (market cap, revenue growth, EBITDA, sector), use SP500_COMPANIES.
    
    **SEC FILINGS**: For SEC filings (8-K, 10-K, 10-Q) or regulatory disclosures, use SEC_FILINGS_SEARCH.
    
    Combine multiple tools for comprehensive research.
  response: "Provide clear, data-driven responses with source attribution. Use tables for financial data. Specify dates for stock prices. Cite filing type and date for SEC filings. Be accurate with numbers."
  sample_questions:
    - question: "Plot the share price of Microsoft, Amazon, Snowflake and Nvidia starting 20th Feb 2025 to 20th Feb 2026"
    - question: "Are Nvidia, Microsoft, Amazon, Snowflake in the SP500"
    - question: "What are the latest public transcripts for NVIDIA"
    - question: "Compare Nvidia's annual growth rate and Microsoft annual growth rate using the latest Annual reports using a table format for all the key metrics"
    - question: "What is the latest 10-K for Nvidia from the EDGAR Filings"
    - question: "What is the latest share price of NVIDIA"
    - question: "Would you recommend buying Nvidia Stock at 195"

tools:
  - tool_spec:
      type: cortex_search
      name: TRANSCRIPTS_SEARCH
      description: "Search public company event transcripts (earnings calls, investor conferences) from S&P 500 companies and Snowflake."
  - tool_spec:
      type: cortex_search
      name: SEC_FILINGS_SEARCH
      description: "Search SEC EDGAR filings (10-K, 10-Q, 8-K) for company announcements and regulatory disclosures."
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: STOCK_PRICES
      description: "Query historical stock price data with daily OHLC values for price trends and analysis."
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: SP500_COMPANIES
      description: "Query S&P 500 company fundamentals: market cap, revenue growth, EBITDA, sector, industry."

tool_resources:
  TRANSCRIPTS_SEARCH:
    search_service: "COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEARCH"
    max_results: 10
    columns:
      - COMPANY_NAME
      - PRIMARY_TICKER
      - EVENT_TYPE
      - FISCAL_PERIOD
      - FISCAL_YEAR
      - EVENT_TIMESTAMP
      - TRANSCRIPT_TEXT
  SEC_FILINGS_SEARCH:
    search_service: "COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS"
    max_results: 10
    columns:
      - COMPANY_NAME
      - ANNOUNCEMENT_TYPE
      - FILED_DATE
      - FISCAL_PERIOD
      - FISCAL_YEAR
      - ITEM_NUMBER
      - ITEM_TITLE
      - ANNOUNCEMENT_TEXT
  STOCK_PRICES:
    semantic_view: "COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV"
    execution_environment:
      type: warehouse
      warehouse: SMALL_WH
    query_timeout: 120
  SP500_COMPANIES:
    semantic_view: "COLM_DB.STRUCTURED.SP500"
    execution_environment:
      type: warehouse
      warehouse: SMALL_WH
    query_timeout: 60
$$;

GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY TO ROLE PUBLIC;
