select {{ dbt_utils.star(source('bronze', 'customers')) }}
from {{ source('bronze', 'customers') }}
