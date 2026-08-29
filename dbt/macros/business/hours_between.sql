{% macro hours_between(start_ts, end_ts) %}
    case
        when {{ start_ts }} is null or {{ end_ts }} is null
        then null
        else (unix_timestamp({{ end_ts }}) - unix_timestamp({{ start_ts }})) / 3600.0
    end
{% endmacro %}
