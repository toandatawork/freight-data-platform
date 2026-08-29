{% macro dq_severity_gate() %}
    -- depends_on: {{ ref('dq_rule_results') }}
    {% if execute %}
        {%- set check_query -%}
      select count(*) as n
      from {{ ref('dq_rule_results') }}
      where severity = 'error' and not is_passed
        and dbt_invocation_id = '{{ invocation_id }}'
        {%- endset -%}

        {%- set results = run_query(check_query) -%}
        {%- set failed_count = results.columns[0].values()[0] if results else 0 -%}

        {% if failed_count > 0 %}
            {{
                exceptions.raise_compiler_error(
                    "DQ severity gate failed: "
                    ~ failed_count
                    ~ " error-severity rule(s) failed in this run (invocation_id="
                    ~ invocation_id
                    ~ ")."
                )
            }}
        {% endif %}
    {% endif %}
    select 1
{% endmacro %}
