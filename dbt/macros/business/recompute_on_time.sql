{% macro recompute_on_time(actual_col, scheduled_col) %}
    case
        when {{ actual_col }} is null or {{ scheduled_col }} is null
        then null
        when {{ actual_col }} <= {{ scheduled_col }}
        then true
        else false
    end
{% endmacro %}
