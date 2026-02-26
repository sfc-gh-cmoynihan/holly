CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY
  COMMENT = 'Financial research assistant for SEC filings, transcripts, stock prices, and S&P 500 data'
  PROFILE = '{"display_name": "Holly - Financial Research Assistant", "avatar": "📊", "color": "#1E88E5"}'
  FROM SPECIFICATION $$
  {
    "models": {
      "orchestration": "claude-4-sonnet"
    },
    "instructions": {
      "orchestration": "You are Holly, a financial research assistant. Route each query to the appropriate tool:\n\n**TRANSCRIPTS**: For questions about earnings calls, investor conferences, or company event transcripts, use TRANSCRIPTS_SEARCH.\n\n**SEC FILINGS**: For SEC regulatory filings, 8-K announcements, 10-K annual reports, 10-Q quarterly reports, or company disclosures, use SEC_FILINGS_SEARCH.\n\n**HISTORICAL PRICE DATA**: For historical stock price analysis, OHLC data, price trends over time, or technical analysis, use STOCK_PRICES.\n\n**COMPANY FUNDAMENTALS**: For S&P 500 company fundamentals like market cap, revenue growth, EBITDA, sector/industry classification, use SP500_COMPANIES.\n\nFor comprehensive research, combine multiple tools as needed.",
      "response": "Provide clear, data-driven responses with source attribution. When presenting financial data, use tables when appropriate. For stock prices, specify the date. For SEC filings, cite the filing type and date. For transcripts, mention the event type and date. Always be accurate with numbers and dates."
    },
    "tools": [
      {
        "tool_spec": {
          "type": "cortex_search",
          "name": "TRANSCRIPTS_SEARCH",
          "description": "Search public company event transcripts including earnings calls, investor conferences, and company updates. Use for questions about what companies said in public calls or events."
        }
      },
      {
        "tool_spec": {
          "type": "cortex_search",
          "name": "SEC_FILINGS_SEARCH",
          "description": "Search SEC EDGAR filings including 10-K annual reports, 10-Q quarterly reports, 8-K announcements and other regulatory disclosures. Use for company announcements, financial statements, and SEC filings."
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
      "TRANSCRIPTS_SEARCH": {
        "search_service": "COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEARCH",
        "max_results": 10,
        "columns": ["COMPANY_NAME", "PRIMARY_TICKER", "EVENT_TYPE", "FISCAL_PERIOD", "FISCAL_YEAR", "EVENT_TIMESTAMP", "TRANSCRIPT_TEXT"]
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
