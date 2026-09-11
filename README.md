# Freight Data Platform: Medallion Architecture & Data Governance

A production-grade Freight Analytics Warehouse built on **Databricks Lakehouse (Delta Lake)** and **dbt Core**, orchestrated via **Apache Airflow (Astronomer Cosmos)**. 

The platform implements an end-to-end data pipeline processing **85,410 shipments over 3 years** across 14 relational tables, featuring strict **Environment Isolation**, **Medallion Architecture**, and a **Metadata-Driven Data Quality Engine**.

---

## 1. Architectural Big Picture: The Medallion Paradigm vs. Environments

A frequent pitfall in data engineering projects is blurring the line between **Data Processing Stages (Medallion Layers)** and **Infrastructure Environments (Catalogs)**. In this platform, these two dimensions are strictly decoupled.

| Environment (Catalog) | Access & Governance | Primary Purpose |
| :--- | :--- | :--- |
| **`freight_dev`** | Local Engineers (CLI `uv run dbt build`) | Disposable sandbox for rapid feature development & testing. |
| **`freight_ci`** | GitHub Actions (Pre-merge ephemeral) | Automated validation on PRs; prevents cross-PR data collisions. |
| **`freight_prod`** | Airflow Scheduler (`0 6 * * *`) only | Immutable single source of truth; exclusive source for BI reporting. |

### Medallion Data Tiers (Schemas)
* **Bronze (`bronze.*`):** Raw 1:1 ingestion from OLTP via Spark JDBC. Append-only, watermarked, zero transformation.
* **Silver (`staging.*`, `intermediate.*`):** Type casting, standardized snake_case naming, surrogate keys, and quarantined defect isolation.
* **Gold (`marts.*`):** Kimball Star Schema with 7 Dimensions and 4 Facts, SCD Type 2 snapshots, and enforced model contracts.
* **Observability (`observability.*`):** Metadata-driven Data Quality engine, profiling drift tracking, and test execution history.

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
    subgraph Source["Source System (OLTP)"]
        GhostDB[("PostgreSQL Source<br/>14 Relational Tables")]
    end

    subgraph BronzeTier["1. Bronze Tier (Raw)"]
        SparkJob["Databricks Job<br/>PySpark JDBC Ingest"]
        DeltaBronze[("Delta Bronze Tables<br/>Raw + _ingested_at")]
    end

    subgraph SilverTier["2. Silver Tier (Conformance)"]
        Staging["Staging Views<br/>stg_freight_*"]
        Intermediate["Intermediate Models<br/>Cleaned & Enriched"]
        Quarantine[("Quarantine Storage<br/>qtn_* Anomaly Tables")]
    end

    subgraph GoldTier["3. Gold Tier (Star Schema Marts)"]
        Dims[("7 Dimension Tables<br/>dim_customer, driver...")]
        Facts[("4 Fact Tables<br/>fct_load, delivery_event...")]
        SCD2[("SCD Type 2 Snapshots<br/>snap_drivers, trucks")]
    end

    subgraph ObservabilityTier["4. Governance & DQ"]
        DQEngine["DQ Rules Engine<br/>Seed + Jinja Macro"]
        DQResults[("dq_rule_results<br/>Pass/Fail Stats")]
        SeverityGate{"DQ Severity Gate<br/>on-run-end hook"}
    end

    subgraph Orchestration["Orchestration"]
        AF_Ingest["Airflow: ingest_bronze"]
        AF_Cosmos["Cosmos DbtTaskGroup<br/>Task-level Granularity"]
    end

    subgraph Consumption["Serving & Analytics"]
        PowerBI["Power BI Dashboard<br/>SLA & Profitability"]
    end

    GhostDB -->|JDBC Extract| SparkJob
    SparkJob --> DeltaBronze
    DeltaBronze --> Staging
    Staging --> Intermediate
    Staging -.->|Isolate Defect Rows| Quarantine
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

### Pipeline Execution Showcase

![Airflow Pipeline Execution](docs/images/airflow_graph_view.png)
*Figure: Production execution state in Apache Airflow (Astronomer Cosmos). Left: 100% Green Grid run status across Ingestion, Staging, and Marts. Right: Dynamic DAG dependency graph.*

---
