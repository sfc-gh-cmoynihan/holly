/*
================================================================================
  HOLLY - Financial Research Assistant
  Installation Script
  
  Author: Colm Moynihan
  Version: 1.0
  Date: 23rd February 2026
  
  Prerequisites:
  - ACCOUNTADMIN role or equivalent privileges
  - Access to SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN (Snowflake Marketplace)
  - Warehouse for compute operations
  
  This script creates all necessary objects for the Holly Cortex Agent:
  - Database and schemas
  - Tables (with data from Cybersyn marketplace)
  - Cortex Search services
  - Semantic views for Cortex Analyst
  - The Holly Cortex Agent
================================================================================
*/

-- ============================================================================
-- STEP 1: SET UP CONTEXT
-- ============================================================================
USE ROLE ACCOUNTADMIN;
CREATE WAREHOUSE IF NOT EXISTS SMALL_WH WITH WAREHOUSE_SIZE = 'SMALL';
USE WAREHOUSE SMALL_WH;

-- ============================================================================
-- STEP 2: CREATE DATABASE AND SCHEMAS
-- ============================================================================
CREATE DATABASE IF NOT EXISTS COLM_DB;

CREATE SCHEMA IF NOT EXISTS COLM_DB.STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.SEMI_STRUCTURED;
CREATE SCHEMA IF NOT EXISTS COLM_DB.UNSTRUCTURED;

-- ============================================================================
-- STEP 3: CREATE TABLES
-- ============================================================================

-- 3.1 S&P 500 Companies (reference data)
CREATE OR REPLACE TABLE COLM_DB.STRUCTURED.SP500_COMPANIES (
    EXCHANGE VARCHAR(16777216),
    SYMBOL VARCHAR(16777216),
    SHORTNAME VARCHAR(16777216),
    LONGNAME VARCHAR(16777216),
    SECTOR VARCHAR(16777216),
    INDUSTRY VARCHAR(16777216),
    CURRENTPRICE NUMBER(38,2),
    MARKETCAP NUMBER(38,0),
    EBITDA NUMBER(38,0),
    REVENUEGROWTH NUMBER(38,3),
    CITY VARCHAR(16777216),
    STATE VARCHAR(16777216),
    COUNTRY VARCHAR(16777216),
    FULLTIMEEMPLOYEES NUMBER(38,0),
    LONGBUSINESSSUMMARY VARCHAR(16777216),
    WEIGHT DECFLOAT(38)
);

-- Load S&P 500 data from CSV (run separately or use PUT/COPY)
-- PUT file://data/SP500_COMPANIES.csv @COLM_DB.STRUCTURED.%SP500_COMPANIES;
-- COPY INTO COLM_DB.STRUCTURED.SP500_COMPANIES FROM @COLM_DB.STRUCTURED.%SP500_COMPANIES FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);

-- 3.2 Stock Price Timeseries (from Cybersyn marketplace)
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
WHERE TICKER IN (SELECT SYMBOL FROM COLM_DB.STRUCTURED.SP500_COMPANIES)
   OR TICKER = 'SNOW';

-- Enable change tracking for Cortex Search compatibility
ALTER TABLE COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES SET CHANGE_TRACKING = TRUE;

-- 3.3 SEC EDGAR Filings (from Cybersyn marketplace)
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
  AND r.FORM_TYPE IN ('8-K','10-K','10-Q');

ALTER TABLE COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS SET CHANGE_TRACKING = TRUE;

-- 3.4 Public Transcripts (from Cybersyn marketplace)
CREATE OR REPLACE SEQUENCE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEQ
    START = 1000
    INCREMENT = 1
    COMMENT = 'Sequence for PUBLIC_TRANSCRIPTS primary key';

