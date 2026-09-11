{{
    config(
        materialized="incremental",
        incremental_strategy="merge",
        unique_key="load_id",
        on_schema_change="append_new_columns",
        contract={"enforced": true},
        tags=["marts"],
    )
}}

with
pickup_events as (
    select
        load_id,
        scheduled_datetime as pickup_scheduled,
        actual_datetime as picked_up_at
    from {{ ref("int_delivery_events_cleaned") }}
    where event_type = 'Pickup'
),

delivery_events as (
    select
        load_id,
        scheduled_datetime as delivery_scheduled,
        actual_datetime as delivered_at
    from {{ ref("int_delivery_events_cleaned") }}
    where event_type = 'Delivery'
),

trip_dispatch as (
    select
        load_id,
        dispatch_date as dispatched_at,
        trip_id
    from {{ ref("stg_freight__trips") }}
),

trip_fuel_cost as (
    select
        t.load_id,
        sum(fp.total_cost) as fuel_cost
    from {{ ref("stg_freight__trips") }} as t
    inner join {{ ref("stg_freight__fuel_purchases") }} as fp on t.trip_id = fp.trip_id
    group by 1
)

select
    l.load_id,
    cast(l.load_date as timestamp) as booked_at,
    cast(td.dispatched_at as timestamp) as dispatched_at,
    pe.picked_up_at,
    de.delivered_at,
    cast(
        {{ hours_between("cast(l.load_date as timestamp)", "td.dispatched_at") }}
        as double
    ) as hrs_book_to_dispatch,
    cast(
        {{ hours_between("td.dispatched_at", "pe.picked_up_at") }} as double
    ) as hrs_dispatch_to_pickup,
    cast(
        {{ hours_between("pe.picked_up_at", "de.delivered_at") }} as double
    ) as hrs_pickup_to_delivery,
    cast(
        {{ hours_between("cast(l.load_date as timestamp)", "de.delivered_at") }}
        as double
    ) as total_lead_time_hrs,
    not {{ recompute_on_time("pe.picked_up_at", "pe.pickup_scheduled") }}
        as is_late_pickup,
    not {{ recompute_on_time("de.delivered_at", "de.delivery_scheduled") }}
        as is_late_delivery,
    cast(l.revenue as double) as revenue,
    cast(coalesce(tf.fuel_cost, 0) as double) as fuel_cost,
    cast(l.revenue - coalesce(tf.fuel_cost, 0) as double) as margin
from {{ ref("stg_freight__loads") }} as l
left join trip_dispatch as td on l.load_id = td.load_id
left join pickup_events as pe on l.load_id = pe.load_id
left join delivery_events as de on l.load_id = de.load_id
left join trip_fuel_cost as tf on l.load_id = tf.load_id
