{{ config(materialized="view", tags=["observability"]) }}

select *
from {{ ref("run_results_raw") }}
