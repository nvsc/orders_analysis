{%- macro generate_schema_name(custom_schema_name, node) -%}

    {%- set single_schema = var('single_schema_name', none) -%}
    
    {%- if single_schema -%}

        {%- set result_schema -%}
            {{ single_schema }}
        {%- endset -%}

    {%- elif custom_schema_name is none -%}

        {%- set result_schema -%}
            {{ target.schema }}
        {%- endset -%}

    {%- elif target.name == "prod" -%}

        {%- set result_schema -%}
            {{ custom_schema_name | trim }}
        {%- endset -%}

    {%- else -%}

        {%- set result_schema -%}
            {{ target.schema }}_{{ custom_schema_name | trim }}
        {%- endset -%}

    {%- endif -%}

    {{result_schema | trim}}

{%- endmacro -%}