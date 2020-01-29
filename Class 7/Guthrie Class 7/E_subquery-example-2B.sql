/*
WITH cte subquery:
Find the top 10 zipcodes with the largest percentage of persons of Latino/Hispanic descent, 
and calculate the percentage of adults and percentage of six-figure income earners in these zip codes
*/

WITH flat_irs AS (
    SELECT
        year,
        zipcode,
        SUM(CASE WHEN agi_map_id = 1 THEN return_count ELSE NULL END) AS agi_under25k,
        SUM(CASE WHEN agi_map_id = 2 THEN return_count ELSE NULL END) AS agi_25k_to_50k,
        SUM(CASE WHEN agi_map_id = 3 THEN return_count ELSE NULL END) AS agi_50k_to_75k,
        SUM(CASE WHEN agi_map_id = 4 THEN return_count ELSE NULL END) AS agi_75k_to_100k,
        SUM(CASE WHEN agi_map_id = 5 THEN return_count ELSE NULL END) AS agi_100K_to_200k,
        SUM(CASE WHEN agi_map_id = 6 THEN return_count ELSE NULL END) AS agi_over200k,
        SUM(return_count) AS total_returns
    FROM irs_nyc_tax_returns
    GROUP BY
        year,
        zipcode
)

SELECT
    cen.zipcode,
    100 * (SUM(Age_all) - (SUM(cen.Age_under5) + SUM(cen.Age_5to9) + SUM(cen.Age_10to14) + SUM(cen.Age_15to19) )) / SUM(Age_all) AS adult_pct,
    100 * SUM(cen.Ethnicity_All_HispancLatino_Descent) / SUM(cen.Age_all) AS latino_pct,
    100 * (SUM(irs.agi_over200k) + SUM(irs.agi_100K_to_200K)) / SUM(total_returns) AS six_figure_income_pct 
FROM nyc_census_data cen
    INNER JOIN flat_irs irs
        ON cen.zipcode = irs.zipcode
WHERE
    irs.year = 2012
GROUP BY
    cen.zipcode
ORDER BY
    latino_pct DESC
LIMIT 10;
