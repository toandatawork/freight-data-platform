# 002. In-Warehouse Data Profiling via dbt

## Context

Data profiling is typically done in standalone Python/Jupyter notebooks, which cannot be automated, tracked, or reproduced in CI pipelines.

## Decision

Implement all data profiling directly inside dbt as metadata-driven incremental models at the Bronze layer.

## Trade-offs

| Pros                                                                                                                      | Cons                                                                                        |
| ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Fully reproducible (`dbt build --select tag:profiling`), visible in data lineage, and tracks statistical drift over time. | Can only profile data already loaded into the warehouse (cannot profile raw external CSVs). |

## Consequences

Every new source table must be loaded into Bronze before profiling; no ad-hoc out-of-pipeline profiling.
