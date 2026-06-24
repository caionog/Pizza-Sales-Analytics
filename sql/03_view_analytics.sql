-- ============================================================
-- 03_view_analytics.sql
-- View de analytics — fonte do Power BI via Direct Query
--
-- Responsabilidade: expor os dados de pizza_sales com dimensões
-- de tempo pré-calculadas, evitando colunas calculadas no Power BI.
--
-- Execute após: 02_etl_integridade.sql
-- ============================================================

CREATE OR ALTER VIEW vw_pizza_sales_analytics AS
SELECT
    -- Chaves e identificadores
    pizza_id,
    order_id,
    pizza_name_id,

    -- Produto
    pizza_name,
    pizza_category,
    pizza_size,
    pizza_ingredients,

    -- Métricas
    quantity,
    unit_price,
    total_price,

    -- Data e hora originais
    order_date,
    order_time,

    -- Dimensões de tempo derivadas
    DATENAME(WEEKDAY, order_date)         AS day_name,
    DATEPART(WEEKDAY, order_date)         AS day_number,
    DATENAME(MONTH,   order_date)         AS month_name,
    MONTH(order_date)                     AS month_number,
    DATEPART(QUARTER, order_date)         AS quarter_number,
    YEAR(order_date)                      AS year_number

FROM pizza_sales;
GO


-- Verificação
SELECT TOP 10 *
FROM vw_pizza_sales_analytics
ORDER BY order_date, order_time;