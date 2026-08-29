{{ config(materialized="table", tags=["intermediate"]) }}

select
    l.load_id,
    l.customer_id,
    l.route_id,
    l.load_date,
    l.load_type,
    l.weight_lbs,
    l.revenue,
    l.fuel_surcharge,
    l.accessorial_charges,
    l.revenue + l.fuel_surcharge + l.accessorial_charges as gross_revenue,
    l.load_status,
    l.booking_type,
    ta.load_id is not null as has_time_anomaly
from {{ ref("stg_freight__loads") }} l
left join {{ ref("qtn_time_anomaly") }} ta on l.load_id = ta.load_id
