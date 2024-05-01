# Movies

This is  project to analyze the the top three top movie rental fee for different countries using a SQL database and visualizing with Microsoft Excel.
Some other queries were also written to generate various desired result.

The database I am using here is name Sakila. It has several tables in it which are linked to one another by various foreign keys.

First, I generated the actors who acted in the most expensive movies available for rent.

          with top_acts as 
          (select fm.title, fm.rental_duration, concat(ac.first_name, ' ', ac.last_name) as full_name,
          fm.length,fm.replacement_cost as Movie_cost
          from film fm 
          join film_actor fa on fa.film_id = fm.film_id
          join actor ac on fa.actor_id = ac.actor_id
          -- group by fm.title
          order by Movie_cost desc, fm.title) 
          select * from top_acts
          -- group by full_name
          order by fm.title;

I also generated the customers who have paid most and check if they have returned the movies rented.

              with Late_returnee as 
              (select concat(c.first_name, ' ',c.last_name) as Full_name, 
              case
                when datediff(r.return_date, r.rental_date) <= 10 then 'Duely_returned'
                  else 'Late_return'
                  end as Returnee,
                  sum(p.amount) as total,
                  c.email
                  from customer c
                  join payment p on p.customer_id = c.customer_id
                  join rental r on r.customer_id = p.customer_id
                  group by Full_name
                  order by Full_name)
                  select * from Late_returnee;

I performed a join to get the actors who acted in movies where the languages spoken there are just English and Italian.

              select A.* from
              (select p1.actors_name,p1.title, p1.dialect from
              (select concat(a.first_name, ' ', a.last_name) as Actors_name, b.title, b.length, l.name as dialect
              from actor a
              join film_actor c on c.actor_id = a.actor_id
              join film b on b.film_id=c.film_id
              join language l on l.language_id = b.film_id
              where l.language_id = 1
              group by Actors_name
              order by b.length desc) p1
              Union
              select p2.actors_name, p2.title, p2.dialect from
              (select concat(a1.first_name, ' ', a1.last_name) as Actors_name, b1.title, b1.length, l1.name as dialect
              from actor a1
              join film_actor c1 on c1.actor_id = a1.actor_id
              join film b1 on b1.film_id=c1.film_id
              join language l1 on l1.language_id = b1.film_id
              where l1.language_id = 2
              group by actors_name
              order by b1.length desc) p2) A;



A table showing the  number of movies acted by each actor was also generated.

        select concat(a.first_name, ' ', a.last_name) as Actors_name, b.title, b.length, l.name as dialect
        from actor a
        join film_actor c on c.actor_id = a.actor_id
        join film b on b.film_id=c.film_id
        join language l on l.language_id = b.film_id;

This was exported to excel and and the top twenty was visualized using a horizontal bar graph, putting into context the possible error value.


A simple procedure was also created to get customer information which include; name, phone, email, address and country when the procedure 
is called.

          drop procedure customer_info ;
          commit;
          delimiter $$
          create procedure customer_info(in  p_customer_id int)
          begin
            select concat(c.first_name, ' ', c.last_name) as full_name,
              a.phone, c.email, concat(a.address, ' ',ct.city) as Address, cy.country
              from customer c
              join address a on a.address_id = c.address_id
              join city ct on ct.city_id = a.city_id
              join country cy on cy.country_id = ct.country_id
              where c.customer_id = p_customer_id;

          End $$
          delimiter ;

          rollback;

          call customer_info(5);


The table which I needed to get the movie rental information which includes the customers' full name, email, full address, movie rental status,
amount and how fast the customers pay.

        (select concat(c.first_name, ' ', c.last_name) as customer_name,c.email as Email_address,
        concat(a.address, ' ', a.district, ',', ct.city,',', cy.country) as full_address,a.phone, cy.country,
        case
          when datediff(r.return_date, r.rental_date) <= 10 then 'Duely_returned'
            else 'Late_return'
            end as Returnee,
            p.amount, 
            dense_rank() over(partition by p.amount 
                order by day(p.payment_date)) as Earliest_pay
          from country cy
            join city ct on cy.country_id = ct.country_id
            join address a on ct.city_id = a.city_id
            join customer c on c.address_id = a.address_id
            join payment p on p.customer_id = c.customer_id
            join rental r on r.customer_id = p.customer_id
            group by customer_name
            order by p.amount desc);



This is the exported to Microsoft excel for visualization. 

The data was put in a pivot chart. 
Here, I brought out the 'amount' column and rename it to 'Rental fee'. The percentage of total customers that pay particular rental fees were 
also derived. The country column was also added as a filter.

A doughnut chart was then created to show the top three rental fee that was paid. One was also created for the general rental fee.

We can toggle from country to country usng a slicer generated with the country filter

This chart tells the top three rental fee paid per country, and also a repesentation of all the rental fees available in each country.

 
