-- Adding a primary key constraint to the actors table
ALTER TABLE Actor
ADD CONSTRAINT pk_actor_id
PRIMARY KEY (actor_id);
------------------------------------------------------------
-- Adding a primary key constraint to the country table
ALTER TABLE country
ADD CONSTRAINT pk_country_id
PRIMARY KEY (country_id);
------------------------------------------------------------
-- Adding a primary key constraint to the Category table
ALTER TABLE Category
ADD CONSTRAINT pk_category_id
PRIMARY KEY (category_id);
------------------------------------------------------------
-- Adding PRIMARY KEY and FOREIGN KEY constraint to city table
ALTER TABLE city
ADD CONSTRAINT pk_city_id
PRIMARY KEY (city_id);

ALTER TABLE city
ADD CONSTRAINT fk_country_id
FOREIGN KEY (country_id) REFERENCES country(country_id);
--------------------------------------------------------------
-- Adding PRIMARY KEY and FOREIGN KEY constraints to the address table
ALTER TABLE address
ADD CONSTRAINT pk_address_id
PRIMARY KEY (address_id);

ALTER TABLE address
ADD CONSTRAINT fk_city_id
FOREIGN KEY (city_id) REFERENCES city(city_id);
---------------------------------------------------------------
-- ADDING PRIMARY AND FOREIGN KEY TO THE FILM TABLE
ALTER TABLE Film
ADD CONSTRAINT pk_film_id
PRIMARY KEY (film_id);

ALTER TABLE Film
ADD CONSTRAINT fk_language_id
FOREIGN KEY (language_id) REFERENCES language(language_id);
----------------------------------------------------------------
-- ADDING PRIMARY KEY AND FOREIGN KEY TO THE inventory table
ALTER TABLE Inventory
ADD CONSTRAINT pk_inventory_id
PRIMARY KEY (inventory_id);

ALTER TABLE Inventory
ALTER COLUMN film_id smallint;

ALTER TABLE Inventory
ADD CONSTRAINT fk_film_id
FOREIGN KEY (film_id) REFERENCES Film(film_id);
------------------------------------------------------------------
-- ADD PRIMARY KEY AND FOREIGN KEY CONSTRAINTS TO store table
ALTER TABLE store
ADD CONSTRAINT pk_store_id
PRIMARY KEY (store_id);

ALTER TABLE store
ADD CONSTRAINT fk_address_id
FOREIGN KEY (address_id) REFERENCES address(address_id);

ALTER TABLE store
ADD CONSTRAINT fk_staff_id
FOREIGN KEY (manager_staff_id) REFERENCES staff(staff_id);
-------------------------------------------------------------------
-- ADD PRIMARY KEY AND FOREIGN KEY CONSTRAINTS TO staff table
ALTER TABLE staff
ADD CONSTRAINT pk_staff_id
PRIMARY KEY (staff_id);

ALTER TABLE staff
ADD CONSTRAINT fk_store_id
FOREIGN KEY (store_id) REFERENCES store(store_id);

ALTER TABLE staff
ADD CONSTRAINT fk_address_id_staff
FOREIGN KEY (address_id) REFERENCES address(address_id);
---------------------------------------------------------------------
ALTER TABLE Customer
ADD CONSTRAINT pk_customer_id
PRIMARY KEY (customer_id);

ALTER TABLE Customer
ADD CONSTRAINT fk_store_id_customer
FOREIGN KEY (store_id) REFERENCES store(store_id);

ALTER TABLE Customer
ADD CONSTRAINT fk_address_id_customer
FOREIGN KEY (address_id) REFERENCES address(address_id);
------------------------------------------------------------------
-- ADDING PRIMARY AND FOREIGN KEY CONSTRIANTS TO payment
ALTER TABLE payment
ADD CONSTRAINT pk_payment_id
PRIMARY KEY (payment_id);

ALTER TABLE payment
ADD CONSTRAINT fk_customer_id_customerpayment
FOREIGN KEY (customer_id) REFERENCES Customer(customer_id);

ALTER TABLE payment
ADD CONSTRAINT fk_staff_id_staffpayment
FOREIGN KEY (staff_id) REFERENCES staff(staff_id);

