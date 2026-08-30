{% macro log_run_results(results) %}
    {% if execute %}
        {% for result in results %}
            {% do log(
                "invocation_id="
                ~ invocation_id
                ~ " node="
                ~ result.node.name
                ~ " status="
                ~ result.status
                ~ " execution_time="
                ~ result.execution_time,
                info=true,
            ) %}
        {% endfor %}
    {% endif %}
{% endmacro %}
