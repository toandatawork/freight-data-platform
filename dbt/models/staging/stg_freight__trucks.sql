select {{ dbt_utils.star(source('bronze', 'trucks')) }}
from {{ source('bronze', 'trucks') }}
