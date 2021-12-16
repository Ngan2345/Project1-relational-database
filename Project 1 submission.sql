-- 1. Question 1 (Slide 1)
-- Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.

SELECT 
    category_name, 
    SUM(count)
FROM (
    SELECT 
        film_title, 
        category_name, 
        count(*)
    FROM (
        SELECT 
            f.title AS film_title, 
            c.name AS category_name
        FROM 
            category c
            JOIN film_category fc ON c.category_id = fc.category_id
            JOIN film f ON f.film_id = fc.film_id
            JOIN inventory i ON f.film_id = i.film_id
            JOIN rental r ON i.inventory_id = r.inventory_id) t1
    GROUP BY 1,2) t2
GROUP BY 1
ORDER BY 2 DESC;

-- 2.1. Question 2.1 (This is only for reference, No Slide)
/* Provide a table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) 
based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories? 
Make sure to also indicate the category that these family-friendly movies fall into.*/

SELECT 
    film_title, 
    category_name,  
    rental_duration, 
    standard_quartile
FROM (
    SELECT 
        f.title AS film_title, 
        c.name AS category_name, 
        f.rental_duration AS rental_duration,
        NTILE (4) OVER (ORDER BY rental_duration) AS standard_quartile
    FROM category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f ON f.film_id = fc.film_id
    ORDER BY 4) t1
WHERE category_name IN ('Comedy', 'Children', 'Music', 'Family', 'Animation');
  
--2.2. Question 2.2 (Slide 2)
-- The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
/*Provide a table with the family-friendly film categories, each of the quartiles, and the corresponding count of movies within each combination of film category for each corresponding rental duration category. 
The resulting SQL table should have three columns:
"Category
Rental length category (quartile 1,2,3,4 with 1 being the shortest and 4 being the longest time)
Count"
Note: In addition, this query will also calculate the running_total of each category count.*/

SELECT 
    category_name, 
    standard_quartile, 
    count, 
    SUM (count) OVER (PARTITION BY category_name) AS running_total
FROM (
    SELECT 
        category_name, 
        standard_quartile, 
        COUNT(*)
    FROM (
        SELECT 
            film_title, 
            category_name,  
            rental_duration, 
            standard_quartile
        FROM (
            SELECT 
                f.title AS film_title, 
                c.name AS category_name, 
                f.rental_duration AS rental_duration,
                NTILE (4) OVER (ORDER BY rental_duration) AS standard_quartile
            FROM category c
                JOIN film_category fc ON c.category_id = fc.category_id
                JOIN film f ON f.film_id = fc.film_id) t1
        WHERE category_name IN ('Comedy', 'Children', 'Music', 'Family', 'Animation')) t2
    GROUP BY 1,2) t3
ORDER BY 1, 2;
 
-- 3. Question 3 (Slide 3)
/*Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. 
Your SQL table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.*/

SELECT 
    DATE_PART('month', r.rental_date) rental_month, 
    DATE_PART('year', r.rental_date) rental_year,  
    s.store_id, 
    COUNT(r.rental_id) AS count_of_rental
FROM rental r
JOIN staff st ON r.staff_id = st.staff_id
JOIN store s ON s.store_id = st.store_id
GROUP BY 1,2,3
ORDER BY 2,1;

--4. Question 4 (Slide 4)
/* Write a query to capture the customer name, month and year of payment, 
and total payment amount for each month by these top 10 paying customers.*/

SELECT 
    DATE_TRUNC('month', p.payment_date) AS paymonth, 
    CONCAT(c.first_name,' ', c.last_name) AS full_name, 
    COUNT(p.payment_id) AS pay_count_per_month, 
    SUM(p.amount) AS pay_amount_per_month
FROM (
    SELECT 
        c.customer_id customer_id, 
        SUM(p.amount) as total_payment
    FROM payment p
    JOIN customer c ON p.customer_id = c.customer_id
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 10)t1
JOIN customer c ON t1.customer_id = c.customer_id
JOIN payment p ON p.customer_id = c.customer_id
GROUP BY 1,2
ORDER BY 2;

-- The end of Project 1