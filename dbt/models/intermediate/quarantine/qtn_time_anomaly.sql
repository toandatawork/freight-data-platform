{{ config(materialized="table", tags=["quarantine"]) }}

with
pickup as (
    select
        load_id,
        actual_datetime as pickup_actual
    from {{ ref("stg_freight__delivery_events") }}
    where event_type = 'Pickup'
),

delivery as (
    select
        load_id,
        actual_datetime as delivery_actual
    from {{ ref("stg_freight__delivery_events") }}
    where event_type = 'Delivery'
)

select
    d.load_id,
    p.pickup_actual,
    d.delivery_actual,
    'delivery_before_pickup' as quarantine_reason,
    current_timestamp() as detected_at,
    'delivery_events' as source_table,
    '{{ invocation_id }}' as dbt_invocation_id
from delivery as d
inner join pickup as p on d.load_id = p.load_id
where d.delivery_actual < p.pickup_actual
