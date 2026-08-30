# 003. Quarantine Pattern Over Silent Filtering

## Context

The dataset contains known data defects (time anomalies, flag mismatches, orphan foreign keys). We needed to decide whether to filter them out silently or keep them.

## Decision

Quarantine bad records into dedicated audit tables (`qtn_*`) with reason codes and detection timestamps instead of discarding them via `WHERE` clauses.

## Trade-offs

| Pros                                                                                   | Cons                                                                                               |
| -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| Preserves full audit trails to investigate and report back to upstream source systems. | Requires extra storage and models; downstream queries must explicitly exclude quarantined records. |

## Consequences

Downstream models and tests must explicitly exclude quarantine tables (e.g., using anti-joins or anomaly flags) to report clean metrics.
