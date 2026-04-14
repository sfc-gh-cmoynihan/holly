/*
================================================================================
  HOLLY - Financial Research Assistant
  Uninstall Script
  
  Author: Colm Moynihan
  Version: 3.0
  Date: 14th April 2026
  
  WARNING: This script will permanently delete all Holly components!
  
  WHAT THIS SCRIPT REMOVES:
  -------------------------
  - Agent: SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY
  - Cortex Search Services: EDGAR_FILINGS_SEARCH, PUBLIC_TRANSCRIPTS_SEARCH, COMPANY_DOCS_SEARCH
  - Semantic Views: STOCK_PRICE_TIMESERIES_SV, AIM_STOCK_PRICES_SV, SP500, EDGAR_FILINGS_SV, STOCK_PRICE_TIMESERIES_IT_SV
  - Tables: SP500_COMPANIES, STOCK_PRICE_TIMESERIES, AIM_STOCK_PRICES, EDGAR_FILINGS, PUBLIC_TRANSCRIPTS, STOCK_PRICE_TIMESERIES_IT
  - Yahoo Finance: Network rule, external access integration, UDF
  - Database: COLM_DB
  - Schema: SNOWFLAKE_INTELLIGENCE.AGENTS (optional)
================================================================================
*/

-- ============================================================================
-- STEP 1: SET UP CONTEXT
-- ============================================================================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE SMALL_WH;

-- ============================================================================
-- STEP 2: DROP CORTEX AGENT
-- ============================================================================
DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY;

-- ============================================================================
-- STEP 3: DROP CORTEX SEARCH SERVICES
-- ============================================================================
DROP CORTEX SEARCH SERVICE IF EXISTS COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS;
DROP CORTEX SEARCH SERVICE IF EXISTS COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEARCH;
DROP CORTEX SEARCH SERVICE IF EXISTS COLM_DB.UNSTRUCTURED.COMPANY_DOCS_SEARCH;

-- ============================================================================
-- STEP 4: DROP SEMANTIC VIEWS
-- ============================================================================
DROP SEMANTIC VIEW IF EXISTS COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV;
DROP SEMANTIC VIEW IF EXISTS COLM_DB.STRUCTURED.AIM_STOCK_PRICES_SV;
DROP SEMANTIC VIEW IF EXISTS COLM_DB.STRUCTURED.SP500;
DROP SEMANTIC VIEW IF EXISTS COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS_SV;
DROP SEMANTIC VIEW IF EXISTS COLM_DB.INTERACTIVE_ANALYTICS.STOCK_PRICE_TIMESERIES_IT_SV;

-- ============================================================================
-- STEP 5: DROP TABLES
-- ============================================================================
DROP TABLE IF EXISTS COLM_DB.STRUCTURED.SP500_COMPANIES;
DROP TABLE IF EXISTS COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES;
DROP TABLE IF EXISTS COLM_DB.STRUCTURED.AIM_STOCK_PRICES;
DROP TABLE IF EXISTS COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS;
DROP TABLE IF EXISTS COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS;
DROP TABLE IF EXISTS COLM_DB.UNSTRUCTURED.DOCS_CHUNKS_TABLE;
DROP DYNAMIC TABLE IF EXISTS COLM_DB.INTERACTIVE_ANALYTICS.STOCK_PRICE_TIMESERIES_IT;

-- ============================================================================
-- STEP 5.1: DROP YAHOO FINANCE OBJECTS
-- ============================================================================
DROP FUNCTION IF EXISTS COLM_DB.STRUCTURED.GET_STOCK_PRICE(VARCHAR);
DROP EXTERNAL ACCESS INTEGRATION IF EXISTS YAHOO_FINANCE_INTEGRATION;
DROP NETWORK RULE IF EXISTS COLM_DB.STRUCTURED.YAHOO_FINANCE_RULE;

-- ============================================================================
-- STEP 5.2: DROP TASKS
-- ============================================================================
ALTER TASK IF EXISTS COLM_DB.STRUCTURED.DAILY_DATA_REFRESH SUSPEND;
DROP TASK IF EXISTS COLM_DB.STRUCTURED.DAILY_DATA_REFRESH;

-- ============================================================================
-- STEP 6: DROP SCHEMAS
-- ============================================================================
DROP SCHEMA IF EXISTS COLM_DB.STRUCTURED;
DROP SCHEMA IF EXISTS COLM_DB.SEMI_STRUCTURED;
DROP SCHEMA IF EXISTS COLM_DB.UNSTRUCTURED;
DROP SCHEMA IF EXISTS COLM_DB.INTERACTIVE_ANALYTICS;

-- ============================================================================
-- STEP 7: DROP DATABASE
-- ============================================================================
DROP DATABASE IF EXISTS COLM_DB;

-- ============================================================================
-- STEP 8: (OPTIONAL) DROP SNOWFLAKE_INTELLIGENCE SCHEMA
-- Uncomment if you want to remove the entire SNOWFLAKE_INTELLIGENCE database
-- ============================================================================
-- DROP SCHEMA IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS;
-- DROP DATABASE IF EXISTS SNOWFLAKE_INTELLIGENCE;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SHOW DATABASES LIKE 'COLM_DB';
SHOW AGENTS IN ACCOUNT;

-- ============================================================================
-- UNINSTALL COMPLETE!
-- All Holly components have been removed.
-- ============================================================================
