{{config(
    materialized='table',
    alias='orders_markup',
    schema='report_orders',
    partition_by={
      "field": "report_date",
      "data_type": "date",
      "granularity": "month"
    },
    cluster_by=['customer_id', 'manufacturer_id']
)}}


WITH 
orders AS (
    SELECT *
    FROM {{ref('core_orders_extended')}}
    WHERE in_production_at IS NOT NULL
    AND status IN ('SHIPPED', 'COMPLETED', 'IN_PRODUCTION')
    AND NOT is_cancelled
)

SELECT 
    DATE(in_production_at) AS report_date,
    customer_id,
    manufacturer_id,
    account_manager_country,
    laser_parts_count > 0 AS has_laser_parts,
    cnc_parts_count > 0 AS has_cnc_parts,
    bended_parts_count > 0 AS has_bending_parts,
    surface_coated_parts_count > 0 AS has_surface_coating,
    insert_operations_parts_count > 0 AS has_insert_operations,
    SUM(markup) AS total_markup,
    SUM(total_parts_count) AS total_parts,
    COUNT(*) AS total_orders
FROM orders
GROUP BY 1,2,3,4,5,6,7,8,9