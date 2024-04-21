{{config(
    materialized='view',
    alias='orders_parts_info',
    schema='core_orders'
)}}


WITH 
orders AS (
    SELECT DISTINCT order_id
    FROM {{source('orders_source', 'orders')}}
),
parts AS (
    SELECT *
    FROM {{ref('core_orders_parts_extended')}}
),
parts_count AS (
    SELECT 
        order_id,
        COUNT(DISTINCT order_part_id) AS total_parts_count,
        COUNT(DISTINCT IF(selected_process_type = 'cnc_machining', order_part_id, NULL)) AS cnc_parts_count,
        COUNT(DISTINCT IF(selected_process_type IN ('laser_cutting', 'laser_tube_cutting'), order_part_id, NULL)) AS laser_parts_count,
        COUNT(DISTINCT IF(has_bending = 1, order_part_id, NULL)) AS bended_parts_count,
        SUM(IF(has_bending = 1, bends_count, 0)) AS total_bends_count,
        COUNT(DISTINCT IF(has_surface_coating, order_part_id, NULL)) AS surface_coated_parts_count,
        COUNT(DISTINCT IF(has_insert_operations, order_part_id, NULL)) AS insert_operations_parts_count
    FROM parts
    GROUP BY 1
),
unique_ral_finishes AS (
    SELECT 
        order_id,
        ARRAY_TO_STRING(ARRAY_AGG(DISTINCT ral_finish_code), ',') AS unique_ral_codes,
        ARRAY_TO_STRING(ARRAY_AGG(DISTINCT ral_finish_type), ',') AS unique_ral_finishes
    FROM parts
    WHERE ral_finish_code IS NOT NULL
    GROUP BY 1
),
unique_surface_finishes AS (
    SELECT 
        order_id,
        ARRAY_TO_STRING(ARRAY_AGG(DISTINCT surface_finish), ',') AS unique_surface_finishes,
    FROM parts
    WHERE surface_finish IS NOT NULL
    GROUP BY 1
),
unique_secondary_surface_finishes AS (
    SELECT 
        order_id,
        ARRAY_TO_STRING(ARRAY_AGG(DISTINCT secondary_surface_finish), ',') AS unique_secondary_surface_finishes,
    FROM parts
    WHERE secondary_surface_finish IS NOT NULL
    GROUP BY 1
)

SELECT *
FROM orders
LEFT JOIN parts_count
USING (order_id)
LEFT JOIN unique_ral_finishes
USING (order_id)
LEFT JOIN unique_surface_finishes
USING (order_id)
LEFT JOIN unique_secondary_surface_finishes
USING (order_id)

