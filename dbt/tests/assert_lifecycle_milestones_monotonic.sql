select s.load_id
from {{ ref("fct_shipment_lifecycle") }} s
left join {{ ref("qtn_time_anomaly") }} ta on s.load_id = ta.load_id
where
    ta.load_id is null
    and (
        (
            s.dispatched_at is not null
            and s.booked_at is not null
            and s.dispatched_at < s.booked_at
        )
        or (
            s.picked_up_at is not null
            and s.dispatched_at is not null
            and s.picked_up_at < s.dispatched_at
        )
        or (
            s.delivered_at is not null
            and s.picked_up_at is not null
            and s.delivered_at < s.picked_up_at
        )
    )
