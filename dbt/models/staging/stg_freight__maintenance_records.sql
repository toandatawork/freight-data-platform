select {{ dbt_utils.star(source('bronze', 'maintenance_records')) }}
from {{ source('bronze', 'maintenance_records') }}
