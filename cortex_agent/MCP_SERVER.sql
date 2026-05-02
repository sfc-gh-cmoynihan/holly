-- ============================================================
-- Holly MCP Server Setup
-- Exposes the Holly Cortex Agent via Snowflake-managed MCP
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_INTELLIGENCE;
USE SCHEMA AGENTS;

-- 1. Create MCP Server
CREATE OR REPLACE MCP SERVER HOLLY_MCP
  FROM SPECIFICATION $$
    tools:
      - name: "holly"
        type: "CORTEX_AGENT_RUN"
        identifier: "SNOWFLAKE_INTELLIGENCE.AGENTS.HOLLY"
        description: "Financial research agent for stock prices, SEC filings, transcripts, and Time Out Group documents"
        title: "Holly - FS Financial Agent"
  $$;

-- 2. Grant access
GRANT USAGE ON MCP SERVER HOLLY_MCP TO ROLE PUBLIC;

-- 3. Create dedicated MCP role (optional, for least-privilege)
CREATE ROLE IF NOT EXISTS HOLLY_MCP_ROLE;
GRANT USAGE ON MCP SERVER HOLLY_MCP TO ROLE HOLLY_MCP_ROLE;
GRANT ROLE HOLLY_MCP_ROLE TO USER ADMIN;

GRANT USAGE ON DATABASE SNOWFLAKE_INTELLIGENCE TO ROLE HOLLY_MCP_ROLE;
GRANT USAGE ON SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS TO ROLE HOLLY_MCP_ROLE;
GRANT USAGE ON DATABASE COLM_DB TO ROLE HOLLY_MCP_ROLE;
GRANT USAGE ON SCHEMA COLM_DB.UNSTRUCTURED TO ROLE HOLLY_MCP_ROLE;
GRANT USAGE ON SCHEMA COLM_DB.SEMI_STRUCTURED TO ROLE HOLLY_MCP_ROLE;
GRANT USAGE ON SCHEMA COLM_DB.STRUCTURED TO ROLE HOLLY_MCP_ROLE;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE HOLLY_MCP_ROLE;
GRANT USAGE ON WAREHOUSE SMALL_WH TO ROLE HOLLY_MCP_ROLE;
GRANT USAGE ON WAREHOUSE HOLLY_IW TO ROLE HOLLY_MCP_ROLE;
GRANT USAGE ON WAREHOUSE HOLLY_WH TO ROLE HOLLY_MCP_ROLE;

-- 4. OAuth security integration (for OAuth-based clients)
CREATE OR REPLACE SECURITY INTEGRATION HOLLY_MCP_OAUTH
  TYPE = OAUTH
  OAUTH_CLIENT = CUSTOM
  OAUTH_CLIENT_TYPE = 'CONFIDENTIAL'
  OAUTH_REDIRECT_URI = 'http://localhost:8001/callback'
  OAUTH_ALLOW_NON_TLS_REDIRECT_URI = TRUE
  OAUTH_ISSUE_REFRESH_TOKENS = TRUE
  OAUTH_REFRESH_TOKEN_VALIDITY = 7776000
  OAUTH_USE_SECONDARY_ROLES = 'IMPLICIT'
  ENABLED = TRUE;

-- Retrieve OAuth credentials (run interactively):
-- SELECT SYSTEM$SHOW_OAUTH_CLIENT_SECRETS('HOLLY_MCP_OAUTH');

-- ============================================================
-- MCP Server URL (use hyphens, not underscores):
-- https://sfseeurope-colm-uswest.snowflakecomputing.com/api/v2/databases/SNOWFLAKE_INTELLIGENCE/schemas/AGENTS/mcp-servers/HOLLY_MCP
--
-- Test with curl:
-- curl -X POST "<URL above>" \
--   -H 'Content-Type: application/json' \
--   -H 'Authorization: Bearer <PAT>' \
--   -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'
--
-- Client config (Cursor .cursor/mcp.json or Claude Desktop):
-- {
--   "mcpServers": {
--     "holly": {
--       "url": "<URL above>",
--       "headers": { "Authorization": "Bearer <PAT>" }
--     }
--   }
-- }
-- ============================================================
