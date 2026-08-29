{% macro build_dq_sql() %}
    {%- set rules_query -%}
    select rule_id, model_name, column_name, rule_type, rule_expression, threshold_pct, severity
    from {{ ref('dq_rules') }}
    {%- endset -%}

    {%- set rules = [] -%}
    {%- if execute -%} {%- set rules = run_query(rules_query).rows -%} {%- endif -%}

    {% for r in rules %}
        {%- set rule_id = r[0] -%}
        {%- set model_name = r[1] -%}
        {%- set column_name = r[2] -%}
        {%- set rule_type = r[3] -%}
        {%- set rule_expression = r[4] -%}
        {%- set threshold_pct = r[5] -%}
        {%- set severity = r[6] -%}

        {%- if rule_type == "not_null" -%}
            {%- set failed_condition = column_name ~ " is null" -%}
        {%- elif rule_type == "in_range" -%}
            {%- set bounds = rule_expression.split(":") -%}
            {%- set failed_condition = (
                column_name
                ~ " not between "
                ~ bounds[0]
                ~ " and "
                ~ bounds[1]
            ) -%}
        {%- elif rule_type == "not_orphaned" -%}
            {%- set ref_parts = rule_expression.split(".") -%}
            {%- set ref_model = ref_parts[0] -%}
            {%- set ref_column = ref_parts[1] -%}
            {%- set failed_condition = (
                column_name
                ~ " not in (select "
                ~ ref_column
                ~ " from "
                ~ ref(ref_model)
                ~ ")"
            ) -%}
        {%- else -%} {%- set failed_condition = "1 = 0" -%}
        {%- endif -%}

        select
            '{{ rule_id }}' as rule_id,
            '{{ model_name }}' as model_name,
            '{{ severity }}' as severity,
            {{ threshold_pct }} as threshold_pct,
            (
                select count(*) from {{ ref(model_name) }} where {{ failed_condition }}
            ) as failed_rows,
            (select count(*) from {{ ref(model_name) }}) as total_rows,
            current_timestamp() as checked_at,
            '{{ invocation_id }}' as dbt_invocation_id
        {% if not loop.last %}
            union all
        {% endif %}
    {% endfor %}
{% endmacro %}
