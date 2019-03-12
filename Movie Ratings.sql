https://lagunita.stanford.edu/c4x/DB/SQL/asset/moviedata.html
https://github.com/qinglin/db_course_stanford/blob/master/SQL%20Movie-Rating%20Query%20Exercises%20(extras)
https://gist.github.com/backpackerhh/2487a2c59789ef13099d#file-extras-sql

-- 1. Find the titles of all movies directed by Steven Spielberg. 
SELECT TITLE 
FROM   MOVIE 
WHERE  DIRECTOR = 'Steven Spielberg'; 

-- 2. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. 
 
SELECT DISTINCT MOVIE.YEAR 
FROM   MOVIE 
       LEFT JOIN RATING 
              ON RATING.MID = MOVIE.MID 
WHERE  RATING.STARS IN ( 4, 5 ) 
ORDER  BY MOVIE.YEAR ASC; 

	-- No explicit join 
SELECT DISTINCT YEAR 
FROM   MOVIE,RATING 
WHERE  MOVIE.MID = RATING.MID 
       AND STARS IN ( 4, 5 ) 
ORDER  BY YEAR; 

SELECT DISTINCT M.YEAR 
FROM   MOVIE M 
       INNER JOIN RATING R 
               ON R.MID = M.MID 
WHERE  R.STARS IN ( 4, 5 ) 
ORDER  BY M.YEAR; 

-- 3. Find the titles of all movies that have no ratings.

SELECT MOVIE.TITLE 
FROM   MOVIE 
       LEFT JOIN RATING 
              ON RATING.MID = MOVIE.MID 
WHERE  RATING.STARS IS NULL; 

-- 4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 

SELECT REVIEWER.NAME 
FROM   REVIEWER 
       LEFT JOIN RATING 
              ON RATING.RID = REVIEWER.RID 
WHERE  RATING.RATINGDATE IS NULL;

-- 5. Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 

SELECT REVIEWER.NAME, 
       MOVIE.TITLE, 
       RATING.STARS, 
       RATING.RATINGDATE 
FROM   REVIEWER 
       LEFT JOIN RATING 
              ON RATING.RID = REVIEWER.RID 
       LEFT JOIN MOVIE 
              ON MOVIE.MID = RATING.MID 
ORDER  BY REVIEWER.NAME, 
          MOVIE.TITLE, 
          RATING.STARS; 
		  
	-- No explicit join
SELECT NAME, 
       TITLE, 
       STARS, 
       RATINGDATE 
FROM   REVIEWER, 
       RATING, 
       MOVIE 
WHERE  RATING.RID = REVIEWER.RID 
       AND MOVIE.MID = RATING.MID 
ORDER  BY NAME, 
          TITLE, 
          STARS; 
		  
-- 6. For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 

SELECT REVIEWER.NAME, 
       MOVIE.TITLE 
FROM   MOVIE 
       INNER JOIN RATING R1 
               ON R1.MID = MOVIE.MID 
       INNER JOIN RATING R2 
               ON R1.RID = R2.RID 
       INNER JOIN REVIEWER 
               ON REVIEWER.RID = R2.RID 
WHERE  R1.MID = R2.MID 
       AND R1.RATINGDATE < R2.RATINGDATE 
       AND R1.STARS < R2.STARS 

	-- To understand impact of self join of rating table on both mid and rid
SELECT MOVIE.MID, 
       MOVIE.TITLE, 
       R1.RID, 
       R1.MID, 
       R1.STARS, 
       R1.RATINGDATE, 
       R2.RID, 
       R2.MID, 
       R2.STARS, 
       R2.RATINGDATE, 
       REVIEWER.RID, 
       REVIEWER.NAME 
FROM   MOVIE 
       INNER JOIN RATING R1 
               ON R1.MID = MOVIE.MID 
       INNER JOIN RATING R2 
               ON R2.RID = R1.RID 
       INNER JOIN REVIEWER 
               ON REVIEWER.RID = R2.RID 
WHERE  R1.MID = R2.MID 
       AND R2.RATINGDATE > R1.RATINGDATE 
       AND R2.STARS > R1.STARS 
	   
	   
-- 7. For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 

SELECT TITLE, 
       MAX(STARS) 
FROM   (SELECT M.TITLE, 
               R.STARS 
        FROM   MOVIE M 
               LEFT JOIN RATING R 
                      ON R.MID = M.MID 
        WHERE  R.STARS IS NOT NULL) 
GROUP  BY TITLE; 

SELECT TITLE, 
       MAX(STARS) 
FROM   MOVIE, 
       RATING 
WHERE  MOVIE.MID = RATING.MID 
GROUP  BY MOVIE.MID -- Can also group by Title 
ORDER  BY TITLE ASC -- ASC is default

-- 8. For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 

SELECT TITLE, 
       ( MAX(STARS) - MIN(STARS) ) AS RATING_SPREAD 
FROM   MOVIE, 
       RATING 
WHERE  MOVIE.MID = RATING.MID 
GROUP  BY MOVIE.MID -- Can also group by Title 
ORDER  BY RATING_SPREAD DESC, TITLE; 


-- 9. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 

SELECT AVG(AVG_RATING_BEFORE1980) - AVG(AVG_RATING_AFTER1980) 
FROM   (SELECT TITLE, 
               AVG(RATING.STARS) AS avg_rating_after1980 
        FROM   MOVIE 
               LEFT JOIN RATING 
                      ON RATING.MID = MOVIE.MID 
        WHERE  YEAR > 1980 
        GROUP  BY TITLE) AS AFTER1980, 
       (SELECT TITLE, 
               AVG(RATING.STARS) AS avg_rating_before1980 
        FROM   MOVIE 
               LEFT JOIN RATING 
                      ON RATING.MID = MOVIE.MID 
        WHERE  YEAR < 1980 
        GROUP  BY TITLE) AS BEFORE1980 
		

	-- Simplified code (better readability) 
SELECT AVG(BEFORE1980.AVG_RATING) - AVG(AFTER1980.AVG_RATING) 
FROM   (SELECT AVG(RATING.STARS) AS avg_rating 
        FROM   MOVIE 
               LEFT JOIN RATING 
                      ON RATING.MID = MOVIE.MID 
        WHERE  YEAR > 1980 
        GROUP  BY TITLE) AS AFTER1980, 
       (SELECT AVG(RATING.STARS) AS avg_rating 
        FROM   MOVIE 
               LEFT JOIN RATING 
                      ON RATING.MID = MOVIE.MID 
        WHERE  YEAR < 1980 
        GROUP  BY TITLE) AS BEFORE1980 
		

-- 12. For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. 

SELECT MOVIE.DIRECTOR, 
       MOVIE.TITLE, 
       MAX(R1.STARS) 
FROM   RATING R1 
       INNER JOIN MOVIE 
               ON MOVIE.MID = R1.MID 
WHERE  MOVIE.DIRECTOR IS NOT NULL 
GROUP  BY MOVIE.DIRECTOR 

