# How Datometry Can Help With Your Teradata Migration

## What is Datometry?

[Datometry](https://datometry.com/datometry-and-snowflake/) is a database virtualisation company [acquired by Snowflake in November 2025](https://www.snowflake.com/en/blog/accelerate-data-migration-datometry-technology/). Its core technology, **Hyper-Q**, enables applications originally written for Teradata to run natively on Snowflake **without rewriting SQL or application code**.

Datometry's technology is being integrated into [SnowConvert AI](https://www.snowflake.com/en/migrate-to-the-cloud/snowconvert/), Snowflake's automated code conversion tool, to provide a comprehensive migration solution.

## The Problem With Traditional Teradata Migrations

Teradata migrations are notoriously complex:

- **SQL dialect differences** -- Teradata uses BTEQ, macros, QUALIFY, session modes (ANSI vs TERA), and proprietary data types that don't map directly to Snowflake
- **Application dependencies** -- Thousands of reports, ETL jobs, and BI dashboards embed Teradata-specific SQL that must be rewritten
- **Dynamic SQL** -- Many applications generate SQL at runtime, meaning static code conversion tools miss large portions of the workload
- **Risk and timeline** -- Traditional migrations regularly exceed budgets and timelines, often by years

## How Datometry Solves This

### Real-Time SQL Virtualisation (Hyper-Q)

Datometry's **Hyper-Q** sits between your existing applications and Snowflake as a middleware layer that:

1. **Intercepts** Teradata SQL from your existing applications, BI tools, and ETL pipelines
2. **Translates** the SQL in real-time to Snowflake-compatible SQL, handling dialect differences automatically
3. **Returns** results to the application in the format it expects

This means your applications continue to "think" they're talking to Teradata, while the actual processing happens on Snowflake. Business users often don't even notice the cutover.

### What Hyper-Q Handles

- Teradata SQL dialect (including TERA and ANSI session modes)
- Complex features like recursion and Global Temporary Tables
- Dynamic/runtime-generated SQL that static tools can't convert
- ETL loaders and utilities (BTEQ, FastLoad, MultiLoad, TPT)
- Teradata-specific data types and functions
- Schema and DDL translation

### Key Benefits

| Metric | Traditional Migration | With Datometry |
|--------|----------------------|----------------|
| Migration speed | 12-24+ months | **Up to 4x faster** |
| Cost | Baseline | **Up to 90% reduction** |
| Application code changes | Extensive rewriting | **Minimal to none** |
| Business disruption | Significant | **Near-zero** |
| Risk of failure | High | **Significantly reduced** |

## Snowflake's Complete Migration Toolkit

Datometry is one part of Snowflake's migration ecosystem:

### 1. SnowConvert AI (Free)
Automated code conversion for DDL, DML, stored procedures, and scripts from Teradata to Snowflake SQL.
- [SnowConvert for Teradata](https://www.snowflake.com/en/migrate-to-the-cloud/snowconvert/)
- Handles: table definitions, views, stored procedures, macros, BTEQ scripts
- Supports: data type mapping, schema reorganisation, syntax translation

### 2. Datometry (Integrated into SnowConvert)
Real-time SQL virtualisation for applications that can't be easily rewritten.
- [Datometry + Snowflake Announcement](https://www.snowflake.com/en/blog/accelerate-data-migration-datometry-technology/)
- Handles: dynamic SQL, runtime-generated queries, BI tool queries, ETL workloads

### 3. Snowpark Migration Accelerator
For migrating Apache Spark workloads to Snowflake.

### 4. Teradata Migration Guide (Snowflake Docs)
Comprehensive 9-phase migration framework covering planning through optimisation.
- [Teradata to Snowflake Migration Guide](https://docs.snowflake.com/en/migrations/guides/teradata)

## Recommended Migration Approach

### Phase 1: Assess
- Inventory your Teradata environment (databases, schemas, ETL jobs, reports)
- Identify workload complexity and application dependencies
- Run [SnowConvert AI](https://www.snowflake.com/en/migrate-to-the-cloud/snowconvert/) assessment on extracted code

### Phase 2: Convert Database Code
- Use **SnowConvert AI** to automatically convert DDL, DML, stored procedures, and scripts
- Review and resolve any conversion warnings (EWIs)
- Address Teradata-specific constructs: macros, QUALIFY, join indexes, COLLECT STATISTICS

### Phase 3: Migrate Applications with Datometry
- Deploy Datometry's virtualisation layer for applications with complex or dynamic SQL
- Applications run unchanged against Snowflake through the translation layer
- Validate results match Teradata outputs

### Phase 4: Migrate Data
- Perform initial bulk historical data transfer
- Set up incremental data migration (CDC) for ongoing synchronisation
- Redirect data pipelines from Teradata to Snowflake (COPY, Snowpipe)

### Phase 5: Validate and Cutover
- Run parallel testing (Teradata and Snowflake side by side)
- Business user acceptance testing
- Cutover applications, decommission Teradata

## Key Teradata-to-Snowflake Differences

| Teradata Concept | Snowflake Equivalent |
|-----------------|---------------------|
| Primary Index | Micro-partition pruning + clustering keys |
| Fallback tables | Built-in replication (no action needed) |
| COLLECT STATISTICS | Automatic (no action needed) |
| Macros | Stored procedures or views |
| QUALIFY | Subquery or outer SELECT |
| BTEQ scripts | SnowSQL or Snowpark Python |
| Join Indexes | Materialised views or clustering keys |
| Session modes (ANSI/TERA) | Handled by Datometry virtualisation |
| FastLoad/MultiLoad | COPY INTO / Snowpipe |

## Links and Resources

- [Snowflake + Datometry Announcement](https://www.snowflake.com/en/blog/accelerate-data-migration-datometry-technology/)
- [Datometry Joins Snowflake](https://datometry.com/datometry-and-snowflake/)
- [SnowConvert AI for Teradata](https://www.snowflake.com/en/migrate-to-the-cloud/snowconvert/)
- [Teradata to Snowflake Migration Guide](https://docs.snowflake.com/en/migrations/guides/teradata)
- [SnowConvert Code Extraction Scripts](https://docs.snowconvert.com/sc/general/getting-started/code-extraction/teradata)
- [Snowflake Migration Support](mailto:snowconvert-support@snowflake.com)
