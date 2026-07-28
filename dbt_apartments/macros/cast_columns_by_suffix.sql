{% macro cast_columns_by_suffix(relation) %}

    {% set cols = adapter.get_columns_in_relation(relation) %}

    {% set select_cols = [] %}

    {% for col in cols %}

        {% if col.name.endswith('_label') %}
            {% do select_cols.append(
                'CAST(' ~ col.name ~ ' AS STRING) AS ' ~ col.name
            ) %}

        {% elif col.name.endswith('_key') %}
            {% do select_cols.append(
                'CASE WHEN ' ~ col.name ~ ' = 1 THEN TRUE ELSE FALSE END AS ' ~ col.name
            ) %}

        {% else %}
            {% do select_cols.append(col.name) %}
        {% endif %}

    {% endfor %}

    {{ return(select_cols | join(',\n')) }}

{% endmacro %}