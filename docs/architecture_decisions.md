# Architecture Decision Records (ADRs)

This document consolidates key architectural decisions, rationale, trade-offs, and consequences established during the engineering of the Freight Data Platform.

---

## ADR 001: Direct Bronze Ingestion (No Object Storage Landing Zone)

* **Context:** We needed to choose where raw operational data should land first: inside a separate cloud object store (e.g., AWS S3 bucket) or directly ingested from source PostgreSQL into Databricks Delta Bronze.
* **Decision:** Ingest directly from PostgreSQL to Databricks Delta Bronze tables using PySpark JDBC. Focus computational engineering on in-warehouse dbt transformations.
* **Trade-offs:**
  * *Pros:* Fewer infrastructure moving parts, simplified orchestration, deeper focus on Medallion modeling.
  * *Cons:* No raw Parquet/JSON file handling prior to lakehouse ingestion.
* **Consequences:** If the platform integrates external unstructured sources (APIs, streaming logs), an object storage landing zone can be introduced upstream of Bronze without altering downstream dbt models.

---

## ADR 002: In-Warehouse Profiling via dbt Incremental Models

* **Context:** Data profiling is traditionally conducted in standalone Python/Jupyter notebooks, which cannot be automated, version-controlled, or tracked in CI/CD pipelines.
* **Decision:** Implement profiling directly inside dbt as metadata-driven incremental models targeting the Bronze layer (`profile_bronze_columns`, `profile_drift`).
* **Trade-offs:**
  * *Pros:* 100% reproducible via `dbt build --select tag:profiling`, natively visible in the data lineage graph, and continuously tracks statistical drift across pipeline runs.
  * *Cons:* Can only profile data already ingested into the lakehouse (no out-of-warehouse CSV profiling).
* **Consequences:** Every source table must land in Bronze before profiling kicks in.

---

## ADR 003: Quarantine Pattern Over Silent Filtering

* **Context:** The source freight dataset contains operational data defects (negative transit times, flag mismatches, orphan customer foreign keys). We evaluated whether to silently filter them out or retain them.
* **Decision:** Route defect records to dedicated audit tables (`qtn_time_anomaly`, `qtn_flag_mismatch`, `qtn_orphan_fk`) with error codes and detection timestamps instead of discarding them via `WHERE` clauses.
* **Trade-offs:**
  * *Pros:* Preserves full data integrity and actionable audit trails to feed back to upstream source operational teams.
  * *Cons:* Requires additional storage and models; downstream queries must explicitly exclude quarantined records.
* **Consequences:** Downstream Marts and tests join clean intermediate views (`int_*_cleaned`), keeping reporting clean while preserving defect visibility.

---

## ADR 004: SCD Type 2 Check Strategy Over Timestamp

* **Context:** Snapshots (`snap_drivers`, `snap_trucks`) require a Slowly Changing Dimension (SCD Type 2) tracking strategy (`timestamp` vs. `check`).
* **Decision:** Use `strategy: check` across specific business columns (e.g., driver status, equipment assignments) rather than `timestamp`.
* **Trade-offs:**
  * *Pros:* Reliable tracking for operational databases lacking dependable `updated_at` triggers.
  * *Cons:* Higher compute cost as dbt performs row-level column comparison hashes instead of checking a single timestamp.
* **Consequences:** If upstream systems implement reliable change-data-capture (CDC) timestamps, the strategy can seamlessly switch to `timestamp` to optimize compute.

---

## ADR 005: Ingestion Credentials via Job Parameters

* **Context:** The Databricks Ingestion Job requires PostgreSQL credentials to pull raw source tables into Bronze. We evaluated Databricks Secret Scopes vs. Job base parameters.
* **Decision:** Pass credentials dynamically via `dbutils.widgets` (Job base parameters).
* **Trade-offs:**
  * *Pros:* Rapid local development and testing without requiring complex Cloud IAM / Databricks CLI Secret Scope provisioning.
  * *Cons:* Parameters appear in Job run execution histories.
* **Consequences:** This is an explicit, conscious trade-off for local/portfolio development. In enterprise production, credentials migrate to AWS Secrets Manager or Azure Key Vault via Databricks Secret Scopes.
