/*
================================================================================
  HOLLY - Financial Research Assistant
  Uninstall Script
  
  Author: Colm Moynihan
  Version: 1.5
  Date: 2nd March 2026
  
  WARNING: This script will permanently delete all Holly components!
  
  WHAT THIS SCRIPT REMOVES:
  -------------------------
  - Agent: SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY
  - Cortex Search Services: EDGAR_FILINGS, PUBLIC_TRANSCRIPTS_SEARCH
  - Semantic Views: STOCK_PRICE_TIMESERIES_SV, SP500
  - Tables: SP500_COMPANIES, STOCK_PRICE_TIMESERIES, EDGAR_FILINGS, PUBLIC_TRANSCRIPTS
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

-- ============================================================================
-- STEP 4: DROP SEMANTIC VIEWS
-- ============================================================================
DROP SEMANTIC VIEW IF EXISTS COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV;
DROP SEMANTIC VIEW IF EXISTS COLM_DB.STRUCTURED.SP500;

-- ============================================================================
-- STEP 5: DROP TABLES
-- ============================================================================
DROP TABLE IF EXISTS COLM_DB.STRUCTURED.SP500_COMPANIES;
DROP TABLE IF EXISTS COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES;
DROP TABLE IF EXISTS COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS;
DROP TABLE IF EXISTS COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS;

-- ============================================================================
-- STEP 6: DROP SCHEMAS
-- ============================================================================
DROP SCHEMA IF EXISTS COLM_DB.STRUCTURED;
DROP SCHEMA IF EXISTS COLM_DB.SEMI_STRUCTURED;
DROP SCHEMA IF EXISTS COLM_DB.UNSTRUCTURED;

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
