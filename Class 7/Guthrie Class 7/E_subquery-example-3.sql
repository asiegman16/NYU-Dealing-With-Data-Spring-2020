/*

CLASS PROJECT:
 we want to compare the demographic makeup of NYC versus the demographic makeup of the “NYC on video media (films/TV)”.  
 To do this, we first need to understand the percentage of NYC citizens in each major demographic bucket to compare versus the films.

*/

WITH 
/* Get US Census demographic totals for major categories for each zip code */
nyc_cen AS (
    SELECT
        cen.zipcode,
    /* Gender */
        SUM(cen.Gender_Male) AS gen_male_cnt,
        SUM(cen.Gender_Female) AS gen_female_cnt,
    /* ages */
        SUM(cen.Age_under5) + SUM(cen.Age_5to9) + SUM(cen.Age_10to14) + SUM(cen.Age_15to19) AS age_under19_cnt,
        SUM(cen.Age_over84) + SUM(cen.Age_80to84) + SUM(cen.Age_75to79) + SUM(cen.Age_70to74) AS age_over70_cnt,
        SUM(cen.Age_20to24) + SUM(cen.Age_25to29) + SUM(cen.Age_30to34) AS age_20to34_cnt,
        SUM(cen.Age_35to39) + SUM(cen.Age_40to44) + SUM(cen.Age_45to49) + SUM(cen.Age_50to54) AS age_25to54_cnt,
        SUM(Age_all) 
            - ( --child count
                SUM(cen.Age_under5) + SUM(cen.Age_5to9) + SUM(cen.Age_10to14) + SUM(cen.Age_15to19)
                )
            - ( --senior citizen count
                SUM(cen.Age_over84) + SUM(cen.Age_80to84) + SUM(cen.Age_75to79) + SUM(cen.Age_70to74)
                )
            - ( --young adult count
                SUM(cen.Age_20to24) + SUM(cen.Age_25to29) + SUM(cen.Age_30to34) 
                )
            - ( --prime earning years count
                SUM(cen.Age_35to39) + SUM(cen.Age_40to44) + SUM(cen.Age_45to49) + SUM(cen.Age_50to54)
                )
         AS age_55to70_cnt,
    /* ethnicity */
         SUM(cen.Ethnicity_White) AS eth_euro_cnt,
         SUM(cen.Ethnicity_AfricanAmerican) AS eth_african_cnt,
         SUM(cen.Ethnicity_Asian) + SUM(cen.Ethnicity_PacificIslander) AS eth_asiapac_cnt,
         SUM(cen.Ethnicity_NativeAmerican) + SUM(cen.Ethnicity_Other) AS eth_other_cnt,
         SUM(cen.Ethnicity_All_HispancLatino_Descent) AS eth_hislat_descent_cnt,
    /* total pop */
        SUM(cen.Age_all) as total_pop_cnt 
    FROM 
        nyc_census_data cen
    GROUP BY
        cen.zipcode
    ORDER BY
        cen.zipcode ASC
),

/* Get IRS income category totals for each zip code */
nyc_irs AS (
    SELECT
        zipcode,
        SUM(CASE WHEN agi_map_id IN (1,2) THEN return_count ELSE NULL END) AS agi_under50k_return_cnt,
        SUM(CASE WHEN agi_map_id IN (3,4) THEN return_count ELSE NULL END) AS agi_50k_to_100k_return_cnt,
        SUM(CASE WHEN agi_map_id IN (5,6) THEN return_count ELSE NULL END) AS agi_over100K_return_cnt,
        SUM(return_count) AS total_return_cnt
    FROM irs_nyc_tax_returns
    WHERE year >= 2012 
        AND year <= 2015
    GROUP BY
        zipcode
    ORDER BY
        zipcode ASC
),

/* Get Totals for NYC zips */
nyc_total_cnt_by_zip AS (
    SELECT
        cen.*,
        irs.agi_under50K_return_cnt,
        irs.agi_50k_to_100k_return_cnt,
        irs.agi_over100K_return_cnt,
        irs.total_return_cnt
    FROM 
        nyc_cen cen
        INNER JOIN
            nyc_irs irs
                ON (cen.zipcode = irs.zipcode)
    ORDER BY
        cen.zipcode
)

/* NYC demographic makeup using 2010 US Census and tax returns from 2012-2015 */
SELECT
-- label
        "all nyc" AS description,
--gender
        CAST(SUM(gen_male_cnt) AS Float) / SUM(total_pop_cnt) AS gen_male_pct,
        CAST(SUM(gen_female_cnt) AS Float) / SUM(total_pop_cnt) AS gen_female_pct,
--age
        CAST(SUM(age_under19_cnt) AS Float)/ SUM(total_pop_cnt) AS age_under19_pct,
        CAST(SUM(age_20to34_cnt) AS Float) / SUM(total_pop_cnt) AS age_20to34_pct,
        CAST(SUM(age_25to54_cnt) AS Float) / SUM(total_pop_cnt) AS age_25to54_pct,
        CAST(SUM(age_55to70_cnt) AS Float) / SUM(total_pop_cnt) AS age_55to70_pct,
        CAST(SUM(age_over70_cnt) AS Float) / SUM(total_pop_cnt) AS age_over70_pct,
--income
        CAST(SUM(agi_under50K_return_cnt) AS Float)/ SUM(total_return_cnt) AS agi_under50K_return_pct,
        CAST(SUM(agi_50k_to_100k_return_cnt) AS Float)/ SUM(total_return_cnt) AS agi_50k_to_100k_return_pct,
        CAST(SUM(agi_over100K_return_cnt) AS Float)/ SUM(total_return_cnt) AS agi_over100K_return_pct,
--ethnicity
        CAST(SUM(eth_euro_cnt) AS Float)/ SUM(total_pop_cnt) AS eth_euro_pct,
        CAST(SUM(eth_african_cnt) AS Float)/ SUM(total_pop_cnt) AS eth_african_pct,
        CAST(SUM(eth_asiapac_cnt) AS Float)/ SUM(total_pop_cnt) AS eth_asiapac_pct,
        CAST(SUM(eth_other_cnt) AS Float)/ SUM(total_pop_cnt) AS eth_other_pct,
        CAST(SUM(eth_hislat_descent_cnt) AS Float)/ SUM(total_pop_cnt) AS eth_hislat_descent_pct
FROM
    nyc_total_cnt_by_zip