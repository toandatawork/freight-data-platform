# 001. No Object Storage Landing Zone

## Context

We needed to decide where raw data should land first: inside a separate cloud object store (like AWS S3) or ingested directly from PostgreSQL into Databricks Bronze.

## Decision

Do not use separate object storage. Ingest directly from PostgreSQL to Databricks Bronze and focus on in-warehouse transformations with dbt.

## Trade-offs

| Pros                                                             | Cons                                                                  |
| ---------------------------------------------------------------- | --------------------------------------------------------------------- |
| Fewer moving parts; simpler setup; deeper focus on dbt modeling. | No hands-on handling of raw S3 files (Parquet/JSON) before ingestion. |

## Consequences

If the system later integrates non-relational sources (APIs, streaming, raw files), an object storage landing zone must be added before Bronze.
