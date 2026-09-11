{{ config(materialized="table", tags=["intermediate"], event_time="actual_datetime") }}

select
    event_id,
    load_id,
    trip_id,
    event_type,
    facility_id,
    scheduled_datetime,
    actual_datetime,
    detention_minutes,
    on_time_flag as on_time_flag_raw,
    {{ recompute_on_time("actual_datetime", "scheduled_datetime") }}
        as is_on_time_computed,
    on_time_flag
    <> {{ recompute_on_time("actual_datetime", "scheduled_datetime") }}
        as flag_mismatch,
    location_city,
    location_state
from {{ ref("stg_freight__delivery_events") }}
