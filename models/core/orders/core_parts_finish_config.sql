{{config(
    materialized='view',
    alias='parts_finish_config',
    schema='core_orders'
)}}

WITH
parts_finish_config AS (
    SELECT *
    FROM {{source('orders_source', 'parts_surface_finish_config')}}
),
unique_parts AS (
    SELECT DISTINCT
        order_part_id
    FROM parts_finish_config
),
surface_finishes AS (
    SELECT 
        order_part_id,
        JSON_EXTRACT_SCALAR(process_config, '$.value') AS surface_finish
    FROM parts_finish_config
    WHERE process_name = 'SURFACE_FINISH'
),
secondary_surface_finishes AS (
    SELECT 
        order_part_id,
        JSON_EXTRACT_SCALAR(process_config, '$.value') AS secondary_surface_finish
    FROM parts_finish_config
    WHERE process_name = 'SECONDARY_SURFACE_FINISH'
),
ral_finishes AS (
    SELECT 
        order_part_id,
        JSON_EXTRACT_SCALAR(process_config, '$.ralCode') AS ral_finish_code,
        JSON_EXTRACT_SCALAR(process_config, '$.ralFinish') AS ral_finish_type,
    FROM parts_finish_config
    WHERE process_name = 'SECONDARY_SURFACE_FINISH_RAL'
)

SELECT 
    order_part_id,
    surface_finish,
    secondary_surface_finish,
    ral_finish_code,
    ral_finish_type
FROM unique_parts
LEFT JOIN surface_finishes
USING (order_part_id)
LEFT JOIN secondary_surface_finishes
USING (order_part_id)
LEFT JOIN ral_finishes
USING (order_part_id)
