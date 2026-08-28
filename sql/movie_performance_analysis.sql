-- ============================================
-- MOVIE PERFORMANCE ANALYSIS
-- SQL Analysis
-- ============================================

-- Preview the dataset
SELECT *
FROM movies
LIMIT 10;
-- ============================================
-- 1. TOP 10 MOST PROFITABLE MOVIES
-- ============================================

SELECT
    title,
    budget,
    revenue,
    profit,
    ROUND(roi, 2) AS roi_percent
FROM movies
WHERE budget > 0
  AND revenue > 0
ORDER BY profit DESC
LIMIT 10;
-- ============================================
-- 2. PERFORMANCE BY GENRE
-- ============================================

WITH RECURSIVE split_genres AS (
    SELECT
        id,
        TRIM(
            CASE
                WHEN INSTR(genres_list, ',') > 0
                THEN SUBSTR(genres_list, 1, INSTR(genres_list, ',') - 1)
                ELSE genres_list
            END
        ) AS genre,
        CASE
            WHEN INSTR(genres_list, ',') > 0
            THEN SUBSTR(genres_list, INSTR(genres_list, ',') + 1)
            ELSE ''
        END AS remaining,
        profit,
        revenue,
        roi
    FROM movies
    WHERE budget > 0
      AND revenue > 0
      AND genres_list IS NOT NULL

    UNION ALL

    SELECT
        id,
        TRIM(
            CASE
                WHEN INSTR(remaining, ',') > 0
                THEN SUBSTR(remaining, 1, INSTR(remaining, ',') - 1)
                ELSE remaining
            END
        ),
        CASE
            WHEN INSTR(remaining, ',') > 0
            THEN SUBSTR(remaining, INSTR(remaining, ',') + 1)
            ELSE ''
        END,
        profit,
        revenue,
        roi
    FROM split_genres
    WHERE remaining <> ''
)

SELECT
    genre,
    COUNT(*) AS movie_count,
    ROUND(AVG(profit), 2) AS average_profit,
    ROUND(AVG(revenue), 2) AS average_revenue,
    ROUND(AVG(roi), 2) AS average_roi
FROM split_genres
WHERE genre <> ''
GROUP BY genre
HAVING COUNT(*) >= 20
ORDER BY average_profit DESC;
-- ============================================
-- 3. TOP DIRECTORS BY AVERAGE PROFIT
-- ============================================

SELECT
    director,
    COUNT(*) AS movie_count,
    ROUND(AVG(profit), 2) AS average_profit,
    ROUND(AVG(revenue), 2) AS average_revenue,
    ROUND(AVG(vote_average), 2) AS average_rating
FROM movies
WHERE budget > 0
  AND revenue > 0
  AND director IS NOT NULL
GROUP BY director
HAVING COUNT(*) >= 5
ORDER BY average_profit DESC
LIMIT 15;
-- ============================================
-- 4. PERFORMANCE BY RATING
-- ============================================

SELECT
    CASE
        WHEN vote_average < 5 THEN 'Below 5'
        WHEN vote_average < 6 THEN '5-6'
        WHEN vote_average < 7 THEN '6-7'
        WHEN vote_average < 8 THEN '7-8'
        ELSE '8+'
    END AS rating_category,

    COUNT(*) AS movie_count,
    ROUND(AVG(profit), 2) AS average_profit,
    ROUND(AVG(revenue), 2) AS average_revenue,
    ROUND(AVG(popularity), 2) AS average_popularity

FROM movies

WHERE budget > 0
  AND revenue > 0

GROUP BY rating_category

ORDER BY
    CASE rating_category
        WHEN 'Below 5' THEN 1
        WHEN '5-6' THEN 2
        WHEN '6-7' THEN 3
        WHEN '7-8' THEN 4
        WHEN '8+' THEN 5
    END;
    -- ============================================
-- 5. PERFORMANCE BY BUDGET SIZE
-- ============================================

SELECT
    CASE
        WHEN budget < 10000000 THEN 'Low Budget'
        WHEN budget < 50000000 THEN 'Medium Budget'
        WHEN budget < 100000000 THEN 'High Budget'
        ELSE 'Blockbuster'
    END AS budget_category,

    COUNT(*) AS movie_count,
    ROUND(AVG(budget), 2) AS average_budget,
    ROUND(AVG(revenue), 2) AS average_revenue,
    ROUND(AVG(profit), 2) AS average_profit,
    ROUND(AVG(vote_average), 2) AS average_rating

FROM movies

WHERE budget > 0
  AND revenue > 0

GROUP BY budget_category

ORDER BY
    CASE budget_category
        WHEN 'Low Budget' THEN 1
        WHEN 'Medium Budget' THEN 2
        WHEN 'High Budget' THEN 3
        WHEN 'Blockbuster' THEN 4
    END;
    -- ============================================
-- 6. POPULARITY VS FINANCIAL PERFORMANCE
-- ============================================

WITH popularity_ranked AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY popularity) AS popularity_quartile
    FROM movies
    WHERE budget > 0
      AND revenue > 0
)

SELECT
    CASE popularity_quartile
        WHEN 1 THEN 'Low Popularity'
        WHEN 2 THEN 'Medium Popularity'
        WHEN 3 THEN 'High Popularity'
        WHEN 4 THEN 'Very High Popularity'
    END AS popularity_category,

    COUNT(*) AS movie_count,
    ROUND(AVG(revenue), 2) AS average_revenue,
    ROUND(AVG(profit), 2) AS average_profit,
    ROUND(AVG(vote_average), 2) AS average_rating

FROM popularity_ranked

GROUP BY popularity_quartile

ORDER BY popularity_quartile;
    -- ============================================
-- 7. MOVIE PERFORMANCE OVER TIME
-- ============================================

SELECT
    release_year,
    COUNT(*) AS movie_count,
    ROUND(AVG(budget), 2) AS average_budget,
    ROUND(AVG(revenue), 2) AS average_revenue,
    ROUND(AVG(profit), 2) AS average_profit,
    ROUND(AVG(vote_average), 2) AS average_rating

FROM movies

WHERE budget > 0
  AND revenue > 0
  AND release_year IS NOT NULL
  AND release_year >= 1980

GROUP BY release_year

HAVING COUNT(*) >= 10

ORDER BY release_year;
