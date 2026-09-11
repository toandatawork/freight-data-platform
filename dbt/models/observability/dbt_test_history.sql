{{ config(materialized="view", tags=["observability"], enabled=false) }}

select *
from {{ ref("run_results_raw") }}
