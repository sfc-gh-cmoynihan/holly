/*
================================================================================
  HOLLY - Financial Research Assistant
  AIM Stock Price Data Loader (In-Account)
  
  Author: Colm Moynihan
  Version: 3.2
  Date: 2nd May 2026
  
  DESCRIPTION:
  Loads Time Out Group PLC (TMO.L) historical daily OHLC stock prices from
  Yahoo Finance directly within Snowflake using a stored procedure with
  external access. No local machine or Python environment required.
  
  PREREQUISITES:
  1. ACCOUNTADMIN role
  2. COLM_DB.STRUCTURED schema exists (created by INSTALL.sql)
  3. AIM_STOCK_PRICES table exists (created by INSTALL.sql)
  
  WHAT THIS SCRIPT CREATES:
  - Network Rule: COLM_DB.STRUCTURED.YAHOO_FINANCE_RULE
  - External Access Integration: YAHOO_FINANCE_INTEGRATION
  - Stored Procedure: COLM_DB.STRUCTURED.LOAD_AIM_STOCK_PRICES()
  
  ESTIMATED RUNTIME: ~30 seconds
================================================================================
*/

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE HOLLY_WH;
USE DATABASE COLM_DB;
USE SCHEMA STRUCTURED;

-- ============================================================================
-- STEP 1: CREATE NETWORK RULE FOR YAHOO FINANCE
-- ============================================================================

CREATE OR REPLACE NETWORK RULE COLM_DB.STRUCTURED.YAHOO_FINANCE_RULE
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = ('query1.finance.yahoo.com', 'query2.finance.yahoo.com');

-- ============================================================================
-- STEP 2: CREATE EXTERNAL ACCESS INTEGRATION
-- ============================================================================

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION YAHOO_FINANCE_INTEGRATION
    ALLOWED_NETWORK_RULES = (COLM_DB.STRUCTURED.YAHOO_FINANCE_RULE)
    ENABLED = TRUE;

-- ============================================================================
-- STEP 3: CREATE STORED PROCEDURE
-- ============================================================================

CREATE OR REPLACE PROCEDURE COLM_DB.STRUCTURED.LOAD_AIM_STOCK_PRICES()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
EXTERNAL_ACCESS_INTEGRATIONS = (YAHOO_FINANCE_INTEGRATION)
HANDLER = 'run'
AS
$$
import urllib.request
import json
from datetime import datetime
import time

def run(session):
    ticker = "TMO.L"
    aim_ticker = "TMO"
    company = "Time Out Group PLC"
    exchange = "AIM"
    currency = "GBX"

    end_ts = int(datetime(2026, 5, 5).timestamp())
    start_ts = int(datetime(2016, 6, 1).timestamp())
    chunk_days = 365
    current_start = start_ts
    all_rows = []

    while current_start < end_ts:
        current_end = min(current_start + chunk_days * 86400, end_ts)
        url = f"https://query1.finance.yahoo.com/v8/finance/chart/{ticker}?period1={current_start}&period2={current_end}&interval=1d"
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        try:
            with urllib.request.urlopen(req) as response:
                data = json.loads(response.read().decode())
            result = data["chart"]["result"][0]
            if "timestamp" not in result:
                current_start = current_end
                time.sleep(0.5)
                continue
            timestamps = result["timestamp"]
            quote = result["indicators"]["quote"][0]
            for i in range(len(timestamps)):
                c = quote.get("close", [])[i] if i < len(quote.get("close", [])) else None
                if c is not None:
                    dt = datetime.utcfromtimestamp(timestamps[i]).strftime("%Y-%m-%d")
                    o = quote.get("open", [])[i]
                    h = quote.get("high", [])[i]
                    l = quote.get("low", [])[i]
                    v = quote.get("volume", [])[i] or 0
                    all_rows.append((dt, aim_ticker, company, exchange, currency,
                                    round(o,2) if o else None, round(h,2) if h else None,
                                    round(l,2) if l else None, round(c,2), v))
        except:
            pass
        current_start = current_end
        time.sleep(0.5)

    seen = set()
    unique = []
    for r in all_rows:
        if r[0] not in seen:
            seen.add(r[0])
            unique.append(r)
    unique.sort(key=lambda x: x[0])

    session.sql("DELETE FROM COLM_DB.STRUCTURED.AIM_STOCK_PRICES").collect()

    for i in range(0, len(unique), 100):
        batch = unique[i:i+100]
        values = ", ".join([f"('{r[0]}','{r[1]}','{r[2]}','{r[3]}','{r[4]}',{r[5]},{r[6]},{r[7]},{r[8]},{r[9]})" for r in batch])
        session.sql(f"INSERT INTO COLM_DB.STRUCTURED.AIM_STOCK_PRICES VALUES {values}").collect()

    return f"Loaded {len(unique)} rows ({unique[0][0]} to {unique[-1][0]})"
$$;

-- ============================================================================
-- STEP 4: LOAD THE DATA
-- ============================================================================

CALL COLM_DB.STRUCTURED.LOAD_AIM_STOCK_PRICES();

-- ============================================================================
-- STEP 5: VERIFY
-- ============================================================================

SELECT COUNT(*) AS total_rows FROM COLM_DB.STRUCTURED.AIM_STOCK_PRICES;
SELECT MIN(DATE) AS earliest, MAX(DATE) AS latest FROM COLM_DB.STRUCTURED.AIM_STOCK_PRICES;
SELECT * FROM COLM_DB.STRUCTURED.AIM_STOCK_PRICES ORDER BY DATE DESC LIMIT 5;
