{% test within_pct_of(model, column_name, compare_model, compare_column, pct) %}
    with
        a as (select sum({{ column_name }}) as total_a from {{ model }}),
        b as (select sum({{ compare_column }}) as total_b from {{ compare_model }})
    select *
    from a
    cross join b
    where abs(total_a - total_b) > (total_b * {{ pct }} / 100.0)
{% endtest %}
