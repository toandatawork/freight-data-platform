{% snapshot snap_trucks %}
    {{
        config(
            target_schema="marts",
            unique_key="truck_id",
            strategy="check",
            check_cols=["status", "home_terminal"],
            hard_deletes="new_record",
        )
    }}
    select *
    from {{ ref("stg_freight__trucks") }}
{% endsnapshot %}
