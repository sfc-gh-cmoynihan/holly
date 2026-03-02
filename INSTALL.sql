/*
================================================================================
  HOLLY - Financial Research Assistant
  Installation Script
  
  Author: Colm Moynihan
  Version: 1.4
  Date: 2nd March 2026
  
  PREREQUISITES:
  --------------
  1. ACCOUNTADMIN role or equivalent privileges
  2. Subscribe to the following Marketplace listing:
     
     Cybersyn Financial & Economic Essentials (Required)
     - Go to: Data Products > Marketplace
     - Search for: "Cybersyn Financial & Economic Essentials"
     - Click "Get" to subscribe (free tier available)
     - This provides: SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN
  
  WHAT THIS SCRIPT CREATES:
  -------------------------
  - Database: COLM_DB (with STRUCTURED, SEMI_STRUCTURED, UNSTRUCTURED schemas)
  - Tables: SP500_COMPANIES (503 companies), STOCK_PRICE_TIMESERIES, EDGAR_FILINGS, PUBLIC_TRANSCRIPTS
  - Cortex Search Services: EDGAR_FILINGS, PUBLIC_TRANSCRIPTS_SEARCH
  - Semantic Views: STOCK_PRICE_TIMESERIES_SV, SP500
  - External Functions: GET_STOCK_PRICE (Yahoo Finance), REFRESH_SP500_COMPANIES (Wikipedia)
  - Tasks: REFRESH_SP500_WEEKLY (Sundays 6 AM ET), REFRESH_TRANSCRIPTS_DAILY (7 AM ET)
  - Agent: SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY

  ESTIMATED RUNTIME: 5-10 minutes (depending on data volume)
================================================================================
*/

-- ============================================================================
-- STEP 1: SET UP CONTEXT
-- ============================================================================
USE ROLE ACCOUNTADMIN;
CREATE WAREHOUSE IF NOT EXISTS SMALL_WH WITH WAREHOUSE_SIZE = 'MEDIUM' AUTO_SUSPEND = 1800;
USE WAREHOUSE SMALL_WH;

-- ============================================================================
-- STEP 2: CREATE DATABASE AND SCHEMAS
-- ============================================================================
CREATE DATABASE IF NOT EXISTS COLM_DB;
CREATE SCHEMA IF NOT EXISTS COLM_DB.STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.SEMI_STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.UNSTRUCTURED;

-- ============================================================================
-- STEP 3: CREATE S&P 500 COMPANIES (Full 503 constituents from Wikipedia)
-- ============================================================================

-- 3.1 Create Network Rule for Wikipedia access
CREATE OR REPLACE NETWORK RULE COLM_DB.STRUCTURED.WIKIPEDIA_RULE
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = ('en.wikipedia.org');

-- 3.2 Create External Access Integration for Wikipedia
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION WIKIPEDIA_INTEGRATION
    ALLOWED_NETWORK_RULES = (COLM_DB.STRUCTURED.WIKIPEDIA_RULE)
    ENABLED = TRUE;

-- 3.3 Create the SP500 table
CREATE OR REPLACE TABLE COLM_DB.STRUCTURED.SP500_COMPANIES (
    SYMBOL VARCHAR,
    COMPANY_NAME VARCHAR,
    SECTOR VARCHAR,
    INDUSTRY VARCHAR,
    HEADQUARTERS VARCHAR,
    DATE_ADDED DATE,
    CIK VARCHAR,
    FOUNDED VARCHAR
);

-- 3.4 Create procedure to load S&P 500 data from Wikipedia
CREATE OR REPLACE PROCEDURE COLM_DB.STRUCTURED.REFRESH_SP500_COMPANIES()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python', 'requests', 'pandas', 'lxml')
HANDLER = 'refresh_sp500'
EXTERNAL_ACCESS_INTEGRATIONS = (WIKIPEDIA_INTEGRATION)
EXECUTE AS CALLER
AS $$
import requests
import pandas as pd
from io import StringIO
from snowflake.snowpark import Session

