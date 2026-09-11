{{ config(materialized='view', tags=['profiling']) }}

with ranked as (
    select
        table_name,
        column_name,
        profiled_at,
        null_pct,
        distinct_count,
        lag(null_pct) over (
            partition by table_name, column_name order by profiled_at
        ) as prev_null_pct,
        lag(distinct_count) over (
            partition by table_name, column_name order by profiled_at
        ) as prev_distinct_count
    from {{ ref('profile_bronze_columns') }}
)

select
    *,
    abs(null_pct - coalesce(prev_null_pct, null_pct)) > 5 as is_null_pct_drifted
from ranked
