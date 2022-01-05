select vine, count(*) as reviews_count, avg(star_rating) as avg_star_rating, 
avg(helpful_votes) as avg_helpful_votes, avg(total_votes) as avg_total_votes,
(avg(helpful_votes) / avg(total_votes)) as percentage_helpful_votes
from vine_table
where vine = 'Y' or vine = 'N'
group by vine
;

--filter based on # of votes. chose 7 being the average # of votes received by vine reviewers
select vine, count(*) as reviews_count, avg(star_rating) as avg_star_rating, 
avg(helpful_votes) as avg_helpful_votes, avg(total_votes) as avg_total_votes,
(avg(helpful_votes) / avg(total_votes)) as percentage_helpful_votes
from vine_table
where vine = 'Y' and total_votes > 7 or vine = 'N' and total_votes > 7
group by vine
;
--checking for duplicates...some customers reviewed products in both datasets and are showing up twice in customer table
select customer_id, count(customer_id) from customers
group by customer_id 
	having count (customer_id) > 1
order by count(customer_count) desc ;

select * from customers
where customer_id = 5179904 or customer_id = 5179869

select review_id, count(review_id) from review_id_table
group by review_id
	having count(review_id) > 1
  
select customers.customer_id, count(customers.customer_count) as total_ratings, avg(vine_table.star_rating) as avg_star_rating
from review_id_table
join vine_table on vine_table.review_id = review_id_table.review_id 
join customers on review_id_table.customer_id = customers.customer_id
where customers.customer_count > 100
group by customers.customer_id
order by total_ratings desc
