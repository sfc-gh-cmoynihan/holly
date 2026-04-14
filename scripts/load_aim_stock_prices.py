import os
import json
import urllib.request
import snowflake.connector
from datetime import datetime, timedelta
import time

TICKER = "TMO.L"
AIM_TICKER = "TMO"
COMPANY_NAME = "Time Out Group PLC"
EXCHANGE = "AIM"
CURRENCY = "GBX"

all_rows = []

end_ts = int(datetime(2026, 4, 15).timestamp())
start_ts = int(datetime(2016, 6, 1).timestamp())

chunk_days = 365
current_start = start_ts

print(f"Fetching daily historical data for {TICKER} in yearly chunks...")

while current_start < end_ts:
    current_end = min(current_start + chunk_days * 86400, end_ts)
    url = f"https://query1.finance.yahoo.com/v8/finance/chart/{TICKER}?period1={current_start}&period2={current_end}&interval=1d"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})

    start_dt = datetime.utcfromtimestamp(current_start).strftime("%Y-%m-%d")
    end_dt = datetime.utcfromtimestamp(current_end).strftime("%Y-%m-%d")
    
    try:
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
        
        result = data["chart"]["result"][0]
        if "timestamp" not in result:
            print(f"  {start_dt} to {end_dt}: no data")
            current_start = current_end
            time.sleep(0.5)
            continue
            
        timestamps = result["timestamp"]
        quote = result["indicators"]["quote"][0]
        
        opens = quote.get("open", [])
        highs = quote.get("high", [])
        lows = quote.get("low", [])
        closes = quote.get("close", [])
        volumes = quote.get("volume", [])
        
        chunk_count = 0
        for i in range(len(timestamps)):
            dt = datetime.utcfromtimestamp(timestamps[i]).strftime("%Y-%m-%d")
            c = closes[i] if i < len(closes) and closes[i] is not None else None
            if c is not None:
                o = opens[i] if i < len(opens) and opens[i] is not None else None
                h = highs[i] if i < len(highs) and highs[i] is not None else None
                l = lows[i] if i < len(lows) and lows[i] is not None else None
                v = volumes[i] if i < len(volumes) and volumes[i] is not None else 0
                all_rows.append((dt, AIM_TICKER, COMPANY_NAME, EXCHANGE, CURRENCY,
                                round(o, 2) if o else None, round(h, 2) if h else None,
                                round(l, 2) if l else None, round(c, 2), v))
                chunk_count += 1
        
        print(f"  {start_dt} to {end_dt}: {chunk_count} daily records")
    except Exception as e:
        print(f"  {start_dt} to {end_dt}: ERROR - {e}")
    
    current_start = current_end
    time.sleep(0.5)

seen = set()
unique_rows = []
for r in all_rows:
    if r[0] not in seen:
        seen.add(r[0])
        unique_rows.append(r)

unique_rows.sort(key=lambda x: x[0])
print(f"\nTotal unique daily records: {len(unique_rows)}")
if unique_rows:
    print(f"Date range: {unique_rows[0][0]} to {unique_rows[-1][0]}")

conn = snowflake.connector.connect(connection_name=os.getenv("SNOWFLAKE_CONNECTION_NAME") or "colms_uswest")
cur = conn.cursor()

cur.execute("USE WAREHOUSE COMPUTE_WH")
cur.execute("USE DATABASE COLM_DB")
cur.execute("USE SCHEMA STRUCTURED")

cur.execute("""
CREATE OR REPLACE TABLE COLM_DB.STRUCTURED.AIM_STOCK_PRICES (
    DATE DATE,
    TICKER VARCHAR(10),
    COMPANY_NAME VARCHAR(200),
    EXCHANGE VARCHAR(10),
    CURRENCY VARCHAR(5),
    OPEN_PRICE FLOAT,
    HIGH_PRICE FLOAT,
    LOW_PRICE FLOAT,
    CLOSE_PRICE FLOAT,
    VOLUME INTEGER
)
""")
print("Table COLM_DB.STRUCTURED.AIM_STOCK_PRICES created.")

batch_size = 500
for i in range(0, len(unique_rows), batch_size):
    batch = unique_rows[i:i + batch_size]
    placeholders = ", ".join(["(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"] * len(batch))
    flat = []
    for r in batch:
        flat.extend(r)
    cur.execute(
        f"INSERT INTO COLM_DB.STRUCTURED.AIM_STOCK_PRICES (DATE, TICKER, COMPANY_NAME, EXCHANGE, CURRENCY, OPEN_PRICE, HIGH_PRICE, LOW_PRICE, CLOSE_PRICE, VOLUME) VALUES {placeholders}",
        flat
    )

cur.execute("SELECT COUNT(*) FROM COLM_DB.STRUCTURED.AIM_STOCK_PRICES")
count = cur.fetchone()[0]
print(f"Loaded {count} rows into COLM_DB.STRUCTURED.AIM_STOCK_PRICES")

cur.execute("SELECT MIN(DATE), MAX(DATE) FROM COLM_DB.STRUCTURED.AIM_STOCK_PRICES")
min_date, max_date = cur.fetchone()
print(f"Date range: {min_date} to {max_date}")

cur.execute("SELECT * FROM COLM_DB.STRUCTURED.AIM_STOCK_PRICES ORDER BY DATE DESC LIMIT 10")
print("\nLatest 10 rows:")
for row in cur.fetchall():
    print(f"  {row[0]} | {row[1]} | Open={row[5]} | High={row[6]} | Low={row[7]} | Close={row[8]} | Vol={row[9]}")

cur.close()
conn.close()
print("\nDone!")
