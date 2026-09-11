{{ config(materialized="table", tags=["marts"]) }}

with
source as (select * from {{ ref("stg_freight__trucks") }}),

known as (
    select
        {{ dbt_utils.generate_surrogate_key(["truck_id"]) }} as truck_key,
        truck_id,
        unit_number,
        make,
        model_year,
        vin,
        acquisition_date,
        acquisition_mileage,
        fuel_type,
        tank_capacity_gallons,
        status,
        home_terminal
    from source
),

unknown as (
    select
        '-1' as truck_key,
        'UNKNOWN' as truck_id,
        'Unknown' as unit_number,
        'Unknown' as make,
        cast(null as int) as model_year,
        cast(null as string) as vin,
        cast(null as date) as acquisition_date,
        cast(null as numeric) as acquisition_mileage,
        'Unknown' as fuel_type,
        cast(null as numeric) as tank_capacity_gallons,
        'Unknown' as status,
        'Unknown' as home_terminal
)

select *
from known
union all
select *
from unknown
