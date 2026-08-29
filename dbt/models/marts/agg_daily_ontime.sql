{{ config(materialized="materialized_view", tags=["marts"]) }}

select
    date_trunc('day', actual_datetime) as day,
    count(*) as total_events,
    sum(case when is_on_time_computed then 1 else 0 end) as on_time_events,
    round(
        100.0 * sum(case when is_on_time_computed then 1 else 0 end) / count(*), 1
    ) as on_time_pct
from {{ ref("int_delivery_events_cleaned") }}
where event_type = 'Delivery'
group by 1
