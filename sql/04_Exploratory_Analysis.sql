-- 03 - EXPLORATORY ANALYSIS
-- Purpose: Explore pricing, reviews, listings, hosts,
--          and geographic patterns in the Airbnb dataset

USE airbnb;
GO


-- 1. DATASET OVERVIEW

-- Total number of listings
SELECT
    COUNT(*) AS total_listings
FROM dbo.vw_ListingsStandardized;


-- Basic dataset dimensions
SELECT
    COUNT(*) AS total_listings,
    COUNT(DISTINCT city) AS total_cities,
    COUNT(DISTINCT room_type) AS total_room_types,
    COUNT(DISTINCT property_type) AS total_property_types
FROM dbo.vw_ListingsStandardized;


-- 2. PRICING ANALYSIS

-- Overall price statistics
-- Prices are standardized to USD for comparison.
SELECT
    COUNT(*) AS listings,
    ROUND(MIN(price_usd), 2) AS min_price_usd,
    ROUND(MAX(price_usd), 2) AS max_price_usd,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0;


-- Price distribution by city
SELECT
    city,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd,
    ROUND(MIN(price_usd), 2) AS min_price_usd,
    ROUND(MAX(price_usd), 2) AS max_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
GROUP BY city
ORDER BY avg_price_usd DESC;


-- Price distribution by room type
SELECT
    room_type,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd,
    ROUND(MIN(price_usd), 2) AS min_price_usd,
    ROUND(MAX(price_usd), 2) AS max_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
GROUP BY room_type
ORDER BY avg_price_usd DESC;


-- Price distribution by property type
SELECT
    property_type,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
GROUP BY property_type
ORDER BY listings DESC;


-- Median and average price by city
SELECT DISTINCT
    city,
    ROUND(
        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY price_usd)
        OVER (PARTITION BY city),
        2
    ) AS median_price_usd,
    ROUND(
        AVG(price_usd) OVER (PARTITION BY city),
        2
    ) AS average_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
ORDER BY median_price_usd DESC;


-- 99th percentile price by city
-- Used to identify extreme price observations
SELECT DISTINCT
    city,
    ROUND(
        PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY price_usd)
        OVER (PARTITION BY city),
        2
    ) AS p99_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
ORDER BY p99_price_usd DESC;


-- Count of extreme-price listings by city
-- Extreme = price above the city-level 99th percentile
WITH PriceStats AS
(
    SELECT
        listing_id,
        city,
        price_usd,
        PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY price_usd)
        OVER (PARTITION BY city) AS p99_price_usd
    FROM dbo.vw_ListingsStandardized
    WHERE price_usd > 0
)
SELECT
    city,
    COUNT(*) AS extreme_listings
FROM PriceStats
WHERE price_usd > p99_price_usd
GROUP BY city
ORDER BY extreme_listings DESC;


-- 3. REVIEW ANALYSIS