def refresh_sp500(session: Session) -> str:
    url = "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
    headers = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"}
    
    try:
        response = requests.get(url, headers=headers, timeout=30)
        tables = pd.read_html(StringIO(response.text))
        sp500_df = tables[0]
        
        session.sql("TRUNCATE TABLE COLM_DB.STRUCTURED.SP500_COMPANIES").collect()
        
        for idx, row in sp500_df.iterrows():
            date_added = "NULL"
            if pd.notna(row.get('Date added')):
                try:
                    date_added = f"'{pd.to_datetime(row['Date added']).strftime('%Y-%m-%d')}'"
                except:
                    date_added = "NULL"
            
            symbol = row['Symbol'].replace("'", "''") if pd.notna(row.get('Symbol')) else None
            company_name = row['Security'].replace("'", "''") if pd.notna(row.get('Security')) else None
            sector = row['GICS Sector'].replace("'", "''") if pd.notna(row.get('GICS Sector')) else None
            industry = row['GICS Sub-Industry'].replace("'", "''") if pd.notna(row.get('GICS Sub-Industry')) else None
            headquarters = row['Headquarters Location'].replace("'", "''") if pd.notna(row.get('Headquarters Location')) else None
            cik = str(row['CIK']) if pd.notna(row.get('CIK')) else None
            founded = str(row['Founded']).replace("'", "''") if pd.notna(row.get('Founded')) else None
            
            sql = f"""INSERT INTO COLM_DB.STRUCTURED.SP500_COMPANIES 
                     (SYMBOL, COMPANY_NAME, SECTOR, INDUSTRY, HEADQUARTERS, DATE_ADDED, CIK, FOUNDED)
                     VALUES (
                         {f"'{symbol}'" if symbol else "NULL"},
                         {f"'{company_name}'" if company_name else "NULL"},
                         {f"'{sector}'" if sector else "NULL"},
                         {f"'{industry}'" if industry else "NULL"},
                         {f"'{headquarters}'" if headquarters else "NULL"},
                         {date_added},
                         {f"'{cik}'" if cik else "NULL"},
                         {f"'{founded}'" if founded else "NULL"}
                     )"""
            session.sql(sql).collect()
        
        count = session.sql("SELECT COUNT(*) FROM COLM_DB.STRUCTURED.SP500_COMPANIES").collect()[0][0]
        return f"Successfully loaded {count} S&P 500 companies"
    except Exception as e:
        return f"Error: {str(e)}"
$$;

-- 3.5 Load the S&P 500 data
CALL COLM_DB.STRUCTURED.REFRESH_SP500_COMPANIES();

-- 3.6 Create weekly task to refresh S&P 500 data
CREATE OR REPLACE TASK COLM_DB.STRUCTURED.REFRESH_SP500_WEEKLY
    WAREHOUSE = SMALL_WH
    SCHEDULE = 'USING CRON 0 6 * * 0 America/New_York'
    COMMENT = 'Weekly refresh of S&P 500 companies from Wikipedia every Sunday at 6 AM ET'
AS
    CALL COLM_DB.STRUCTURED.REFRESH_SP500_COMPANIES();

ALTER TASK COLM_DB.STRUCTURED.REFRESH_SP500_WEEKLY RESUME;

-- ============================================================================
-- STEP 4: CREATE STOCK PRICE DATA (from Cybersyn Marketplace)
-- ============================================================================

CREATE OR REPLACE TABLE COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES 
    CLUSTER BY (TICKER, DATE)
    COMMENT = 'Historical stock price data for Cortex Analyst'
AS
SELECT 
    TICKER,
    ASSET_CLASS,
    PRIMARY_EXCHANGE_CODE,
    PRIMARY_EXCHANGE_NAME,
    VARIABLE,
    VARIABLE_NAME,
    DATE,
    VALUE,
    EVENT_TIMESTAMP_UTC
FROM SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN.STOCK_PRICE_TIMESERIES
WHERE TICKER IN (SELECT SYMBOL FROM COLM_DB.STRUCTURED.SP500_COMPANIES);

ALTER TABLE COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- STEP 5: CREATE SEC EDGAR FILINGS DATA (from Cybersyn Marketplace)
-- ============================================================================

CREATE OR REPLACE TABLE COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS
    CLUSTER BY (COMPANY_NAME, FILED_DATE)
    COMMENT = 'SEC filings for Cortex Search'
AS
SELECT 
    r.COMPANY_NAME,
    r.FORM_TYPE AS ANNOUNCEMENT_TYPE,
    r.FILED_DATE,
    r.FISCAL_PERIOD,
    r.FISCAL_YEAR,
    a.ITEM_NUMBER,
    a.ITEM_TITLE,
    a.PLAINTEXT_CONTENT AS ANNOUNCEMENT_TEXT
FROM SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN.SEC_CORPORATE_REPORT_INDEX r
INNER JOIN SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN.SEC_CORPORATE_REPORT_ITEM_ATTRIBUTES a
    ON r.ADSH = a.ADSH 
WHERE r.FILED_DATE >= '2025-01-01'
  AND r.FORM_TYPE IN ('8-K', '10-K', '10-Q');

ALTER TABLE COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- STEP 6: CREATE PUBLIC TRANSCRIPTS DATA (All S&P 500 transcripts from Cybersyn)
-- ============================================================================

