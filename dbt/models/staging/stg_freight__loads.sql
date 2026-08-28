select {{ dbt_utils.star(source('bronze', 'loads')) }}
from {{ source('bronze', 'loads') }}