ALTER TABLE payment
ADD CONSTRAINT fk_rental_id_rentalpayment
FOREIGN KEY (rental_id) REFERENCES rental(rental_id);
-----------------------------------------------------------------
-- ADDING PRIMARY AND FOREIGN KEY CONSTRAINTS TO rental
ALTER TABLE rental
ADD CONSTRAINT pk_rental_id
PRIMARY KEY (rental_id);

ALTER TABLE rental
ADD CONSTRAINT fk_customer_id_customerrental
FOREIGN KEY (customer_id) REFERENCES Customer(customer_id);

ALTER TABLE rental
ADD CONSTRAINT fk_inventory_id_inventoryrental
FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id);

ALTER TABLE rental
ADD CONSTRAINT fk_staff_id_staffrental
FOREIGN KEY (staff_id) REFERENCES staff(staff_id);
----------------------------------------------------------------------
ALTER TABLE Inventory
ADD CONSTRAINT fk_store_id_inventorystore
FOREIGN KEY (store_id) REFERENCES store(store_id);
------------------------------------------------------------------------
ALTER TABLE Film_Actor
ALTER COLUMN film_id smallint;

ALTER TABLE Film_Category
ALTER COLUMN film_id smallint NOT NULL;

ALTER TABLE Film_Actor
ALTER COLUMN film_id smallint NOT NULL;

ALTER TABLE Film_Actor
ADD CONSTRAINT pk_Film_Actor
PRIMARY KEY (actor_id, film_id);

ALTER TABLE Film_Actor
ADD CONSTRAINT fk_Film_Actor_Film
FOREIGN KEY (film_id) REFERENCES Film(film_id);

ALTER TABLE Film_Actor
ADD CONSTRAINT fk_Film_Actor
FOREIGN KEY (actor_id) REFERENCES Actor(actor_id);
------------------------------------------------------------------------
ALTER TABLE Film_Category
ADD CONSTRAINT pk_Film_Category
PRIMARY KEY (category_id, film_id);

ALTER TABLE Film_Category
ADD CONSTRAINT fk_Film_Category
FOREIGN KEY (film_id) REFERENCES Film(film_id);

ALTER TABLE Film_Category
ADD CONSTRAINT fk_Film_Cat
FOREIGN KEY (category_id) REFERENCES Category(category_id);
-------------------------------------------------------------------------
CREATE TABLE dimdate
(
	date_key int NOT NULL PRIMARY KEY,
	date date NOT NULL,
	year int NOT NULL,
	quarter int NOT NULL,
	month int NOT NULL,
	day int NOT NULL,
	week INT NOT NULL,
	is_weekend BIT
);

CREATE TABLE dimcustomers
(
	customer_key int NOT NULL PRIMARY KEY,
	customer_id int NOT NULL,
	first_name varchar(50) NOT NULL,
	last_name varchar(50) NOT NULL,
	email varchar(50),
	address varchar(50) NOT NULL,
	address2 varchar(50),
	district varchar(50) NOT NULL,
	city varchar(50) NOT NULL,
	country varchar(50) NOT NULL,
	postal_code varchar(50),
	phone varchar(50),
	active CHAR(1) NOT NULL,
	CREATED_DT date,
	LAST_UPDT_DT date
);

CREATE TABLE dimmovie
(
	movie_key int NOT NULL PRIMARY KEY,
	film_id smallint NOT NULL,
	title varchar(50) NOT NULL,
	description varchar(150),
	release_year int,
	language varchar(50) NOT NULL,
	rental_duration int NOT NULL,
	length int NOT NULL,
	rating varchar(50) NOT NULL,
	special_features varchar(450) NOT NULL,
	active CHAR(1) NOT NULL,
	CREATED_DT date,
	LAST_UPDT_DT date
);

CREATE TABLE dimstore
(
	store_key int NOT NULL PRIMARY KEY,
	store_id int NOT NULL,
	address varchar(50) NOT NULL,
	address2 varchar(50),
	district varchar(50),
	city varchar(50) NOT NULL,
	country varchar(50) NOT NULL,
	postal_code int,
	rating varchar(50) NOT NULL,
	manager_first_name varchar(50) NOT NULL,
	manager_last_name varchar(50) NOT NULL,
	active CHAR(1) NOT NULL,
	CREATED_DT date,
	LAST_UPDT_DT date
);
----------------------------------------------------------------------------------------------------------
-- POPULATE THE DATE DIMENSION

