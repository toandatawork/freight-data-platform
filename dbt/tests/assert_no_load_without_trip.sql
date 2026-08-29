select l.load_id
from {{ ref("fct_load") }} l
left join {{ ref("stg_freight__trips") }} t on l.load_id = t.load_id
where l.load_status = 'Completed' and t.trip_id is null
