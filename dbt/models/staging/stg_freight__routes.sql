select {{ dbt_utils.star(source('bronze', 'routes')) }}
from {{ source('bronze', 'routes') }}
