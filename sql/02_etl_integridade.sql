-- ============================================================
-- 02_etl_integridade.sql
-- Verificação de integridade e modelagem da tabela pizza_sales
--
-- Responsabilidade: garantir que os dados inseridos pelo script
-- Python estão corretos e que a tabela está bem definida para
-- servir como fonte confiável para análise.
--
-- Execute após: 01_ingestao.py
-- ============================================================


-- ------------------------------------------------------------
-- PASSO 1 — CRIAR A TABELA (caso ainda não exista)
-- Execute antes do script Python na primeira carga
-- ------------------------------------------------------------

IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'pizza_sales'
)
BEGIN
    CREATE TABLE pizza_sales (
        pizza_id            INT             NOT NULL PRIMARY KEY,
        order_id            INT             NOT NULL,
        pizza_name_id       VARCHAR(50)     NOT NULL,
        quantity            INT             NOT NULL,
        order_date          DATE            NOT NULL,
        order_time          TIME            NOT NULL,
        unit_price          DECIMAL(10, 2)  NOT NULL,
        total_price         DECIMAL(10, 2)  NOT NULL,
        pizza_size          VARCHAR(5)      NOT NULL,
        pizza_category      VARCHAR(50)     NOT NULL,
        pizza_ingredients   VARCHAR(500)    NOT NULL,
        pizza_name          VARCHAR(100)    NOT NULL
    );

    PRINT 'Tabela pizza_sales criada.';
END
ELSE
BEGIN
    PRINT 'Tabela pizza_sales já existe — pulando criação.';
END
GO


-- ------------------------------------------------------------
-- PASSO 2 — VERIFICAÇÕES DE INTEGRIDADE PÓS-INSERÇÃO
-- ------------------------------------------------------------

-- 2.1 Contar registros inseridos (esperado: 48.620)
SELECT COUNT(*) AS total_registros FROM pizza_sales;

-- 2.2 Verificar nulos em colunas críticas
SELECT
    SUM(CASE WHEN order_date   IS NULL THEN 1 ELSE 0 END) AS nulos_order_date,
    SUM(CASE WHEN unit_price   IS NULL THEN 1 ELSE 0 END) AS nulos_unit_price,
    SUM(CASE WHEN total_price  IS NULL THEN 1 ELSE 0 END) AS nulos_total_price,
    SUM(CASE WHEN pizza_name   IS NULL THEN 1 ELSE 0 END) AS nulos_pizza_name
FROM pizza_sales;

-- 2.3 Verificar consistência de total_price = unit_price * quantity
SELECT COUNT(*) AS registros_inconsistentes
FROM pizza_sales
WHERE total_price <> ROUND(unit_price * quantity, 2);

-- 2.4 Verificar range de datas (esperado: 2015-01-01 a 2015-12-31)
SELECT
    MIN(order_date) AS data_minima,
    MAX(order_date) AS data_maxima
FROM pizza_sales;

-- 2.5 Verificar valores únicos de pizza_size e pizza_category
SELECT DISTINCT pizza_size     FROM pizza_sales ORDER BY pizza_size;
SELECT DISTINCT pizza_category FROM pizza_sales ORDER BY pizza_category;