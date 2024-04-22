WITH 
orders AS (
    SELECT * REPLACE (
            CAST(markup AS NUMERIC) AS markup,
            -- Fix zero customer price with non-zero markup
            CAST(manufacturer_price AS NUMERIC) + CAST(markup AS NUMERIC) AS customer_price,
            CAST(manufacturer_price AS NUMERIC) AS manufacturer_price,
            CAST(shipping_price AS NUMERIC) AS shipping_price
        ),
        DATE_TRUNC(DATE(in_production_at), MONTH) AS report_month
    FROM {{source('orders_upload', 'orders_ext')}}
    WHERE in_production_at IS NOT NULL
    AND status IN ('SHIPPED', 'COMPLETED', 'IN_PRODUCTION')
    AND NOT is_cancelled
),
revenue_per_month AS (
    SELECT 
        report_month,
        SUM(IF(laser_parts_count > 0, markup, 0)) AS revenue_laser,
        SUM(IF(cnc_parts_count > 0, markup, 0)) AS revenue_cnc,
        SUM(IF(laser_parts_count > 0, 1, 0)) AS orders_laser,
        SUM(IF(cnc_parts_count > 0, 1, 0)) AS orders_cnc,        
    FROM orders
    GROUP BY 1
),
revenue_per_country AS (
    SELECT *
    FROM (
        SELECT 
            report_month,
            account_manager_country,
            IF(laser_parts_count > 0, markup, 0) AS revenue_laser,
            IF(cnc_parts_count > 0, markup, 0) AS revenue_cnc,
        FROM orders 
    ) PIVOT (
        SUM(revenue_laser) AS revenue_laser,
        SUM(revenue_cnc) AS revenue_cnc
        FOR account_manager_country IN ('EE', 'GB')
    )
),
median_customer_prices AS (
    SELECT 
        report_month,
        production_type,
        customer_price,
        ROW_NUMBER() OVER (PARTITION BY report_month, production_type ORDER BY customer_price) AS idx,
        COUNT(*) OVER (PARTITION BY report_month, production_type) AS total_count
    FROM (
        SELECT 
            report_month,
            'LASER' AS production_type,
            customer_price,
        FROM orders
        WHERE laser_parts_count > 0
        UNION ALL
        SELECT 
            report_month,
            'CNC' AS production_type,
            customer_price
        FROM orders
        WHERE cnc_parts_count > 0
    )
    QUALIFY idx BETWEEN FLOOR(total_count / 2) AND CEIL(total_count / 2)
),
median_customer_prices_stat AS (
    SELECT 
        report_month,
        AVG(IF(production_type = 'LASER', customer_price, NULL)) AS median_price_laser,
        AVG(IF(production_type = 'CNC', customer_price, NULL)) AS median_price_cnc
    FROM median_customer_prices
    GROUP BY 1
),
secondary_surface_finish_stat AS (
    SELECT 
        report_month,
        COUNT(*) AS orders_secondary_surface_finish
    FROM orders
    WHERE secondary_surface_finish IS NOT NULL
    GROUP BY 1
)

SELECT * 
FROM revenue_per_month
LEFT JOIN median_customer_prices_stat
USING (report_month)
LEFT JOIN revenue_per_country
USING (report_month)
LEFT JOIN secondary_surface_finish_stat
USING (report_month)
WHERE report_month >= '2024-01-01'