-- Review coverage
WITH ReviewedListings AS
(
    SELECT DISTINCT
        listing_id
    FROM dbo.Reviews
)
SELECT
    COUNT(*) AS total_listings,
    SUM(
        CASE
            WHEN r.listing_id IS NULL THEN 1
            ELSE 0
        END
    ) AS listings_without_reviews,
    SUM(
        CASE
            WHEN r.listing_id IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS listings_with_reviews
FROM dbo.vw_ListingsStandardized AS l
LEFT JOIN ReviewedListings AS r
    ON l.listing_id = r.listing_id;


-- Total reviews per listing
WITH ReviewCounts AS
(
    SELECT
        listing_id,
        COUNT(*) AS total_reviews
    FROM dbo.Reviews
    GROUP BY listing_id
)
SELECT
    COUNT(*) AS listings_with_reviews,
    ROUND(AVG(total_reviews), 2) AS avg_reviews_per_listing,
    MIN(total_reviews) AS min_reviews,
    MAX(total_reviews) AS max_reviews
FROM ReviewCounts;


-- Average reviews by city
WITH ReviewCounts AS
(
    SELECT
        listing_id,
        COUNT(*) AS total_reviews
    FROM dbo.Reviews
    GROUP BY listing_id
)
SELECT
    l.city,
    COUNT(*) AS listings,
    ROUND(
        AVG(ISNULL(r.total_reviews, 0)),
        2
    ) AS avg_reviews
FROM dbo.vw_ListingsStandardized AS l
LEFT JOIN ReviewCounts AS r
    ON l.listing_id = r.listing_id
GROUP BY l.city
ORDER BY avg_reviews DESC;


-- Average reviews by room type
WITH ReviewCounts AS
(
    SELECT
        listing_id,
        COUNT(*) AS total_reviews
    FROM dbo.Reviews
    GROUP BY listing_id
)
SELECT
    l.room_type,
    COUNT(*) AS listings,
    ROUND(
        AVG(ISNULL(r.total_reviews, 0)),
        2
    ) AS avg_reviews
FROM dbo.vw_ListingsStandardized AS l
LEFT JOIN ReviewCounts AS r
    ON l.listing_id = r.listing_id
GROUP BY l.room_type
ORDER BY avg_reviews DESC;


-- Review rating distribution
SELECT
    CASE
        WHEN review_scores_rating IS NULL THEN 'Missing'
        WHEN review_scores_rating < 80 THEN 'Below 80'
        WHEN review_scores_rating < 90 THEN '80-89'
        WHEN review_scores_rating < 95 THEN '90-94'
        ELSE '95+'
    END AS rating_group,
    COUNT(*) AS listings
FROM dbo.vw_ListingsStandardized
GROUP BY
    CASE
        WHEN review_scores_rating IS NULL THEN 'Missing'
        WHEN review_scores_rating < 80 THEN 'Below 80'
        WHEN review_scores_rating < 90 THEN '80-89'
        WHEN review_scores_rating < 95 THEN '90-94'
        ELSE '95+'
    END
ORDER BY listings DESC;


-- Average price by rating group
SELECT
    CASE
        WHEN review_scores_rating IS NULL THEN 'Missing'
        WHEN review_scores_rating < 80 THEN 'Below 80'
        WHEN review_scores_rating < 90 THEN '80-89'
        WHEN review_scores_rating < 95 THEN '90-94'
        ELSE '95+'
    END AS rating_group,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
GROUP BY
    CASE
        WHEN review_scores_rating IS NULL THEN 'Missing'
        WHEN review_scores_rating < 80 THEN 'Below 80'
        WHEN review_scores_rating < 90 THEN '80-89'
        WHEN review_scores_rating < 95 THEN '90-94'
        ELSE '95+'
    END
ORDER BY rating_group;


-- 4. LISTING CHARACTERISTICS

-- Room type distribution
SELECT
    room_type,
    COUNT(*) AS listings,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM dbo.vw_ListingsStandardized
GROUP BY room_type
ORDER BY listings DESC;


-- Property type distribution
SELECT
    property_type,
    COUNT(*) AS listings,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM dbo.vw_ListingsStandardized
GROUP BY property_type
ORDER BY listings DESC;


-- Accommodation capacity
SELECT
    accommodates,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
  AND accommodates > 0
GROUP BY accommodates
ORDER BY accommodates;


-- Bedrooms distribution
SELECT
    bedrooms,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
  AND bedrooms IS NOT NULL
GROUP BY bedrooms
ORDER BY bedrooms;


-- Minimum nights distribution
SELECT
    CASE
        WHEN minimum_nights <= 2 THEN '1-2 nights'
        WHEN minimum_nights <= 7 THEN '3-7 nights'
        WHEN minimum_nights <= 30 THEN '8-30 nights'
        ELSE '31+ nights'
    END AS minimum_nights_group,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
GROUP BY
    CASE
        WHEN minimum_nights <= 2 THEN '1-2 nights'
        WHEN minimum_nights <= 7 THEN '3-7 nights'
        WHEN minimum_nights <= 30 THEN '8-30 nights'
        ELSE '31+ nights'
    END
ORDER BY listings DESC;


-- Instant booking availability
SELECT
    instant_bookable,
    COUNT(*) AS listings,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM dbo.vw_ListingsStandardized
GROUP BY instant_bookable
ORDER BY listings DESC;


-- 5. HOST ANALYSIS

-- Superhost distribution and performance
SELECT
    host_is_superhost,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd,
    ROUND(AVG(review_scores_rating), 2) AS avg_rating
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
GROUP BY host_is_superhost
ORDER BY listings DESC;


-- Host portfolio size
SELECT
    CASE
        WHEN host_total_listings_count = 1
            THEN '1 listing'
        WHEN host_total_listings_count BETWEEN 2 AND 5
            THEN '2-5 listings'
        WHEN host_total_listings_count BETWEEN 6 AND 20
            THEN '6-20 listings'
        ELSE '21+ listings'
    END AS host_portfolio_group,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
GROUP BY
    CASE
        WHEN host_total_listings_count = 1
            THEN '1 listing'
        WHEN host_total_listings_count BETWEEN 2 AND 5
            THEN '2-5 listings'
        WHEN host_total_listings_count BETWEEN 6 AND 20
            THEN '6-20 listings'
        ELSE '21+ listings'
    END
ORDER BY listings DESC;


-- Host tenure
-- Reference date is fixed because the dataset is historical.
SELECT
    CASE
        WHEN DATEDIFF(YEAR, host_since, '2021-03-01') < 1
            THEN '<1 year'
        WHEN DATEDIFF(YEAR, host_since, '2021-03-01') < 3
            THEN '1-2 years'
        WHEN DATEDIFF(YEAR, host_since, '2021-03-01') < 5
            THEN '3-4 years'
        ELSE '5+ years'
    END AS host_tenure_group,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
  AND host_since IS NOT NULL
GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, host_since, '2021-03-01') < 1
            THEN '<1 year'
        WHEN DATEDIFF(YEAR, host_since, '2021-03-01') < 3
            THEN '1-2 years'
        WHEN DATEDIFF(YEAR, host_since, '2021-03-01') < 5
            THEN '3-4 years'
        ELSE '5+ years'
    END