select * from payment;

DROP PROCEDURE IF EXISTS PopulateDimDateDimension;

CREATE PROCEDURE PopulateDimDateDimension
AS
BEGIN
    DELETE FROM DIMDATE;

    DECLARE @startDate DATE
    DECLARE @endDate DATE

    -- Set the start and end dates based on your Transactions table
    SELECT @startDate = MIN(payment_date), @endDate = MAX(payment_date)
    FROM payment;

    WITH DateCTE AS (
        SELECT
            @startDate AS loopdate
        UNION ALL
        SELECT
            DATEADD(DAY, 1, loopdate)
        FROM
            DateCTE
        WHERE
            loopdate < @endDate
    )
    INSERT INTO DIMDATE (date_key, date, year, quarter, month, day, week, is_weekend)
    SELECT
        ROW_NUMBER() OVER (ORDER BY loopdate) AS date_key,
        loopdate AS date,
        YEAR(loopdate) AS year,
        DATEPART(QUARTER, loopdate) AS quarter,
        MONTH(loopdate) AS month,
        DAY(loopdate) AS day,
        DATEPART(WEEK, loopdate) AS week,
        CASE WHEN DATEPART(WEEKDAY, loopdate) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend
    FROM
        DateCTE;
END;


EXEC PopulateDimDateDimension

SELECT * FROM dimdate;
-------------------------------------------------------------------------------------------------------------
select * from dimcustomers;

ALTER TABLE dimcustomers
ALTER COLUMN district varchar(50) NULL;

select C.customer_id, C.first_name, C.last_name, C.email, ct.city, cn.country,
A.address, A.address2, A.district, A.postal_code, A.phone
from customer C
JOIN address A ON C.address_id = A.address_id
JOIN city ct ON A.city_id = ct.city_id
JOIN country cn ON ct.country_id = cn.country_id;

CREATE SEQUENCE CustomerSequence
AS INT
START WITH 1000
INCREMENT BY 1;

DROP SEQUENCE IF EXISTS CustomerSequence;

DROP PROCEDURE IF EXISTS SP_OnlineDimCustomer_Load_type2;

CREATE PROCEDURE SP_OnlineDimCustomer_Load_type2 AS
SET NOCOUNT ON
Begin
	DECLARE @customer_id INT;
	DECLARE @first_name VARCHAR(50);
	DECLARE @last_name VARCHAR(50);
	DECLARE @email VARCHAR(50);
	DECLARE @address VARCHAR(50);
	DECLARE @address2 VARCHAR(50);
	DECLARE @district VARCHAR(50);
	DECLARE @city VARCHAR(50);
	DECLARE @country VARCHAR(50);
	DECLARE @postal_code VARCHAR(50);
	DECLARE @phone VARCHAR(50);
	DECLARE @customer_key INT;

	DECLARE CustomerCursor CURSOR FOR
	select C.customer_id, C.first_name, C.last_name, C.email, ct.city, cn.country,
	A.address, A.address2, A.district, A.postal_code, A.phone
	from customer C
	JOIN address A ON C.address_id = A.address_id
	JOIN city ct ON A.city_id = ct.city_id
	JOIN country cn ON ct.country_id = cn.country_id;

	OPEN CustomerCursor;
	FETCH NEXT FROM CustomerCursor INTO @customer_id, @first_name, @last_name, @email, @city, @country, @address, @address2, @district, @postal_code, @phone;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @customer_key = NEXT VALUE FOR CustomerSequence;

		IF EXISTS (SELECT 1 FROM dimcustomers WHERE customer_id = @customer_id AND LAST_UPDT_DT IS NULL AND (first_name <> @first_name OR last_name <> @last_name OR email <> @email OR address <> @address OR address2 <> @address2 OR district <> @district OR city <> @city OR country <> @country OR postal_code <> @postal_code OR phone <> @phone))
		BEGIN
			UPDATE dimcustomers
			SET active='N', LAST_UPDT_DT=CONVERT(DATE, GETDATE())
			WHERE customer_id = @customer_id and LAST_UPDT_DT IS NULL;

			INSERT INTO dimcustomers(customer_key, customer_id, first_name, last_name, email, address, address2, district, city, country, postal_code, phone, active, CREATED_DT, LAST_UPDT_DT)
			VALUES (@customer_key, @customer_id, @first_name, @last_name, @email, @address, @address2, @district, @city, @country, @postal_code, @phone, 'Y', CONVERT(DATE, GETDATE()), NULL)
		END
		ELSE IF NOT EXISTS (
            SELECT 1
            FROM dimcustomers
            WHERE customer_id = @customer_id
              AND LAST_UPDT_DT IS NULL
              AND (first_name = @first_name AND last_name = @last_name AND email = @email AND address = @address AND address2 = @address2 AND district = @district AND city = @city AND country = @country AND postal_code = @postal_code AND phone = @phone)
        )
		BEGIN
			INSERT INTO dimcustomers (customer_key, customer_id, first_name, last_name, email, address, address2, district, city, country, postal_code, phone, active, CREATED_DT, LAST_UPDT_DT)
			VALUES (@customer_key, @customer_id, @first_name, @last_name, @email, @address, @address2, @district, @city, @country, @postal_code, @phone, 'Y', CONVERT(DATE, GETDATE()), NULL)
		END

		FETCH NEXT FROM CustomerCursor INTO @customer_id, @first_name, @last_name, @email, @city, @country, @address, @address2, @district, @postal_code, @phone;

	END

	CLOSE CustomerCursor;
	DEALLOCATE CustomerCursor;
