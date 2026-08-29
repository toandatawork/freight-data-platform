-- depends_on: {{ ref('stg_freight__loads') }}
-- depends_on: {{ ref('stg_freight__trips') }}
-- depends_on: {{ ref('stg_freight__drivers') }}
-- depends_on: {{ ref('stg_freight__trucks') }}
-- depends_on: {{ ref('stg_freight__fuel_purchases') }}
-- depends_on: {{ ref('stg_freight__delivery_events') }}
{{ config(materialized="incremental", tags=["dq"]) }}

with rule_checks as ({{ build_dq_sql() }})

select
    *,
    round(100.0 * failed_rows / nullif(total_rows, 0), 2) as failed_pct,
    (100.0 * failed_rows / nullif(total_rows, 0)) <= threshold_pct as is_passed
from rule_checks
