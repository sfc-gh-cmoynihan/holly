CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY
  COMMENT = 'Financial research assistant that orchestrates across SEC filings, expert transcripts, stock prices, and S&P 500 company data'
  PROFILE = '{"display_name": "Holly - Financial Research Assistant", "avatar": "📊", "color": "#1E88E5"}'
  FROM SPECIFICATION $$
  {
    "models": {
      "orchestration": "claude-4-sonnet"
    },
    "instructions": {
      "orchestration": "You are Holly, a financial research assistant. Determine the best tool(s) for each query:\n\n1. SEC_FILINGS_SEARCH - Use for questions about company announcements, earnings reports, 10-K/10-Q filings, SEC disclosures, and regulatory filings. Search by company name, announcement type, or filing date.\n\n2. TRANSCRIPTS_SEARCH - Use for expert interview insights, analyst opinions, market commentary, and qualitative research from Third Bridge transcripts.\n\n3. STOCK_PRICES - Use for quantitative stock price analysis: historical prices, OHLC data, price trends, returns calculations, and technical analysis for tickers like AMZN, MSFT, SNOW.\n\n4. SP500_COMPANIES - Use for S&P 500 company fundamentals: market cap, revenue growth, EBITDA, sector/industry classification, employee counts, and company profiles.\n\nFor comprehensive research questions, combine multiple tools - e.g., search filings for context, then query stock prices for quantitative data.",
      "response": "Provide clear, data-driven responses with source attribution. When presenting financial data, use tables when appropriate. For stock prices, specify the date range analyzed. For SEC filings, cite the filing type and date. For transcripts, mention the source context. Always be accurate with numbers and dates."
    },
    "tools": [
      {
        "tool_spec": {
          "type": "cortex_search",
          "name": "SEC_FILINGS_SEARCH",
          "description": "Search SEC EDGAR filings including 10-K, 10-Q, 8-K reports and other regulatory disclosures. Contains company announcements, earnings reports, and financial statements. Searchable by company name with attributes for announcement type, filing date, fiscal period/year, and item details."
        }
      },
      {
        "tool_spec": {
          "type": "cortex_search",
          "name": "TRANSCRIPTS_SEARCH",
          "description": "Search Third Bridge expert interview transcripts for qualitative research insights. Contains expert opinions on companies, industries, and market trends. Searchable by title with attributes for agenda, content type, target companies, and relevant companies."
        }
      },
      {
        "tool_spec": {
          "type": "cortex_analyst_text_to_sql",
          "name": "STOCK_PRICES",
          "description": "Query historical stock price data with daily OHLC (Open, High, Low, Close) values. Contains 158M+ rows covering multiple exchanges. Use for price analysis, returns calculations, volatility analysis, and technical indicators. Supports tickers including major tech stocks (AMZN, MSFT, SNOW)."
        }
      },
      {
        "tool_spec": {
          "type": "cortex_analyst_text_to_sql",
          "name": "SP500_COMPANIES",
          "description": "Query S&P 500 company fundamentals including market cap, revenue growth, EBITDA, sector, industry, employee count, headquarters location, and business summaries. Use for company comparisons, sector analysis, and fundamental screening."
        }
      }
    ],
    "tool_resources": {
      "SEC_FILINGS_SEARCH": {
        "search_service": "COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS",
        "max_results": 10,
        "columns": ["COMPANY_NAME", "ANNOUNCEMENT_TYPE", "FILED_DATE", "FISCAL_PERIOD", "FISCAL_YEAR", "ITEM_NUMBER", "ITEM_TITLE", "ANNOUNCEMENT_TEXT"]
      },
      "TRANSCRIPTS_SEARCH": {
        "search_service": "COLM_DB.UNSTRUCTURED.TRANSCRIPTS",
        "max_results": 5,
        "columns": ["TITLE", "AGENDA", "CONTENT_TYPE", "TARGET_COMPANIES", "STARTS_AT", "TRANSCRIPT_URL", "RELEVANT_COMPANIES", "TRANSCRIPT"]
      },
      "STOCK_PRICES": {
        "semantic_view": "COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV",
        "execution_environment": {
          "type": "warehouse",
          "warehouse": "SMALL_WH"
        },
        "query_timeout": 120
      },
      "SP500_COMPANIES": {
        "semantic_view": "COLM_DB.STRUCTURED.SP500",
        "execution_environment": {
          "type": "warehouse",
          "warehouse": "SMALL_WH"
        },
        "query_timeout": 60
      }
    }
  }
  $$;

GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY TO ROLE PUBLIC;
