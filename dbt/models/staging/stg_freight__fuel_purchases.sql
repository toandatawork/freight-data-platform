select {{ dbt_utils.star(source('bronze', 'fuel_purchases')) }}
from {{ source('bronze', 'fuel_purchases') }}