CREATE OR REPLACE TABLE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS (
    TRANSCRIPT_ID NUMBER DEFAULT COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEQ.NEXTVAL PRIMARY KEY,
    COMPANY_ID VARCHAR(16777216),
    CIK VARCHAR(16777216),
    COMPANY_NAME VARCHAR(16777216),
    PRIMARY_TICKER VARCHAR(16777216),
    FISCAL_PERIOD VARCHAR(16777216),
    FISCAL_YEAR VARCHAR(16777216),
    EVENT_TYPE VARCHAR(16777216),
    TRANSCRIPT_TYPE VARCHAR(16777216),
    TRANSCRIPT VARIANT,
    EVENT_TIMESTAMP TIMESTAMP_NTZ(9),
    CREATED_AT TIMESTAMP_NTZ(9),
    UPDATED_AT TIMESTAMP_NTZ(9)
);

INSERT INTO COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS (
    COMPANY_ID, CIK, COMPANY_NAME, PRIMARY_TICKER, FISCAL_PERIOD, FISCAL_YEAR,
    EVENT_TYPE, TRANSCRIPT_TYPE, TRANSCRIPT, EVENT_TIMESTAMP, CREATED_AT, UPDATED_AT
)
SELECT 
    a.COMPANY_ID, a.CIK, a.COMPANY_NAME, a.PRIMARY_TICKER, a.FISCAL_PERIOD, a.FISCAL_YEAR,
    a.EVENT_TYPE, a.TRANSCRIPT_TYPE, a.TRANSCRIPT, a.EVENT_TIMESTAMP, a.CREATED_AT, a.UPDATED_AT
FROM SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN.COMPANY_EVENT_TRANSCRIPT_ATTRIBUTES_V2 a
INNER JOIN COLM_DB.STRUCTURED.SP500_COMPANIES sp ON a.PRIMARY_TICKER = sp.SYMBOL
WHERE a.EVENT_TIMESTAMP > '2025-01-01'
UNION ALL
SELECT 
    a.COMPANY_ID, a.CIK, a.COMPANY_NAME, a.PRIMARY_TICKER, a.FISCAL_PERIOD, a.FISCAL_YEAR,
    a.EVENT_TYPE, a.TRANSCRIPT_TYPE, a.TRANSCRIPT, a.EVENT_TIMESTAMP, a.CREATED_AT, a.UPDATED_AT
FROM SNOWFLAKE_PUBLIC_DATA_PAID.CYBERSYN.COMPANY_EVENT_TRANSCRIPT_ATTRIBUTES_V2 a
WHERE a.EVENT_TIMESTAMP > '2025-01-01' AND a.PRIMARY_TICKER = 'SNOW';

ALTER TABLE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS SET CHANGE_TRACKING = TRUE;

-- 3.5 Third Bridge Transcripts (private - requires separate data load)
CREATE OR REPLACE TABLE COLM_DB.UNSTRUCTURED.TB_TRANSCRIPTS (
    ID VARCHAR(16777216),
    UUID VARCHAR(16777216),
    TITLE VARCHAR(16777216),
    AGENDA VARCHAR(16777216),
    COMPLIANCE_CLASSIFICATION ARRAY,
    CONTENT_TYPE VARCHAR(16777216),
    KEY_INSIGHTS VARCHAR(16777216),
    LANGUAGE OBJECT,
    SPECIALISTS ARRAY,
    RELEVANT_COMPANIES ARRAY,
    TARGET_COMPANIES ARRAY,
    STARTS_AT TIMESTAMP_NTZ(9),
    TRANSCRIPT ARRAY,
    TRANSCRIPT_UPLOADED_AT TIMESTAMP_NTZ(9),
    TRANSCRIPT_LAST_UPDATED_AT TIMESTAMP_NTZ(9),
    TRANSCRIPT_URL VARCHAR(16777216)
);

ALTER TABLE COLM_DB.UNSTRUCTURED.TB_TRANSCRIPTS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- STEP 4: CREATE CORTEX SEARCH SERVICES
-- ============================================================================

