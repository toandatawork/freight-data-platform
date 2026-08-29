{{ config(materialized="table", tags=["marts"]) }}

with
    source as (select * from {{ ref("stg_freight__trailers") }}),

    known as (
        select
            {{ dbt_utils.generate_surrogate_key(["trailer_id"]) }} as trailer_key,
            trailer_id,
            trailer_number,
            trailer_type,
            length_feet,
            model_year,
            vin,
            acquisition_date,
            status,
            current_location
        from source
    ),

    unknown as (
        select
            '-1' as trailer_key,
            'UNKNOWN' as trailer_id,
            'Unknown' as trailer_number,
            'Unknown' as trailer_type,
            cast(null as numeric) as length_feet,
            cast(null as int) as model_year,
            cast(null as string) as vin,
            cast(null as date) as acquisition_date,
            'Unknown' as status,
            'Unknown' as current_location
    )

select *
from known
union all
select *
from unknown
