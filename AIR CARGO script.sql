/*	Write a query to create route_details table using suitable data types for the fields, such as route_id, 
flight_num, origin_airport, destination_airport, aircraft_id, and distance_miles. 
Implement the check constraint for the flight number and unique constraint for the route_id fields.
 Also, make sure that the distance miles field is greater than 0.*/
 
create table route_details
( route_id int not null,
flight_num int not null,
origin_airport varchar(50) not null,
destination_airport varchar(50) not null,
aircraft_id varchar(50) not null,
distance_miles int not null,
primary key (route_id),
constraint flight_num_check check ((substr(flight_num,1,2)=11)),
constraint route_id_check check (distance_miles>0) )

select * from route_details

/*2.	Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. 
Take data  from the passengers_on_flights table. */

select * from passengers_on_flights  
 where route_id between 1 and 25
order by route_id  ;

/*	Write a query to identify the number of passengers and total revenue in business class from the ticket_details table. */

select count(customer_id) as num_of_passenger, sum(Price_per_ticket) as total_revenue, class_id 
from ticket_details
where class_id="Bussiness"

/*	Write a query to display the full name of the customer by extracting the first name and last name from the customer table. */

select first_name,last_name,concat(first_name," ",last_name) as full_name from customer

/*	Write a query to extract the customers who have registered and booked a ticket. Use data from the customer and ticket_details tables */

SELECT 
    customer.customer_id, 
    CONCAT(first_name, " ", last_name) AS full_name,
    COUNT(ticket_details.no_of_tickets) AS total_booked_ticket 
FROM 
    customer
JOIN 
    ticket_details USING (customer_id)
GROUP BY 
    customer.customer_id, full_name
ORDER BY 
    total_booked_ticket DESC;

/*	Write a query to identify the customer’s first name and last name based on their customer ID and brand (Emirates) from the ticket_details table. */

select customer.customer_id,first_name,last_name,ticket_details.brand 
from customer
join ticket_details on customer.customer_id=ticket_details.customer_id
where brand="Emirates"

/* Write a query to identify the customers who have travelled by Economy Plus class using Group 
By and Having clause on the passengers_on_flights table. */

SELECT 
    customer.customer_id,
    CONCAT(customer.first_name, " ", customer.last_name) AS name,
    ticket_details.class_id
FROM 
    customer
JOIN 
    ticket_details 
ON 
    ticket_details.customer_id = customer.customer_id
WHERE 
    ticket_details.class_id = 'Economy Plus'
GROUP BY 
    customer.customer_id, name, ticket_details.class_id;

/*.	Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table. */

select * from ticket_details
select if( sum(no_of_tickets*Price_per_ticket) > 10000 ,"revenue > 10000","revenue < 10000") as revenue_status
from ticket_details


/*	Write a query to create and grant access to a new user to perform operations on a database. */

CREATE USER 'AD'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'AD'@'localhost' WITH GRANT OPTION;

/*	Write a query to find the maximum ticket price for each class using window functions on the ticket_details table.
*/

SELECT 
    class_id, 
    MAX(Price_per_ticket) AS max_price 
FROM 
    ticket_details 
GROUP BY class_id


/*	Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table. */

CREATE INDEX idx_route_id ON passengers_on_flights(route_id);

select * from passengers_on_flights
where route_id='4'


/* For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.
*/

CREATE VIEW passengers_with_route_4 AS
SELECT * 
FROM passengers_on_flights
WHERE route_id = 4

/*	Write a query to calculate the total price of all tickets booked by a customer across different aircraft IDs using rollup function.
*/

SELECT 
    customer_id, 
    aircraft_id,
    SUM( Price_per_ticket*no_of_tickets ) AS total_price 
FROM 
    ticket_details 
GROUP BY 
    ROLLUP(customer_id, aircraft_id);


/*	Write a query to create a view with only business class customers along with the brand of airlines.
*/
CREATE VIEW passengers_with_classid_business AS
SELECT * 
FROM ticket_details
WHERE class_id = 'Bussiness'


/*	Write a query to create a stored procedure to get the details of all passengers
 flying between a range of routes defined in run time. Also, return an error message if the table doesn't exist.
*/

DELIMITER //

CREATE PROCEDURE PASSENGERS_BY_ROUTES(IN min_route INT, IN max_route INT)
BEGIN
    SELECT * FROM passengers_on_flights
    WHERE route_id BETWEEN min_route AND max_route;
END //

DELIMITER ;



/*16.	Write a query to create a stored procedure that extracts all the details from the routes table where the travelled distance is more than 2000 miles.
*/
DELIMITER //

CREATE PROCEDURE DISTANCE_BY_ROUTES()
BEGIN
    SELECT * FROM routes
    WHERE distance_miles > 2000 ;
END //

DELIMITER ;


/*17.	Write a query to create a stored procedure that groups the distance travelled by each flight into three categories.
 The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500, 
 and long-distance travel (LDT) for >6500.
*/

DELIMITER //

CREATE PROCEDURE DISTANCE_CATEGORIES()
BEGIN
    SELECT 
        flight_num,
        route_id,
        distance_miles,
        CASE 
            WHEN distance_miles >= 0 AND distance_miles <= 2000 THEN 'SDT' 
            WHEN distance_miles > 2000 AND distance_miles <= 6500 THEN 'IDT' 
            ELSE 'LDT' 
        END AS travel_category
    FROM 
        routes;
END //

DELIMITER ;



/*18.	Write a query to extract ticket purchase date, customer ID, class ID and specify 
if the complimentary services are provided for the specific class using a stored function 
in stored procedure on the ticket_details table.
Condition:
•	If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No
*/

DELIMITER //

CREATE FUNCTION complimentary_services(class_id VARCHAR(50))
RETURNS VARCHAR(3)
DETERMINISTIC
BEGIN
    DECLARE complimentary_services VARCHAR(3);

    IF class_id IN ('Business', 'Economy Plus') THEN
        SET complimentary_services = 'Yes';
    ELSE 
        SET complimentary_services = 'No';
    END IF;

    RETURN complimentary_services;
END //

DELIMITER ;




/*Write a query to extract the first record of the customer whose last name ends with Scott using a cursor from the customer table.
*/

DELIMITER //

CREATE PROCEDURE GetFirstCustomerWithLastNameScott()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE first_name VARCHAR(50);
    DECLARE last_name VARCHAR(50);
    DECLARE customer_id INT;
    
    DECLARE cur CURSOR FOR 
    SELECT customer_id, first_name, last_name 
    FROM customer 
    WHERE last_name LIKE '%Scott';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    FETCH cur INTO customer_id, first_name, last_name;
    
    IF NOT done THEN
        SELECT customer_id, first_name, last_name;
    END IF;
    
    CLOSE cur;
END //

DELIMITER ;


/*
*/


