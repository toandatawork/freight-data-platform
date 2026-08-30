# 004. SCD Type 2 Check Strategy Over Timestamp Strategy

## Context

Snapshots (`snap_drivers`, `snap_trucks`) require an SCD Type 2 tracking strategy (`timestamp` vs. `check`).

## Decision

Use `strategy: check` across specific monitored columns instead of `timestamp`.

## Trade-offs

| Pros                                                                | Cons                                                                                   |
| ------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Accurate for datasets without a true, reliable `updated_at` column. | Higher compute cost because dbt compares column values rather than a single timestamp. |

## Consequences

If the upstream source later provides reliable `updated_at` timestamps, we can switch to the `timestamp` strategy to reduce comparison overhead.
