CREATE OR REPLACE SEMANTIC VIEW COLM_DB.STRUCTURED.AIM_STOCK_PRICES_SV
  TABLES (
    COLM_DB.STRUCTURED.AIM_STOCK_PRICES
  )
  FACTS (
    AIM_STOCK_PRICES.OPEN_PRICE AS OPEN_PRICE
      comment='Opening price in GBX (pence) for the trading day.',
    AIM_STOCK_PRICES.HIGH_PRICE AS HIGH_PRICE
      comment='Highest price in GBX (pence) during the trading day.',
    AIM_STOCK_PRICES.LOW_PRICE AS LOW_PRICE
      comment='Lowest price in GBX (pence) during the trading day.',
    AIM_STOCK_PRICES.CLOSE_PRICE AS CLOSE_PRICE
      comment='Closing price in GBX (pence) for the trading day. Use this for share price queries.',
    AIM_STOCK_PRICES.VOLUME AS VOLUME
      comment='Number of shares traded during the trading day.'
  )
  DIMENSIONS (
    AIM_STOCK_PRICES.DATE AS DATE
      comment='Trading date for the price data.',
    AIM_STOCK_PRICES.TICKER AS TICKER
      comment='Stock ticker symbol. Currently contains TMO (Time Out Group PLC).',
    AIM_STOCK_PRICES.COMPANY_NAME AS COMPANY_NAME
      comment='Full company name e.g. Time Out Group PLC.',
    AIM_STOCK_PRICES.EXCHANGE AS EXCHANGE
      comment='Stock exchange. AIM (Alternative Investment Market, London Stock Exchange).',
    AIM_STOCK_PRICES.CURRENCY AS CURRENCY
      comment='Price currency. GBX (pence sterling). Divide by 100 to get GBP.'
  )
  COMMENT = 'London AIM market daily stock prices for Time Out Group PLC (TMO). Prices are in GBX (pence). Use CLOSE_PRICE for share price queries. When plotting charts over periods longer than 1 month, use weekly aggregation (DATE_TRUNC week) with AVG for smoother visualizations.'
  AI_VERIFIED_QUERIES (
    "Plot the share price of Time Out Group over the last 12 months" AS (
      QUESTION 'Plot the share price of Time Out Group over the last 12 months'
      VERIFIED_AT 1744624000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION true
      SQL 'SELECT DATE_TRUNC(''WEEK'', DATE) AS WEEK, TICKER, ROUND(AVG(CLOSE_PRICE), 2) AS SHARE_PRICE_GBX FROM COLM_DB.STRUCTURED.AIM_STOCK_PRICES WHERE TICKER = ''TMO'' AND DATE >= DATEADD(MONTH, -12, CURRENT_DATE()) GROUP BY DATE_TRUNC(''WEEK'', DATE), TICKER ORDER BY WEEK'
    ),
    "What is the latest share price of Time Out Group?" AS (
      QUESTION 'What is the latest share price of Time Out Group?'
      VERIFIED_AT 1744624000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION true
      SQL 'SELECT TICKER, COMPANY_NAME, DATE, CLOSE_PRICE AS SHARE_PRICE_GBX, ROUND(CLOSE_PRICE / 100, 4) AS SHARE_PRICE_GBP, VOLUME FROM COLM_DB.STRUCTURED.AIM_STOCK_PRICES WHERE TICKER = ''TMO'' ORDER BY DATE DESC LIMIT 1'
    ),
    "What was the highest share price of TMO in the last year?" AS (
      QUESTION 'What was the highest share price of TMO in the last year?'
      VERIFIED_AT 1744624000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION true
      SQL 'SELECT TICKER, COMPANY_NAME, DATE, HIGH_PRICE AS HIGH_GBX, CLOSE_PRICE AS CLOSE_GBX, VOLUME FROM COLM_DB.STRUCTURED.AIM_STOCK_PRICES WHERE TICKER = ''TMO'' AND DATE >= DATEADD(YEAR, -1, CURRENT_DATE()) ORDER BY HIGH_PRICE DESC LIMIT 1'
    ),
    "Show the biggest daily price drops for Time Out Group in the last 12 months" AS (
      QUESTION 'Show the biggest daily price drops for Time Out Group in the last 12 months'
      VERIFIED_AT 1744624000
      VERIFIED_BY 'ADMIN'
      ONBOARDING_QUESTION true
      SQL 'SELECT DATE, CLOSE_PRICE AS CLOSE_GBX, LAG(CLOSE_PRICE) OVER (ORDER BY DATE) AS PREV_CLOSE_GBX, ROUND((CLOSE_PRICE - LAG(CLOSE_PRICE) OVER (ORDER BY DATE)) / NULLIF(LAG(CLOSE_PRICE) OVER (ORDER BY DATE), 0) * 100, 2) AS PCT_CHANGE, VOLUME FROM COLM_DB.STRUCTURED.AIM_STOCK_PRICES WHERE TICKER = ''TMO'' AND DATE >= DATEADD(MONTH, -12, CURRENT_DATE()) ORDER BY PCT_CHANGE ASC LIMIT 10'
    )
  );
