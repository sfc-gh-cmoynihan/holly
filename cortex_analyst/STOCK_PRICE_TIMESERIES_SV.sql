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