END;

EXEC SP_OnlineDimCustomer_Load_type2;

select * from dimcustomers;
-------------------------------------------------------------------------------------------------------------------------------------------------------------
select * from dimmovie;

select F.film_id, F.title, F.description, F.release_year, l.name as language, F.rental_duration,
F.length, F.rating, F.special_features
from Film F JOIN language l ON F.language_id = l.language_id;

select C.customer_id, C.first_name, C.last_name, C.email, ct.city, cn.country,
A.address, A.address2, A.district, A.postal_code, A.phone
from customer C
JOIN address A ON C.address_id = A.address_id
JOIN city ct ON A.city_id = ct.city_id
JOIN country cn ON ct.country_id = cn.country_id;

CREATE SEQUENCE MovieSequence
AS INT
START WITH 1000
INCREMENT BY 1;

DROP SEQUENCE IF EXISTS MovieSequence;

DROP PROCEDURE IF EXISTS SP_OnlineDimMovie_Load_type2;

CREATE PROCEDURE SP_OnlineDimMovie_Load_type2 AS
SET NOCOUNT ON
Begin
	DECLARE @film_id INT;
	DECLARE @title VARCHAR(50);
	DECLARE @description VARCHAR(150);
	DECLARE @release_year INT;
	DECLARE @language VARCHAR(50);
	DECLARE @rental_duration INT;
	DECLARE @length INT;
	DECLARE @rating VARCHAR(50);
	DECLARE @special_features VARCHAR(450);
	DECLARE @active CHAR(1);
	DECLARE @movie_key INT;

	DECLARE MovieCursor CURSOR FOR
	select F.film_id, F.title, F.description, F.release_year, l.name as language, F.rental_duration,
	F.length, F.rating, F.special_features
	from Film F JOIN language l ON F.language_id = l.language_id;

	OPEN MovieCursor;
	FETCH NEXT FROM MovieCursor INTO @film_id, @title, @description, @release_year, @language, @rental_duration, @length, 
	@rating, @special_features;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @movie_key = NEXT VALUE FOR MovieSequence;

		IF EXISTS (SELECT 1 FROM dimmovie WHERE film_id = @film_id AND LAST_UPDT_DT IS NULL AND (title <> @title OR description <> @description OR release_year <> @release_year OR language <> @language OR rental_duration <> @rental_duration OR length <> @length OR rating <> @rating OR special_features <> @special_features))
		BEGIN
			UPDATE dimmovie
			SET active='N', LAST_UPDT_DT=CONVERT(DATE, GETDATE())
			WHERE film_id = @film_id and LAST_UPDT_DT IS NULL;

			INSERT INTO dimmovie(movie_key, film_id, title, description, release_year, language, rental_duration, length, rating, special_features, active, CREATED_DT, LAST_UPDT_DT)
			VALUES (@movie_key, @film_id, @title, @description, @release_year, @language, @rental_duration, @length, @rating, @special_features, 'Y', CONVERT(DATE, GETDATE()), NULL)
		END
		ELSE IF NOT EXISTS (
            SELECT 1
            FROM dimmovie
            WHERE film_id = @film_id
              AND LAST_UPDT_DT IS NULL
              AND (title = @title AND description = @description AND release_year = @release_year AND language = @language AND rental_duration = @rental_duration AND length = @length AND special_features = @special_features)
        )
		BEGIN
			INSERT INTO dimmovie(movie_key, film_id, title, description, release_year, language, rental_duration, length, rating, special_features, active, CREATED_DT, LAST_UPDT_DT)
			VALUES (@movie_key, @film_id, @title, @description, @release_year, @language, @rental_duration, @length, @rating, @special_features, 'Y', CONVERT(DATE, GETDATE()), NULL)
		END

		FETCH NEXT FROM MovieCursor INTO @film_id, @title, @description, @release_year, @language, @rental_duration, @length, @rating, @special_features;

	END

	CLOSE MovieCursor;
	DEALLOCATE MovieCursor;
