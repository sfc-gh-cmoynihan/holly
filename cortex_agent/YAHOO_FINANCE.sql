-- Yahoo Finance External Function for Holly
-- This creates a Python UDF that fetches real-time stock prices from Yahoo Finance
-- Requires: Network Rule, External Access Integration, Python UDF

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_INTELLIGENCE;
USE SCHEMA AGENTS;
USE WAREHOUSE ADHOC_WH;

-- Step 1: Create Network Rule to allow outbound access to Yahoo Finance API
CREATE OR REPLACE NETWORK RULE YAHOO_FINANCE_RULE
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = ('query1.finance.yahoo.com', 'query2.finance.yahoo.com');

-- Step 2: Create External Access Integration using the network rule
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION YAHOO_FINANCE_INTEGRATION
    ALLOWED_NETWORK_RULES = (YAHOO_FINANCE_RULE)
    ENABLED = TRUE;

-- Step 3: Create the Python UDF that fetches stock prices
CREATE OR REPLACE FUNCTION GET_STOCK_PRICE(TICKER VARCHAR)
RETURNS VARIANT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('requests')
HANDLER = 'get_stock_price'
EXTERNAL_ACCESS_INTEGRATIONS = (YAHOO_FINANCE_INTEGRATION)
AS $$
import requests
from datetime import datetime

def get_stock_price(ticker):
    url = f"https://query1.finance.yahoo.com/v8/finance/chart/{ticker}"
    headers = {"User-Agent": "Mozilla/5.0"}
    
    try:
        response = requests.get(url, headers=headers, timeout=10)
        data = response.json()
        
        result = data.get("chart", {}).get("result", [])
        if not result:
            return {"error": "No data found for ticker", "ticker": ticker}
        
        meta = result[0].get("meta", {})
        regular_market_time = meta.get("regularMarketTime")
        
        quote_date = None
        quote_time = None
        if regular_market_time:
            dt = datetime.utcfromtimestamp(regular_market_time)
            quote_date = dt.strftime('%d-%b-%Y')
            quote_time = dt.strftime('%H:%M:%S GMT')
        
        return {
            "ticker": ticker.upper(),
            "price": meta.get("regularMarketPrice"),
            "previous_close": meta.get("previousClose"),
            "currency": meta.get("currency"),
            "exchange": meta.get("exchangeName"),
            "market_state": meta.get("marketState"),
            "quote_date": quote_date,
            "quote_time": quote_time
        }
    except Exception as e:
        return {"error": str(e), "ticker": ticker}
$$;

-- Test the function
SELECT GET_STOCK_PRICE('NVDA');
