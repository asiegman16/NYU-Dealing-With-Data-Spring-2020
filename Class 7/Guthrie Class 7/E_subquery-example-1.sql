/*
Find the % of people under 19 years old in the  5 zipcodes with the most film permits during 2012 
*/ 

SELECT
    cen.zipcode
    ,100 * (SUM(cen.Age_under5) + SUM(cen.Age_5to9) + SUM(cen.Age_10to14) + SUM(cen.Age_15to19)) / SUM(Age_all) AS child_pct
FROM nyc_census_data cen
WHERE cen.zipcode IN (
    --this subquery will return the 5 zipcodes with the most film permits during 2012
    SELECT
        zipcode
    FROM nyc_film_permits
    WHERE StartDateTime BETWEEN DATE("2012-01-01") AND DATE("2012-12-31")
    GROUP BY
        zipcode
    ORDER BY
        COUNT(DISTINCT EventID) DESC
    LIMIT 5
)
GROUP BY
    cen.zipcode

    