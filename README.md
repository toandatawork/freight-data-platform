# Freight Data Platform: Medallion Architecture & Data Governance

A production-grade Freight Analytics Warehouse built on **Databricks Lakehouse (Delta Lake)** and **dbt Core**, orchestrated via **Apache Airflow (Astronomer Cosmos)**. 

The platform implements an end-to-end data pipeline processing **85,410 shipments over 3 years** across 14 relational tables, featuring strict **Environment Isolation**, **Medallion Architecture**, and a **Metadata-Driven Data Quality Engine**.

---

## 1. Architectural Big Picture: The Medallion Paradigm vs. Environments

A frequent pitfall in data engineering projects is blurring the line between **Data Processing Stages (Medallion Layers)** and **Infrastructure Environments (Catalogs)**. In this platform, these two dimensions are strictly decoupled.

```
+-------------------------------------------------------------------------------------------------------+
|                                    ENVIRONMENT ISOLATION (CATALOGS)                                   |
|                                                                                                       |
|  [ freight_dev ]                     [ freight_ci ]                      [ freight_prod ]             |
|  Local development & feature testing Ephemeral PR checks (GitHub Actions) Automated Airflow execution|
|                                                                          Only source read by BI       |
+-------------------------------------------------------------------------------------------------------+
                                                   |
                                                   v
+-------------------------------------------------------------------------------------------------------+
|                                       MEDALLION DATA TIERS (SCHEMAS)                                  |
|                                                                                                       |
|  1. BRONZE (bronze.*)       --> Raw ingestion from OLTP via Spark JDBC. 1:1 schema, append-only,     |
|                                 watermarked, zero transformations.                                    |
|                                                                                                       |
|  2. SILVER (staging.*,      --> Cleaned & conformist views/tables. Data type casting, ISO timestamp   |
|     intermediate.*)             enrichment, surrogate key hashing, and quarantine isolation of        |
|                                 operational anomalies.                                                |
|                                                                                                       |
|  3. GOLD (marts.*)          --> Kimball Dimensional Modeling. 7 Dimensions, 4 Facts, SCD Type 2       |
|                                 snapshots, enforce strict contracts, and Power BI exposures.          |
|                                                                                                       |
|  4. OBSERVABILITY           --> Metadata-driven Data Quality engine, table profiling metrics,         |
|     (observability.*)           and execution run histories.                                          |
+-------------------------------------------------------------------------------------------------------+
```

---

## 2. Environment Isolation Matrix (Three-Level Namespace)

Databricks Unity Catalog provides a 3-level namespace: `<catalog>.<schema>.<table>`. This platform leverages catalogs for **complete multi-environment isolation**:

| Catalog | Target Persona / Engine | Ingestion Mode | Data Quality & Lifecycle |
| :--- | :--- | :--- | :--- |
| **`freight_dev`** | Data / Analytics Engineers (Local CLI) | Manual / On-demand Spark Job | Disposable scratchpad. Developers can freely `DROP SCHEMA` or test partial dbt runs without impacting downstream consumers. |
| **`freight_ci`** | GitHub Actions CI/CD Runners | Automated fixture seeding | Ephemeral validation sandbox. Every Pull Request triggers Slim CI (`state:modified+`) into isolated schemas, preventing cross-PR data pollution. |
| **`freight_prod`** | Apache Airflow Scheduler (`0 6 * * *`) | Automated daily incremental | **Immutable single source of truth**. No human developer has write access (`dbt build` is forbidden from local). Only BI consumers (`bi_reader`) are granted query access. |

---

## 3. Detailed Data Pipeline Flow: From Ingestion to Consumption

```mermaid
flowchart LR
    subgraph Source["Source Systems (OLTP)"]
        GhostDB[("Ghost PostgreSQL\n14 Operational Tables\n(Loads, Trips, Drivers, Trucks...)")]
    end

    subgraph Databricks["Databricks Lakehouse (Compute & Storage)"]
        subgraph BronzeTier["1. Bronze Tier (Raw Ingestion)"]
            SparkJob["Databricks Job\n(PySpark JDBC + Watermarking)"]
            DeltaBronze[("Delta Lake Tables\n`bronze.*`\n(Raw + _ingested_at)")]
        end

        subgraph SilverTier["2. Silver Tier (Validation & Cleansing)"]
            Staging["Staging Views\n`staging.stg_*`\n(Cast types, Snake_case)"]
            Intermediate["Intermediate Models\n`int_delivery_events_cleaned`\n`int_loads_enriched`"]
            Quarantine[("Quarantine Storage\n`qtn_time_anomaly`\n`qtn_orphan_fk`")]
        end

        subgraph GoldTier["3. Gold Tier (Star Schema Marts)"]
            Dims[("7 Dimension Tables\n`dim_customer`, `dim_driver`,\n`dim_truck`, `dim_date`...")]
            Facts[("4 Fact Tables\n`fct_load`, `fct_trip`,\n`fct_delivery_event`,\n`fct_shipment_lifecycle`")]
            SCD2[("SCD Type 2 Snapshots\n`snap_drivers`,\n`snap_trucks`")]
        end

        subgraph ObservabilityTier["4. Governance & Observability"]
            DQEngine["DQ Rules Engine\n(Seed + Jinja SQL Builder)"]
            DQResults[("`dq_rule_results`\nPass/Fail per invocation")]
            SeverityGate{"DQ Severity Gate\non-run-end hook"}
        end
    end

    subgraph Orchestration["Orchestration (Airflow + Cosmos)"]
        AF_Ingest["Task: ingest_bronze"]
        AF_Cosmos["DbtTaskGroup: dbt_freight\n(Task-level Granularity)"]
    end

    subgraph Consumption["Serving & Business Intelligence"]
        PowerBI["Power BI Executive Dashboard\n(SLA, Late Delivery Root Cause)"]
    end

    %% Dependencies
    GhostDB -->|JDBC extract| SparkJob
    SparkJob --> DeltaBronze

    DeltaBronze --> Staging
    Staging --> Intermediate
    Staging -.->|Isolate defect rows| Quarantine

    Intermediate --> Dims
    Intermediate --> Facts
    Intermediate --> SCD2

    Staging --> DQEngine
    DQEngine --> DQResults
    DQResults --> SeverityGate

    AF_Ingest -.->|Triggers| SparkJob
    AF_Cosmos -.->|Orchestrates| Staging & Intermediate & Dims & Facts

    Facts --> PowerBI
    Dims --> PowerBI
```

