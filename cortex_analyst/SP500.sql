create or replace semantic view SP500
	tables (
		COLM_DB.STRUCTURED.SP500_COMPANIES comment='The table contains records of publicly traded companies that are constituents of the S&P 500 index. Each record represents a single company and includes identifying information, sector and industry classifications, financial metrics and performance indicators, geographic location details, and workforce size.'
	)
	facts (
		SP500_COMPANIES.CURRENTPRICE as CURRENTPRICE comment='The current trading price of the company''s stock in US dollars.',
		SP500_COMPANIES.REVENUEGROWTH as REVENUEGROWTH comment='The percentage growth in revenue compared to a previous period.'
	)
	dimensions (
		SP500_COMPANIES.CITY as CITY comment='The city where the S&P 500 company is headquartered or located.',
		SP500_COMPANIES.COUNTRY as COUNTRY comment='The country where the company is headquartered or incorporated.',
		SP500_COMPANIES.EBITDA as EBITDA comment='Earnings before interest, taxes, depreciation, and amortization for the company.',
		SP500_COMPANIES.EXCHANGE as EXCHANGE comment='The stock exchange where the company is listed.',
		SP500_COMPANIES.FULLTIMEEMPLOYEES as FULLTIMEEMPLOYEES comment='The number of full-time employees at the company.',
		SP500_COMPANIES.INDUSTRY as INDUSTRY comment='The industry classification or sector in which the company operates.',
		SP500_COMPANIES.LONGBUSINESSSUMMARY as LONGBUSINESSSUMMARY comment='A brief description of the company''s business operations and headquarters location.',
		SP500_COMPANIES.LONGNAME as LONGNAME comment='The full legal name of the company.',
		SP500_COMPANIES.MARKETCAP as MARKETCAP comment='Market capitalization of the company measured in dollars.',
		SP500_COMPANIES.SECTOR as SECTOR comment='The economic sector classification of the company.',
		SP500_COMPANIES.SHORTNAME as SHORTNAME comment='The short name or common business name of the S&P 500 company.',
		SP500_COMPANIES.STATE as STATE comment='The state where the S&P 500 company is headquartered or located.',
		SP500_COMPANIES.SYMBOL as SYMBOL comment='Stock ticker symbols for companies in the S&P 500 index.',
		SP500_COMPANIES.WEIGHT as WEIGHT
	)
	with extension (CA='{
		"tables":[{
			"name":"SP500_COMPANIES",
			"dimensions":[
				{"name":"CITY","sample_values":["Findlay","Thousand Oaks","Philadelphia"]},
				{"name":"COUNTRY","sample_values":["United Kingdom","Ireland","Switzerland"]},
				{"name":"EBITDA","sample_values":["123469996032","2505100032","4209900032"]},
				{"name":"EXCHANGE","sample_values":["BTS","NGM","NYQ"]},
				{"name":"FULLTIMEEMPLOYEES","sample_values":["228000","18000","6118"]},
				{"name":"INDUSTRY","sample_values":["Computer Hardware","Banks - Regional","Medical Distribution"]},
				{"name":"LONGBUSINESSSUMMARY","sample_values":["Apple Inc. designs, manufactures...","Caterpillar Inc. manufactures...","Arthur J. Gallagher & Co..."]},
				{"name":"LONGNAME","sample_values":["Baker Hughes Company","O''Reilly Automotive, Inc.","Prologis, Inc."]},
				{"name":"MARKETCAP","sample_values":["2365033807872","3298803056640","38703910912"]},
				{"name":"SECTOR","sample_values":["Communication Services","Technology","Consumer Cyclical"]},
				{"name":"SHORTNAME","sample_values":["O''Reilly Automotive, Inc.","lululemon athletica inc.","Baker Hughes Company"]},
				{"name":"STATE","sample_values":["WA","TX","ID"]},
				{"name":"SYMBOL","sample_values":["DUK","TSLA","GS"]},
				{"name":"WEIGHT","sample_values":["0.01203480365497622","0.0017944556478219147","0.002155362554349837"]}
			],
			"facts":[
				{"name":"CURRENTPRICE","sample_values":["377.11","76.97","436.60"]},
				{"name":"REVENUEGROWTH","sample_values":["0.187","0.053","-0.152"]}
			]
		}],
		"verified_queries":[
			{"name":"What is the average market capitalization for companies in the Technology sector?","sql":"SELECT AVG(marketcap) AS avg_market_cap FROM sp500_companies WHERE sector = ''Technology''","question":"What is the average market capitalization for companies in the Technology sector?","verified_at":1771516869,"verified_by":"Colm Moynihan","use_as_onboarding_question":false},
			{"name":"Which companies have the highest revenue growth and what are their current stock prices?","sql":"SELECT shortname, revenuegrowth, currentprice FROM sp500_companies WHERE NOT revenuegrowth IS NULL ORDER BY revenuegrowth DESC NULLS LAST","question":"Which companies have the highest revenue growth and what are their current stock prices?","verified_at":1771516887,"verified_by":"Colm Moynihan","use_as_onboarding_question":false}
		]
	}');
