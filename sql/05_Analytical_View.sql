CREATE OR ALTER VIEW dbo.vw_AirbnbAnalytics AS

WITH ReviewStats AS
(
    SELECT
        listing_id,
        COUNT(*) AS total_reviews
    FROM dbo.Reviews
    GROUP BY listing_id
),

PriceStats AS
(
    SELECT
        listing_id,

        PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY price)
        OVER (PARTITION BY city) AS p99_price,

        PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY price_usd)
        OVER (PARTITION BY city) AS p99_price_usd

    FROM dbo.vw_ListingsStandardized
    WHERE price > 0
),

CityPriceStats AS
(
    SELECT
        listing_id,
        city,

        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY price)
        OVER (PARTITION BY city) AS city_median_price,

        PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY price_usd)
        OVER (PARTITION BY city) AS city_median_price_usd

    FROM dbo.vw_ListingsStandardized
    WHERE price > 0
)

SELECT
    l.listing_id,
    l.name,
    l.host_id,
    l.host_since,
    l.host_location,
    l.host_response_time,
    l.host_response_rate,
    l.host_acceptance_rate,
    l.host_is_superhost,
    l.host_total_listings_count,
    l.host_has_profile_pic,
    l.host_identity_verified,
    l.neighbourhood,
    l.district,
    l.city,
    l.latitude,
    l.longitude,
    l.property_type,
    l.room_type,
    l.accommodates,
    l.bedrooms,
    l.amenities,

    -- Original local-currency price
    l.price,

    -- Standardized USD price
    l.price_usd,

    l.minimum_nights,
    l.maximum_nights,
    l.review_scores_rating,
    l.review_scores_accuracy,
    l.review_scores_cleanliness,
    l.review_scores_checkin,
    l.review_scores_communication,
    l.review_scores_location,
    l.review_scores_value,
    l.instant_bookable,

    ISNULL(r.total_reviews, 0) AS total_reviews,

    p.p99_price,
    p.p99_price_usd,

    c.city_median_price,
    c.city_median_price_usd,

    -- Relative price within the city
    l.price / NULLIF(c.city_median_price, 0)
        AS price_vs_city_median,

    -- Same relative price expressed using USD
    l.price_usd / NULLIF(c.city_median_price_usd, 0)
        AS price_usd_vs_city_median,

    CASE
        WHEN ISNULL(r.total_reviews, 0) = 0
            THEN 'No Reviews'
        ELSE 'Has Reviews'
    END AS review_status,

    CASE
        WHEN l.host_since IS NULL
            THEN NULL
        ELSE DATEDIFF(YEAR, l.host_since, '2021-03-01')
    END AS host_tenure_years,

    CASE
        WHEN l.price > p.p99_price
            THEN 'Extreme'
        ELSE 'Normal'
    END AS price_category

FROM dbo.vw_ListingsStandardized AS l

LEFT JOIN ReviewStats AS r
    ON l.listing_id = r.listing_id

LEFT JOIN PriceStats AS p
    ON l.listing_id = p.listing_id

LEFT JOIN CityPriceStats AS c
    ON l.listing_id = c.listing_id

WHERE l.price > 0;
GO