ORDER BY listings DESC;


-- Superhost vs review volume
WITH ReviewCounts AS
(
    SELECT
        listing_id,
        COUNT(*) AS total_reviews
    FROM dbo.Reviews
    GROUP BY listing_id
)
SELECT
    l.host_is_superhost,
    COUNT(*) AS listings,
    ROUND(
        AVG(ISNULL(r.total_reviews, 0)),
        2
    ) AS avg_reviews
FROM dbo.vw_ListingsStandardized AS l
LEFT JOIN ReviewCounts AS r
    ON l.listing_id = r.listing_id
GROUP BY l.host_is_superhost
ORDER BY avg_reviews DESC;


-- 6. GEOGRAPHIC ANALYSIS

-- Listing distribution by city
SELECT
    city,
    COUNT(*) AS listings,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM dbo.vw_ListingsStandardized
GROUP BY city
ORDER BY listings DESC;


-- Average price by city and neighbourhood
SELECT
    city,
    neighbourhood,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
GROUP BY city, neighbourhood
HAVING COUNT(*) >= 20
ORDER BY avg_price_usd DESC;


-- Room type distribution by city
SELECT
    city,
    room_type,
    COUNT(*) AS listings
FROM dbo.vw_ListingsStandardized
GROUP BY city, room_type
ORDER BY city, listings DESC;


-- Average price by city and room type
SELECT
    city,
    room_type,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
GROUP BY city, room_type
ORDER BY city, avg_price_usd DESC;


-- 7. RELATIONSHIP ANALYSIS

-- Price vs accommodation capacity
SELECT
    accommodates,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
  AND accommodates > 0
GROUP BY accommodates
ORDER BY accommodates;


-- Price vs number of bedrooms
SELECT
    bedrooms,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
  AND bedrooms IS NOT NULL
GROUP BY bedrooms
ORDER BY bedrooms;


-- Price vs minimum stay
SELECT
    CASE
        WHEN minimum_nights <= 2 THEN '1-2 nights'
        WHEN minimum_nights <= 7 THEN '3-7 nights'
        WHEN minimum_nights <= 30 THEN '8-30 nights'
        ELSE '31+ nights'
    END AS minimum_nights_group,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
GROUP BY
    CASE
        WHEN minimum_nights <= 2 THEN '1-2 nights'
        WHEN minimum_nights <= 7 THEN '3-7 nights'
        WHEN minimum_nights <= 30 THEN '8-30 nights'
        ELSE '31+ nights'
    END
ORDER BY listings DESC;


-- Rating vs average price
SELECT
    CASE
        WHEN review_scores_rating IS NULL THEN 'Missing'
        WHEN review_scores_rating < 80 THEN 'Below 80'
        WHEN review_scores_rating < 90 THEN '80-89'
        WHEN review_scores_rating < 95 THEN '90-94'
        ELSE '95+'
    END AS rating_group,
    COUNT(*) AS listings,
    ROUND(AVG(price_usd), 2) AS avg_price_usd
FROM dbo.vw_ListingsStandardized
WHERE price_usd > 0
GROUP BY
    CASE
        WHEN review_scores_rating IS NULL THEN 'Missing'
        WHEN review_scores_rating < 80 THEN 'Below 80'
        WHEN review_scores_rating < 90 THEN '80-89'
        WHEN review_scores_rating < 95 THEN '90-94'
        ELSE '95+'
    END
ORDER BY rating_group;


-- 8. KEY ANALYTICAL CHECKS

-- Listings with zero reviews
SELECT
    COUNT(*) AS listings_without_reviews
FROM dbo.vw_ListingsStandardized AS l
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.Reviews AS r
    WHERE r.listing_id = l.listing_id
);


-- Listings with high minimum-night requirements
SELECT
    COUNT(*) AS listings_31_plus_nights
FROM dbo.vw_ListingsStandardized
WHERE minimum_nights >= 31;


-- Listings with missing ratings
SELECT
    COUNT(*) AS listings_without_rating
FROM dbo.vw_ListingsStandardized
WHERE review_scores_rating IS NULL;


-- Listings with extreme prices
WITH PriceStats AS
(
    SELECT
        listing_id,
        city,
        price_usd,
        PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY price_usd)
        OVER (PARTITION BY city) AS p99_price_usd
    FROM dbo.vw_ListingsStandardized
    WHERE price_usd > 0
)
SELECT
    COUNT(*) AS extreme_price_listings
FROM PriceStats
WHERE price_usd > p99_price_usd;


-- Listings with large host portfolios
SELECT
    COUNT(*) AS listings_from_hosts_with_21_plus_listings
FROM dbo.vw_ListingsStandardized
WHERE host_total_listings_count >= 21;


-- END OF EXPLORATORY ANALYSIS