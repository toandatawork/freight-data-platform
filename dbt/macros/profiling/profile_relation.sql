{% macro profile_relation(source_name, table_name) %}
    {%- set cols_query%}
        select column_name, data_type
        from {{ target.catalog }}.information_schema.columns
        where table_schema = 'bronze' and table_name = '{{ table_name }}'
        order by ordinal_position
    {%- endset %}

    {%- set results = [] -%}
    {# Skip during parsing; run only during execution to prevent compiler errors #}
    {%- if execute -%}
        {%- set results = run_query(cols_query).rows %}
    {%- endif -%}

  {% for col in results %}
  select
      '{{ table_name }}'             as table_name,
      '{{ col[0] }}'                 as column_name,
      '{{ col[1] }}'                 as data_type,
      count(*)                       as row_count,
      count({{ col[0] }})            as non_null_count,
      count(*) - count({{ col[0] }}) as null_count,
      round(100.0 * (count(*) - count({{ col[0] }})) / nullif(count(*), 0), 2) as null_pct,
      count(distinct {{ col[0] }})   as distinct_count,
      cast(min(cast({{ col[0] }} as string)) as string) as min_value,
      cast(max(cast({{ col[0] }} as string)) as string) as max_value,
      current_timestamp()            as profiled_at
  from {{ source(source_name, table_name) }}
  {% if not loop.last %}union all{% endif %}
  {% endfor %}

{% endmacro %}