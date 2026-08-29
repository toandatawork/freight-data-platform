select
    date_trunc('month', purchase_date) as month,
    avg(price_per_gallon)              as avg_price_per_gallon,
    min(price_per_gallon)              as min_price,
    max(price_per_gallon)              as max_price
from {{ ref('stg_freight__fuel_purchases') }}
group by 1
order by 1