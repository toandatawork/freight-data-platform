select {{ dbt_utils.star(source('bronze', 'driver_monthly_metrics')) }}
from {{ source('bronze', 'driver_monthly_metrics') }}
