
/*Creating a Customer Summary Report

In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database,
including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

Step 1: Create a View
First, create a view that summarizes rental information for each customer.
The view should include the customer's ID, name, email address, and total number of rentals (rental_count).*/

use sakila;

DROP VIEW IF EXISTS rental_report;

CREATE VIEW rental_report AS
select c.customer_id, concat(first_name, " ", last_name) as 'full_name', email, count(rental_id) as 'Total_number_of_rentals'
from sakila.customer c 
left join sakila.rental r 
on c.customer_id = r.customer_id
group by c.customer_id;

/*Step 2: Create a Temporary Table
Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
The Temporary Table should use the rental summary view created in Step 1 to join with the payment table
and calculate the total amount paid by each customer.*/

create temporary table total_paid as
select full_name, sum(amount) as 'total_amount'
from rental_report rr 
left join payment p 
on rr.customer_id = p.customer_id
group by full_name;

/*Step 3: Create a CTE and the Customer Summary Report
Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2.
The CTE should include the customer's name, email address, rental count, and total amount paid.*/
	

with summary as (
	select rr.full_name, rr.email, Total_number_of_rentals, total_amount
	from rental_report rr
	left join total_paid t
	on rr.full_name = t.full_name
	)
select full_name, email, Total_number_of_rentals, total_amount
from summary;


/*Next, using the CTE, create the query to generate the final customer summary report, which should include:
customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column 
from total_paid and rental_count.*/

with final_summary as (
	select rr.full_name, rr.email, Total_number_of_rentals, total_amount, round(total_amount/Total_number_of_rentals,2) as average_payment_per_rental
	from rental_report rr
	left join total_paid t
	on rr.full_name = t.full_name
	group by rr.full_name, rr.email, Total_number_of_rentals, total_amount
	)
select *
from final_summary;

