select c.event_id
from {{ ref("int_delivery_events_cleaned") }} c
left join {{ ref("qtn_flag_mismatch") }} q on c.event_id = q.event_id
where c.flag_mismatch = true and q.event_id is null
