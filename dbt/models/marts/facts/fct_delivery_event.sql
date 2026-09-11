{{
    config(
        materialized="incremental",
        incremental_strategy="microbatch",
        event_time="actual_datetime",
        batch_size="month",
        begin="2022-01-01",
        on_schema_change="append_new_columns",
        tags=["marts"],
    )
}}

select
    de.event_id,
    de.load_id,
    de.trip_id,
    de.event_type,
    dd.date_key as event_date_key,
    de.scheduled_datetime,
    de.actual_datetime,
    de.detention_minutes,
    de.on_time_flag_raw,
    de.is_on_time_computed,
    de.flag_mismatch,
    coalesce(df.facility_key, '-1') as facility_key
from {{ ref("int_delivery_events_cleaned") }} as de
left join {{ ref("dim_facility") }} as df on de.facility_id = df.facility_id
left join {{ ref("dim_date") }} as dd on cast(de.actual_datetime as date) = dd.date_day
