/*
================================================================================
  HOLLY - Financial Research Assistant
  Installation Script
  
  Author: Colm Moynihan
  Version: 1.1
  Date: 24th February 2026
  
  PREREQUISITES:
  --------------
  1. ACCOUNTADMIN role or equivalent privileges
   2. Subscribe to Cybersyn marketplace data:
      - Go to: Data Products > Marketplace
      - Search for: "Cybersyn Financial & Economic Essentials"
      - Click "Get" to subscribe (free tier available)
      - This provides: SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN
  
  WHAT THIS SCRIPT CREATES:
  -------------------------
  - Database: COLM_DB (with STRUCTURED, SEMI_STRUCTURED, UNSTRUCTURED schemas)
  - Tables: SP500_COMPANIES, STOCK_PRICE_TIMESERIES, EDGAR_FILINGS, PUBLIC_TRANSCRIPTS, TB_TRANSCRIPTS
  - Cortex Search Services: EDGAR_FILINGS, PUBLIC_TRANSCRIPTS_SEARCH, TB_TRANSCRIPTS
  - Semantic Views: STOCK_PRICE_TIMESERIES_SV, SP500
  - Task: DAILY_DATA_REFRESH (runs daily at 6:00 AM GMT)
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
-- STEP 3: CREATE REFERENCE DATA (S&P 500 Companies - Top 10 + SNOW)
-- ============================================================================

CREATE OR REPLACE TABLE COLM_DB.STRUCTURED.SP500_COMPANIES (
    EXCHANGE VARCHAR,
    SYMBOL VARCHAR,
    SHORTNAME VARCHAR,
    LONGNAME VARCHAR,
    SECTOR VARCHAR,
    INDUSTRY VARCHAR,
    CURRENTPRICE NUMBER(38,2),
    MARKETCAP NUMBER(38,0),
    EBITDA NUMBER(38,0),
    REVENUEGROWTH NUMBER(38,3),
    CITY VARCHAR,
    STATE VARCHAR,
    COUNTRY VARCHAR,
    FULLTIMEEMPLOYEES NUMBER(38,0),
    LONGBUSINESSSUMMARY VARCHAR,
    WEIGHT FLOAT
);

INSERT INTO COLM_DB.STRUCTURED.SP500_COMPANIES VALUES
('NMS', 'AAPL', 'Apple Inc.', 'Apple Inc.', 'Technology', 'Consumer Electronics', 254.49, 3846819807232, 134660997120, 0.061, 'Cupertino', 'CA', 'United States', 164000, 'Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide.', 0.0692),
('NMS', 'NVDA', 'NVIDIA Corporation', 'NVIDIA Corporation', 'Technology', 'Semiconductors', 134.70, 3298803056640, 61184000000, 1.224, 'Santa Clara', 'CA', 'United States', 29600, 'NVIDIA Corporation provides graphics and compute solutions. The company operates through Graphics and Compute & Networking segments.', 0.0593),
('NMS', 'MSFT', 'Microsoft Corporation', 'Microsoft Corporation', 'Technology', 'Software - Infrastructure', 436.60, 3246068596736, 136551997440, 0.160, 'Redmond', 'WA', 'United States', 228000, 'Microsoft Corporation develops and supports software, services, devices, and solutions worldwide.', 0.0584),
('NMS', 'AMZN', 'Amazon.com, Inc.', 'Amazon.com, Inc.', 'Consumer Cyclical', 'Internet Retail', 224.92, 2365033807872, 111583002624, 0.110, 'Seattle', 'WA', 'United States', 1551000, 'Amazon.com, Inc. engages in the retail sale of consumer products, advertising, and subscriptions through online and physical stores.', 0.0425),
('NMS', 'GOOGL', 'Alphabet Inc.', 'Alphabet Inc.', 'Communication Services', 'Internet Content & Information', 191.41, 2351625142272, 123469996032, 0.151, 'Mountain View', 'CA', 'United States', 181269, 'Alphabet Inc. offers various products and platforms in the United States, Europe, the Middle East, Africa, the Asia-Pacific, Canada, and Latin America.', 0.0423),
('NMS', 'GOOG', 'Alphabet Inc.', 'Alphabet Inc.', 'Communication Services', 'Internet Content & Information', 192.96, 2351623045120, 123469996032, 0.151, 'Mountain View', 'CA', 'United States', 181269, 'Alphabet Inc. offers various products and platforms in the United States, Europe, the Middle East, Africa, the Asia-Pacific, Canada, and Latin America.', 0.0423),
('NMS', 'META', 'Meta Platforms, Inc.', 'Meta Platforms, Inc.', 'Communication Services', 'Internet Content & Information', 585.25, 1477457739776, 79208996864, 0.189, 'Menlo Park', 'CA', 'United States', 72404, 'Meta Platforms, Inc. engages in the development of products that enable people to connect and share with friends and family.', 0.0266),
('NMS', 'TSLA', 'Tesla, Inc.', 'Tesla, Inc.', 'Consumer Cyclical', 'Auto Manufacturers', 421.06, 1351627833344, 13244000256, 0.078, 'Austin', 'TX', 'United States', 140473, 'Tesla, Inc. designs, develops, manufactures, leases, and sells electric vehicles, and energy generation and storage systems.', 0.0243),
('NMS', 'AVGO', 'Broadcom Inc.', 'Broadcom Inc.', 'Technology', 'Semiconductors', 220.79, 1031217348608, 22958000128, 0.164, 'Palo Alto', 'CA', 'United States', 20000, 'Broadcom Inc. designs, develops, and supplies various semiconductor connectivity solutions.', 0.0186),
('NYQ', 'BRK-B', 'Berkshire Hathaway Inc.', 'Berkshire Hathaway Inc.', 'Financial Services', 'Insurance - Diversified', 453.20, 978776031232, 149547008000, -0.002, 'Omaha', 'NE', 'United States', 396500, 'Berkshire Hathaway Inc. engages in insurance, freight rail transportation, and utility businesses.', 0.0176),
('NMS', 'SNOW', 'Snowflake Inc.', 'Snowflake Inc.', 'Technology', 'Software - Application', 163.25, 55000000000, 1500000000, 0.350, 'Bozeman', 'MT', 'United States', 6000, 'Snowflake Inc. provides a cloud-based data platform for data warehousing, data lakes, data engineering, and data science.', 0.0099);

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
-- STEP 6: CREATE PUBLIC TRANSCRIPTS DATA (from Cybersyn Marketplace)
-- ============================================================================

CREATE OR REPLACE SEQUENCE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEQ
    START = 1000 INCREMENT = 1;

CREATE OR REPLACE TABLE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS (
    TRANSCRIPT_ID NUMBER DEFAULT COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEQ.NEXTVAL PRIMARY KEY,
    COMPANY_ID VARCHAR,
    CIK VARCHAR,
    COMPANY_NAME VARCHAR,
    PRIMARY_TICKER VARCHAR,
    FISCAL_PERIOD VARCHAR,
    FISCAL_YEAR VARCHAR,
    EVENT_TYPE VARCHAR,
    TRANSCRIPT_TYPE VARCHAR,
    TRANSCRIPT VARIANT,
    EVENT_TIMESTAMP TIMESTAMP_NTZ,
    CREATED_AT TIMESTAMP_NTZ,
    UPDATED_AT TIMESTAMP_NTZ
);

INSERT INTO COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS (
    COMPANY_ID, CIK, COMPANY_NAME, PRIMARY_TICKER, FISCAL_PERIOD, FISCAL_YEAR,
    EVENT_TYPE, TRANSCRIPT_TYPE, TRANSCRIPT, EVENT_TIMESTAMP, CREATED_AT, UPDATED_AT
)
SELECT 
    a.COMPANY_ID, a.CIK, a.COMPANY_NAME, a.PRIMARY_TICKER, a.FISCAL_PERIOD, a.FISCAL_YEAR,
    a.EVENT_TYPE, a.TRANSCRIPT_TYPE, a.TRANSCRIPT, a.EVENT_TIMESTAMP, a.CREATED_AT, a.UPDATED_AT
FROM SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN.COMPANY_EVENT_TRANSCRIPT_ATTRIBUTES_V2 a
WHERE a.EVENT_TIMESTAMP > '2025-01-01' 
  AND a.PRIMARY_TICKER IN (SELECT SYMBOL FROM COLM_DB.STRUCTURED.SP500_COMPANIES);

ALTER TABLE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- STEP 7: CREATE PRIVATE TRANSCRIPTS TABLE (Third Bridge - empty, for demo)
-- ============================================================================

CREATE OR REPLACE TABLE COLM_DB.UNSTRUCTURED.TB_TRANSCRIPTS (
    ID VARCHAR,
    UUID VARCHAR,
    TITLE VARCHAR,
    AGENDA VARCHAR,
    COMPLIANCE_CLASSIFICATION ARRAY,
    CONTENT_TYPE VARCHAR,
    KEY_INSIGHTS VARCHAR,
    LANGUAGE OBJECT,
    SPECIALISTS ARRAY,
    RELEVANT_COMPANIES ARRAY,
    TARGET_COMPANIES ARRAY,
    STARTS_AT TIMESTAMP_NTZ,
    TRANSCRIPT ARRAY,
    TRANSCRIPT_UPLOADED_AT TIMESTAMP_NTZ,
    TRANSCRIPT_LAST_UPDATED_AT TIMESTAMP_NTZ,
    TRANSCRIPT_URL VARCHAR
);

ALTER TABLE COLM_DB.UNSTRUCTURED.TB_TRANSCRIPTS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- STEP 8: CREATE CORTEX SEARCH SERVICES
-- ============================================================================

-- 8.1 SEC Filings Search
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

-- 8.2 Public Transcripts Search
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

-- 8.3 Private Transcripts Search (Third Bridge)
CREATE OR REPLACE CORTEX SEARCH SERVICE COLM_DB.UNSTRUCTURED.TB_TRANSCRIPTS
    ON TITLE
    ATTRIBUTES TITLE, AGENDA, CONTENT_TYPE, TARGET_COMPANIES, STARTS_AT, TRANSCRIPT_URL, RELEVANT_COMPANIES
    WAREHOUSE = 'SMALL_WH'
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
AS (
    SELECT TITLE, AGENDA, CONTENT_TYPE, TARGET_COMPANIES, STARTS_AT, TRANSCRIPT_URL, RELEVANT_COMPANIES, TRANSCRIPT
    FROM COLM_DB.UNSTRUCTURED.TB_TRANSCRIPTS
);

-- ============================================================================
-- STEP 9: CREATE SEMANTIC VIEWS FOR CORTEX ANALYST
-- ============================================================================

-- 9.1 Stock Price Timeseries Semantic View
CREATE OR REPLACE SEMANTIC VIEW COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV
    TABLES (COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES)
    FACTS (STOCK_PRICE_TIMESERIES.VALUE AS VALUE COMMENT 'Stock price or volume value')
    DIMENSIONS (
        STOCK_PRICE_TIMESERIES.TICKER AS TICKER COMMENT 'Stock ticker symbol (e.g., AAPL, MSFT, SNOW)',
        STOCK_PRICE_TIMESERIES.ASSET_CLASS AS ASSET_CLASS COMMENT 'Type of security',
        STOCK_PRICE_TIMESERIES.PRIMARY_EXCHANGE_CODE AS PRIMARY_EXCHANGE_CODE COMMENT 'Exchange code',
        STOCK_PRICE_TIMESERIES.PRIMARY_EXCHANGE_NAME AS PRIMARY_EXCHANGE_NAME COMMENT 'Exchange name',
        STOCK_PRICE_TIMESERIES.VARIABLE AS VARIABLE COMMENT 'Variable identifier',
        STOCK_PRICE_TIMESERIES.VARIABLE_NAME AS VARIABLE_NAME COMMENT 'Variable name (All-Day High, All-Day Low, etc.)',
        STOCK_PRICE_TIMESERIES.DATE AS DATE COMMENT 'Trading date',
        STOCK_PRICE_TIMESERIES.EVENT_TIMESTAMP_UTC AS EVENT_TIMESTAMP_UTC COMMENT 'Event timestamp'
    )
    COMMENT = 'Stock price timeseries for Cortex Analyst'
    WITH EXTENSION (CA='{
        "tables":[{
            "name":"STOCK_PRICE_TIMESERIES",
            "dimensions":[
                {"name":"TICKER","sample_values":["AAPL","MSFT","SNOW","NVDA","AMZN"]},
                {"name":"VARIABLE_NAME","sample_values":["All-Day High","All-Day Low","All-Day Close","Nasdaq Volume"]}
            ],
            "facts":[{"name":"VALUE","sample_values":["150.25","275.50","185.75"]}],
            "time_dimensions":[{"name":"DATE","sample_values":["2025-01-15","2025-02-01","2025-02-20"]}]
        }]
    }');

-- 9.2 S&P 500 Companies Semantic View
CREATE OR REPLACE SEMANTIC VIEW COLM_DB.STRUCTURED.SP500
    TABLES (COLM_DB.STRUCTURED.SP500_COMPANIES COMMENT 'S&P 500 company fundamentals')
    FACTS (
        SP500_COMPANIES.CURRENTPRICE AS CURRENTPRICE COMMENT 'Current stock price in USD',
        SP500_COMPANIES.REVENUEGROWTH AS REVENUEGROWTH COMMENT 'Revenue growth percentage'
    )
    DIMENSIONS (
        SP500_COMPANIES.SYMBOL AS SYMBOL COMMENT 'Stock ticker symbol',
        SP500_COMPANIES.SHORTNAME AS SHORTNAME COMMENT 'Company short name',
        SP500_COMPANIES.LONGNAME AS LONGNAME COMMENT 'Company full name',
        SP500_COMPANIES.SECTOR AS SECTOR COMMENT 'Business sector',
        SP500_COMPANIES.INDUSTRY AS INDUSTRY COMMENT 'Industry classification',
        SP500_COMPANIES.MARKETCAP AS MARKETCAP COMMENT 'Market capitalization',
        SP500_COMPANIES.EBITDA AS EBITDA COMMENT 'EBITDA',
        SP500_COMPANIES.CITY AS CITY COMMENT 'Headquarters city',
        SP500_COMPANIES.STATE AS STATE COMMENT 'Headquarters state',
        SP500_COMPANIES.COUNTRY AS COUNTRY COMMENT 'Headquarters country',
        SP500_COMPANIES.FULLTIMEEMPLOYEES AS FULLTIMEEMPLOYEES COMMENT 'Employee count',
        SP500_COMPANIES.LONGBUSINESSSUMMARY AS LONGBUSINESSSUMMARY COMMENT 'Business description',
        SP500_COMPANIES.WEIGHT AS WEIGHT COMMENT 'S&P 500 index weight'
    )
    WITH EXTENSION (CA='{
        "tables":[{
            "name":"SP500_COMPANIES",
            "dimensions":[
                {"name":"SECTOR","sample_values":["Technology","Consumer Cyclical","Communication Services","Financial Services"]},
                {"name":"INDUSTRY","sample_values":["Consumer Electronics","Semiconductors","Software - Infrastructure","Internet Retail"]},
                {"name":"SYMBOL","sample_values":["AAPL","MSFT","NVDA","AMZN","SNOW"]}
            ],
            "facts":[
                {"name":"CURRENTPRICE","sample_values":["254.49","436.60","134.70"]},
                {"name":"REVENUEGROWTH","sample_values":["0.061","0.160","1.224"]}
            ]
        }]
    }');

-- ============================================================================
-- STEP 10: CREATE HOLLY CORTEX AGENT
-- ============================================================================

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;

CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY
  COMMENT = 'Financial research assistant for SEC filings, transcripts, stock prices, and company data'
  PROFILE = '{"display_name": "Holly - Financial Research Assistant", "avatar": "📊", "color": "#1E88E5"}'
  FROM SPECIFICATION $$
  {
    "models": {"orchestration": "claude-4-sonnet"},
    "instructions": {
      "orchestration": "You are Holly, a financial research assistant. Route each query to the appropriate tool:\n\n**PUBLIC TRANSCRIPTS**: For earnings calls, investor conferences, or company event transcripts from S&P 500 companies or Snowflake, use PUBLIC_TRANSCRIPTS_SEARCH.\n\n**PRIVATE TRANSCRIPTS**: For Third Bridge expert interview transcripts or proprietary research, use TB_TRANSCRIPTS_SEARCH.\n\n**HISTORICAL PRICES**: For historical stock price analysis, OHLC data, or price trends, use STOCK_PRICES.\n\n**COMPANY FUNDAMENTALS**: For S&P 500 company data (market cap, revenue growth, EBITDA, sector), use SP500_COMPANIES.\n\n**SEC FILINGS**: For SEC filings (8-K, 10-K, 10-Q) or regulatory disclosures, use SEC_FILINGS_SEARCH.\n\nCombine multiple tools for comprehensive research.",
      "response": "Provide clear, data-driven responses with source attribution. Use tables for financial data. Specify dates for stock prices. Cite filing type and date for SEC filings. Be accurate with numbers."
    },
    "tools": [
      {"tool_spec": {"type": "cortex_search", "name": "PUBLIC_TRANSCRIPTS_SEARCH", "description": "Search public company event transcripts (earnings calls, investor conferences) from S&P 500 companies and Snowflake."}},
      {"tool_spec": {"type": "cortex_search", "name": "TB_TRANSCRIPTS_SEARCH", "description": "Search private Third Bridge expert interview transcripts for proprietary research insights."}},
      {"tool_spec": {"type": "cortex_search", "name": "SEC_FILINGS_SEARCH", "description": "Search SEC EDGAR filings (10-K, 10-Q, 8-K) for company announcements and regulatory disclosures."}},
      {"tool_spec": {"type": "cortex_analyst_text_to_sql", "name": "STOCK_PRICES", "description": "Query historical stock price data with daily OHLC values for price trends and analysis."}},
      {"tool_spec": {"type": "cortex_analyst_text_to_sql", "name": "SP500_COMPANIES", "description": "Query S&P 500 company fundamentals: market cap, revenue growth, EBITDA, sector, industry."}}
    ],
    "tool_resources": {
      "PUBLIC_TRANSCRIPTS_SEARCH": {"search_service": "COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEARCH", "max_results": 10, "columns": ["COMPANY_NAME", "PRIMARY_TICKER", "EVENT_TYPE", "FISCAL_PERIOD", "FISCAL_YEAR", "EVENT_TIMESTAMP", "TRANSCRIPT_TEXT"]},
      "TB_TRANSCRIPTS_SEARCH": {"search_service": "COLM_DB.UNSTRUCTURED.TB_TRANSCRIPTS", "max_results": 5, "columns": ["TITLE", "AGENDA", "CONTENT_TYPE", "TARGET_COMPANIES", "STARTS_AT", "TRANSCRIPT_URL", "RELEVANT_COMPANIES", "TRANSCRIPT"]},
      "SEC_FILINGS_SEARCH": {"search_service": "COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS", "max_results": 10, "columns": ["COMPANY_NAME", "ANNOUNCEMENT_TYPE", "FILED_DATE", "FISCAL_PERIOD", "FISCAL_YEAR", "ITEM_NUMBER", "ITEM_TITLE", "ANNOUNCEMENT_TEXT"]},
      "STOCK_PRICES": {"semantic_view": "COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV", "execution_environment": {"type": "warehouse", "warehouse": "SMALL_WH"}, "query_timeout": 120},
      "SP500_COMPANIES": {"semantic_view": "COLM_DB.STRUCTURED.SP500", "execution_environment": {"type": "warehouse", "warehouse": "SMALL_WH"}, "query_timeout": 60}
    }
  }
  $$;

GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY TO ROLE PUBLIC;

-- ============================================================================
-- STEP 11: CREATE SCHEDULED DATA REFRESH TASK
-- ============================================================================

-- Create warehouse for scheduled tasks if not exists
CREATE WAREHOUSE IF NOT EXISTS ADHOC_WH WITH WAREHOUSE_SIZE = 'MEDIUM' AUTO_SUSPEND = 1800;

-- Daily refresh task: Runs at 6:00 AM GMT/UTC
CREATE OR REPLACE TASK COLM_DB.STRUCTURED.DAILY_DATA_REFRESH
  WAREHOUSE = ADHOC_WH
  SCHEDULE = 'USING CRON 0 6 * * * UTC'
  COMMENT = 'Daily refresh of EDGAR_FILINGS and PUBLIC_TRANSCRIPTS tables at 6:00 AM GMT'
AS
BEGIN
  -- Refresh EDGAR_FILINGS table with latest SEC filings
  MERGE INTO COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS AS target
  USING (
    SELECT 
      COMPANY_NAME,
      FORM_TYPE AS ANNOUNCEMENT_TYPE,
      FILED_DATE::DATE AS FILED_DATE,
      FISCAL_PERIOD,
      FISCAL_YEAR::FLOAT AS FISCAL_YEAR,
      ITEM_NUMBER,
      ITEM_TITLE,
      PLAINTEXT_CONTENT AS ANNOUNCEMENT_TEXT
    FROM SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN.SEC_CORPORATE_REPORT_ITEM_ATTRIBUTES
    WHERE PLAINTEXT_CONTENT IS NOT NULL
  ) AS source
  ON target.COMPANY_NAME = source.COMPANY_NAME 
     AND target.FILED_DATE = source.FILED_DATE 
     AND target.ITEM_NUMBER = source.ITEM_NUMBER
  WHEN NOT MATCHED THEN
    INSERT (COMPANY_NAME, ANNOUNCEMENT_TYPE, FILED_DATE, FISCAL_PERIOD, FISCAL_YEAR, ITEM_NUMBER, ITEM_TITLE, ANNOUNCEMENT_TEXT)
    VALUES (source.COMPANY_NAME, source.ANNOUNCEMENT_TYPE, source.FILED_DATE, source.FISCAL_PERIOD, source.FISCAL_YEAR, source.ITEM_NUMBER, source.ITEM_TITLE, source.ANNOUNCEMENT_TEXT);

  -- Refresh PUBLIC_TRANSCRIPTS table with latest earnings call transcripts
  MERGE INTO COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS AS target
  USING (
    SELECT 
      COMPANY_ID,
      CIK,
      COMPANY_NAME,
      PRIMARY_TICKER,
      FISCAL_PERIOD,
      FISCAL_YEAR,
      EVENT_TYPE,
      TRANSCRIPT_TYPE,
      TRANSCRIPT,
      EVENT_TIMESTAMP,
      CREATED_AT,
      UPDATED_AT
    FROM SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN.COMPANY_EVENT_TRANSCRIPT_ATTRIBUTES_V2
    WHERE TRANSCRIPT IS NOT NULL
  ) AS source
  ON target.COMPANY_ID = source.COMPANY_ID 
     AND target.EVENT_TIMESTAMP = source.EVENT_TIMESTAMP
     AND target.FISCAL_PERIOD = source.FISCAL_PERIOD
     AND target.FISCAL_YEAR = source.FISCAL_YEAR
  WHEN NOT MATCHED THEN
    INSERT (COMPANY_ID, CIK, COMPANY_NAME, PRIMARY_TICKER, FISCAL_PERIOD, FISCAL_YEAR, EVENT_TYPE, TRANSCRIPT_TYPE, TRANSCRIPT, EVENT_TIMESTAMP, CREATED_AT, UPDATED_AT)
    VALUES (source.COMPANY_ID, source.CIK, source.COMPANY_NAME, source.PRIMARY_TICKER, source.FISCAL_PERIOD, source.FISCAL_YEAR, source.EVENT_TYPE, source.TRANSCRIPT_TYPE, source.TRANSCRIPT, source.EVENT_TIMESTAMP, source.CREATED_AT, source.UPDATED_AT);
END;

-- Enable the task
ALTER TASK COLM_DB.STRUCTURED.DAILY_DATA_REFRESH RESUME;

-- ============================================================================
-- STEP 12: VERIFICATION
-- ============================================================================

SELECT 'SP500_COMPANIES' AS table_name, COUNT(*) AS row_count FROM COLM_DB.STRUCTURED.SP500_COMPANIES
UNION ALL SELECT 'STOCK_PRICE_TIMESERIES', COUNT(*) FROM COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES
UNION ALL SELECT 'EDGAR_FILINGS', COUNT(*) FROM COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS
UNION ALL SELECT 'PUBLIC_TRANSCRIPTS', COUNT(*) FROM COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS
UNION ALL SELECT 'TB_TRANSCRIPTS', COUNT(*) FROM COLM_DB.UNSTRUCTURED.TB_TRANSCRIPTS;

SHOW CORTEX SEARCH SERVICES IN DATABASE COLM_DB;
SHOW SEMANTIC VIEWS IN DATABASE COLM_DB;
DESC AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY;

-- ============================================================================
-- INSTALLATION COMPLETE!
-- Navigate to: AI & ML > Snowflake Intelligence > Holly
-- ============================================================================
