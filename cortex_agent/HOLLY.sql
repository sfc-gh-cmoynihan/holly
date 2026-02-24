CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY
  COMMENT = 'Financial research assistant that orchestrates across SEC filings, transcripts, stock prices, and S&P 500 company data'
  PROFILE = '{"display_name": "Holly - Financial Research Assistant", "avatar": "📊", "color": "#1E88E5"}'
  FROM SPECIFICATION $$
  {
    "models": {
      "orchestration": "claude-4-sonnet"
    },
    "instructions": {
      "orchestration": "You are Holly, a financial research assistant. Route each query to the appropriate tool:\n\n**PUBLIC TRANSCRIPTS**: For questions about public earnings calls, investor conferences, or company event transcripts from S&P 500 companies or Snowflake, use PUBLIC_TRANSCRIPTS_SEARCH.\n\n**PRIVATE TRANSCRIPTS**: For questions about private or Third Bridge expert interview transcripts, analyst opinions, or proprietary research insights, use TB_TRANSCRIPTS_SEARCH.\n\n**HISTORICAL PRICE DATA**: For historical stock price analysis, OHLC data, price trends over time, or technical analysis, use STOCK_PRICES semantic view.\n\n**COMPANY FUNDAMENTALS**: For S&P 500 company fundamentals like market cap, revenue growth, EBITDA, sector/industry classification, use SP500_COMPANIES.\n\n**SEC FILINGS**: For SEC regulatory filings, 8-K announcements, 10-Q quarterly reports, or company disclosures, use SEC_FILINGS_SEARCH.\n\nFor comprehensive research, combine multiple tools as needed.",
      "response": "Provide clear, data-driven responses with source attribution. When presenting financial data, use tables when appropriate. For stock prices, specify the date. For SEC filings, cite the filing type and date. For transcripts, mention whether it was a public or private source. Always be accurate with numbers and dates."
    },
    "tools": [
      {
        "tool_spec": {
          "type": "cortex_search",
          "name": "PUBLIC_TRANSCRIPTS_SEARCH",
          "description": "Search public company event transcripts including earnings calls, investor conferences, and company updates from S&P 500 companies and Snowflake. Use for questions about what companies said in public calls or events."
        }
      },
      {
        "tool_spec": {
          "type": "cortex_search",
          "name": "TB_TRANSCRIPTS_SEARCH",
          "description": "Search private Third Bridge expert interview transcripts for proprietary research insights. Use for private or confidential analyst opinions, expert interviews, and qualitative research not available publicly."
        }
      },
      {
        "tool_spec": {
          "type": "cortex_search",
          "name": "SEC_FILINGS_SEARCH",
          "description": "Search SEC EDGAR filings including 10-K, 10-Q, 8-K reports and other regulatory disclosures. Use for company announcements, earnings reports, and SEC regulatory filings."
        }
      },
      {
        "tool_spec": {
          "type": "cortex_analyst_text_to_sql",
          "name": "STOCK_PRICES",
          "description": "Query historical stock price data with daily OHLC (Open, High, Low, Close) values. Use for historical price analysis, price trends over time, returns calculations, and technical indicators."
        }
      },
      {
        "tool_spec": {
          "type": "cortex_analyst_text_to_sql",
          "name": "SP500_COMPANIES",
          "description": "Query S&P 500 company fundamentals including market cap, revenue growth, EBITDA, sector, industry, employee count, headquarters location, and business summaries."
        }
      }
    ],
    "tool_resources": {
      "PUBLIC_TRANSCRIPTS_SEARCH": {
        "search_service": "COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEARCH",
        "max_results": 10,
        "columns": ["COMPANY_NAME", "PRIMARY_TICKER", "EVENT_TYPE", "FISCAL_PERIOD", "FISCAL_YEAR", "EVENT_TIMESTAMP", "TRANSCRIPT_TEXT"]
      },
      "TB_TRANSCRIPTS_SEARCH": {
        "search_service": "COLM_DB.UNSTRUCTURED.TB_TRANSCRIPTS",
        "max_results": 5,
        "columns": ["TITLE", "AGENDA", "CONTENT_TYPE", "TARGET_COMPANIES", "STARTS_AT", "TRANSCRIPT_URL", "RELEVANT_COMPANIES", "TRANSCRIPT"]
      },
      "SEC_FILINGS_SEARCH": {
        "search_service": "COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS",
        "max_results": 10,
        "columns": ["COMPANY_NAME", "ANNOUNCEMENT_TYPE", "FILED_DATE", "FISCAL_PERIOD", "FISCAL_YEAR", "ITEM_NUMBER", "ITEM_TITLE", "ANNOUNCEMENT_TEXT"]
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