END;

EXEC SP_OnlineDimMovie_Load_type2;

select * from dimmovie;
---------------------------------------------------------------------------------------
select * from dimstore;

select * from store;

select * from address;

select * from city;

select * from staff;

ALTER TABLE dimstore
DROP COLUMN rating;

select s.store_id, a.address, a.address2, a.district, ct.city, cn.country, a.postal_code, st.first_name, st.last_name from store s
JOIN address a ON s.address_id = a.address_id
JOIN city ct ON a.city_id = ct.city_id
JOIN country cn ON ct.country_id = cn.country_id
JOIN staff st ON s.manager_staff_id = st.staff_id;

select F.film_id, F.title, F.description, F.release_year, l.name as language, F.rental_duration,
F.length, F.rating, F.special_features
from Film F JOIN language l ON F.language_id = l.language_id;

select C.customer_id, C.first_name, C.last_name, C.email, ct.city, cn.country,
A.address, A.address2, A.district, A.postal_code, A.phone
from customer C
JOIN address A ON C.address_id = A.address_id
JOIN city ct ON A.city_id = ct.city_id
JOIN country cn ON ct.country_id = cn.country_id;
---------------------------------------------------------------------------------
select * from dimstore;

CREATE SEQUENCE StoreSequence
AS INT
START WITH 1000
INCREMENT BY 1;

DROP SEQUENCE IF EXISTS StoreSequence;

DROP PROCEDURE IF EXISTS SP_OnlineDimStore_Load_type2;

