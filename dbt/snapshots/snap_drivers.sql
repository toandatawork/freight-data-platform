{% snapshot snap_drivers %}
    {{
        config(
            target_schema="marts",
            unique_key="driver_id",
            strategy="check",
            check_cols=["employment_status", "termination_date", "home_terminal"],
            hard_deletes="new_record",
        )
    }}
    select *
    from {{ ref("stg_freight__drivers") }}
{% endsnapshot %}
