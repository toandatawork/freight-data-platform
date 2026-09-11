{{
    config(
        materialized="incremental",
        incremental_strategy="merge",
        unique_key="load_id",
        on_schema_change="append_new_columns",
        partition_by=["load_month"],
        tags=["marts"],
    )
}}

select
    l.load_id,
    dd.date_key as load_date_key,
    l.load_type,
    l.weight_lbs,
    l.revenue,
    l.fuel_surcharge,
    l.accessorial_charges,
    l.gross_revenue,
    l.load_status,
    l.booking_type,
    l.has_time_anomaly,
    coalesce(dc.customer_key, '-1') as customer_key,
    coalesce(dr.route_key, '-1') as route_key,
    date_trunc('month', l.load_date) as load_month
from {{ ref("int_loads_enriched") }} as l
left join {{ ref("dim_customer") }} as dc on l.customer_id = dc.customer_id
left join {{ ref("dim_route") }} as dr on l.route_id = dr.route_id
left join {{ ref("dim_date") }} as dd on l.load_date = dd.date_day
