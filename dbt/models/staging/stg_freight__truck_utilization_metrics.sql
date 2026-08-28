select {{ dbt_utils.star(source('bronze', 'truck_utilization_metrics')) }}
from {{ source('bronze', 'truck_utilization_metrics') }}
