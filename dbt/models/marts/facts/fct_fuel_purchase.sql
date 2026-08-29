{{
    config(
        materialized="incremental",
        incremental_strategy="append",
        on_schema_change="append_new_columns",
        tags=["marts"],
    )
}}

select
    fp.fuel_purchase_id,
    fp.trip_id,
    coalesce(dt.truck_key, '-1') as truck_key,
    coalesce(dd2.driver_key, '-1') as driver_key,
    dd.date_key as purchase_date_key,
    fp.purchase_date,
    fp.location_city,
    fp.location_state,
    fp.gallons,
    fp.price_per_gallon,
    fp.total_cost
from {{ ref("stg_freight__fuel_purchases") }} fp
left join {{ ref("dim_truck") }} dt on fp.truck_id = dt.truck_id
left join {{ ref("dim_driver") }} dd2 on fp.driver_id = dd2.driver_id
left join {{ ref("dim_date") }} dd on cast(fp.purchase_date as date) = dd.date_day
{% if is_incremental() %}
    where fp.purchase_date > (select max(purchase_date) from {{ this }})
{% endif %}