-- 4.1 SEC Filings Search
CREATE OR REPLACE CORTEX SEARCH SERVICE COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS
    ON ANNOUNCEMENT_TEXT
    ATTRIBUTES COMPANY_NAME, ANNOUNCEMENT_TYPE, FILED_DATE, FISCAL_PERIOD, FISCAL_YEAR, ITEM_NUMBER, ITEM_TITLE
    WAREHOUSE = 'SMALL_WH'
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
AS (
    SELECT
        COMPANY_NAME,
        ANNOUNCEMENT_TYPE,
        FILED_DATE,
        FISCAL_PERIOD,
        FISCAL_YEAR,
        ITEM_NUMBER,
        ITEM_TITLE,
        ANNOUNCEMENT_TEXT
    FROM COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS
);

-- 4.2 Public Transcripts Search
CREATE OR REPLACE CORTEX SEARCH SERVICE COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEARCH
    ON transcript_text
    ATTRIBUTES company_name, primary_ticker, event_type, fiscal_period, fiscal_year
    WAREHOUSE = 'SMALL_WH'
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
AS (
    SELECT
        TRANSCRIPT_ID,
        COMPANY_ID,
        CIK,
        COMPANY_NAME,
        PRIMARY_TICKER,
        FISCAL_PERIOD,
        FISCAL_YEAR,
        EVENT_TYPE,
        EVENT_TIMESTAMP,
        TRANSCRIPT:text::VARCHAR as transcript_text
    FROM COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS
    WHERE TRANSCRIPT:text IS NOT NULL
);

-- 4.3 Third Bridge (Private) Transcripts Search
CREATE OR REPLACE CORTEX SEARCH SERVICE COLM_DB.UNSTRUCTURED.TB_TRANSCRIPTS
    ON TITLE
    ATTRIBUTES TITLE, AGENDA, CONTENT_TYPE, TARGET_COMPANIES, STARTS_AT, TRANSCRIPT_URL, RELEVANT_COMPANIES
    WAREHOUSE = 'SMALL_WH'
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
AS (
    SELECT
        TITLE,
        AGENDA,
        CONTENT_TYPE,
        TARGET_COMPANIES,
        STARTS_AT,
        TRANSCRIPT_URL,
        RELEVANT_COMPANIES,
        TRANSCRIPT
    FROM COLM_DB.UNSTRUCTURED.TB_TRANSCRIPTS
);

-- ============================================================================
-- STEP 5: CREATE SEMANTIC VIEWS (CORTEX ANALYST)
-- ============================================================================

