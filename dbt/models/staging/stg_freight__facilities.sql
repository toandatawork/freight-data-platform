select {{ dbt_utils.star(source('bronze', 'facilities')) }}
from {{ source('bronze', 'facilities') }}
