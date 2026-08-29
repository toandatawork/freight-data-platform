{% test not_orphaned(model, column_name, to, field, threshold_pct=0) %}
    with
        orphans as (
            select {{ column_name }} as key_value
            from {{ model }}
            where
                {{ column_name }} is not null
                and {{ column_name }} not in (select {{ field }} from {{ to }})
        ),
        counts as (
            select
                (select count(*) from orphans) as orphan_count,
                (select count(*) from {{ model }}) as total_count
        )
    select o.*
    from orphans o
    cross join counts c
    where c.orphan_count > c.total_count * {{ threshold_pct }} / 100.0
{% endtest %}
