/*
================================================================================
  HOLLY - Financial Research Assistant
  Uninstall Script
  
  Author: Colm Moynihan
  Version: 3.2
  Date: 2nd May 2026
  
  WARNING: This script will permanently delete all Holly components!
  
  WHAT THIS SCRIPT REMOVES:
  -------------------------
  - Agent: SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY
  - MCP Server: SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY_MCP (if exists)
  - Cortex Search Services: EDGAR_FILINGS_SEARCH, PUBLIC_TRANSCRIPTS_SEARCH, COMPANY_DOCS_SEARCH
  - Semantic Views: STOCK_PRICE_TIMESERIES_SV, STOCK_PRICE_TIMESERIES_IW_SV, AIM_STOCK_PRICES_SV, SP500, EDGAR_FILINGS_SV
  - Tables: SP500_COMPANIES, STOCK_PRICE_TIMESERIES, STOCK_PRICE_TIMESERIES_SP500_IT, STOCK_PRICE_TIMESERIES_IT, AIM_STOCK_PRICES, EDGAR_FILINGS, PUBLIC_TRANSCRIPTS, DOCS_CHUNKS_TABLE
  - Warehouses: HOLLY_IW, HOLLY_WH
  - Functions: PDF_TEXT_CHUNKER, GET_STOCK_PRICE
  - Stages: COMPANY_ANNOUNCEMENTS
  - Tasks: DAILY_DATA_REFRESH, REFRESH_STOCK_PRICE_IT
  - Yahoo Finance: Network rule, external access integration
  - MCP: HOLLY_MCP_ROLE, HOLLY_MCP_OAUTH
  - Database: COLM_DB
  - Schema: SNOWFLAKE_INTELLIGENCE.AGENTS (optional)
================================================================================
*/

-- ============================================================================
-- STEP 1: SET UP CONTEXT
-- ============================================================================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================================
-- STEP 2: DROP CORTEX AGENT AND MCP SERVER
-- ============================================================================
DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY;
DROP MCP SERVER IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY_MCP;

-- ============================================================================
-- STEP 3: DROP CORTEX SEARCH SERVICES
-- ============================================================================
DROP CORTEX SEARCH SERVICE IF EXISTS COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS_SEARCH;
DROP CORTEX SEARCH SERVICE IF EXISTS COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEARCH;
DROP CORTEX SEARCH SERVICE IF EXISTS COLM_DB.UNSTRUCTURED.COMPANY_DOCS_SEARCH;

-- ============================================================================
-- STEP 4: DROP SEMANTIC VIEWS
-- ============================================================================
DROP SEMANTIC VIEW IF EXISTS COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV;
DROP SEMANTIC VIEW IF EXISTS COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_IW_SV;
DROP SEMANTIC VIEW IF EXISTS COLM_DB.STRUCTURED.AIM_STOCK_PRICES_SV;
DROP SEMANTIC VIEW IF EXISTS COLM_DB.STRUCTURED.SP500;
DROP SEMANTIC VIEW IF EXISTS COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS_SV;

-- ============================================================================
-- STEP 5: DROP TASKS
-- ============================================================================
ALTER TASK IF EXISTS COLM_DB.STRUCTURED.DAILY_DATA_REFRESH SUSPEND;
DROP TASK IF EXISTS COLM_DB.STRUCTURED.DAILY_DATA_REFRESH;
ALTER TASK IF EXISTS COLM_DB.STRUCTURED.REFRESH_STOCK_PRICE_IT SUSPEND;
DROP TASK IF EXISTS COLM_DB.STRUCTURED.REFRESH_STOCK_PRICE_IT;
ALTER TASK IF EXISTS COLM_DB.STRUCTURED.SUSPEND_HOLLY_IW SUSPEND;
DROP TASK IF EXISTS COLM_DB.STRUCTURED.SUSPEND_HOLLY_IW;

-- ============================================================================
-- STEP 6: DROP FUNCTIONS AND STAGES
-- ============================================================================
DROP FUNCTION IF EXISTS COLM_DB.UNSTRUCTURED.PDF_TEXT_CHUNKER(VARCHAR);
DROP FUNCTION IF EXISTS COLM_DB.STRUCTURED.GET_STOCK_PRICE(VARCHAR);
DROP STAGE IF EXISTS COLM_DB.UNSTRUCTURED.COMPANY_ANNOUNCEMENTS;

-- ============================================================================
-- STEP 7: DROP TABLES
-- ============================================================================
DROP TABLE IF EXISTS COLM_DB.STRUCTURED.SP500_COMPANIES;
DROP TABLE IF EXISTS COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES;
DROP INTERACTIVE TABLE IF EXISTS COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SP500_IT;
DROP INTERACTIVE TABLE IF EXISTS COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_IT;
DROP TABLE IF EXISTS COLM_DB.STRUCTURED.AIM_STOCK_PRICES;
DROP TABLE IF EXISTS COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS;
DROP TABLE IF EXISTS COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS;
DROP TABLE IF EXISTS COLM_DB.UNSTRUCTURED.DOCS_CHUNKS_TABLE;

-- ============================================================================
-- STEP 8: DROP YAHOO FINANCE OBJECTS
-- ============================================================================
DROP EXTERNAL ACCESS INTEGRATION IF EXISTS YAHOO_FINANCE_INTEGRATION;
DROP NETWORK RULE IF EXISTS COLM_DB.STRUCTURED.YAHOO_FINANCE_RULE;

-- ============================================================================
-- STEP 9: DROP MCP ROLE AND OAUTH INTEGRATION
-- ============================================================================
DROP ROLE IF EXISTS HOLLY_MCP_ROLE;
DROP SECURITY INTEGRATION IF EXISTS HOLLY_MCP_OAUTH;

-- ============================================================================
-- STEP 10: DROP WAREHOUSES
-- ============================================================================
DROP WAREHOUSE IF EXISTS HOLLY_IW;
DROP WAREHOUSE IF EXISTS HOLLY_WH;

-- ============================================================================
-- STEP 11: DROP SCHEMAS AND DATABASE
-- ============================================================================
DROP SCHEMA IF EXISTS COLM_DB.STRUCTURED;
DROP SCHEMA IF EXISTS COLM_DB.SEMI_STRUCTURED;
DROP SCHEMA IF EXISTS COLM_DB.UNSTRUCTURED;
DROP DATABASE IF EXISTS COLM_DB;

-- ============================================================================
-- STEP 12: (OPTIONAL) DROP SNOWFLAKE_INTELLIGENCE SCHEMA
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
