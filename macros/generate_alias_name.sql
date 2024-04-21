{%- macro generate_alias_name(custom_alias_name=none, node=none) -%}

    {%- set single_schema = var('single_schema_name', none) -%}

    {%- if custom_alias_name -%}

        {%- set result_alias -%}
            {{ custom_alias_name | trim }}
        {%- endset -%}

    {%- else -%}

        {%- set result_alias -%}
            {{ node.name }}
        {%- endset -%}

    {%- endif -%}

    {%- if single_schema -%}

        {%- set result_alias -%}
            {{ target.name }}_{{ node.config.schema }}_{{ result_alias }}
        {%- endset -%}

    {%- endif -%}

    {{result_alias | trim}}

{%- endmacro -%}
