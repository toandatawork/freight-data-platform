select
    {{ dbt_utils.star(source('bronze', 'delivery_events'), except=["on_time_flag"]) }},
    case
        when lower(on_time_flag) = 'true' then true
        when lower(on_time_flag) = 'false' then false
    end as on_time_flag
from {{ source('bronze', 'delivery_events') }}
