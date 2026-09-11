{{
    config(
        materialized='incremental',
        unique_key=['table_name', 'column_name', 'profiled_at'],
        tags=['profiling']
    )
}}

{% set bronze_tables = [
    "customers", "trucks", "trailers", "facilities", "routes", "drivers",
    "loads", "trips", "fuel_purchases", "maintenance_records",
    "delivery_events", "safety_incidents",
    "driver_monthly_metrics", "truck_utilization_metrics"
] %}

{% for t in bronze_tables %}
    {{ profile_relation('bronze', t) }}
    {% if not loop.last %}union all{% endif %}
{% endfor %}
