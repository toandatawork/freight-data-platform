{% test timestamps_in_order(model, column_a, column_b) %}
    select * from {{ model }} where {{ column_a }} > {{ column_b }}
{% endtest %}