### Medallion Layer Specifications

#### 🟢 Bronze: High-Watermark Raw Ingestion
- **Engine:** PySpark running inside a Databricks Job task (`databricks/nb_ingest_bronze.py`).
- **Strategy:** 
  - Dimension-like small tables (e.g., `customers`, `facilities`, `routes`): **Full-refresh Overwrite**.
  - High-volume transaction tables (`loads`, `trips`, `fuel_purchases`): **Incremental Append** based on table-specific high-watermark timestamps (e.g., `load_date > MAX(load_date)`).
- **Metadata Tagging:** Every record is enriched with ingestion lineage metadata: `_ingested_at` (UTC timestamp) and `_source_file` (`ghost_postgres.oltp.<table>`).

#### ⚪ Silver: Conformance & Quarantine Pattern
- **Staging (`models/staging/`):** Renames source columns to standard snake_case, handles timestamp formatting, and documents base schemas.
- **Data Cleansing & Enrichment (`models/intermediate/`):** Implements business business logic (recomputing actual shipment transit duration, detecting weather or traffic delays).
- **Quarantine Layer (`models/intermediate/quarantine/`):** Instead of silently discarding or filtering invalid records, defect rows (e.g., negative transit times, orphan customer foreign keys) are routed to dedicated `qtn_*` tables for data engineering auditing.

#### 🟡 Gold: Dimensional Modeling (Kimball Architecture)
- **Dimensions (`models/marts/dimensions/`):** Formats 7 conforming dimensions. Implements **Slowly Changing Dimensions (SCD Type 2)** via dbt snapshots (`snap_drivers_snapshot`, `snap_trucks_snapshot`) tracking driver equipment assignments and status history over time.
- **Facts (`models/marts/facts/`):**
  - `fct_load`: Shipment transaction fact with strict **dbt model contracts** enforced.
  - `fct_delivery_event`: High-throughput microbatch incremental model recording milestone events (Pickup, Delivery).
  - `fct_shipment_lifecycle`: Accumulated snapshot fact tracing full dispatch-to-delivery lifecycle duration.

#### 🟣 Observability: Metadata-Driven Quality Control
- **DQ Engine (`macros/dq/build_dq_sql.sql`):** Reads validation thresholds defined in `seeds/dq_rules.csv` and compiles automated multi-table assertion SQL.
- **Severity Gate (`macros/dq/dq_severity_gate.sql`):** Integrated into the dbt `on-run-end` lifecycle. Evaluates failure counts of `error`-level assertions and aborts the pipeline run before downstream consumption can proceed.

---

## 4. Orchestration: Apache Airflow & Astronomer Cosmos

Instead of treating dbt as a black-box `BashOperator("dbt build")`, this platform utilizes **Astronomer Cosmos** (`cosmos.DbtTaskGroup`):
- **Task-level Granularity:** Parses `manifest.json` to dynamically generate individual Airflow tasks for every dbt model, seed, test, and snapshot.
- **Isolated Virtual Environments:** Resolves dependency conflicts between Airflow (2.10) and dbt (1.12) by containerizing dbt inside a dedicated virtual environment (`/home/airflow/dbt_venv`).
- **Idempotency Verification:** Includes a dedicated DAG (`freight_backfill`) targeting microbatch models to prove pipeline determinism across re-runs.

---

## 5. Quickstart & Local Execution

### Prerequisites
- Python 3.12 (`uv` package manager)
- Docker & Docker Compose
- Databricks Workspace account with SQL Warehouse access

```bash
# 1. Clone & install dependencies
git clone https://github.com/toandatawork/freight-analytics-warehouse.git
cd freight-analytics-warehouse
uv sync

# 2. Environment Configuration
cp .env.example .env
# Populate DBX_HOST, DBX_HTTP_PATH, DBX_TOKEN, DBX_JOB_ID

# 3. Local dbt Development (targets freight_dev)
cd dbt
uv run dbt deps
uv run dbt build --target dev

# 4. Start Orchestration Cluster (Airflow UI at http://localhost:8080)
cd ../airflow
docker compose up -d
```
