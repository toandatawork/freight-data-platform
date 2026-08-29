{{ config(materialized="table", tags=["quarantine"]) }}

select
    event_id,
    load_id,
    on_time_flag_raw,
    is_on_time_computed,
    'flag_mismatch' as quarantine_reason,
    current_timestamp() as detected_at,
    'delivery_events' as source_table,
    '{{ invocation_id }}' as dbt_invocation_id
from {{ ref("int_delivery_events_cleaned") }}
where flag_mismatch
