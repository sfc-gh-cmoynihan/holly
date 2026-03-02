/*
================================================================================
  HOLLY - Financial Research Assistant
  Installation Script
  
  Author: Colm Moynihan
  Version: 1.5
  Date: 2nd March 2026
  
  PREREQUISITES:
  --------------
  1. ACCOUNTADMIN role or equivalent privileges
  2. Subscribe to the following Marketplace listing:
     
     Snowflake Public Data (Free)
     90+ sources of public domain data in one location
     - Go to: Data Products > Marketplace
     - Search for: "Snowflake Public Data (Free)"
     - Click "Get" to subscribe (completely free)
     - This provides: SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE
  
  WHAT THIS SCRIPT CREATES:
  -------------------------
  - Database: COLM_DB (with STRUCTURED, SEMI_STRUCTURED, UNSTRUCTURED schemas)
  - Tables: SP500_COMPANIES (503 companies), STOCK_PRICE_TIMESERIES, EDGAR_FILINGS, PUBLIC_TRANSCRIPTS
  - Cortex Search Services: EDGAR_FILINGS, PUBLIC_TRANSCRIPTS_SEARCH
  - Semantic Views: STOCK_PRICE_TIMESERIES_SV, SP500
  - Agent: SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY

  ESTIMATED RUNTIME: 5-10 minutes (depending on data volume)
================================================================================
*/

-- ============================================================================
-- STEP 1: SET UP CONTEXT
-- ============================================================================
USE ROLE ACCOUNTADMIN;
CREATE WAREHOUSE IF NOT EXISTS SMALL_WH WITH WAREHOUSE_SIZE = 'XLARGE' AUTO_SUSPEND = 60;
USE WAREHOUSE SMALL_WH;

-- ============================================================================
-- STEP 2: CREATE DATABASE AND SCHEMAS
-- ============================================================================
CREATE DATABASE IF NOT EXISTS COLM_DB;
CREATE SCHEMA IF NOT EXISTS COLM_DB.STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.SEMI_STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.UNSTRUCTURED;

-- ============================================================================
-- STEP 3: CREATE S&P 500 COMPANIES TABLE
-- ============================================================================

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

-- Load S&P 500 companies from Cybersyn company index (matching tickers from stock price data)
INSERT INTO COLM_DB.STRUCTURED.SP500_COMPANIES (SYMBOL, COMPANY_NAME, SECTOR, INDUSTRY, HEADQUARTERS, CIK)
SELECT DISTINCT
    s.TICKER AS SYMBOL,
    COALESCE(c.COMPANY_NAME, s.TICKER) AS COMPANY_NAME,
    NULL AS SECTOR,
    NULL AS INDUSTRY,
    NULL AS HEADQUARTERS,
    c.CIK
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.STOCK_PRICE_TIMESERIES s
LEFT JOIN SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.SEC_CIK_INDEX c 
    ON s.TICKER = UPPER(REGEXP_REPLACE(c.COMPANY_NAME, '[^A-Z]', ''))
WHERE s.PRIMARY_EXCHANGE_CODE IN ('XNYS', 'XNAS')
  AND s.DATE >= DATEADD(year, -1, CURRENT_DATE())
QUALIFY ROW_NUMBER() OVER (PARTITION BY s.TICKER ORDER BY c.CIK) = 1;

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
    VALUE
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.STOCK_PRICE_TIMESERIES
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
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.SEC_CORPORATE_REPORT_INDEX r
INNER JOIN SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.SEC_CORPORATE_REPORT_ITEM_ATTRIBUTES a
    ON r.ADSH = a.ADSH 
INNER JOIN COLM_DB.STRUCTURED.SP500_COMPANIES s
    ON r.CIK = s.CIK
WHERE r.FILED_DATE >= '2024-01-01'
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
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.COMPANY_EVENT_TRANSCRIPT_ATTRIBUTES t
INNER JOIN COLM_DB.STRUCTURED.SP500_COMPANIES s ON t.PRIMARY_TICKER = s.SYMBOL;

ALTER TABLE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS SET CHANGE_TRACKING = TRUE;

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
-- STEP 9: CREATE HOLLY CORTEX AGENT
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
    
    **COMPANY FUNDAMENTALS**: For S&P 500 company data (sector, industry, headquarters), use SP500_COMPANIES.
    
    **SEC FILINGS**: For SEC filings (8-K, 10-K, 10-Q) or regulatory disclosures, use SEC_FILINGS_SEARCH.
    
    Combine multiple tools for comprehensive research.
  response: "Provide clear, data-driven responses with source attribution. Use tables for financial data. Specify dates for stock prices. Cite filing type and date for SEC filings. Be accurate with numbers."
  sample_questions:
    - question: "Plot the share price of Microsoft, Amazon, Snowflake and Nvidia starting 20th Feb 2025 to 20th Feb 2026"
    - question: "Are Nvidia, Microsoft, Amazon, Snowflake in the SP500"
    - question: "What are the latest public transcripts for NVIDIA"
    - question: "Compare Nvidia's annual growth rate and Microsoft annual growth rate using the latest Annual reports using a table format for all the key metrics"
    - question: "What is the latest 10-K for Nvidia from the EDGAR Filings"
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
      description: "Query S&P 500 company fundamentals: sector, industry, headquarters."

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
-- STEP 10: VERIFICATION
-- ============================================================================

SELECT 'SP500_COMPANIES' AS table_name, COUNT(*) AS row_count FROM COLM_DB.STRUCTURED.SP500_COMPANIES
UNION ALL SELECT 'STOCK_PRICE_TIMESERIES', COUNT(*) FROM COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES
UNION ALL SELECT 'EDGAR_FILINGS', COUNT(*) FROM COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS
UNION ALL SELECT 'PUBLIC_TRANSCRIPTS', COUNT(*) FROM COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS;

SHOW CORTEX SEARCH SERVICES IN DATABASE COLM_DB;
SHOW SEMANTIC VIEWS IN DATABASE COLM_DB;
DESC AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY;

-- ============================================================================
-- INSTALLATION COMPLETE!
-- 
-- Expected row counts:
--   SP500_COMPANIES: varies based on available tickers
--   STOCK_PRICE_TIMESERIES: varies based on date range
--   EDGAR_FILINGS: varies based on filings
--   PUBLIC_TRANSCRIPTS: varies based on available transcripts
--
-- Navigate to: AI & ML > Snowflake Intelligence > Holly
-- ============================================================================
