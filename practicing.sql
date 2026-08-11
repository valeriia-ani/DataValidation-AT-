SELECT 
	employee_id,
	full_name,
	salary
FROM employees
WHERE salary >
(
	SELECT avg (salary) FROM employees
);

SELECT employee_id,
       full_name,
       salary
FROM employees
WHERE salary < (
    SELECT AVG(salary)
    FROM employees);

SELECT product_id,
       product_name,
       price
FROM products
WHERE price < (
    SELECT AVG(price)
    FROM products
);

-- Найти самый дорогой товар.

SELECT product_id,
       product_name,
       price
FROM products
WHERE price = (
    SELECT MAX(price)
    FROM products
);

-- Найти самый дешевый товар.
SELECT product_id,
       product_name,
       price
FROM products
WHERE price = (
    SELECT MIN(price)
    FROM products
);

-- Найти все заказы клиента с максимальным customer_id.

SELECT *
FROM orders
WHERE customer_id = (
    SELECT MAX(customer_id)
    FROM orders
);
-- Показать самую большую зарплату рядом с каждым сотрудником.
SELECT employee_id,
       full_name,
       salary,
       MAX(salary) OVER() AS max_salary
FROM employees;

-- Вывести количество сотрудников рядом с каждой строкой.
SELECT employee_id,
       full_name,
       salary,
       COUNT(*) OVER() AS total_employees
FROM employees;

-- Показать рейтинг сотрудников по зарплате через RANK().
SELECT employee_id,
       full_name,
       salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

-- Топ-3 клиента по сумме покупок в каждом городе
WITH client_totals AS (
    SELECT
        c.city,
        c.customer_id,
        c.customer_name,
        COUNT(DISTINCT o.order_id) AS orders_count,
        SUM(oi.quantity * oi.unit_price) AS total_amount
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.status IN ('Оплачен', 'Доставлен')
    GROUP BY
        c.city,
        c.customer_id,
        c.customer_name
),
ranked_clients AS (
    SELECT
        city,
        customer_id,
        customer_name,
        orders_count,
        total_amount,
        DENSE_RANK() OVER (
            PARTITION BY city
            ORDER BY total_amount DESC
        ) AS client_rank
    FROM client_totals
)
SELECT
    city,
    customer_id,
    customer_name,
    orders_count,
    total_amount,
    client_rank
FROM ranked_clients
WHERE client_rank <= 3
ORDER BY
    city,
    client_rank,
    customer_id;