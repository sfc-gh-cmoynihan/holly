/*
================================================================================
  HOLLY - Financial Research Assistant
  Uninstall Script
  
  Author: Colm Moynihan
  Version: 1.0
  Date: 26th February 2026
  
  WARNING: This script will permanently delete all Holly components!
  
  WHAT THIS SCRIPT REMOVES:
  -------------------------
  - Agent: SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY
  - Cortex Search Services: EDGAR_FILINGS, PUBLIC_TRANSCRIPTS_SEARCH
  - Semantic Views: STOCK_PRICE_TIMESERIES_SV, SP500
  - Tables: SP500_COMPANIES, STOCK_PRICE_TIMESERIES, EDGAR_FILINGS, 
            PUBLIC_TRANSCRIPTS, DOCS_CHUNKS_TABLE
  - Functions: PDF_TEXT_CHUNKER, ASK_QUESTIONS_RAG, GET_STOCK_PRICE
  - Integrations: YAHOO_FINANCE_INTEGRATION, YAHOO_FINANCE_RULE
  - Task: DAILY_DATA_REFRESH
  - Stages: REPORTS
  - Sequences: PUBLIC_TRANSCRIPTS_SEQ
  - Database: COLM_DB
  - Schema: SNOWFLAKE_INTELLIGENCE.AGENTS (optional)
================================================================================
*/

-- ============================================================================
-- STEP 1: SET UP CONTEXT
-- ============================================================================
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE ADHOC_WH;

-- ============================================================================
-- STEP 2: SUSPEND AND DROP TASK
-- ============================================================================
ALTER TASK IF EXISTS COLM_DB.STRUCTURED.DAILY_DATA_REFRESH SUSPEND;
DROP TASK IF EXISTS COLM_DB.STRUCTURED.DAILY_DATA_REFRESH;

-- ============================================================================
-- STEP 3: DROP CORTEX AGENT
-- ============================================================================
DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY;

-- ============================================================================
-- STEP 4: DROP CORTEX SEARCH SERVICES
-- ============================================================================
DROP CORTEX SEARCH SERVICE IF EXISTS COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS;
DROP CORTEX SEARCH SERVICE IF EXISTS COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEARCH;

-- ============================================================================
-- STEP 5: DROP SEMANTIC VIEWS
-- ============================================================================
DROP SEMANTIC VIEW IF EXISTS COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_SV;
DROP SEMANTIC VIEW IF EXISTS COLM_DB.STRUCTURED.SP500;

-- ============================================================================
-- STEP 6: DROP FUNCTIONS
-- ============================================================================
DROP FUNCTION IF EXISTS COLM_DB.UNSTRUCTURED.PDF_TEXT_CHUNKER(VARCHAR);
DROP FUNCTION IF EXISTS COLM_DB.UNSTRUCTURED.ASK_QUESTIONS_RAG(VARCHAR);
DROP FUNCTION IF EXISTS COLM_DB.STRUCTURED.GET_STOCK_PRICE(VARCHAR);
DROP FUNCTION IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.GET_STOCK_PRICE(VARCHAR);

-- ============================================================================
-- STEP 7: DROP EXTERNAL ACCESS INTEGRATION (Yahoo Finance)
-- ============================================================================
DROP NETWORK RULE IF EXISTS COLM_DB.STRUCTURED.YAHOO_FINANCE_RULE;
DROP NETWORK RULE IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.YAHOO_FINANCE_RULE;
DROP EXTERNAL ACCESS INTEGRATION IF EXISTS YAHOO_FINANCE_INTEGRATION;

-- ============================================================================
-- STEP 8: DROP TABLES
-- ============================================================================
DROP TABLE IF EXISTS COLM_DB.STRUCTURED.SP500_COMPANIES;
DROP TABLE IF EXISTS COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES;
DROP TABLE IF EXISTS COLM_DB.SEMI_STRUCTURED.EDGAR_FILINGS;
DROP TABLE IF EXISTS COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS;
DROP TABLE IF EXISTS COLM_DB.UNSTRUCTURED.DOCS_CHUNKS_TABLE;

-- ============================================================================
-- STEP 9: DROP SEQUENCES
-- ============================================================================
DROP SEQUENCE IF EXISTS COLM_DB.UNSTRUCTURED.PUBLIC_TRANSCRIPTS_SEQ;

-- ============================================================================
-- STEP 10: DROP STAGES
-- ============================================================================
DROP STAGE IF EXISTS COLM_DB.UNSTRUCTURED.REPORTS;

-- ============================================================================
-- STEP 11: DROP SCHEMAS
-- ============================================================================
DROP SCHEMA IF EXISTS COLM_DB.STRUCTURED;
DROP SCHEMA IF EXISTS COLM_DB.SEMI_STRUCTURED;
DROP SCHEMA IF EXISTS COLM_DB.UNSTRUCTURED;

-- ============================================================================
-- STEP 12: DROP DATABASE
-- ============================================================================
DROP DATABASE IF EXISTS COLM_DB;

-- ============================================================================
-- STEP 13: (OPTIONAL) DROP SNOWFLAKE_INTELLIGENCE SCHEMA
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
