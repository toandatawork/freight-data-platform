{{ config(materialized="table", tags=["marts"]) }}

with
    source as (select * from {{ ref("stg_freight__customers") }}),

    known as (
        select
            {{ dbt_utils.generate_surrogate_key(["customer_id"]) }} as customer_key,
            customer_id,
            customer_name,
            customer_type,
            credit_terms_days,
            primary_freight_type,
            account_status,
            contract_start_date,
            annual_revenue_potential
        from source
    ),

    unknown as (
        select
            '-1' as customer_key,
            'UNKNOWN' as customer_id,
            'Unknown' as customer_name,
            'Unknown' as customer_type,
            cast(null as int) as credit_terms_days,
            'Unknown' as primary_freight_type,
            'Unknown' as account_status,
            cast(null as date) as contract_start_date,
            cast(null as numeric) as annual_revenue_potential
    )

select *
from known
union all
select *
from unknown
