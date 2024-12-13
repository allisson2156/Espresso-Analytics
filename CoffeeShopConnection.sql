

DESCRIBE coffee_shop_sales;

-- Adicionar uma nova coluna do tipo DATETIME para armazenar a data e hora combinadas
ALTER TABLE coffee_shop_sales ADD COLUMN transaction_datetime DATETIME;

-- Atualizar a nova coluna combinando os valores das colunas transaction_date e transaction_time
UPDATE coffee_shop_sales
SET transaction_datetime = STR_TO_DATE(
    CONCAT(transaction_date, ' ', transaction_time), -- Combina data e hora em um único formato string
    '%Y-%m-%d %H:%i:%s' -- Define o formato esperado para converter a string em DATETIME
);

-- MUDA O NOME DA COLUNA `ï»¿transaction_id` para 'transaction_id'
ALTER TABLE coffee_shop_sales
CHANGE COLUMN `ï»¿transaction_id` transaction_id INT;

-- TOTAL DE VENDAS
SELECT ROUND(SUM(unit_price * transaction_qty)) as Total_Sales 
FROM coffee_shop_sales 
WHERE MONTH(transaction_datetime) = 5; -- Para o mês de Maio 

-- TOTAL DE PEDIDOS 
SELECT COUNT(﻿transaction_id) as Total_Orders
FROM coffee_shop_sales 
WHERE MONTH (transaction_datetime)= 5; -- Para o mês de Maio 

-- KPI DE VENDAS TOTAIS - DIFERENÇA MêS A MÊS E CRESCIMENTO MÊS A MÊS 
SELECT 
    MONTH(transaction_datetime) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_datetime))) / LAG(SUM(unit_price * transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_datetime)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_datetime) IN (4, 5) -- Para os mês de Abril e Maio 
GROUP BY 
    MONTH(transaction_datetime)
ORDER BY 
    MONTH(transaction_datetime);

-- KPI DE PEDIDOS TOTAIS - DIFERENÇA MÊS A MÊS E CRESCIMENTO MÊS A MÊS
SELECT 
    MONTH(transaction_datetime) AS month,
    ROUND(COUNT('﻿transaction_id')) AS total_orders,
    (COUNT('﻿transaction_id') - LAG(COUNT('﻿transaction_id'), 1) 
    OVER (ORDER BY MONTH(transaction_datetime))) / LAG(COUNT('﻿transaction_id'), 1) 
    OVER (ORDER BY MONTH(transaction_datetime)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_datetime) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_datetime)
ORDER BY 
    MONTH(transaction_datetime);

-- QUANTIDADE TOTAL VENDIDA 
SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM coffee_shop_sales 
WHERE MONTH(transaction_datetime) = 5; -- Para o mês de Maio 

-- KPI DE QUANTIDADE TOTAL VENDIDA - DIFERENÇA MÊS A MÊS E CRESCIMENTO MÊS A MÊS 
SELECT 
    MONTH(transaction_datetime) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_datetime))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_datetime)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_datetime) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_datetime)
ORDER BY 
    MONTH(transaction_datetime);

-- TABELA DE CALENDÁRIO – VENDAS DIÁRIAS, QUANTIDADE E TOTAL DE PEDIDOS
SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT('transaction_id') AS total_orders
FROM 
    coffee_shop_sales
WHERE 
    DATE(transaction_datetime) = '2023-05-18'; -- Para todas as transações do dia 18 de maio de 2023

-- TENDÊNCIA DE VENDAS AO LONGO DO PERÍODO
SELECT AVG(total_sales) AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_datetime) = 5  -- Filtra para maio
    GROUP BY 
        transaction_datetime
) AS internal_query;

-- VENDAS DIÁRIAS PARA O MÊS SELECIONADO
SELECT 
    DAY(transaction_datetime) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_datetime) = 5  -- Filtra para maio
GROUP BY 
    DAY(transaction_datetime)
ORDER BY 
    DAY(transaction_datetime);

-- COMPARANDO VENDAS DIÁRIAS COM A MÉDIA
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_datetime) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_datetime) = 5  -- Filtra para maio
    GROUP BY 
        DAY(transaction_datetime)
) AS sales_data
ORDER BY 
    day_of_month;

-- VENDAS POR DIA DA SEMANA / FIM DE SEMANA
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_datetime) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_datetime) = 5  -- Filtra para maio
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_datetime) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;

-- VENDAS POR LOCALIZAÇÃO DA LOJA
SELECT 
    store_location,
    SUM(unit_price * transaction_qty) as Total_Sales
FROM coffee_shop_sales
WHERE
    MONTH(transaction_datetime) = 5 
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC;

-- VENDAS POR CATEGORIA DE PRODUTO
SELECT 
    product_category,
    ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
    MONTH(transaction_datetime) = 5 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;

-- VENDAS POR PRODUTOS (TOP 10)
SELECT 
    product_type,
    ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM coffee_shop_sales
WHERE
    MONTH(transaction_datetime) = 5 
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;

-- VENDAS POR DIA | HORA
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffee_shop_sales
WHERE 
    DAYOFWEEK(transaction_datetime) = 3 -- Filtra para terça-feira (1 é domingo, 2 é segunda-feira, ..., 7 é sábado)
    AND HOUR(transaction_datetime) = 8 -- Filtra para a hora número 8
    AND MONTH(transaction_datetime) = 5; -- Filtra para maio

-- OBTER VENDAS DE SEGUNDA A DOMINGO PARA O MÊS DE MAIO
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_datetime) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_datetime) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_datetime) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_datetime) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_datetime) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_datetime) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_datetime) = 5 -- Filtra para maio
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_datetime) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_datetime) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_datetime) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_datetime) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_datetime) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_datetime) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;

-- OBTER VENDAS PARA TODAS AS HORAS DO MÊS DE MAIO
SELECT 
    HOUR(transaction_datetime) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_datetime) = 5 -- Filtra para maio
GROUP BY 
    HOUR(transaction_datetime)
ORDER BY 
    HOUR(transaction_datetime);

