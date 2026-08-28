select
    {{ dbt_utils.star(
        source('bronze', 'safety_incidents'),
        except=["at_fault_flag", "injury_flag", "preventable_flag"]
    ) }},
    case when lower(at_fault_flag) = 'true' then true
         when lower(at_fault_flag) = 'false' then false end as at_fault_flag,
    case when lower(injury_flag) = 'true' then true
         when lower(injury_flag) = 'false' then false end as injury_flag,
    case when lower(preventable_flag) = 'true' then true
         when lower(preventable_flag) = 'false' then false end as preventable_flag
from {{ source('bronze', 'safety_incidents') }}