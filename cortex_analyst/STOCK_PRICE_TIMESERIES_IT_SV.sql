create or replace semantic view STOCK_PRICE_TIMESERIES_IT_SV
	tables (
		COLM_DB.STRUCTURED.STOCK_PRICE_TIMESERIES_IT
	)
	facts (
		STOCK_PRICE_TIMESERIES_IT.VALUE as VALUE comment='Value reported for the variable.'
	)
	dimensions (
		STOCK_PRICE_TIMESERIES_IT.ASSET_CLASS as ASSET_CLASS comment='Type of security.',
		STOCK_PRICE_TIMESERIES_IT.PRIMARY_EXCHANGE_CODE as PRIMARY_EXCHANGE_CODE comment='The exchange code for the primary trading venue of a security.',
		STOCK_PRICE_TIMESERIES_IT.PRIMARY_EXCHANGE_NAME as PRIMARY_EXCHANGE_NAME comment='The exchange name for the primary trading venue of a security.',
		STOCK_PRICE_TIMESERIES_IT.TICKER as TICKER comment='Alphanumeric code that represents a specific publicly traded security on the NASDAQ exchange.',
		STOCK_PRICE_TIMESERIES_IT.VARIABLE as VARIABLE comment='Unique identifier for a variable.',
		STOCK_PRICE_TIMESERIES_IT.VARIABLE_NAME as VARIABLE_NAME comment='Human-readable unique name for the variable.',
		STOCK_PRICE_TIMESERIES_IT.DATE as DATE comment='Date associated with the value.',
		STOCK_PRICE_TIMESERIES_IT.EVENT_TIMESTAMP_UTC as EVENT_TIMESTAMP_UTC comment='Timestamp when the event occurred in UTC.'
	)
	comment='Interactive Table for low-latency stock price queries'
	with extension (CA='{
		"tables":[{
			"name":"STOCK_PRICE_TIMESERIES_IT",
			"dimensions":[
				{"name":"ASSET_CLASS","sample_values":["Common Shares","Closed-End Funds","Equity"]},
				{"name":"PRIMARY_EXCHANGE_CODE","sample_values":["NYS","PSE","NAS"]},
				{"name":"PRIMARY_EXCHANGE_NAME","sample_values":["NEW YORK STOCK EXCHANGE","NASDAQ CAPITAL MARKET","NYSE ARCA"]},
				{"name":"TICKER","sample_values":["USB","CWT","MIT"]},
				{"name":"VARIABLE","sample_values":["all-day_high_adjusted","pre-market_open","post-market_close"]},
				{"name":"VARIABLE_NAME","sample_values":["Nasdaq Volume","All-Day High","Post-Market Close"]}
			],
			"facts":[
				{"name":"VALUE","sample_values":["50.8","27.21","28.99"]}
			],
			"filters":[
				{"name":"major_tech_stocks","description":"Filters for major technology stocks including Amazon (AMZN), Microsoft (MSFT), and Snowflake (SNOW). Use when questions ask about ''tech stocks'', ''major technology companies'', ''FAANG stocks'', ''cloud companies'', ''Amazon Microsoft Snowflake'', or specific analysis of these three securities. Helps analyze performance and trends among leading technology sector stocks.","expr":"ticker IN (''AMZN'', ''MSFT'', ''SNOW'')"}
			],
			"time_dimensions":[
				{"name":"DATE","sample_values":["2022-10-12","2023-04-25","2019-07-17"]},
				{"name":"EVENT_TIMESTAMP_UTC","sample_values":["2024-07-16T13:30:00.000+0000","2021-08-06T20:00:00.000+0000","2022-10-24T13:30:00.000+0000"]}
			]
		}]
	}');