-- 5.1 Stock Price Timeseries Semantic View
CREATE OR REPLACE SEMANTIC VIEW COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV
    TABLES (
        COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES
    )
    FACTS (
        STOCK_PRICE_TIMESERIES.VALUE AS VALUE COMMENT 'Value reported for the variable.'
    )
    DIMENSIONS (
        STOCK_PRICE_TIMESERIES.ASSET_CLASS AS ASSET_CLASS COMMENT 'Type of security.',
        STOCK_PRICE_TIMESERIES.PRIMARY_EXCHANGE_CODE AS PRIMARY_EXCHANGE_CODE COMMENT 'The exchange code for the primary trading venue of a security.',
        STOCK_PRICE_TIMESERIES.PRIMARY_EXCHANGE_NAME AS PRIMARY_EXCHANGE_NAME COMMENT 'The exchange name for the primary trading venue of a security.',
        STOCK_PRICE_TIMESERIES.TICKER AS TICKER COMMENT 'Alphanumeric code that represents a specific publicly traded security.',
        STOCK_PRICE_TIMESERIES.VARIABLE AS VARIABLE COMMENT 'Unique identifier for a variable.',
        STOCK_PRICE_TIMESERIES.VARIABLE_NAME AS VARIABLE_NAME COMMENT 'Human-readable unique name for the variable.',
        STOCK_PRICE_TIMESERIES.DATE AS DATE COMMENT 'Date associated with the value.',
        STOCK_PRICE_TIMESERIES.EVENT_TIMESTAMP_UTC AS EVENT_TIMESTAMP_UTC COMMENT 'Timestamp when the event occurred in UTC.'
    )
    COMMENT = 'Stock price timeseries for Cortex Analyst'
    WITH EXTENSION (CA='{
        "tables":[{
            "name":"STOCK_PRICE_TIMESERIES",
            "dimensions":[
                {"name":"ASSET_CLASS","sample_values":["Common Shares","Closed-End Funds","Equity"]},
                {"name":"PRIMARY_EXCHANGE_CODE","sample_values":["NYS","PSE","NAS"]},
                {"name":"PRIMARY_EXCHANGE_NAME","sample_values":["NEW YORK STOCK EXCHANGE","NASDAQ CAPITAL MARKET","NYSE ARCA"]},
                {"name":"TICKER","sample_values":["AAPL","MSFT","SNOW"]},
                {"name":"VARIABLE","sample_values":["all-day_high_adjusted","pre-market_open","post-market_close"]},
                {"name":"VARIABLE_NAME","sample_values":["Nasdaq Volume","All-Day High","Post-Market Close"]}
            ],
            "facts":[
                {"name":"VALUE","sample_values":["150.25","275.50","185.75"]}
            ],
            "filters":[
                {"name":"major_tech_stocks","description":"Filters for major technology stocks including Amazon (AMZN), Microsoft (MSFT), and Snowflake (SNOW).","expr":"ticker IN (''AMZN'', ''MSFT'', ''SNOW'')"}
            ],
            "time_dimensions":[
                {"name":"DATE","sample_values":["2025-01-15","2025-02-01","2025-02-20"]}
            ]
        }]
    }');

-- 5.2 S&P 500 Companies Semantic View
CREATE OR REPLACE SEMANTIC VIEW COLM_DB.STRUCTURED.SP500
    TABLES (
        COLM_DB.STRUCTURED.SP500_COMPANIES COMMENT 'S&P 500 company fundamentals including sector, industry, financials, and business summaries.'
    )
    FACTS (
        SP500_COMPANIES.CURRENTPRICE AS CURRENTPRICE COMMENT 'The current trading price of the company stock in US dollars.',
        SP500_COMPANIES.REVENUEGROWTH AS REVENUEGROWTH COMMENT 'The percentage growth in revenue compared to a previous period.'
    )
    DIMENSIONS (
        SP500_COMPANIES.CITY AS CITY COMMENT 'The city where the company is headquartered.',
        SP500_COMPANIES.COUNTRY AS COUNTRY COMMENT 'The country where the company is headquartered.',
        SP500_COMPANIES.EBITDA AS EBITDA COMMENT 'Earnings before interest, taxes, depreciation, and amortization.',
        SP500_COMPANIES.EXCHANGE AS EXCHANGE COMMENT 'The stock exchange where the company is listed.',
        SP500_COMPANIES.FULLTIMEEMPLOYEES AS FULLTIMEEMPLOYEES COMMENT 'The number of full-time employees.',
        SP500_COMPANIES.INDUSTRY AS INDUSTRY COMMENT 'The industry classification.',
        SP500_COMPANIES.LONGBUSINESSSUMMARY AS LONGBUSINESSSUMMARY COMMENT 'A description of the company business operations.',
        SP500_COMPANIES.LONGNAME AS LONGNAME COMMENT 'The full legal name of the company.',
        SP500_COMPANIES.MARKETCAP AS MARKETCAP COMMENT 'Market capitalization in dollars.',
        SP500_COMPANIES.SECTOR AS SECTOR COMMENT 'The economic sector classification.',
        SP500_COMPANIES.SHORTNAME AS SHORTNAME COMMENT 'The short name of the company.',
        SP500_COMPANIES.STATE AS STATE COMMENT 'The state where the company is headquartered.',
        SP500_COMPANIES.SYMBOL AS SYMBOL COMMENT 'Stock ticker symbol.',
        SP500_COMPANIES.WEIGHT AS WEIGHT COMMENT 'Weight in S&P 500 index.'
    )
    WITH EXTENSION (CA='{
        "tables":[{
            "name":"SP500_COMPANIES",
            "dimensions":[
                {"name":"SECTOR","sample_values":["Technology","Healthcare","Financials"]},
                {"name":"INDUSTRY","sample_values":["Software","Banks","Pharmaceuticals"]},
                {"name":"SYMBOL","sample_values":["AAPL","MSFT","AMZN"]}
            ],
            "facts":[
                {"name":"CURRENTPRICE","sample_values":["175.50","425.00","185.25"]},
                {"name":"REVENUEGROWTH","sample_values":["0.15","0.08","-0.05"]}
            ]
        }]
    }');

