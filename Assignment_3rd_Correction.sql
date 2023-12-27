1. Write a stored procedure that accepts the month and year as inputs and prints the ordernumber, orderdate and status of the orders placed in that month.
-- Example: call order_status(2005, 11);

DELIMITER //
Create procedure order_status( IN t_year INT,
                                    IN t_month INT )
  BEGIN 
    select orderNumber,
               orderdate,
               status
      from orders
        where year(orderDate) = t_year
            AND
                month(orderDate) = t_month;
  END //
DELIMITER ;

call order_status(2005, 4);

/*2. a. Write function that takes the customernumber as input and returns the purchase_status based on the following criteria . [table:Payments]
-- if the total purchase amount for the customer is < 25000 status = Silver, amount between 25000 and 50000, status = Gold -- if amount > 50000 Platinum*/

select *,
     CASE
      WHEN amount < 25000 THEN 'Silver'
      WHEN amount BETWEEN 25000 AND 50000 THEN 'Gold'
            ELSE 'Platinum'
            END AS Status
  from payments;

-- b. Write a query that displays customerNumber, customername and purchase_status from customers table.

select c.customerNumber,
     c.customerName,
       o.status
  from customers c
    LEFT JOIN orders o
    USING (customerNumber);

3. Replicate the functionality of 'on delete cascade' and 'on update cascade' using triggers on movies and rentals tables.
-- Note: Both tables - movies and rentals - don't have primary or foreign keys. Use only triggers to implement the above.

-- Q. For ON DELETE CASCADE, if a parent with an id is deleted, a record in child with parent_id = parent.id will be automatically deleted. This should be no problem.

-- 1. This means that ON UPDATE CASCADE will do the same thing when id of the parent is updated?

-- 2. If (1) is true, it means that there is no need to use ON UPDATE CASCADE if parent.id is not updatable (or will never be updated) like when it is AUTO_INCREMENT or always set to be TIMESTAMP. Is that right?

-- 3. If (2) is not true, in what other kind of situation should we use ON UPDATE CASCADE?

-- A. It's true that if your primary key is just an identity value auto incremented, you would have no real use for ON UPDATE CASCADE.

-- However, let's say that your primary key is a 10 digit UPC bar code and because of expansion, you need to change it to a 13-digit UPC bar code. In that case, -- ON UPDATE CASCADE would allow you to change the primary key value and any tables that have foreign key references to the value will be changed accordingly.

-- In reference to #4, if you change the child ID to something that doesn't exist in the parent table (and you have referential integrity), you should get a foreign key error.

/*What if I (for some reason) update the child.parent_id to be something not existing, will it then be automatically deleted?*/

DELIMITER //
CREATE TRIGGER delete_cascade
  AFTER DELETE on movies
    FOR EACH ROW 
    BEGIN
      UPDATE rentals
        SET movieid = NULL
          WHERE movieid
                       NOT IN
            ( SELECT distinct id
              from movies );
    END //
DELIMITER ;

drop trigger if exists delete_cascade;

select *
  from movies;

INSERT INTO movies ( id,             title,          category )
      Values ( 11, 'The Dark Knight', 'Action/Adventure');

INSERT INTO rentals ( memid, first_name, last_name, movieid ) 
           Values (     9,     'Moin',   'Dalvi',      11 );

delete from movies
  where id = 11;

SELECT id
  from movies;

SELECT *
  from rentals;

DELIMITER //
CREATE TRIGGER update_cascade
  AFTER UPDATE on movies
    FOR EACH ROW 
    BEGIN
      UPDATE rentals
        SET movieid = new.id
          WHERE movieid = old.id;
    END //
DELIMITER ;

DROP trigger if exists update_cascade;

INSERT INTO movies ( id,             title,          category )
      Values ( 12, 'The Dark Knight', 'Action/Adventure'); 

UPDATE rentals
  SET movieid = 12
    WHERE memid = 9;

UPDATE movies
  SET id = 11
    WHERE title regexp 'Dark Knight';

select *
  from movies;

select *
  from rentals;
  
/*4. Select the first name of the employee who gets the third highest salary. [table: employee]*/
select *
  from employee
    order by salary desc
      limit 2,1;
/*5. Assign a rank to each employee based on their salary. The person having the highest salary has rank 1. [table: employee]*/
select *,
     dense_rank () OVER (order by salary desc) as Rank_salary
  from employee;