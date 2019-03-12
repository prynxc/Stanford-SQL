-- 1. Find the names of all reviewers who rated Gone with the Wind. 

SELECT DISTINCT NAME 
FROM   MOVIE, 
       RATING, 
       REVIEWER 
WHERE  RATING.MID = MOVIE.MID 
       AND RATING.RID = REVIEWER.RID 
       AND TITLE = 'Gone with the Wind'; 
	   
SELECT DISTINCT RVWR.NAME 
FROM   MOVIE M 
       INNER JOIN RATING RTNG 
               ON RTNG.MID = M.MID 
       INNER JOIN REVIEWER RVWR 
               ON RVWR.RID = RTNG.RID 
WHERE  M.TITLE = 'Gone with the Wind'; 

-- 2. For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. 

SELECT MOVIE.DIRECTOR, 
       MOVIE.TITLE, 
       RATING.STARS 
FROM   MOVIE 
       INNER JOIN RATING 
               ON RATING.MID = MOVIE.MID 
       INNER JOIN REVIEWER 
               ON REVIEWER.RID = RATING.RID 
WHERE  MOVIE.DIRECTOR = REVIEWER.NAME; 


SELECT NAME, 
       TITLE, 
       STARS 
FROM   MOVIE, 
       REVIEWER, 
       RATING 
WHERE  MOVIE.DIRECTOR = REVIEWER.NAME 
       AND MOVIE.MID = RATING.MID 
       AND REVIEWER.RID = RATING.RId;  

-- 3. Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 

SELECT TITLE 
FROM   MOVIE 
UNION 
SELECT NAME 
FROM   REVIEWER 
ORDER  BY NAME, 
          TITLE; 

-- 4. Find the titles of all movies not reviewed by Chris Jackson. 

SELECT MOVIE.TITLE 
FROM   MOVIE 
WHERE  MID NOT IN (SELECT MID 
                   FROM   REVIEWER 
                          LEFT JOIN RATING 
                                 ON RATING.RID = REVIEWER.RID 
                   WHERE  NAME IN ( 'Chris Jackson')) 

-- 6. For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.

SELECT REVIEWER.NAME, 
       MOVIE.TITLE, 
       RATING.STARS 
FROM   RATING 
       LEFT JOIN MOVIE 
              ON MOVIE.MID = RATING.MID 
       LEFT JOIN REVIEWER 
              ON REVIEWER.RID = RATING.RID 
WHERE  STARS = (SELECT MIN(STARS) 
                FROM   RATING); 

-- 7. List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order. 

SELECT MOVIE.TITLE, 
       AVG(RATING.STARS) AS average_stars 
FROM   RATING 
       LEFT JOIN MOVIE 
              ON MOVIE.MID = RATING.MID 
GROUP  BY MOVIE.TITLE 
ORDER  BY AVERAGE_STARS DESC, 
          MOVIE.TITLE ;

-- 8. Find the names of all reviewers who have contributed three or more ratings.

SELECT REVIEWER.NAME 
FROM   REVIEWER 
       INNER JOIN RATING 
               ON REVIEWER.RID = RATING.RID 
GROUP  BY REVIEWER.NAME 
HAVING COUNT(REVIEWER.RID) >= 3 

-- 9. Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title.

SELECT MOVIE.TITLE, 
       MOVIE.DIRECTOR 
FROM   (SELECT DIRECTOR 
        FROM   MOVIE 
        GROUP  BY DIRECTOR 
        HAVING COUNT(DIRECTOR) > 1) AS M1 
       INNER JOIN MOVIE 
               ON M1.DIRECTOR = MOVIE.DIRECTOR 
ORDER  BY MOVIE.DIRECTOR, 
          MOVIE.TITLE; ; 

SELECT TITLE, 
       DIRECTOR 
FROM   MOVIE M1 
WHERE  (SELECT COUNT(*) 
        FROM   MOVIE M2 
        WHERE  M1.DIRECTOR = M2.DIRECTOR) > 1 


-- 10. Find the movie(s) with the highest average rating. Return the movie title(s) and average rating.

SELECT MOVIE.TITLE, 
       Avg(STARS) 
FROM   MOVIE 
       INNER JOIN RATING 
               ON RATING.MID = MOVIE.MID 
GROUP  BY MOVIE.MID 
HAVING Avg(STARS) = (SELECT Max(AVG_STARS) 
                     FROM   (SELECT MOVIE.TITLE, 
                                    Avg(RATING.STARS) AS avg_stars 
                             FROM   MOVIE 
                                    INNER JOIN RATING 
                                            ON RATING.MID = MOVIE.MID 
                             GROUP  BY MOVIE.MID)) 

-- 11. Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating.

SELECT TITLE, 
       Avg(STARS) 
FROM   MOVIE 
       INNER JOIN RATING 
               ON RATING.MID = MOVIE.MID 
GROUP  BY MOVIE.MID 
HAVING Avg(STARS) = (SELECT Min(AVERAGE_STARS) 
                     FROM   (SELECT TITLE, 
                                    Avg(STARS) AS Average_stars 
                             FROM   MOVIE 
                                    INNER JOIN RATING 
                                            ON RATING.MID = MOVIE.MID 
                             GROUP  BY MOVIE.MID)) 
		
-- 12. For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. 


SELECT DIRECTOR, 
       TITLE, 
       Max(STARS) 
FROM   MOVIE M, 
       RATING R 
WHERE  M.MID = R.MID 
       AND DIRECTOR IS NOT NULL 
GROUP  BY DIRECTOR 
ORDER  BY STARS DESC 