# Write a query to find what is the total business done by each store
use sakila;

select s.store_id as 'Store ID', concat(c.city,', ',cy.country) as `Store`, sum(p.amount) as `Total business` 
from payment as p
join rental as r on r.rental_id = p.rental_id
join inventory as i on i.inventory_id = r.inventory_id
join store as s on s.store_id = i.store_id
join address as a on a.address_id = s.address_id
join city as c on c.city_id = a.city_id
join country as cy on cy.country_id = c.country_id
group by s.store_id;

# Convert the previous query into a stored procedure.

#DROP PROCEDURE IF EXISTS total_business;

delimiter $$ 
create procedure total_business ()

begin 
	select s.store_id as 'Store ID', concat(c.city,', ',cy.country) as `Store`, sum(p.amount) as `Total business` 
	from payment as p
	join rental as r on r.rental_id = p.rental_id
	join inventory as i on i.inventory_id = r.inventory_id
	join store as s on s.store_id = i.store_id
	join address as a on a.address_id = s.address_id
	join city as c on c.city_id = a.city_id
	join country as cy on cy.country_id = c.country_id
	group by s.store_id;

end; 
$$
delimiter ; 

#Convert the previous query into a stored procedure that takes the input for store_id and displays the total sales for that store.
DROP PROCEDURE IF EXISTS total_business_store_id;
delimiter $$ 
create procedure total_business_store_id (in id int)

begin 
	select s.store_id as 'Store ID', concat(c.city,', ',cy.country) as `Store`, sum(p.amount) as `Total business` 
	from payment as p
	join rental as r on r.rental_id = p.rental_id
	join inventory as i on i.inventory_id = r.inventory_id
	join store as s on s.store_id = i.store_id
	join address as a on a.address_id = s.address_id
	join city as c on c.city_id = a.city_id
	join country as cy on cy.country_id = c.country_id
    where s.store_id =  id
	group by s.store_id;

end; 
 
$$
delimiter ; 
call total_business_store_id(2);

#Update the previous query. Declare a variable total_sales_value of float type, that will store the returned result (of the total sales amount for the store). Call the stored procedure and print the results.

DROP PROCEDURE IF EXISTS total_sale;
delimiter $$ 
create procedure total_sale (in id int, out total_sale_value float)

begin     
	select sum(amount) into total_sale_value
	from (select s.store_id, p.amount 
    from payment as p
	join rental as r on r.rental_id = p.rental_id
	join inventory as i on i.inventory_id = r.inventory_id
	join store as s on s.store_id = i.store_id
	join address as a on a.address_id = s.address_id
	join city as c on c.city_id = a.city_id
	join country as cy on cy.country_id = c.country_id
    where s.store_id =  id) sub
    group by store_id;
  

end; 
 
$$
delimiter ; 
SET @thisThing=-1;
call total_sale(2, @thisThing);
select @thisThing;

#In the previous query, add another variable flag. If the total sales value for the store is over 30.000, then label it as green_flag, otherwise label is as red_flag. Update the stored procedure that takes an input as the store_id and returns total sales value for that store and flag value.

DROP PROCEDURE IF EXISTS total_sale_flag;
delimiter $$ 
create procedure total_sale_flag (in id int, out param_ varchar(30))

begin
	declare flag varchar(30) default "";
    declare total_sale_value float default 0.0; 
	select sum(amount) into total_sale_value
from (select s.store_id, p.amount 
    from payment as p
	join rental as r on r.rental_id = p.rental_id
	join inventory as i on i.inventory_id = r.inventory_id
	join store as s on s.store_id = i.store_id
	join address as a on a.address_id = s.address_id
	join city as c on c.city_id = a.city_id
	join country as cy on cy.country_id = c.country_id
    where s.store_id =  id) sub
	group by store_id;
  
select total_sale_value; 
if total_sale_value > 30000 then 
	set flag = 'green_flag';
else set flag = 'red_flag'; 
end if;  
select flag into param_; 

end; 
 
$$
delimiter ; 
call total_sale_flag(2, @x); 
select @x; 