-- ============================================================================
-- STEP 6: CREATE SNOWFLAKE INTELLIGENCE DATABASE AND SCHEMA
-- ============================================================================
CREATE DATABASE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE;
CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;

-- ============================================================================
-- STEP 7: CREATE HOLLY CORTEX AGENT
-- ============================================================================
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY
  COMMENT = 'Financial research assistant that orchestrates across SEC filings, transcripts, stock prices, and S&P 500 company data'
  PROFILE = '{"display_name": "Holly - Financial Research Assistant", "avatar": "📊", "color": "#1E88E5"}'
  FROM SPECIFICATION $$
  {
    "models": {
      "orchestration": "claude-4-sonnet"
    },
    "instructions": {
      "orchestration": "You are Holly, a financial research assistant. Route each query to the appropriate tool:\n\n**ANNUAL REPORTS**: For questions about annual reports, 10-K filings, or company annual financial statements, use ASK_QUESTION_RAG to search and answer from annual report documents.\n\n**SHARE PRICES**: For questions about current or recent stock prices, share prices, or real-time quotes, use GET_STOCK_PRICE with the ticker symbol.\n\n**PUBLIC TRANSCRIPTS**: For questions about public earnings calls, investor conferences, or company event transcripts from S&P 500 companies or Snowflake, use PUBLIC_TRANSCRIPTS_SEARCH.\n\n**PRIVATE TRANSCRIPTS**: For questions about private or Third Bridge expert interview transcripts, analyst opinions, or proprietary research insights, use TB_TRANSCRIPTS_SEARCH.\n\n**HISTORICAL PRICE DATA**: For historical stock price analysis, OHLC data, price trends over time, or technical analysis, use STOCK_PRICES semantic view.\n\n**COMPANY FUNDAMENTALS**: For S&P 500 company fundamentals like market cap, revenue growth, EBITDA, sector/industry classification, use SP500_COMPANIES.\n\n**SEC FILINGS**: For SEC regulatory filings, 8-K announcements, 10-Q quarterly reports, or company disclosures, use SEC_FILINGS_SEARCH.\n\nFor comprehensive research, combine multiple tools as needed.",
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

-- Grant public access to Holly
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY TO ROLE PUBLIC;

-- ============================================================================
-- STEP 8: VERIFICATION
-- ============================================================================

-- Verify tables created
SELECT 'Tables' as object_type, COUNT(*) as count 
FROM COLM_DB.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA IN ('STRUCTURED', 'SEMI_STRUCTURED', 'UNSTRUCTURED');

-- Verify Cortex Search services
SHOW CORTEX SEARCH SERVICES IN DATABASE COLM_DB;

-- Verify semantic views
SHOW SEMANTIC VIEWS IN DATABASE COLM_DB;

-- Verify agent
DESC AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY;

-- ============================================================================
-- INSTALLATION COMPLETE
-- Navigate to AI & ML > Snowflake Intelligence to use Holly
-- ============================================================================
