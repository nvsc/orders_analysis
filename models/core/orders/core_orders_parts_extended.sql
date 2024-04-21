{{config(
    materialized='view',
    alias='parts_extended',
    schema='core_orders'
)}}

WITH 
parts AS (
    SELECT *
    FROM {{source('orders_source', 'parts')}}
),
parts_finish_config AS (
    SELECT *
    FROM {{ref('core_parts_finish_config')}}
)

SELECT *
FROM parts
LEFT JOIN parts_finish_config
USING (order_part_id)