select {{ dbt_utils.star(source('bronze', 'trips')) }}
from {{ source('bronze', 'trips') }}
