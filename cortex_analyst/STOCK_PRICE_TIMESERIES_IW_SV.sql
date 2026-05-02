CREATE OR REPLACE SEMANTIC VIEW COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_IW_SV
  TABLES (
    COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_IT
  )
  FACTS (
    STOCK_PRICE_TIMESERIES_IT.VALUE AS VALUE
      comment='Value reported for the variable (price in USD or volume count).'
  )
  DIMENSIONS (
    STOCK_PRICE_TIMESERIES_IT.TICKER AS TICKER
      comment='Stock ticker symbol. Contains all publicly traded US stocks beyond the S&P 500 index. Use for stocks NOT in the S&P 500.',
    STOCK_PRICE_TIMESERIES_IT.ASSET_CLASS AS ASSET_CLASS
      comment='Type of security e.g. Common Shares.',
    STOCK_PRICE_TIMESERIES_IT.PRIMARY_EXCHANGE_CODE AS PRIMARY_EXCHANGE_CODE
      comment='Exchange code e.g. NYS, NAS.',
    STOCK_PRICE_TIMESERIES_IT.PRIMARY_EXCHANGE_NAME AS PRIMARY_EXCHANGE_NAME
      comment='Full exchange name e.g. NEW YORK STOCK EXCHANGE, NASDAQ.',
    STOCK_PRICE_TIMESERIES_IT.VARIABLE AS VARIABLE
      comment='Unique variable identifier e.g. post-market_close, pre-market_open.',
    STOCK_PRICE_TIMESERIES_IT.VARIABLE_NAME AS VARIABLE_NAME
      comment='Human-readable variable name. Valid values: Post-Market Close, Pre-Market Open, All-Day High, All-Day Low, Nasdaq Volume. Use Post-Market Close for share price or closing price queries.',
    STOCK_PRICE_TIMESERIES_IT.DATE AS DATE
      comment='Trading date for the price data.'
  )
  COMMENT = 'Stock price time series for all US-listed stocks (including those outside the S&P 500). Use VARIABLE_NAME = Post-Market Close for share/closing prices. Use this semantic view for any ticker NOT in the S&P 500 index. When plotting charts over periods longer than 1 month, use weekly aggregation (DATE_TRUNC week) with AVG for smoother visualizations.'
  AI_VERIFIED_QUERIES (
    "Plot the share price of Palantir over the last 12 months" AS (
      QUESTION 'Plot the share price of Palantir over the last 12 months'
      VERIFIED_AT 1746144000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION true
      SQL 'SELECT DATE_TRUNC(''WEEK'', DATE) AS WEEK, TICKER, ROUND(AVG(VALUE), 2) AS SHARE_PRICE FROM COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_IT WHERE TICKER = ''PLTR'' AND VARIABLE_NAME = ''Post-Market Close'' AND DATE >= DATEADD(MONTH, -12, CURRENT_DATE()) GROUP BY DATE_TRUNC(''WEEK'', DATE), TICKER ORDER BY WEEK'
    ),
    "What is the latest share price of Rivian?" AS (
      QUESTION 'What is the latest share price of Rivian?'
      VERIFIED_AT 1746144000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION true
      SQL 'SELECT TICKER, DATE, VALUE AS SHARE_PRICE FROM COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_IT WHERE TICKER = ''RIVN'' AND VARIABLE_NAME = ''Post-Market Close'' ORDER BY DATE DESC LIMIT 1'
    ),
    "Compare the stock price of Coinbase and Robinhood over the last 6 months" AS (
      QUESTION 'Compare the stock price of Coinbase and Robinhood over the last 6 months'
      VERIFIED_AT 1746144000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION false
      SQL 'SELECT DATE_TRUNC(''WEEK'', DATE) AS WEEK, TICKER, ROUND(AVG(VALUE), 2) AS SHARE_PRICE FROM COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_IT WHERE TICKER IN (''COIN'', ''HOOD'') AND VARIABLE_NAME = ''Post-Market Close'' AND DATE >= DATEADD(MONTH, -6, CURRENT_DATE()) GROUP BY DATE_TRUNC(''WEEK'', DATE), TICKER ORDER BY WEEK, TICKER'
    )
  );
