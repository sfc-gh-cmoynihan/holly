CREATE OR REPLACE SEMANTIC VIEW COLM_DB.STRUCTURED.SP500
    TABLES (COLM_DB.STRUCTURED.SP500_COMPANIES)
    DIMENSIONS (
        SP500_COMPANIES.SYMBOL AS SYMBOL
          comment='Stock ticker symbol e.g. AAPL, MSFT, NVDA, AMZN, GOOGL.',
        SP500_COMPANIES.COMPANY_NAME AS COMPANY_NAME
          comment='Full company name e.g. Apple Inc., Microsoft.',
        SP500_COMPANIES.SECTOR AS SECTOR
          comment='GICS sector e.g. Information Technology, Health Care, Financials.',
        SP500_COMPANIES.INDUSTRY AS INDUSTRY
          comment='GICS industry e.g. Semiconductors, Systems Software.',
        SP500_COMPANIES.HEADQUARTERS AS HEADQUARTERS
          comment='Company headquarters location e.g. Cupertino, California.',
        SP500_COMPANIES.DATE_ADDED AS DATE_ADDED
          comment='Date the company was added to the S&P 500 index.',
        SP500_COMPANIES.CIK AS CIK
          comment='SEC Central Index Key identifier.',
        SP500_COMPANIES.FOUNDED AS FOUNDED
          comment='Year the company was founded.'
    )
    COMMENT = 'S&P 500 index constituents with company details. Use SYMBOL for ticker lookups.';
