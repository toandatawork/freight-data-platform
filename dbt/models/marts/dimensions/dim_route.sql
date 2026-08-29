{{ config(materialized="table", tags=["marts"]) }}

with
    source as (select * from {{ ref("stg_freight__routes") }}),

    known as (
        select
            {{ dbt_utils.generate_surrogate_key(["route_id"]) }} as route_key,
            route_id,
            origin_city,
            origin_state,
            destination_city,
            destination_state,
            typical_distance_miles,
            base_rate_per_mile,
            fuel_surcharge_rate,
            typical_transit_days
        from source
    ),

    unknown as (
        select
            '-1' as route_key,
            'UNKNOWN' as route_id,
            'Unknown' as origin_city,
            'Unknown' as origin_state,
            'Unknown' as destination_city,
            'Unknown' as destination_state,
            cast(null as numeric) as typical_distance_miles,
            cast(null as numeric) as base_rate_per_mile,
            cast(null as numeric) as fuel_surcharge_rate,
            cast(null as int) as typical_transit_days
    )

select *
from known
union all
select *
from unknown
