DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
)


--1. Count the number of Movies vs Tv Shows
SELECT type, count(*) as Movies_vs_TV from netflix 
group by type

--2. Find the Most Common Rating for Movies and TV Shows
select type, rating 
from (select type, rating, count(*), rank() over(partition by type order by count(*) desc) as ranking
from netflix 
group by 1, 2) as t1
where ranking = 1 

--3.List all the movies released in a specific year (2020)
select * from netflix 
where 
	type = 'Movie' and
	release_year = 2020

--4 Find the top 5 countries with the most content on netflix
SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
limit 5

--5 Identify the longest movie
select title, duration from netflix
where type = 'Movie' and
duration = (select max(duration) from netflix)

--6. Find the content added in the last 5 years 
SELECT * FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT title, type, director from netflix 
where director like '%Rajiv Chilaka%'

--8 list all Tv shows with more than 5 seasons 
SELECT title, duration
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5

--9 Count the number of content items in each genre 
Select 
Unnest(String_to_array(listed_in, ',')) as genre, count(show_id) from netflix
group by 1

--10. Find each year, and the average number of content released by India on Netflix. 
--    Return the top 5 years with the highest average content release 
select 
Extract(Year from to_date(date_added, 'Month DD, YYYY')) as year, count(*), round(count(*)/(select count(*)
from netflix where country = 'India')::numeric*100,2) as avg_content_per_year
from netflix 
where country = 'India'
group by 1

--11. List all the movies that are documentaries
select * from netflix
where listed_in LIKE '%Documentaries'

--12. Find all content without a director 
select * from netflix 
where director is null

--13. Find how many movies actor 'Salman Khan' appeared in the last 10 years 
select * from netflix 
where casts like '%Salman Khan%'
and release_year > extract(year from current_date) - 10

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
select unnest(string_to_array(casts, ',')) as actor, count(*) from netflix
where country = 'India' and type = 'Movie'
group by actor 
order by count(*) desc
limit 10

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
with new_table
as(
select *, 
case 
when description like '%kill%'
or description like '%violence%'  then 'Violent'
else 
'Non-Violent'
end category 
 from netflix
)
Select 
category, count(*) as total_content 
from new_table
group by 1



