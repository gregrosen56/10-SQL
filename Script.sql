USE sakila
;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name
	  ,last_name
FROM actor
;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT upper(concat(first_name, " ", last_name)) AS 'Actor Name'
FROM actor
;
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id
	  ,first_name
      ,last_name
FROM actor
WHERE first_name = 'Joe'
;
-- 2b. Find all actors whose last name contain the letters GEN:
SELECT *
FROM actor
WHERE last_name LIKE '%GEN%'
;
-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name
		,first_name
;
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id
      ,country
FROM country
WHERE country IN ('Afghanistan','Bangladesh','China')
;
-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name varchar(45)
;
SELECT first_name
	  ,middle_name
      ,last_name
FROM actor
;
-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
CHANGE middle_name middle_name BLOB
;
-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP COLUMN middle_name
;
-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name
      ,count(actor_id) AS count
FROM actor
GROUP BY last_name
;
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name
      ,count(actor_id) AS count
FROM actor
GROUP BY last_name
HAVING count >= 2
;
-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor 
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
	AND
      last_name = 'WILLIAMS'
;
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.) 
UPDATE actor 
	SET first_name = CASE WHEN first_name = 'HARPO' 
						THEN 'GROUCHO'
						ELSE 'MUCHO GROUCHO'
                        END
WHERE actor_id = 172
;
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE ADDRESS
;
CREATE TABLE `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
;
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name
	  ,s.last_name
      ,a.address
FROM staff AS s
	JOIN
     address AS a
	ON
     s.address_id = a.address_id
;
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name
      ,s.last_name
      ,sum(p.amount) AS total
FROM staff AS s
	JOIN
     payment AS p
	ON
	 s.staff_id = p.staff_id
WHERE p.payment_date LIKE '2005-08%'
GROUP BY s.first_name
		,s.last_name
;
-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title
      ,count(a.actor_id) AS actors
FROM film AS f
	INNER JOIN
     film_actor AS a
	ON
	 f.film_id = a.film_id
GROUP BY f.title
;
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT count(i.inventory_id) AS copies
FROM film AS f
	JOIN
	 inventory AS i
	ON
     f.film_id = i.film_id
WHERE f.title = 'HUNCHBACK IMPOSSIBLE'
;  /* 6 COPIES */
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT c.first_name
	  ,c.last_name
      ,sum(p.amount) AS total
FROM customer AS c
	JOIN
     payment AS p
	ON
     c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name
;
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE language_id IN
	(
    SELECT language_id 
	FROM language
	WHERE name = 'English'
	)
	AND title LIKE 'K%' 
     OR title LIKE 'Q%'
;
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name
	  ,last_name
FROM actor
WHERE actor_id IN
(
SELECT actor_id
FROM film_actor
WHERE film_id IN	
    (
	SELECT film_id
	FROM film
	WHERE title = 'ALONE TRIP'
	)
)
;
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT c.first_name
	  ,c.last_name
      ,c.email
FROM customer AS c
	LEFT JOIN
     address AS a
		ON
	 c.address_id = a.address_id
	LEFT JOIN city
		ON
	 a.city_id = city.city_id
	LEFT JOIN country
		ON
	 city.country_id = country.country_id
WHERE country.country = 'Canada'
;
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.
SELECT f.title
FROM film AS f
	JOIN
     film_category AS fc
		ON
	 f.film_id = fc.film_id
	JOIN
     category AS c
		ON
	 fc.category_id = c.category_id
WHERE c.name = 'Family'
;
-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title
	  ,count(r.rental_id) AS count
FROM film AS f
	JOIN
     inventory AS i
		ON
	 f.film_id = i.film_id
	JOIN rental AS r
		ON
	 i.inventory_id = r.inventory_id
GROUP BY f.title
HAVING count >= 30  -- CHANGE LIMIT TO YOUR PREFERENCE
ORDER BY count DESC
;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id
	  ,sum(p.amount) AS amount
FROM staff AS s
	JOIN
     payment AS p
		ON
	 s.staff_id = p.staff_id
GROUP BY s.store_id
;
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id
	  ,city.city
      ,country.country
FROM store AS s
	JOIN
     address AS a
		ON
	 s.address_id = a.address_id
	JOIN
     city
		ON
	 a.city_id = city.city_id
	JOIN
	 country
		ON
	 city.country_id = country.country_id
;
-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS category
      ,sum(p.amount) AS revenue
FROM category AS c
	JOIN film_category
		ON
         c.category_id = film_category.category_id
	JOIN inventory
		ON
         film_category.film_id = inventory.film_id
	JOIN rental
		ON
         inventory.inventory_id = rental.inventory_id
	JOIN payment AS p
		ON
         rental.rental_id = p.rental_id
GROUP BY c.name
ORDER BY revenue DESC LIMIT 5
;
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_genres AS
SELECT c.name AS category
      ,sum(p.amount) AS revenue
FROM category AS c
	JOIN film_category
		ON
         c.category_id = film_category.category_id
	JOIN inventory
		ON
         film_category.film_id = inventory.film_id
	JOIN rental
		ON
         inventory.inventory_id = rental.inventory_id
	JOIN payment AS p
		ON
         rental.rental_id = p.rental_id
GROUP BY c.name
ORDER BY revenue DESC LIMIT 5
;
-- 8b. How would you display the view that you created in 8a?
SELECT category
	  ,revenue
FROM top_genres
;
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_genres
;