CREATE PROCEDURE SP_OnlineDimStore_Load_type2 AS
SET NOCOUNT ON
Begin
	DECLARE @store_id INT;
	DECLARE @address VARCHAR(50);
	DECLARE @address2 VARCHAR(50);
	DECLARE @district VARCHAR(50);
	DECLARE @city VARCHAR(50);
	DECLARE @country VARCHAR(50);
	DECLARE @postal_code INT;
	DECLARE @manager_first_name VARCHAR(50);
	DECLARE @manager_last_name VARCHAR(50);
	DECLARE @store_key INT;

	DECLARE StoreCursor CURSOR FOR
	select s.store_id, a.address, a.address2, a.district, ct.city, cn.country, a.postal_code, st.first_name, st.last_name from store s
	JOIN address a ON s.address_id = a.address_id
	JOIN city ct ON a.city_id = ct.city_id
	JOIN country cn ON ct.country_id = cn.country_id
	JOIN staff st ON s.manager_staff_id = st.staff_id;

	OPEN StoreCursor;
	FETCH NEXT FROM StoreCursor INTO @store_id, @address, @address2, @district, @city, @country, @postal_code, 
	@manager_first_name, @manager_last_name;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @store_key = NEXT VALUE FOR StoreSequence;

		IF EXISTS (SELECT 1 FROM dimstore WHERE store_id = @store_id AND LAST_UPDT_DT IS NULL AND (address <> @address OR address2 <> @address2 OR district <> @district OR city <> @city OR country <> @country OR postal_code <> @postal_code OR manager_first_name <> @manager_first_name OR manager_last_name <> @manager_last_name))
		BEGIN
			UPDATE dimstore
			SET active='N', LAST_UPDT_DT=CONVERT(DATE, GETDATE())
			WHERE store_id = @store_id and LAST_UPDT_DT IS NULL;

			INSERT INTO dimstore(store_key, store_id, address, address2, district, city, country, postal_code, manager_first_name, manager_last_name, active, CREATED_DT, LAST_UPDT_DT)
			VALUES (@store_key, @store_id, @address, @address2, @district, @city, @country, @postal_code, @manager_first_name, @manager_last_name, 'Y', CONVERT(DATE, GETDATE()), NULL)
		END
		ELSE IF NOT EXISTS (
            SELECT 1
            FROM dimstore
            WHERE store_id = @store_id
              AND LAST_UPDT_DT IS NULL
              AND (address = @address AND address2 = @address2 AND district = @district AND city = @city AND country = @country AND postal_code = @postal_code AND manager_first_name = @manager_first_name AND manager_last_name = @manager_last_name)
        )
		BEGIN
			INSERT INTO dimstore(store_key, store_id, address, address2, district, city, country, postal_code, manager_first_name, manager_last_name, active, CREATED_DT, LAST_UPDT_DT)
			VALUES (@store_key, @store_id, @address, @address2, @district, @city, @country, @postal_code, @manager_first_name, @manager_last_name, 'Y', CONVERT(DATE, GETDATE()), NULL)
		END

		FETCH NEXT FROM StoreCursor INTO @store_id, @address, @address2, @district, @city, @country, @postal_code, 
	@manager_first_name, @manager_last_name;

	END

	CLOSE StoreCursor;
	DEALLOCATE StoreCursor;
END;

EXEC SP_OnlineDimStore_Load_type2;

select * from dimstore;
-----------------------------------------------------------------------------------------------
select * from payment;

DROP SEQUENCE IF EXISTS SalesSequence;

DROP PROCEDURE IF EXISTS TruncateAndLoadSales;

/*CREATE TABLE factsales
(
	sales_key INT PRIMARY KEY,
	customer_key INT,
	movie_key INT,
	store_key INT,
	date_key INT,
	sales_amount float

	CONSTRAINT FK_CustomerKey FOREIGN KEY (customer_key) REFERENCES dimcustomers(customer_key),
    CONSTRAINT FK_MovieKey FOREIGN KEY (movie_key) REFERENCES dimmovie(movie_key),
	CONSTRAINT FK_StoreKey FOREIGN KEY (store_key) REFERENCES dimstore(store_key),
    CONSTRAINT FK_DateKey FOREIGN KEY (date_key) REFERENCES dimdate(date_key)
);*/

CREATE SEQUENCE SalesSequence
AS INT
START WITH 1000
INCREMENT BY 1;

select * from payment;

CREATE PROCEDURE TruncateAndLoadSales
AS
BEGIN
    -- Truncate the fact table
    TRUNCATE TABLE factsales;  -- Replace YourFactTableName with the actual name of your fact table

    -- Reload the fact table using your query
    INSERT INTO factsales (sales_key, customer_key, movie_key, store_key, date_key, sales_amount)
    SELECT NEXT VALUE FOR SalesSequence as sales_key, C.customer_key as customer_key, DM.movie_key as movie_key, 
	DS.store_key as store_key, D.date_key as date_key, K.amount as sales_amount
    FROM
        (SELECT p.customer_id, i.film_id, i.store_id, p.amount, p.payment_date from payment p
		JOIN rental r ON (p.rental_id = r.rental_id)
		JOIN Inventory i ON (r.inventory_id = i.inventory_id)) K
    JOIN (SELECT customer_key, customer_id FROM dimcustomers) C ON K.customer_id = C.customer_id
    JOIN (SELECT store_id, store_key FROM dimstore) DS ON K.store_id = DS.store_id
	JOIN (select film_id, movie_key FROM dimmovie) DM ON K.film_id = DM.film_id
    JOIN (SELECT date_key, date FROM dimdate) D ON K.payment_date = D.date;

END;

EXEC TruncateAndLoadSales;

SELECT * FROM factsales;