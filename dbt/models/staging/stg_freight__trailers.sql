select {{ dbt_utils.star(source('bronze', 'trailers')) }}
from {{ source('bronze', 'trailers') }}
