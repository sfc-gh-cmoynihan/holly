CREATE OR REPLACE SEMANTIC VIEW COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV
  TABLES (
    COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SP500_IT
  )
  FACTS (
    STOCK_PRICE_TIMESERIES_SP500_IT.VALUE AS VALUE
      comment='Value reported for the variable (price in USD or volume count).'
  )
  DIMENSIONS (
    STOCK_PRICE_TIMESERIES_SP500_IT.TICKER AS TICKER
      comment='Stock ticker symbol e.g. AAPL, MSFT, NVDA, AMZN, GOOGL. Contains all S&P 500 companies.',
    STOCK_PRICE_TIMESERIES_SP500_IT.ASSET_CLASS AS ASSET_CLASS
      comment='Type of security e.g. Common Shares.',
    STOCK_PRICE_TIMESERIES_SP500_IT.PRIMARY_EXCHANGE_CODE AS PRIMARY_EXCHANGE_CODE
      comment='Exchange code e.g. NYS, NAS.',
    STOCK_PRICE_TIMESERIES_SP500_IT.PRIMARY_EXCHANGE_NAME AS PRIMARY_EXCHANGE_NAME
      comment='Full exchange name e.g. NEW YORK STOCK EXCHANGE, NASDAQ.',
    STOCK_PRICE_TIMESERIES_SP500_IT.VARIABLE AS VARIABLE
      comment='Unique variable identifier e.g. post-market_close, pre-market_open.',
    STOCK_PRICE_TIMESERIES_SP500_IT.VARIABLE_NAME AS VARIABLE_NAME
      comment='Human-readable variable name. Valid values: Post-Market Close, Pre-Market Open, All-Day High, All-Day Low, Nasdaq Volume. Use Post-Market Close for share price or closing price queries.',
    STOCK_PRICE_TIMESERIES_SP500_IT.DATE AS DATE
      comment='Trading date for the price data.'
  )
  COMMENT = 'S&P 500 daily stock price time series. Use VARIABLE_NAME = Post-Market Close for share/closing prices. When plotting charts over periods longer than 1 month, use weekly aggregation (DATE_TRUNC week) with AVG for smoother visualizations.'
  AI_VERIFIED_QUERIES (
    "Plot the share price of Meta, Microsoft, Amazon, Google, and Nvidia from the last 12 months" AS (
      QUESTION 'Plot the share price of Meta, Microsoft, Amazon, Google, and Nvidia from the last 12 months'
      VERIFIED_AT 1743552000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION true
      SQL 'SELECT DATE_TRUNC(''WEEK'', DATE) AS WEEK, TICKER, ROUND(AVG(VALUE), 2) AS SHARE_PRICE FROM COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SP500_IT WHERE TICKER IN (''META'', ''MSFT'', ''AMZN'', ''GOOGL'', ''NVDA'') AND VARIABLE_NAME = ''Post-Market Close'' AND DATE >= DATEADD(MONTH, -12, CURRENT_DATE()) GROUP BY DATE_TRUNC(''WEEK'', DATE), TICKER ORDER BY WEEK, TICKER'
    ),
    "Plot the share price of Microsoft, Amazon, Meta and Nvidia starting 20th Feb 2025 to 20th Feb 2026" AS (
      QUESTION 'Plot the share price of Microsoft, Amazon, Meta and Nvidia starting 20th Feb 2025 to 20th Feb 2026'
      VERIFIED_AT 1743552000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION true
      SQL 'SELECT DATE_TRUNC(''WEEK'', DATE) AS WEEK, TICKER, ROUND(AVG(VALUE), 2) AS SHARE_PRICE FROM COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SP500_IT WHERE TICKER IN (''MSFT'', ''AMZN'', ''META'', ''NVDA'') AND VARIABLE_NAME = ''Post-Market Close'' AND DATE >= ''2025-02-20'' AND DATE <= ''2026-02-20'' GROUP BY DATE_TRUNC(''WEEK'', DATE), TICKER ORDER BY WEEK, TICKER'
    ),
    "What is the closing price of NVDA for the last 30 days?" AS (
      QUESTION 'What is the closing price of NVDA for the last 30 days?'
      VERIFIED_AT 1743552000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION false
      SQL 'SELECT DATE, TICKER, VALUE AS CLOSING_PRICE FROM COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SP500_IT WHERE TICKER = ''NVDA'' AND VARIABLE_NAME = ''Post-Market Close'' AND DATE >= DATEADD(DAY, -30, CURRENT_DATE()) ORDER BY DATE'
    ),
    "What is the latest share price of NVIDIA?" AS (
      QUESTION 'What is the latest share price of NVIDIA?'
      VERIFIED_AT 1743552000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION true
      SQL 'SELECT TICKER, DATE, VALUE AS SHARE_PRICE FROM COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SP500_IT WHERE TICKER = ''NVDA'' AND VARIABLE_NAME = ''Post-Market Close'' ORDER BY DATE DESC LIMIT 1'
    ),
    "Compare the stock price of Microsoft and Google over the last 6 months" AS (
      QUESTION 'Compare the stock price of Microsoft and Google over the last 6 months'
      VERIFIED_AT 1743552000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION true
      SQL 'SELECT DATE_TRUNC(''WEEK'', DATE) AS WEEK, TICKER, ROUND(AVG(VALUE), 2) AS SHARE_PRICE FROM COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SP500_IT WHERE TICKER IN (''MSFT'', ''GOOGL'') AND VARIABLE_NAME = ''Post-Market Close'' AND DATE >= DATEADD(MONTH, -6, CURRENT_DATE()) GROUP BY DATE_TRUNC(''WEEK'', DATE), TICKER ORDER BY WEEK, TICKER'
    )
  );
