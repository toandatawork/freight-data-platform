# Trusted Delivery Analytics

A freight analytics warehouse built with dbt on Databricks, featuring a metadata-driven
data quality layer. Source: 14 tables, 85,410 shipments over 3 years.

> 🚧 Work in progress — Phase 0 of 12 (repository scaffolding).

## Data

Synthetic dataset from Kaggle. Not committed to this repository (57MB) — see `data/README.md`
for the source and download instructions.

**Note:** this data is script-generated, not real operational records. The data defects it
contains are material for demonstrating a quality-control pipeline, not findings about the
freight industry.

## Setup

```bash
uv sync                            # install Python dependencies
bash scripts/download_data.sh      # download dataset into data/raw/
cp .env.example .env               # then fill in credentials
```

## Repository layout

| Directory    | Contents                                                 |
| ------------ | -------------------------------------------------------- |
| `dbt/`       | dbt project — transformations, tests, data quality rules |
| `ingestion/` | loads CSV into the source Postgres database              |
| `data/raw/`  | dataset (gitignored)                                     |
| `scripts/`   | data download and verification utilities                 |
| `docs/`      | data dictionary, architecture, decision records          |
