{{ config(materialized="table", tags=["marts"]) }}

with
    source as (select * from {{ ref("stg_freight__facilities") }}),

    known as (
        select
            {{ dbt_utils.generate_surrogate_key(["facility_id"]) }} as facility_key,
            facility_id,
            facility_name,
            facility_type,
            city,
            state,
            latitude,
            longitude,
            dock_doors,
            operating_hours
        from source
    ),

    unknown as (
        select
            '-1' as facility_key,
            'UNKNOWN' as facility_id,
            'Unknown' as facility_name,
            'Unknown' as facility_type,
            'Unknown' as city,
            'Unknown' as state,
            cast(null as numeric) as latitude,
            cast(null as numeric) as longitude,
            cast(null as int) as dock_doors,
            'Unknown' as operating_hours
    )

select *
from known
union all
select *
from unknown
