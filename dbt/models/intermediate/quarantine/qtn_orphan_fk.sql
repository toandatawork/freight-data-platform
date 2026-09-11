{{ config(materialized="table", tags=["quarantine"]) }}

with
orphan_driver as (
    select
        t.trip_id,
        t.driver_id as ref_id,
        'orphan_driver' as quarantine_reason
    from {{ ref("stg_freight__trips") }} as t
    left join {{ ref("stg_freight__drivers") }} as d on t.driver_id = d.driver_id
    where d.driver_id is null
),

orphan_truck as (
    select
        t.trip_id,
        t.truck_id as ref_id,
        'orphan_truck' as quarantine_reason
    from {{ ref("stg_freight__trips") }} as t
    left join {{ ref("stg_freight__trucks") }} as tr on t.truck_id = tr.truck_id
    where tr.truck_id is null
)

select
    trip_id,
    ref_id,
    quarantine_reason,
    current_timestamp() as detected_at,
    'trips' as source_table,
    '{{ invocation_id }}' as dbt_invocation_id
from orphan_driver
union all
select
    trip_id,
    ref_id,
    quarantine_reason,
    current_timestamp() as detected_at,
    'trips' as source_table,
    '{{ invocation_id }}' as dbt_invocation_id
from orphan_truck