CREATE OR REPLACE TABLE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY t.EVENT_TIMESTAMP DESC) AS TRANSCRIPT_ID,
    t.COMPANY_ID,
    t.CIK,
    t.COMPANY_NAME,
    t.PRIMARY_TICKER,
    t.FISCAL_PERIOD,
    t.FISCAL_YEAR,
    t.EVENT_TYPE,
    t.TRANSCRIPT_TYPE,
    t.TRANSCRIPT,
    t.EVENT_TIMESTAMP,
    t.CREATED_AT,
    t.UPDATED_AT
FROM SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN.COMPANY_EVENT_TRANSCRIPT_ATTRIBUTES_V2 t
INNER JOIN COLM_DB.STRUCTURED.SP500_COMPANIES s ON t.PRIMARY_TICKER = s.SYMBOL;

ALTER TABLE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS SET CHANGE_TRACKING = TRUE;

-- 6.1 Create procedure to refresh transcripts
CREATE OR REPLACE PROCEDURE COLM_DB.UNSTRUCTURED.REFRESH_PUBLIC_TRANSCRIPTS()
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'refresh_transcripts'
EXECUTE AS CALLER
AS $$
def refresh_transcripts(session) -> str:
    session.sql("""
        CREATE OR REPLACE TABLE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS AS
        SELECT 
            ROW_NUMBER() OVER (ORDER BY t.EVENT_TIMESTAMP DESC) AS TRANSCRIPT_ID,
            t.COMPANY_ID,
            t.CIK,
            t.COMPANY_NAME,
            t.PRIMARY_TICKER,
            t.FISCAL_PERIOD,
            t.FISCAL_YEAR,
            t.EVENT_TYPE,
            t.TRANSCRIPT_TYPE,
            t.TRANSCRIPT,
            t.EVENT_TIMESTAMP,
            t.CREATED_AT,
            t.UPDATED_AT
        FROM SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN.COMPANY_EVENT_TRANSCRIPT_ATTRIBUTES_V2 t
        INNER JOIN COLM_DB.STRUCTURED.SP500_COMPANIES s ON t.PRIMARY_TICKER = s.SYMBOL
    """).collect()
    
    count = session.sql("SELECT COUNT(*) FROM COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS").collect()[0][0]
    return f"Successfully refreshed PUBLIC_TRANSCRIPTS with {count} transcripts"
$$;

-- 6.2 Create daily task to refresh transcripts
CREATE OR REPLACE TASK COLM_DB.UNSTRUCTURED.REFRESH_TRANSCRIPTS_DAILY
    WAREHOUSE = SMALL_WH
    SCHEDULE = 'USING CRON 0 7 * * * America/New_York'
    COMMENT = 'Daily refresh of S&P 500 public transcripts from Cybersyn at 7 AM ET'
AS
    CALL COLM_DB.UNSTRUCTURED.REFRESH_PUBLIC_TRANSCRIPTS();

ALTER TASK COLM_DB.UNSTRUCTURED.REFRESH_TRANSCRIPTS_DAILY RESUME;

-- ============================================================================
-- STEP 7: CREATE CORTEX SEARCH SERVICES
-- ============================================================================

-- 7.1 SEC Filings Search
CREATE OR REPLACE CORTEX SEARCH SERVICE COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS
    ON ANNOUNCEMENT_TEXT
    ATTRIBUTES COMPANY_NAME, ANNOUNCEMENT_TYPE, FILED_DATE, FISCAL_PERIOD, FISCAL_YEAR, ITEM_NUMBER, ITEM_TITLE
    WAREHOUSE = 'SMALL_WH'
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
AS (
    SELECT COMPANY_NAME, ANNOUNCEMENT_TYPE, FILED_DATE, FISCAL_PERIOD, FISCAL_YEAR, ITEM_NUMBER, ITEM_TITLE, ANNOUNCEMENT_TEXT
    FROM COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS
);

-- 7.2 Public Transcripts Search
CREATE OR REPLACE CORTEX SEARCH SERVICE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEARCH
    ON TRANSCRIPT_TEXT
    ATTRIBUTES COMPANY_NAME, PRIMARY_TICKER, EVENT_TYPE, FISCAL_PERIOD, FISCAL_YEAR
    WAREHOUSE = 'SMALL_WH'
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
AS (
    SELECT TRANSCRIPT_ID, COMPANY_ID, CIK, COMPANY_NAME, PRIMARY_TICKER, FISCAL_PERIOD, FISCAL_YEAR, EVENT_TYPE, EVENT_TIMESTAMP,
           TRANSCRIPT:text::VARCHAR AS TRANSCRIPT_TEXT
    FROM COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS
    WHERE TRANSCRIPT:text IS NOT NULL
);

-- ============================================================================
-- STEP 8: CREATE SEMANTIC VIEWS FOR CORTEX ANALYST
-- ============================================================================

