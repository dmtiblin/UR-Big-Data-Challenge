--group by vine & compare 
select vine, count(*) as reviews_count, round(avg(star_rating),2) as avg_star_rating, 
round(avg(helpful_votes),2) as avg_helpful_votes, round(avg(total_votes),2) as avg_total_votes,
round((avg(helpful_votes) / avg(total_votes)),2) as percentage_helpful_votes
from vine_table
where vine = 'Y' or vine = 'N'
group by vine
;

--filter vine groups based on # of votes. chose 7 being the average # of votes received by vine reviewers
select vine, count(*) as reviews_count, round(avg(star_rating),2) as avg_star_rating, 
round(avg(helpful_votes),2) as avg_helpful_votes, round(avg(total_votes),2) as avg_total_votes,
round((avg(helpful_votes) / avg(total_votes)),2) as percentage_helpful_votes
from vine_table
where vine = 'Y' and total_votes > 7 or vine = 'N' and total_votes > 7
group by vine
;
--checking for duplicates...some customers reviewed products in both datasets and are showing up twice in customer table
select customer_id, count(customer_id) from customers
group by customer_id 
	having count (customer_id) > 1
order by count(customer_count) desc ;

select review_id, count(review_id) from review_id_table
group by review_id
	having count(review_id) > 1

--group by customer to view avg ratings
create view aggregated_by_customer_table as 
select customers.customer_id, count(review_id_table.review_id) as total_ratings, round(avg(vine_table.star_rating),2) as avg_star_rating,
	round(avg(vine_table.helpful_votes),2) as avg_helpful_votes, round(avg(vine_table.total_votes),2) as avg_total_votes,
	count(case when vine_table.vine = 'N' THEN review_id_table.review_id END ) as non_vine_review_count,
	ROUND( avg(case when vine_table.vine = 'N' THEN vine_table.star_rating END),2) as avg_non_vine_star_rating,
	ROUND (avg(case when vine_table.vine = 'N' THEN vine_table.helpful_votes END),2) as avg_non_vine_helpful_votes,
	count(case when vine_table.vine = 'Y' THEN review_id_table.review_id END) as vine_review_count,
	ROUND (avg(case when vine_table.vine = 'Y' THEN vine_table.star_rating END),2) as avg_vine_star_rating,
	ROUND (avg(case when vine_table.vine = 'Y' THEN vine_table.helpful_votes END),2) as avg_vine_helpful_votes,
	ROUND (avg(case when vine_table.vine = 'Y' THEN vine_table.star_rating END) - avg(case when vine_table.vine = 'N' THEN vine_table.star_rating END),2) as rating_bias,
	ROUND(avg(case when vine_table.vine = 'Y' THEN vine_table.helpful_votes END) - avg(case when vine_table.vine = 'N' THEN vine_table.helpful_votes END),2) as helpful_bias
from review_id_table
join vine_table on vine_table.review_id = review_id_table.review_id 
join customers on review_id_table.customer_id = customers.customer_id
group by customers.customer_id
having count(case when vine_table.vine = 'N' THEN review_id_table.review_id END ) > 4 
	AND count(case when vine_table.vine = 'Y' THEN review_id_table.review_id END )>4
order by total_ratings desc
;
select * from aggregated_by_customer_table;


--calculate avg bias within Vine program reviewers
select round(avg(avg_star_rating),2) as avg_star_rating,
	ROUND (avg(avg_vine_star_rating),2) as avg_vine_star_rating,
	ROUND (avg(avg_non_vine_star_rating),2) as avg_non_vine_star_rating,
	round(avg(rating_bias),2) as avg_rating_bias, round(avg(helpful_bias),2) as avg_helpful_bias
from aggregated_by_customer_table
;

--check avg rating by product vs vine star rating  
create view totals_by_product_table 
as
select 
	review_id_table.product_id, 
	--vine_table.vine, 
	count(review_id_table.review_id) as total_review_count, 
	round(avg(vine_table.star_rating),2) as avg_star_rating,
	count(case when vine_table.vine = 'N' THEN review_id_table.review_id END ) as non_vine_review_count,
	ROUND( avg(case when vine_table.vine = 'N' THEN vine_table.star_rating END),2) as avg_non_vine_star_rating,
	count(case when vine_table.vine = 'Y' THEN review_id_table.review_id END) as vine_review_count,
	ROUND (avg(case when vine_table.vine = 'Y' THEN vine_table.star_rating END),2) as avg_vine_star_rating,
	((ROUND (avg(case when vine_table.vine = 'Y' THEN vine_table.star_rating END),2)) - (ROUND (avg(case when vine_table.vine = 'N' THEN vine_table.star_rating END),2) )) as bias
from review_id_table
join vine_table on vine_table.review_id = review_id_table.review_id
group by  review_id_table.product_id 
	having count(case when vine_table.vine = 'Y' THEN review_id_table.review_id END) > 1
	and  count(case when vine_table.vine = 'N' THEN review_id_table.review_id END) > 1
order by review_id_table.product_id
;

select * from totals_by_product_table 
where total_review_count > 7
order by total_review_count desc 
;

--calculate the avg amount of bias across all products
select avg(bias) as avg_bias , avg(bias)/5 as avg_percent_bias
from totals_by_product_table ;
--calculate avg amt of bias across producs with at least 7 ratings
select avg(bias) as avg_bias , avg(bias)/5 as avg_percent_bias
from totals_by_product_table 
where total_review_count > 7;
--calculate avg amt of bias across producs with at least 250 ratings
select avg(bias) as avg_bias , avg(bias)/5 as avg_percent_bias
from totals_by_product_table 
where total_review_count > 250;
--calculate avg amt of bias across producs with at least 10 vine and 10 non-vine reviews
select avg(bias) as avg_bias , avg(bias)/5 as avg_percent_bias
from totals_by_product_table 
where non_vine_review_count > 20 AND vine_review_count > 20;
select * from totals_by_product_table
where non_vine_review_count > 20 AND vine_review_count > 20;
