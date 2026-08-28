select {{ dbt_utils.star(source('bronze', 'drivers')) }}
from {{ source('bronze', 'drivers') }}
