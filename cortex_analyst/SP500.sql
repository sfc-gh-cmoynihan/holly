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
