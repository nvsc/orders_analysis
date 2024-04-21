{{config(
    materialized='view',
    alias='orders_extended',
    schema='core_orders'
)}}


WITH 
orders AS (
    SELECT *
    FROM {{source('orders_source', 'orders')}}
),
orders_parts AS (
    SELECT *
    FROM {{ref('core_orders_parts_info')}}
)

SELECT *
FROM orders
LEFT JOIN orders_parts
USING (order_id)
