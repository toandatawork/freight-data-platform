with
    pickup as (
        select load_id, actual_datetime as pickup_actual
        from {{ ref("int_delivery_events_cleaned") }}
        where event_type = 'Pickup'
    ),
    delivery as (
        select load_id, actual_datetime as delivery_actual
        from {{ ref("int_delivery_events_cleaned") }}
        where event_type = 'Delivery'
    )
select l.load_id
from {{ ref("fct_load") }} l
join delivery d on l.load_id = d.load_id
join pickup p on l.load_id = p.load_id
where l.has_time_anomaly = false and d.delivery_actual < p.pickup_actual
