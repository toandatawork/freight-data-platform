{{ config(materialized="table", tags=["dq"]) }}

select
    model_name,
    date_trunc('day', checked_at) as check_date,
    count(*) as total_rules,
    sum(case when is_passed then 1 else 0 end) as passed_rules,
    round(
        100.0 * sum(case when is_passed then 1 else 0 end) / count(*), 1
    ) as quality_score
from {{ ref("dq_rule_results") }}
group by 1, 2
