with monthly as (
    select
        date_trunc('month', load_date) as month,
        count(*) as load_count
    from {{ ref('stg_freight__loads') }}
    group by 1
),
yearly_avg as (
    select avg(load_count) as avg_load_count from monthly
)

select
    m.month,
    m.load_count,
    round(m.load_count / y.avg_load_count, 3) as seasonality_index
from monthly m
cross join yearly_avg y
order by 1