-- 8.1 Stock Price Timeseries Semantic View
CREATE OR REPLACE SEMANTIC VIEW COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV
    TABLES (COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES)
    FACTS (STOCK_PRICE_TIMESERIES.VALUE AS VALUE)
    DIMENSIONS (
        STOCK_PRICE_TIMESERIES.TICKER AS TICKER,
        STOCK_PRICE_TIMESERIES.ASSET_CLASS AS ASSET_CLASS,
        STOCK_PRICE_TIMESERIES.PRIMARY_EXCHANGE_CODE AS PRIMARY_EXCHANGE_CODE,
        STOCK_PRICE_TIMESERIES.PRIMARY_EXCHANGE_NAME AS PRIMARY_EXCHANGE_NAME,
        STOCK_PRICE_TIMESERIES.VARIABLE AS VARIABLE,
        STOCK_PRICE_TIMESERIES.VARIABLE_NAME AS VARIABLE_NAME,
        STOCK_PRICE_TIMESERIES.DATE AS DATE
    );

-- 8.2 S&P 500 Companies Semantic View
CREATE OR REPLACE SEMANTIC VIEW COLM_DB.STRUCTURED.SP500
    TABLES (COLM_DB.STRUCTURED.SP500_COMPANIES)
    DIMENSIONS (
        SP500_COMPANIES.SYMBOL AS SYMBOL,
        SP500_COMPANIES.COMPANY_NAME AS COMPANY_NAME,
        SP500_COMPANIES.SECTOR AS SECTOR,
        SP500_COMPANIES.INDUSTRY AS INDUSTRY,
        SP500_COMPANIES.HEADQUARTERS AS HEADQUARTERS,
        SP500_COMPANIES.DATE_ADDED AS DATE_ADDED,
        SP500_COMPANIES.CIK AS CIK,
        SP500_COMPANIES.FOUNDED AS FOUNDED
    );

-- ============================================================================
-- STEP 9: CREATE YAHOO FINANCE EXTERNAL FUNCTION (Real-time Stock Prices)
-- ============================================================================

-- 9.1 Create Network Rule for Yahoo Finance API access
CREATE OR REPLACE NETWORK RULE COLM_DB.STRUCTURED.YAHOO_FINANCE_RULE
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = ('query1.finance.yahoo.com', 'query2.finance.yahoo.com');

-- 9.2 Create External Access Integration
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION YAHOO_FINANCE_INTEGRATION
    ALLOWED_NETWORK_RULES = (COLM_DB.STRUCTURED.YAHOO_FINANCE_RULE)
    ENABLED = TRUE;

-- 9.3 Create the Python UDF for real-time stock prices
CREATE OR REPLACE FUNCTION COLM_DB.STRUCTURED.GET_STOCK_PRICE(TICKER VARCHAR)
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

-- ============================================================================
-- STEP 10: CREATE HOLLY CORTEX AGENT
-- ============================================================================

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY
  COMMENT = 'Financial research assistant for SEC filings, transcripts, stock prices, and company data'
  FROM SPECIFICATION $$
models:
  orchestration: claude-4-sonnet

instructions:
  orchestration: |
    You are Holly the FS Financial Agent. When a user first greets you or says hello, respond with: "Good afternoon, I am Holly the FS Financial Agent. How can I help you?"
    
    Route each query to the appropriate tool:
    
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

-- ============================================================================
-- STEP 11: VERIFICATION
-- ============================================================================

SELECT 'SP500_COMPANIES' AS table_name, COUNT(*) AS row_count FROM COLM_DB.STRUCTURED.SP500_COMPANIES
UNION ALL SELECT 'STOCK_PRICE_TIMESERIES', COUNT(*) FROM COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES
UNION ALL SELECT 'EDGAR_FILINGS', COUNT(*) FROM COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS
UNION ALL SELECT 'PUBLIC_TRANSCRIPTS', COUNT(*) FROM COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS;

SHOW CORTEX SEARCH SERVICES IN DATABASE COLM_DB;
SHOW SEMANTIC VIEWS IN DATABASE COLM_DB;
SHOW TASKS IN DATABASE COLM_DB;
DESC AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY;

-- Test Yahoo Finance function
SELECT COLM_DB.STRUCTURED.GET_STOCK_PRICE('NVDA') AS NVIDIA_REALTIME_PRICE;

-- ============================================================================
-- INSTALLATION COMPLETE!
-- 
-- Expected row counts:
--   SP500_COMPANIES: ~503 companies
--   STOCK_PRICE_TIMESERIES: varies based on date range
--   EDGAR_FILINGS: varies based on filings
--   PUBLIC_TRANSCRIPTS: ~60,000+ transcripts
--
-- Scheduled Tasks:
--   REFRESH_SP500_WEEKLY: Sundays at 6 AM ET
--   REFRESH_TRANSCRIPTS_DAILY: Daily at 7 AM ET
--
-- Navigate to: AI & ML > Snowflake Intelligence > Holly
-- ============================================================================
