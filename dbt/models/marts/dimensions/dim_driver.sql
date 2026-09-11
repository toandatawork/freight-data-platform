{{ config(materialized="table", tags=["marts"]) }}

with
source as (select * from {{ ref("stg_freight__drivers") }}),

known as (
    select
        {{ dbt_utils.generate_surrogate_key(["driver_id"]) }} as driver_key,
        driver_id,
        first_name,
        last_name,
        hire_date,
        termination_date,
        license_number,
        license_state,
        date_of_birth,
        home_terminal,
        employment_status,
        cdl_class,
        years_experience
    from source
),

unknown as (
    select
        '-1' as driver_key,
        'UNKNOWN' as driver_id,
        'Unknown' as first_name,
        'Unknown' as last_name,
        cast(null as date) as hire_date,
        cast(null as date) as termination_date,
        cast(null as string) as license_number,
        cast(null as string) as license_state,
        cast(null as date) as date_of_birth,
        'Unknown' as home_terminal,
        'Unknown' as employment_status,
        cast(null as string) as cdl_class,
        cast(null as numeric) as years_experience
)

select *
from known
union all
select *
from unknown
