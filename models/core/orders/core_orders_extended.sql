{{config(
    materialized='view',
    alias='orders_extended',
    schema='core_orders'
)}}


WITH 
orders AS (
    SELECT * REPLACE (
        CAST(markup AS NUMERIC) AS markup,
        -- Fix zero customer price with non-zero markup
        CAST(manufacturer_price AS NUMERIC) + CAST(markup AS NUMERIC) AS customer_price,
        CAST(manufacturer_price AS NUMERIC) AS manufacturer_price,
        CAST(shipping_price AS NUMERIC) AS shipping_price
    )
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
