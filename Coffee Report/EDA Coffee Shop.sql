-- EDA coffee shop Business

-- HR analysis

-- Total hiring employee over time 
SELECT 
	EXTRACT(YEAR FROM hire_date) AS Hired_Year,
	COUNT(employee_id) AS total_employees
FROM employees
GROUP BY 
	Hired_Year
ORDER BY 
	Hired_Year ASC; -- hired start from 2010-2023. 2019 has the highest hired, meanwhile 2023 has the lowest

-- Hired trend
WITH hired_year AS (
    SELECT 
        EXTRACT(YEAR FROM hire_date) AS hired_years,
        COUNT(employee_id) AS hired_total
    FROM 
        employees
    GROUP BY 
        hired_years
)
SELECT 
    hired_years,
    hired_total,
    hired_total - LAG(hired_total) OVER (ORDER BY hired_years) AS YoY_Growth,
    ROUND((hired_total - LAG(hired_total) OVER (ORDER BY hired_years)) * 100.0 
        / NULLIF(LAG(hired_total) OVER (ORDER BY hired_years), 0), 2) AS YoY_Growth_Percent
FROM hired_year; -- hired employees growth 


--  Employee distribution (gender)
SELECT 
	gender,
	count(employee_id) AS total_employees,
	ROUND(AVG(salary)::NUMERIC, 2) AS Averge_Salary
FROM employees
GROUP BY
	gender;
	
-- Employee  Distribution (City) 
SELECT 
	l.city, 
	COUNT(employee_id) AS Total_Employees,
	ROUND(AVG(salary)::NUMERIC,  2) AS Average_salary
FROM 
	employees AS e
LEFT JOIN 
	shops AS s
USING 
	(coffeeshop_id)
LEFT JOIN 
	locations AS l
ON s.city_id = l.city_id
GROUP  BY 
	l.city
ORDER BY 
	Total_Employees DESC; -- Los Angles has the highest employee. london has the lowest employee, but has the highest average salary

-- Top 3 paid employee per city
WITH salary_rank AS (
	SELECT 
		e.employee_id,
		e.first_name,
		e.last_name,
		e.salary,
		l.city,
		RANK() OVER (PARTITION BY l.city ORDER BY e.salary DESC) AS ranks
	FROM 
		employees AS e
	LEFT JOIN 
		shops AS s
	USING 
		(coffeeshop_ID)
	LEFT JOIN 
		locations AS l 
	ON s.city_id = l.city_id
)
SELECT *
FROM
	salary_rank
WHERE ranks <= 3; -- TOP 3 paid employee for each city


-- Gender distribution (country)
SELECT 
    l.city,
    COUNT(CASE WHEN e.gender = 'M' THEN 1 END) AS male_count,
    COUNT(CASE WHEN e.gender = 'F' THEN 1 END) AS female_count,
    COUNT(*) AS total_employees
FROM 
	employees AS e
LEFT JOIN 
	shops AS s 
USING
	(coffeeshop_id)
LEFT JOIN 
	locations AS l 
ON s.city_id = l.city_id
GROUP BY 
	l.city
ORDER BY 
	total_employees DESC; -- female > male. los angles has the most male and female employees

----------------------

-- Shop and Location analysis

-- Total shops per region
SELECT 
	l.city, 
	COUNT(s.coffeeshop_name) Total_shops
FROM 
	shops AS s
LEFT JOIN 
	locations AS l
USING
	(city_id)
GROUP BY
	l.city; -- los angles and new york have 2 coffeeshop, meanwhile london has only 1

-- Coffee Types supply
SELECT 
	s.coffeeshop_name, 
	COUNT(coffee_type) AS Total_Types
FROM shops AS s
LEFT JOIN suppliers AS sp
USING (coffeeshop_id)
GROUP BY 
	s.coffeeshop_name; -- Ancient bean (London) has 4 coffee_types (needs more skill and salary), meanwhile Urband Grind (los angles) only has 2


-- Suppliers Count
SELECT 
	s.coffeeshop_name,
	l.city, 
	COUNT(supplier_name) Total_supplier
FROM 
	shops AS s
LEFT JOIN 
	locations AS l
USING
	(city_id)
LEFT JOIN 
	suppliers AS sp
ON s.coffeeshop_id = sp.coffeeshop_id
GROUP BY
	l.city, s.coffeeshop_name
ORDER BY
	Total_supplier DESC; -- Ancient Bean (london) has the most supplier, meanwhile common Ground (los angeles) has the lowest