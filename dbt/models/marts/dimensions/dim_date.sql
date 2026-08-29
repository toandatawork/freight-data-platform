{{ config(materialized="table", tags=["marts"]) }}

with
    spine as (
        {{
            dbt_utils.date_spine(
                datepart="day",
                start_date="cast('2022-01-01' as date)",
                end_date="cast('2025-01-01' as date)",
            )
        }}
    )

select
    {{ dbt_utils.generate_surrogate_key(["date_day"]) }} as date_key,
    date_day,
    year(date_day) as year,
    month(date_day) as month,
    day(date_day) as day,
    quarter(date_day) as quarter,
    date_format(date_day, 'EEEE') as day_name,
    date_format(date_day, 'MMMM') as month_name
from spine
