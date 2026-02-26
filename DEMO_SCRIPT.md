# Holly Demo Script

## Introduction

Good morning and afternoon. What I'm going to show you here is an AI for BI agent. This agent is called Holly, and it's really easy to build - it was fast, easy, and also very secure.

We sourced all the data from the Marketplace. We have our Snowflake Public Data, which has EDGAR filings, stock price series, and some public company transcripts. We have the S&P 500 index, Third Bridge private transcripts, and an external function to Yahoo Finance to find out the latest share prices.

We've loaded them into our Snowflake data lake.

## Agent Overview

This is the agent here - this is Holly, it's under Agents on Snowsight. What it has here is a bunch of tools. We've enabled web search, and we've connected two structured data sources: one is the S&P 500 list, and the other is the stock price time series data.

## Demo Questions

### Question 1: Plot Share Prices

Let's ask it a question. The first question we asked was:

> "Plot the share price of Amazon, Microsoft, Snowflake and NVIDIA for the last year"

And it has plotted that. You'll see the output - Microsoft kind of goes up and down, it's tracking pretty low. NVIDIA started the year at $139, it's now tracing up towards $186, which looks quite an interesting buy.

### Question 2: S&P 500 Check

Then we can ask another question of the S&P:

> "Which of these four stocks are in the S&P 500: MSFT, Snowflake, NVIDIA, and Amazon?"

It gets its name from Red Dwarf, if you watch that show.

So there's four stocks, and it's gonna automatically generate the SQL from this natural language, this English language here, and it's gonna give me the answer straight away. Of the four stocks you mentioned, 3 are in the S&P - that's Microsoft, Amazon, NVIDIA.

Now, I'm restricted to buy only stuff that's within the S&P 500, so I'm stuck to these 3.

### Question 3: Latest Transcripts

> "Give me the latest public and private transcripts of NVIDIA"

The stock price data comes from a semantic view, which allows us to search for anything within this. Same with the S&P 500.

For the transcripts, we have two tables - the Third Bridge transcripts which were shared through our data marketplace, and the public transcripts which also came from our marketplace as well.

Here are the latest NVIDIA transcripts. The last public transcript was from August 27th - total revenue for the quarter was $46 billion, 56% growth, really good numbers from that quarter.

And this is the private transcript - there was an interview with a business development manager in Taiwan, and we can get that interview there as well.

### Question 4: Live Share Price

> "What is the latest share price of NVIDIA?"

It's going to go off and call an external function that will find that particular price. It's $191.

### Question 5: Annual Report Summary

> "Please summarize the latest annual report of NVIDIA"

For the annual reports, we have all the unstructured stuff. We've loaded a bunch of annual reports in PDF - Microsoft, Snowflake, NVIDIA, Amazon. We've also vectorized it into a Chunks Table with vectors, and that allows us to then ask questions.

So we've taken that PDF, gone into the chunks table, and used the latest LLM to give us that summary. 114% year-over-year growth, which is really good. $130 billion revenue. Large-scale production of the Blackwell architecture, launched the GeForce RTX50 series GPU - some really interesting things.

### Question 6: Company Comparison

> "Compare Microsoft's annual growth versus NVIDIA using the latest annual reports"

You can do cross-comparison of those things as well, which is pretty cool. You'll see here the revenue in a table format - Microsoft's larger revenue, but NVIDIA's got $130 billion with 114% growth, so it looks really, really good.

### Question 7: Latest 10K

> "Give me the latest 10K for NVIDIA"

We have that data as well. You can see the different things and the comprehensive values.

### Question 8: Investment Recommendation

> "Would you recommend buying NVIDIA at $191?"

It obviously doesn't tell us "I can give you investment advice", which is correct. It's giving you what the price is today, the summary, the historical trends. I can see the different insights I got from the various tools.

## Trade Execution Demo

So I think I'm going to go in and do a buy order here. I'm going to select NVIDIA. This is my securities mask for my operational systems.

I'm gonna buy 10,000 units, Good for Day order. The price is $192, so I'll do a limit order at $195.50 to hopefully get a bit of a discount if it trades on Monday.

Preview the order - buying 10,000 at $195.50. We have plenty of cash reserves, and we're placing the order in our system.

This creates a FIX ML message, fires that off to our OMS, and we'll get a confirmation order back. There's your confirmation order, which is pretty cool.

Then we can look at the settlement details, do a refresh to make sure the order's come through, and see the different orders and what has settled and what hasn't. As we move from T+2 to T+1 depending on where our trade execution is, we can at least see if we're ahead and not getting any failed settlements.

## Summary

A very interesting demo, as you can see:

- We saw our public data
- We checked whether the stock was in the S&P 500
- We did a live share price on Yahoo to see the latest share price of NVIDIA
- We looked at private transcripts from Third Bridge
- We looked at the Microsoft and NVIDIA annual reports and compared them in terms of growth
- We ran this through Snowflake Intelligence
- We showed you how Holly works and how it plugs into all of these tools

This is how easy it is. There's a quick start on our Quick Start series at **quickstart.snowflake.com**.

Thank you very much.
