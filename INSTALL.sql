/*
================================================================================
  HOLLY - Financial Research Assistant
  Installation Script
  
  Author: Colm Moynihan
  Version: 1.8
  Date: 2nd March 2026
  
  PREREQUISITES:
  --------------
  1. ACCOUNTADMIN role or equivalent privileges
  2. Subscribe to the following Marketplace listing:
     
     Cybersyn Financial & Economic Essentials (Free Trial)
     - Go to: Data Products > Marketplace
     - Search for: "Cybersyn Financial & Economic Essentials"
     - Click "Get" to subscribe (free trial available)
     - This provides: SNOWFLAKE_PUBLIC_DATA_PAID.PUBLIC_DATA
  
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

-- Load S&P 500 companies (503 constituents as of March 2026 + SNOW)
INSERT INTO COLM_DB.STRUCTURED.SP500_COMPANIES (SYMBOL, COMPANY_NAME, CIK)
WITH SP500_TICKERS AS (
    SELECT column1 AS TICKER FROM VALUES
    ('A'),('AAPL'),('ABBV'),('ABNB'),('ABT'),('ACGL'),('ACN'),('ADBE'),('ADI'),('ADM'),
    ('ADP'),('ADSK'),('AEE'),('AEP'),('AES'),('AFL'),('AIG'),('AIZ'),('AJG'),('AKAM'),
    ('ALB'),('ALGN'),('ALL'),('ALLE'),('AMAT'),('AMCR'),('AMD'),('AME'),('AMGN'),('AMP'),
    ('AMT'),('AMZN'),('ANET'),('AON'),('AOS'),('APA'),('APD'),('APH'),('APO'),('APTV'),
    ('ARE'),('ATO'),('AVB'),('AVGO'),('AVY'),('AWK'),('AXON'),('AXP'),('AZO'),('BA'),
    ('BAC'),('BALL'),('BAX'),('BBY'),('BDX'),('BEN'),('BF.B'),('BG'),('BIIB'),('BK'),
    ('BKNG'),('BKR'),('BLDR'),('BLK'),('BMY'),('BR'),('BRK.B'),('BRO'),('BSX'),('BX'),
    ('BXP'),('C'),('CAG'),('CAH'),('CARR'),('CAT'),('CB'),('CBOE'),('CBRE'),('CCI'),
    ('CCL'),('CDNS'),('CDW'),('CEG'),('CF'),('CFG'),('CHD'),('CHRW'),('CHTR'),('CI'),
    ('CINF'),('CL'),('CLX'),('CMCSA'),('CME'),('CMG'),('CMI'),('CMS'),('CNC'),('CNP'),
    ('COF'),('COIN'),('COO'),('COP'),('COR'),('COST'),('CPAY'),('CPB'),('CPRT'),('CPT'),
    ('CRL'),('CRM'),('CRWD'),('CSCO'),('CSGP'),('CSX'),('CTAS'),('CTRA'),('CTSH'),('CTVA'),
    ('CVS'),('CVX'),('CZR'),('D'),('DAL'),('DASH'),('DAY'),('DD'),('DDOG'),('DE'),
    ('DECK'),('DELL'),('DG'),('DGX'),('DHI'),('DHR'),('DIS'),('DLR'),('DLTR'),('DOC'),
    ('DOV'),('DOW'),('DPZ'),('DRI'),('DTE'),('DUK'),('DVA'),('DVN'),('DXCM'),('EA'),
    ('EBAY'),('ECL'),('ED'),('EFX'),('EG'),('EIX'),('EL'),('ELV'),('EMN'),('EMR'),
    ('ENPH'),('EOG'),('EPAM'),('EQIX'),('EQR'),('EQT'),('ERIE'),('ES'),('ESS'),('ETN'),
    ('ETR'),('EVRG'),('EW'),('EXC'),('EXE'),('EXPD'),('EXPE'),('EXR'),('F'),('FANG'),
    ('FAST'),('FCX'),('FDS'),('FDX'),('FE'),('FFIV'),('FI'),('FICO'),('FIS'),('FITB'),
    ('FOX'),('FOXA'),('FRT'),('FSLR'),('FTNT'),('FTV'),('GD'),('GDDY'),('GE'),('GEHC'),
    ('GEN'),('GEV'),('GILD'),('GIS'),('GL'),('GLW'),('GM'),('GNRC'),('GOOG'),('GOOGL'),
    ('GPC'),('GPN'),('GRMN'),('GS'),('GWW'),('HAL'),('HAS'),('HBAN'),('HCA'),('HD'),
    ('HIG'),('HII'),('HLT'),('HOLX'),('HON'),('HPE'),('HPQ'),('HRL'),('HSIC'),('HST'),
    ('HSY'),('HUBB'),('HUM'),('HWM'),('IBM'),('ICE'),('IDXX'),('IEX'),('IFF'),('INCY'),
    ('INTC'),('INTU'),('INVH'),('IP'),('IPG'),('IQV'),('IR'),('IRM'),('ISRG'),('IT'),
    ('ITW'),('IVZ'),('J'),('JBHT'),('JBL'),('JCI'),('JKHY'),('JNJ'),('JPM'),('K'),
    ('KDP'),('KEY'),('KEYS'),('KHC'),('KIM'),('KKR'),('KLAC'),('KMB'),('KMI'),('KMX'),
    ('KO'),('KR'),('KVUE'),('L'),('LDOS'),('LEN'),('LH'),('LHX'),('LII'),('LIN'),
    ('LKQ'),('LLY'),('LMT'),('LNT'),('LOW'),('LRCX'),('LULU'),('LUV'),('LVS'),('LW'),
    ('LYB'),('LYV'),('MA'),('MAA'),('MAR'),('MAS'),('MCD'),('MCHP'),('MCK'),('MCO'),
    ('MDLZ'),('MDT'),('MET'),('META'),('MGM'),('MHK'),('MKC'),('MKTX'),('MLM'),('MMC'),
    ('MMM'),('MNST'),('MO'),('MOH'),('MOS'),('MPC'),('MPWR'),('MRK'),('MRNA'),('MS'),
    ('MSCI'),('MSFT'),('MSI'),('MTB'),('MTCH'),('MTD'),('MU'),('NCLH'),('NDAQ'),('NDSN'),
    ('NEE'),('NEM'),('NFLX'),('NI'),('NKE'),('NOC'),('NOW'),('NRG'),('NSC'),('NTAP'),
    ('NTRS'),('NUE'),('NVDA'),('NVR'),('NWS'),('NWSA'),('NXPI'),('O'),('ODFL'),('OKE'),
    ('OMC'),('ON'),('ORCL'),('ORLY'),('OTIS'),('OXY'),('PANW'),('PAYC'),('PAYX'),('PCAR'),
    ('PCG'),('PEG'),('PEP'),('PFE'),('PFG'),('PG'),('PGR'),('PH'),('PHM'),('PKG'),
    ('PLD'),('PLTR'),('PM'),('PNC'),('PNR'),('PNW'),('PODD'),('POOL'),('PPG'),('PPL'),
    ('PRU'),('PSA'),('PSKY'),('PSX'),('PTC'),('PWR'),('PYPL'),('QCOM'),('RCL'),('REG'),
    ('REGN'),('RF'),('RJF'),('RL'),('RMD'),('ROK'),('ROL'),('ROP'),('ROST'),('RSG'),
    ('RTX'),('RVTY'),('SBAC'),('SBUX'),('SCHW'),('SHW'),('SJM'),('SLB'),('SMCI'),('SNA'),
    ('SNPS'),('SO'),('SOLV'),('SPG'),('SPGI'),('SRE'),('STE'),('STLD'),('STT'),('STX'),
    ('STZ'),('SW'),('SWK'),('SWKS'),('SYF'),('SYK'),('SYY'),('T'),('TAP'),('TDG'),
    ('TDY'),('TECH'),('TEL'),('TER'),('TFC'),('TGT'),('TJX'),('TKO'),('TMO'),('TMUS'),
    ('TPL'),('TPR'),('TRGP'),('TRMB'),('TROW'),('TRV'),('TSCO'),('TSLA'),('TSN'),('TT'),
    ('TTD'),('TTWO'),('TXN'),('TXT'),('TYL'),('UAL'),('UBER'),('UDR'),('UHS'),('ULTA'),
    ('UNH'),('UNP'),('UPS'),('URI'),('USB'),('V'),('VICI'),('VLO'),('VLTO'),('VMC'),
    ('VRSK'),('VRSN'),('VRTX'),('VST'),('VTR'),('VTRS'),('VZ'),('WAB'),('WAT'),('WBA'),
    ('WBD'),('WDAY'),('WDC'),('WEC'),('WELL'),('WFC'),('WM'),('WMB'),('WMT'),('WRB'),
    ('WSM'),('WST'),('WTW'),('WY'),('WYNN'),('XEL'),('XOM'),('XYL'),('YUM'),('ZBH'),
    ('ZBRA'),('ZTS'),('SNOW')
)
SELECT DISTINCT
    t.TICKER AS SYMBOL,
    COALESCE(c.COMPANY_NAME, t.TICKER) AS COMPANY_NAME,
    c.CIK
FROM SP500_TICKERS t
LEFT JOIN SNOWFLAKE_PUBLIC_DATA_PAID.PUBLIC_DATA.SEC_CIK_INDEX c 
    ON t.TICKER = UPPER(REGEXP_REPLACE(c.COMPANY_NAME, '[^A-Z0-9]', ''))
QUALIFY ROW_NUMBER() OVER (PARTITION BY t.TICKER ORDER BY c.CIK) = 1;

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
FROM SNOWFLAKE_PUBLIC_DATA_PAID.PUBLIC_DATA.STOCK_PRICE_TIMESERIES
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
FROM SNOWFLAKE_PUBLIC_DATA_PAID.PUBLIC_DATA.SEC_CORPORATE_REPORT_INDEX r
INNER JOIN SNOWFLAKE_PUBLIC_DATA_PAID.PUBLIC_DATA.SEC_CORPORATE_REPORT_ITEM_ATTRIBUTES a
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
FROM SNOWFLAKE_PUBLIC_DATA_PAID.PUBLIC_DATA.COMPANY_EVENT_TRANSCRIPT_ATTRIBUTES t
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

-- Scale down warehouse after heavy data loading
ALTER WAREHOUSE SMALL_WH SET WAREHOUSE_SIZE = 'MEDIUM' AUTO_SUSPEND = 300;

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
